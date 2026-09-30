SET @activity_slots_version_sql = (
    SELECT IF(
        EXISTS(
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = DATABASE()
              AND table_name = 'activity_slots'
              AND column_name = 'version'
        ),
        'SELECT 1',
        'ALTER TABLE activity_slots ADD COLUMN version BIGINT NOT NULL DEFAULT 0'
    )
);
PREPARE activity_slots_version_stmt FROM @activity_slots_version_sql;
EXECUTE activity_slots_version_stmt;
DEALLOCATE PREPARE activity_slots_version_stmt;
