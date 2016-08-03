kojid@1455:

        # upload the build output
        for filepath in logs:
            self.uploadFile(os.path.join(outputdir, filepath),
                            relPath=os.path.dirname(filepath))
        for relpath, files in output_files.iteritems():
            for filename in files:
                self.uploadFile(os.path.join(outputdir, relpath, filename),
                                relPath=relpath)

        # Should only find log files in the mock result directory.
        # Don't upload these log files, they've already been streamed
        # the hub.
        for filename in os.listdir(buildroot.resultdir()):
            root, ext = os.path.splitext(filename)
            if ext == '.log':
                filepath = os.path.join(buildroot.resultdir(), filename)
                if os.path.isfile(filepath) and os.stat(filepath).st_size > 0:
                    # only files with content get uploaded to the hub
                    logs.append(filename)

        return {'maven_info': maven_info,
                'buildroot_id': buildroot.id,
                'logs': logs,
                'files': output_files}



kojid@1214:

        self.build_task_id = self.session.host.subtask(method='buildMaven',
                                                       arglist=[url, build_tag, build_opts],
                                                       label='build',
                                                       parent=self.id,
                                                       arch='noarch')
        maven_results = self.wait(self.build_task_id)[self.build_task_id]
        maven_results['task_id'] = self.build_task_id

        build_info = None
        if not self.opts.get('scratch'):
            maven_info = maven_results['maven_info']
            if maven_info['version'].endswith('-SNAPSHOT'):
                raise koji.BuildError, '-SNAPSHOT versions are only supported in scratch builds'
            build_info = koji.maven_info_to_nvr(maven_info)

            if not self.opts.get('skip_tag'):
                dest_cfg = self.session.getPackageConfig(dest_tag['id'], build_info['name'])
                # Make sure package is on the list for this tag
                if dest_cfg is None:
                    raise koji.BuildError, "package %s not in list for tag %s" \
                        % (build_info['name'], dest_tag['name'])
                elif dest_cfg['blocked']:
                    raise koji.BuildError, "package %s is blocked for tag %s" \
                        % (build_info['name'], dest_tag['name'])

            build_info = self.session.host.initMavenBuild(self.id, build_info, maven_info)
            self.build_id = build_info['id']

        try:
            rpm_results = None
            spec_url = self.opts.get('specfile')
            if spec_url:
                rpm_results = self.buildWrapperRPM(spec_url, self.build_task_id, target_info, build_info, repo_id)

            if self.opts.get('scratch'):
                self.session.host.moveMavenBuildToScratch(self.id, maven_results, rpm_results)
            else:
                self.session.host.completeMavenBuild(self.id, self.build_id, maven_results, rpm_results)
        except (SystemExit, ServerExit, KeyboardInterrupt):
            # we do not trap these
            raise
        except:
            if not self.opts.get('scratch'):
                #scratch builds do not get imported
                self.session.host.failBuild(self.id, self.build_id)
            # reraise the exception
            raise

        if not self.opts.get('scratch') and not self.opts.get('skip_tag'):
            tag_task_id = self.session.host.subtask(method='tagBuild',
                                                    arglist=[dest_tag['id'], self.build_id, False, None, True],
                                                    label='tag',
                                                    parent=self.id,
                                                    arch='noarch')
            self.wait(tag_task_id)

koji/__init__.py@1040:

    nvr = {'name': maveninfo['group_id'] + '-' + maveninfo['artifact_id'],
           'version': maveninfo['version'].replace('-', '_'),
           'release': None,
           'epoch': None}
    # for backwards-compatibility
    nvr['package_name'] = nvr['name']

kojihub.py@8182:

 def makeTask(self,*args,**opts):
        #this is mainly for debugging
        #only an admin can make arbitrary tasks
        context.session.assertPerm('admin')
        return make_task(*args,**opts)

