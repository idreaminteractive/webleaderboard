-- migrate:up
PRAGMA defer_foreign_keys = ON;

PRAGMA foreign_keys = OFF;

CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name varchar(255) NOT NULL,
    optional_example INTEGER,
    email varchar(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER user_update_updated_at_trigger
AFTER
UPDATE
    ON user FOR EACH ROW BEGIN
UPDATE
    user
SET
    updated_at = CURRENT_TIMESTAMP
WHERE
    rowid = NEW.rowid;

END;

PRAGMA foreign_key_check;

PRAGMA foreign_keys = ON;

PRAGMA defer_foreign_keys = OFF;

-- migrate:down