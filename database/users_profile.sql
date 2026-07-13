CREATE TABLE users_profile (
    user_id INTEGER PRIMARY KEY,
    age INTEGER,
    sex BOOLEAN,
    weight_kg DOUBLE PRECISION,
    height_cm DOUBLE PRECISION,
    time_per_1km_min DOUBLE PRECISION,
    VO2max_mlkg_min DOUBLE PRECISION,
    CONSTRAINT fk_users FOREIGN KEY(user_id) 
    REFERENCES users(id) ON DELETE CASCADE 
);