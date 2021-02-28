START TRANSACTION;

INSERT INTO `types` VALUES ('string'), ('float'), ('bool'), ('int');

INSERT INTO `units` VALUES 
    (' ','none','string'),
    ('%','percentage','float'),
    ('°C','degree celsius C','float'),
    ('char','free text','string'),
    ('h','hours','int'),
    ('Here','presence','bool'),
    ('Hz','frequence','float'),
    ('kW','power','float'),
    ('lx', 'lux', 'float'),
    ('V','volt','float'),
    ('W', 'watts', 'float');


INSERT INTO `ugrps` (`id`, `name`) VALUES 
    (1, 'SUPERADMIN'),
    (2, 'regular'),
    (3, 'other');


INSERT INTO `users` (`id`, `name`, `email`, `password`) VALUES 
    (1, 'admin', 'admin@lala.com', MD5('testtest')),
    (2, 'regular_user', 'regular_user@lala.com', MD5('testtest')),
    (3, 'no_rights_user', 'no_rights@lala.com', MD5('testtest'));


INSERT INTO `users_ugrps` (`user_id`, `ugrp_id`, `is_admin`) VALUES
    -- SUPERUSER is SUPERADMIN
    (1, 1, 1),
    -- regular_user is admin of "regular"
    (2, 2, 1),
    -- regular_user is a user of "other"
    (2, 3, 0);


INSERT INTO `ogrps` (`id`, `name`, `ugrp_id`) VALUES
    -- some objectgroups owned by "regular"
    (1, 'regular_misc', 2),
    (2, 'regular_temp', 2),
    -- one group owned by "other"
    (3, 'other_objects', 3);


INSERT INTO `objects` (`id`, `name`, `description`, `ugrp_id`, `unit_symbol`, `creationdate`) VALUES
    -- objects owned by regular usergroup
    (1, 'volts box 1', '', 2, 'V', '2019-01-01'),
    (2, 'volts box 2', NULL, 2, 'V', '2019-01-01'),
    (3, 'tmp box 1', NULL, 2, 'h', '2019-01-01'),
    (4, 'tmp box 2', NULL, 2, 'Here', DEFAULT),
    (5, 'some free text', NULL, 2, 'char', DEFAULT),
    -- one object owned by the "other" usergroup
    (6, 'owned by other', NULL, 3, 'V', DEFAULT),
    -- objects that have values in cassandra
    (3008, 'blueFactory sensor', 'test empty values endpoint', 2, 'W', DEFAULT),
    (6602, 'aggr simple', 'test for aggr simple', 2, 'lx', '2019-01-01'),
    (13370, 'aggr extended', 'test for agg extended', 2, 'V', '2019-01-01');


INSERT INTO `objects_ogrps` (`ogrp_id`, `object_id`) VALUES
    -- misc has volts box 1 & 2
    (1, 1),
    (1, 2),
    -- tmp has tmp box 1 & 2
    (2, 3),
    (2, 4),
    -- group "other objects" has one object
    (3, 6);


INSERT INTO `apikeys`(`id`, `user_id`, `secret`, `readonly`) VALUES
    (1, 1, 'wr1', 0),
    (2, 1, 'ro1', 1),
    (3, 2, 'wr2', 0),
    (4, 2, 'ro2', 1),
    (5, 3, 'wr3', 0),
    (6, 3, 'ro3', 1);


INSERT INTO `rights` (`ogrp_id`, `ugrp_id`) VALUES
    -- regular user has access to objectgroup "other objects"
    (3, 2);

INSERT INTO `comments` (`object_id`, `dfrom`, `dto`, `comment`) VALUES 
    (1, '2019-01-01T10:00', '2020-01-01T10:00', 'comment on one full year'),
    (1, '2019-12-31T20:00', '2020-01-01T02:00', 'happy new year !');

INSERT INTO `tokens` (`id`, `token`, `object_id`, `description`) VALUES
    (1, '012345678901234567890123456789a1', 1, 'test'),
    (2, '012345678901234567890123456789a2', 2, 'test'),
    (3, '012345678901234567890123456789a3', 3, 'test'),
    (4, '012345678901234567890123456789a4', 4, 'test'),
    (5, '012345678901234567890123456789a5', 5, 'test');

COMMIT;
