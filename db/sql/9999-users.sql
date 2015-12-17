BEGIN WORK;

INSERT INTO users (name, status, usertype) VALUES ('kojiadmin', 0, 0);
INSERT INTO user_perms (user_id, perm_id, creator_id) VALUES ((select id from users where name = 'kojiadmin'), 1, (select id from users where name = 'kojiadmin'));

INSERT INTO users (name, status, usertype) VALUES ('testuser', 0, 0);

COMMIT WORK;
