CREATE TABLE file_changes (
    id SERIAL PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    change_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_watcher (
    id SERIAL PRIMARY KEY,
    file_id INTEGER NOT NULL,
    watcher_id INTEGER NOT NULL,
    watch_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (file_id) REFERENCES file_changes (id)
);

CREATE TABLE watchers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);

INSERT INTO watchers (name, email) VALUES ('Watcher1', 'watcher1@example.com');
INSERT INTO watchers (name, email) VALUES ('Watcher2', 'watcher2@example.com');

CREATE FUNCTION notify_watcher() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO file_watcher (file_id, watcher_id) VALUES (NEW.id, (SELECT id FROM watchers WHERE name = 'Watcher1'));
    INSERT INTO file_watcher (file_id, watcher_id) VALUES (NEW.id, (SELECT id FROM watchers WHERE name = 'Watcher2'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_watcher_trigger AFTER INSERT ON file_changes FOR EACH ROW EXECUTE FUNCTION notify_watcher();

INSERT INTO file_changes (file_name, file_path, change_type) VALUES ('file1.txt', '/path/to/file1.txt', 'created');
INSERT INTO file_changes (file_name, file_path, change_type) VALUES ('file2.txt', '/path/to/file2.txt', 'updated');
INSERT INTO file_changes (file_name, file_path, change_type) VALUES ('file3.txt', '/path/to/file3.txt', 'deleted');

SELECT * FROM file_changes;
SELECT * FROM file_watcher;
SELECT * FROM watchers;

CREATE VIEW watcher_view AS SELECT watchers.name, file_changes.file_name, file_changes.change_type FROM watchers JOIN file_watcher ON watchers.id = file_watcher.watcher_id JOIN file_changes ON file_watcher.file_id = file_changes.id;

SELECT * FROM watcher_view;

DROP TRIGGER notify_watcher_trigger ON file_changes;
DROP FUNCTION notify_watcher;
DROP TABLE file_watcher;
DROP TABLE file_changes;
DROP TABLE watchers;