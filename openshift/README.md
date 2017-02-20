Prerequisites on running koji on Openshift:

* Import the template

* Create a service account should be able to run container as root.

  Run the following commands on master:
  ```
  $ sudo su
  # oc project <namespace>
  # oc create serviceaccount koji-sa
  # oc patch scc anyuid --type=json -p '[{"op": "add", "path": "/users/0", "value":"system:serviceaccount:<namespace>:koji-sa"}]'
  ```
  (replace `<namespace>` with expected namespace)

* Ask the cluster admin to create koji-volume and koji-clients-volume volumes in this namespace

  For local testing:
  ```
  $ sudo su
  # mkdir -p /volumes/koji-volume /volumes/koji-clients-volume
  # chown nobody:nobody /volumes/koji-volume /volumes/koji-clients-volume
  # chcon -u system_u -r object_r -t svirt_sandbox_file_t -l s0 /volumes/koji-volume /volumes/koji-clients-volume
  # oc project <namespace>
  # oc create -f openshift/pv-koji-volume.yaml
  # oc create -f openshift/pv-koji-clients-volume.yaml
  ```
  (replace `<namespace>` with expected namespace)

* Start 'hub' build:
  ```
  oc start-build hub
  ```
