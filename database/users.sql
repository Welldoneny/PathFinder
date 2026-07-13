CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    login VARCHAR(255) NOT NULL UNIQUE,
    hash_password VARCHAR(255) NOT NULL,
    salt CHAR(32) NOT NULL DEFAULT encode(gen_random_bytes(16), 'hex'),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_users PRIMARY KEY (id)
);