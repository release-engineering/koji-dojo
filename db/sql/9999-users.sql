BEGIN WORK;

\set name 'kojiadmin'
INSERT INTO users (name, status, usertype) VALUES (:name, 0, 0);
\set uid (select id from users where name=:name)

INSERT INTO user_perms (user_id, perm_id, creator_id) VALUES (uid, 1, uid);

\set name 'testuser'
INSERT INTO users (name, status, usertype) VALUES (:name, 0, 0);
\set uid (select id from users where name=:name)

COMMIT WORK;
