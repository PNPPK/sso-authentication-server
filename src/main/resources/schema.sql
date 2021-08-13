DROP TABLE USERS IF EXISTS;
DROP TABLE HASHES IF EXISTS;
DROP TABLE REFRESH_SESSIONS IF EXISTS;

CREATE TABLE USERS (
    id IDENTITY NOT NULL,
    login VARCHAR(64) NOT NULL,
    salt VARCHAR(256) NOT NULL,
    config VARCHAR(512) NOT NULL,
    name VARCHAR(64) NOT NULL,
    enabled BOOLEAN NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_login_key UNIQUE (login)
);

CREATE TABLE HASHES (
    hash VARCHAR(512)
);

CREATE TABLE REFRESH_SESSIONS (
    user_id BIGINT,
    refresh_token VARCHAR(64),
    expires_in TIMESTAMP WITH TIME ZONE,
    fingerprint VARCHAR(128),
    CONSTRAINT refresh_sessions_pkey PRIMARY KEY (refresh_token),
    CONSTRAINT refresh_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES USERS (id)
);

