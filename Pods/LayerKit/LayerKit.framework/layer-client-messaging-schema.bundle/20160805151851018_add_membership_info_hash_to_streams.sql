-- Adding the `members_hash` to the `streams` table.
ALTER TABLE streams ADD members_hash TEXT;

-- Populate the `members_hash` by calculating the stream membership hash.
UPDATE streams SET members_hash = (SELECT GROUP_CONCAT(HEX(member_id), ",") FROM (SELECT member_id FROM stream_members WHERE stream_members.deleted_at IS NULL AND stream_members.stream_database_identifier = streams.database_identifier ORDER BY member_id ASC));

-- Adding the `participants_hash` to the `conversations` table.
ALTER TABLE conversations ADD participants_hash TEXT;

-- Populate the `participants_hash` by calculating the conversations participants hash.
UPDATE conversations SET participants_hash = (SELECT GROUP_CONCAT(HEX(member_id), ",") FROM (SELECT member_id FROM conversation_participants WHERE conversation_participants.deleted_at IS NULL AND conversation_participants.conversation_database_identifier = conversation_participants.database_identifier ORDER BY member_id ASC));
