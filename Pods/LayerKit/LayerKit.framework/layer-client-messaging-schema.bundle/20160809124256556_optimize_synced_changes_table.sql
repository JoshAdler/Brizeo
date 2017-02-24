-- The `synced_changes` table has a general `row_identifier` column that is used
-- as a reference to multiple tables, depending on what the `table_name` says.
--
-- In this migration we're going to unwrap that column into multiple columns,
-- and use the database primitives to take care of the entity relationships
-- and indexes.

CREATE TABLE new_synced_changes (
  change_identifier INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  change_type INTEGER NOT NULL,
  stream_database_identifier INTEGER,
  mutation_database_identifier INTEGER,
  event_database_identifier INTEGER,
  event_content_part_database_identifier INTEGER,
  remote_keyed_value_database_identifier INTEGER,
  stream_member_database_identifier INTEGER,
  associated_stream_database_identifier INTEGER NOT NULL,
  FOREIGN KEY(stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(mutation_database_identifier) REFERENCES mutations(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_database_identifier) REFERENCES events(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(event_content_part_database_identifier) REFERENCES event_content_parts(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(remote_keyed_value_database_identifier) REFERENCES remote_keyed_values(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(stream_member_database_identifier) REFERENCES stream_members(database_identifier) ON DELETE CASCADE,
  FOREIGN KEY(associated_stream_database_identifier) REFERENCES streams(database_identifier) ON DELETE CASCADE
);

-------------------------------------------------------------------------------
-- Migrate old `synced_changes` into the `new_synced_changes` and fill out
-- all the associated columns.
-------------------------------------------------------------------------------
INSERT INTO new_synced_changes
     SELECT NULL,                               -- for `change_identifier`
            synced_changes.change_type,         -- for 'change_type'
            CASE WHEN (synced_changes.table_name = 'streams') THEN synced_changes.row_identifier ELSE NULL END AS stream_database_identifier,
            CASE WHEN (synced_changes.table_name = 'mutations') THEN synced_changes.row_identifier ELSE NULL END AS mutation_database_identifier,
            CASE WHEN (synced_changes.table_name = 'events') THEN synced_changes.row_identifier ELSE NULL END AS event_database_identifier,
            CASE WHEN (synced_changes.table_name = 'event_content_parts') THEN synced_changes.row_identifier ELSE NULL END AS event_content_part_database_identifier,
            CASE WHEN (synced_changes.table_name = 'remote_keyed_values') THEN synced_changes.row_identifier ELSE NULL END AS remote_keyed_value_database_identifier,
            CASE WHEN (synced_changes.table_name = 'stream_members') THEN synced_changes.row_identifier ELSE NULL END AS stream_member_database_identifier,
            CASE WHEN (synced_changes.table_name = 'streams') THEN synced_changes.row_identifier
                 WHEN (synced_changes.table_name = 'mutations' AND mutations.target = 1) THEN events_to_mutations.stream_database_identifier
                 WHEN (synced_changes.table_name = 'mutations' AND mutations.target = 2) THEN mutations.stream_database_identifier
                 WHEN (synced_changes.table_name = 'events') THEN events.stream_database_identifier
                 WHEN (synced_changes.table_name = 'event_content_parts') THEN events_to_event_content_parts.stream_database_identifier
                 WHEN (synced_changes.table_name = 'remote_keyed_values') THEN remote_keyed_values.object_id
                 WHEN (synced_changes.table_name = 'stream_members') THEN stream_members.stream_database_identifier
                 END AS associated_stream_database_identifier
       FROM synced_changes
  LEFT JOIN mutations ON (mutations.database_identifier = synced_changes.row_identifier AND synced_changes.table_name = 'mutations')
  LEFT JOIN events AS events_to_mutations ON (events_to_mutations.database_identifier = mutations.event_database_identifier AND mutations.target = 1)
  LEFT JOIN events ON (events.database_identifier = synced_changes.row_identifier AND synced_changes.table_name = 'events')
  LEFT JOIN event_content_parts ON (event_content_parts.database_identifier = synced_changes.row_identifier AND synced_changes.table_name = 'event_content_parts')
  LEFT JOIN events AS events_to_event_content_parts ON (events_to_event_content_parts.database_identifier = event_content_parts.event_database_identifier)
  LEFT JOIN remote_keyed_values ON (remote_keyed_values.database_identifier = synced_changes.row_identifier)
  LEFT JOIN stream_members ON (stream_members.database_identifier = synced_changes.row_identifier);

-- Getting rid of the old synced_changes table.
DROP TABLE synced_changes;

-- Let's make the new table to be `synced_changes`
ALTER TABLE new_synced_changes RENAME to synced_changes;

CREATE INDEX synced_changes_stream_db_id_idx ON synced_changes(stream_database_identifier);
CREATE INDEX synced_changes_mutation_db_id_idx ON synced_changes(mutation_database_identifier);
CREATE INDEX synced_changes_event_db_id_idx ON synced_changes(event_database_identifier);
CREATE INDEX synced_changes_event_content_part_db_id_idx ON synced_changes(event_content_part_database_identifier);
CREATE INDEX synced_changes_remote_keyed_value_db_id_idx ON synced_changes(remote_keyed_value_database_identifier);
CREATE INDEX synced_changes_stream_member_db_id_idx ON synced_changes(stream_member_database_identifier);
CREATE INDEX synced_changes_associated_stream_db_id_idx ON synced_changes(associated_stream_database_identifier);

DROP TRIGGER IF EXISTS track_deletes_of_remote_keyed_values;
DROP TRIGGER IF EXISTS track_deletes_of_stream_members;
DROP TRIGGER IF EXISTS track_deletes_of_streams;
DROP TRIGGER IF EXISTS track_event_content_part_purges;
DROP TRIGGER IF EXISTS track_event_content_part_transfer_status_changes;
DROP TRIGGER IF EXISTS track_inserts_of_events_delete;
DROP TRIGGER IF EXISTS track_inserts_of_events_non_delete;
DROP TRIGGER IF EXISTS track_inserts_of_mutations;
DROP TRIGGER IF EXISTS track_inserts_of_remote_keyed_values;
DROP TRIGGER IF EXISTS track_inserts_of_streams;
DROP TRIGGER IF EXISTS track_inserts_of_stream_members;
DROP TRIGGER IF EXISTS track_re_inserts_of_remote_keyed_values;
DROP TRIGGER IF EXISTS track_stream_distinct_updates;
DROP TRIGGER IF EXISTS track_updates_of_event_seqs;
DROP TRIGGER IF EXISTS track_updates_of_mutations;
DROP TRIGGER IF EXISTS track_updates_of_remote_keyed_values;
DROP TRIGGER IF EXISTS track_updates_of_starting_seq;
DROP TRIGGER IF EXISTS track_updates_of_stream_database_identifier_for_conversation;
DROP TRIGGER IF EXISTS track_updates_of_stream_id_for_events;
DROP TRIGGER IF EXISTS track_updates_of_streams;

CREATE TRIGGER track_deletes_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at NOT NULL AND OLD.deleted_at IS NULL)
BEGIN
  INSERT INTO synced_changes(remote_keyed_value_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD.database_identifier, 2, OLD.object_id);
END;

CREATE TRIGGER track_deletes_of_stream_members AFTER UPDATE OF deleted_at ON stream_members
WHEN NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL
BEGIN
  INSERT INTO synced_changes(stream_member_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD._ROWID_, 2, OLD.stream_database_identifier);
END;

CREATE TRIGGER track_deletes_of_streams AFTER UPDATE OF deletion_mode ON streams
WHEN NEW.deletion_mode = 2
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD.database_identifier, 2, OLD.database_identifier);
END;

CREATE TRIGGER track_event_content_part_purges AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status = 2 AND NEW.purged <> OLD.purged AND NEW.purged = 1 AND NEW.last_accessed IS NULL
BEGIN
  INSERT INTO synced_changes(event_content_part_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD._ROWID_, 2, (
    SELECT events.stream_database_identifier FROM events
    LEFT OUTER JOIN event_content_parts ON (events.database_identifier = event_content_parts.event_database_identifier)
    WHERE event_content_parts.database_identifier = NEW.database_identifier
  ));
END;

CREATE TRIGGER track_event_content_part_transfer_status_changes AFTER UPDATE OF transfer_status ON event_content_parts
WHEN NEW.transfer_status <> OLD.transfer_status AND NEW.purged = 0
BEGIN
  INSERT INTO synced_changes(event_content_part_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD._ROWID_, 1, (
    SELECT events.stream_database_identifier FROM events
    LEFT OUTER JOIN event_content_parts ON (events.database_identifier = event_content_parts.event_database_identifier)
    WHERE event_content_parts.database_identifier = NEW.database_identifier
  ));
END;

CREATE TRIGGER track_inserts_of_events_delete AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type = 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier) AND (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq)
BEGIN
  INSERT INTO synced_changes(event_database_identifier, change_type, associated_stream_database_identifier) VALUES ((SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq), 2, NEW.stream_database_identifier);
  UPDATE events SET type = 10, subtype = NULL, external_content_id = NULL, member_id = NULL, target_seq = NULL WHERE database_identifier = (SELECT database_identifier FROM events WHERE stream_database_identifier = NEW.stream_database_identifier AND seq = NEW.target_seq);
END;

CREATE TRIGGER track_inserts_of_events_non_delete AFTER INSERT ON events FOR EACH ROW
WHEN NEW.seq IS NOT NULL AND NEW.type != 9 AND NOT EXISTS (SELECT 1 FROM events WHERE client_id = NEW.client_id AND database_identifier != NEW.database_identifier)
BEGIN
  INSERT INTO synced_changes(event_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_inserts_of_stream_mutations AFTER INSERT ON mutations
WHEN NEW.is_synchronized = 1 AND NEW.stream_database_identifier IS NOT NULL
BEGIN
  INSERT INTO synced_changes(mutation_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_inserts_of_event_mutations AFTER INSERT ON mutations
WHEN NEW.is_synchronized = 1 AND NEW.stream_database_identifier IS NULL AND NEW.event_database_identifier IS NOT NULL
BEGIN
  INSERT INTO synced_changes(mutation_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, (
    SELECT events.stream_database_identifier FROM events
    WHERE events.database_identifier = NEW.event_database_identifier
  ));
END;

CREATE TRIGGER track_inserts_of_remote_keyed_values AFTER INSERT ON remote_keyed_values
WHEN NEW.timestamp NOT NULL
BEGIN
  INSERT INTO synced_changes(remote_keyed_value_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.object_id);
END;

CREATE TRIGGER track_inserts_of_stream_members AFTER INSERT ON stream_members
WHEN NEW.seq IS NOT NULL
BEGIN
  INSERT INTO synced_changes(stream_member_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW._ROWID_, 0, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_inserts_of_streams AFTER INSERT ON streams
WHEN NEW.stream_id IS NOT NULL
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.database_identifier);
END;

CREATE TRIGGER track_re_inserts_of_remote_keyed_values AFTER UPDATE OF deleted_at ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND (NEW.deleted_at IS NULL AND OLD.deleted_at NOT NULL)
BEGIN
  INSERT INTO synced_changes(remote_keyed_value_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.object_id);
END;

CREATE TRIGGER track_stream_distinct_updates AFTER UPDATE OF is_distinct ON streams
WHEN NEW.is_distinct IS NOT NULL AND OLD.is_distinct IS NOT NULL AND NEW.is_distinct != OLD.is_distinct
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (OLD.database_identifier, 1, NEW.database_identifier);
END;

CREATE TRIGGER track_updates_of_event_seqs AFTER UPDATE OF seq ON events
WHEN NEW.seq IS NOT NULL AND OLD.seq IS NULL
BEGIN
  INSERT INTO synced_changes(event_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 1, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_updates_of_stream_mutations AFTER UPDATE OF is_synchronized ON mutations
WHEN NEW.is_synchronized = 1 AND OLD.is_synchronized = 0 AND NEW.stream_database_identifier IS NOT NULL
BEGIN
  INSERT INTO synced_changes(mutation_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_updates_of_event_mutations AFTER UPDATE OF is_synchronized ON mutations
WHEN NEW.is_synchronized = 1 AND OLD.is_synchronized = 0 AND NEW.stream_database_identifier IS NULL
BEGIN
  INSERT INTO synced_changes(mutation_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 0, (
    SELECT events.stream_database_identifier FROM events
    WHERE events.database_identifier = NEW.event_database_identifier
  ));
END;

CREATE TRIGGER track_updates_of_remote_keyed_values AFTER UPDATE OF timestamp ON remote_keyed_values
WHEN NEW.timestamp NOT NULL AND OLD.deleted_at IS NULL AND (NEW.value != OLD.value)
BEGIN
  INSERT INTO synced_changes(remote_keyed_value_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 1, NEW.object_id);
END;

CREATE TRIGGER track_updates_of_starting_seq AFTER UPDATE OF starting_seq ON streams
WHEN OLD.starting_seq IS NULL AND NEW.starting_seq IS NOT NULL
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 1, NEW.database_identifier);
END;

CREATE TRIGGER track_updates_of_stream_database_identifier_for_conversation AFTER UPDATE OF stream_database_identifier ON conversations
WHEN (OLD.stream_id IS NULL AND NEW.stream_id IS NULL) OR OLD.stream_id = NEW.stream_id
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.stream_database_identifier, 1, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_updates_of_stream_id_for_events AFTER UPDATE OF stream_database_identifier ON events
WHEN NEW.stream_database_identifier IS NOT NULL AND OLD.stream_database_identifier IS NOT NULL AND NEW.stream_database_identifier != NEW.stream_database_identifier
BEGIN
  INSERT INTO synced_changes(event_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 1, NEW.stream_database_identifier);
END;

CREATE TRIGGER track_updates_of_streams AFTER UPDATE OF stream_id ON streams
WHEN NEW.stream_id IS NOT NULL AND OLD.stream_id IS NULL
BEGIN
  INSERT INTO synced_changes(stream_database_identifier, change_type, associated_stream_database_identifier) VALUES (NEW.database_identifier, 1, NEW.database_identifier);
END;
