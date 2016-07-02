/* Why is this needed? */
/* INSERT INTO content_generator (name) VALUES ('test-cg'); */

/* Create users */
INSERT INTO users (name, status, usertype) VALUES
    /* ('kojiuser', 0, 0), */
    ('kojiweb', 0, 0),
    ('kojiadmin', 0, 0);

/* Make some users admin */
INSERT INTO user_perms (user_id, perm_id, creator_id) (
    SELECT users.id, permissions.id, users.id FROM users, permissions
    WHERE users.name IN (
        'kojiadmin',
        'kojiweb'
    ) AND permissions.name = 'admin'
);
