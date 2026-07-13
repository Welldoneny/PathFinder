CREATE TABLE routes (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER NOT NULL,
    distance_km DOUBLE PRECISION,
    total_ascent_m DOUBLE PRECISION,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    points JSONB NOT NULL DEFAULT '[]',
    CONSTRAINT pk_routes PRIMARY KEY (id),
    CONSTRAINT fk_routes_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
);