DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) UNIQUE,
    password_hash VARCHAR(100), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
    phone BIGINT UNSIGNED UNIQUE,

    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'юзеры';

INSERT users (firstname, lastname, email, password_hash, phone)
VALUES
	('Jacob', 'Ford', 'hfhh32534djj@mail.ru', 'dfsvsdfsdgsfs4323;', 76722876627),
    ('Jacob', 'Gibs', 'llllllhdjj@mail.ru', 'dfsvcdffvll234323;', 76789976629),
    ('Maria', 'Port', 'hf63ffj@mail.ru', 'dfsv3234253524323;', 79978626629),
    ('Jacob', 'Med', 'hfwetghbj@mail.ru', 'dfsvcdfvbl;lkjh234323;', 78889876629),
    ('Max', 'Kirs', 'hhfdfjj@mail.ru', 'dfsvcdffvllkjhkl;l;/.323;', 76789876629),    
    ('Thomas', 'Ford', '87656543djj@mail.ru', 'dfsvc?;/;l.ll234323;', 76789654555),
    ('Jacob', 'Nord', 'hfh565hdjj@mail.ru', 'dfsvcdfdgh234323;', 76425476629),
    ('Artur', 'Jeners', 'sasdasadaj@mail.ru', 'df2345tfvll234323;', 78555576629),
    ('John', 'Lends', 'hlkjhjklaa234j@mail.ru', 'dfsfdfdgdfvll234323;', 79799876629),    
    ('Phin', 'Gilberd', 'h13232r3j@mail.ru', 'dfsdhnghml234323;', 79781176629);

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
    photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)

-- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

ALTER TABLE profiles ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id) REFERENCES users(id)
ON UPDATE CASCADE -- (значение по умолчанию)
ON DELETE RESTRICT; -- (значение по умолчанию)

INSERT profiles (user_id, gender, birthday, hometown)
VALUES
	(1, 'm', '2002-10-11', 'Moscow'),
	(2, 'm', '2001-05-12', 'Spb'),
	(3, 'f', '2009-09-08', 'Smolensk'),
	(4, 'm', '2001-10-11', 'Moscow'),
	(5, 'm', '2001-10-15', 'Moscow'),
	(6, 'm', '2003-10-15', 'Spb'),
	(7, 'm', '2006-08-11', 'Moscow'),
	(8, 'm', '2008-07-15', 'Moscow'),
	(9, 'm', '2001-08-08', 'Kirov'),
	(10, 'm', '2010-12-09', 'Spb');


DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
-- id SERIAL, -- изменили на составной ключ (initiator_user_id, target_user_id)
    initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('requested', 'approved', 'declined', 'unfriended'), # DEFAULT 'requested',
-- status TINYINT(1) UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
    requested_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP, -- можно будет даже не упоминать это поле при обновлении

    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)-- ,
-- CHECK (initiator_user_id <> target_user_id)
);
-- чтобы пользователь сам себе не отправил запрос в друзья
-- ALTER TABLE friend_requests
-- ADD CHECK(initiator_user_id <> target_user_id);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
    id SERIAL,
    name VARCHAR(150),
    admin_user_id BIGINT UNSIGNED NOT NULL,

    INDEX communities_name_idx(name), -- индексу можно давать свое имя (communities_name_idx)
    FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
    user_id BIGINT UNSIGNED NOT NULL,
    community_id BIGINT UNSIGNED NOT NULL,

    PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
    id SERIAL,
    name VARCHAR(255), -- записей мало, поэтому в индексе нет необходимости
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
    id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    body text,
    filename VARCHAR(255),
-- file BLOB,
    size INT,
    metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
    id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()
-- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)


/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
);

ALTER TABLE likes
ADD CONSTRAINT likes_fk
FOREIGN KEY (media_id) REFERENCES media(id);

ALTER TABLE likes
ADD CONSTRAINT likes_fk_1
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE profiles
ADD CONSTRAINT profiles_fk_1
FOREIGN KEY (photo_id) REFERENCES media(id);

DROP TABLE IF EXISTS type_of_alert;
CREATE TABLE type_of_alert (
    id SERIAL,
    type_name VARCHAR(150) NOT NULL,
    is_about_media BOOLEAN NOT NULL,
    is_about_message BOOLEAN NOT NULL,
    is_about_like BOOLEAN NOT NULL,
    id_media BIGINT UNSIGNED NOT NULL,
    id_like BIGINT UNSIGNED NOT NULL,
    id_messages BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (id_media) REFERENCES media(id),
    FOREIGN KEY (id_like) REFERENCES likes(id),
    FOREIGN KEY (id_messages) REFERENCES messages(id)
);

DROP TABLE IF EXISTS alerts;
CREATE TABLE alerts (
    id SERIAL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(150) NOT NULL,
    type_of_alert_id BIGINT UNSIGNED NOT NULL,
    sent_at DATETIME DEFAULT NOW() NOT NULL,

    FOREIGN KEY (to_user_id) REFERENCES users(id),
    FOREIGN KEY (type_of_alert_id) REFERENCES type_of_alert(id)
);

ALTER TABLE profiles
ADD is_active BOOLEAN DEFAULT FALSE
AFTER birthday;

UPDATE profiles
SET is_active = 1
WHERE YEAR(NOW()) - YEAR(birthday) - (RIGHT(NOW(), 5) < RIGHT(birthday, 5)) >= 18;

DELETE FROM messages
WHERE created_at > NOW();




