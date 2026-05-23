# Track 010 — Settings Backup Restore Spec

## Goal

Implement Settings screen, local preferences, backup, and restore.

## Requirements

1. Settings screen displays:
   - Currency.
   - Theme.
   - Default leftover allocation.
   - Daily reminder.
   - Backup data.
   - Restore data.
   - About app.
2. Theme can switch System/Light/Dark.
3. Preferences persist in DataStore.
4. Backup exports JSON local file.
5. Restore validates JSON file.
6. Restore asks confirmation before replacing data.
7. Restore recalculates dashboard.

## Acceptance Criteria

- Settings persist.
- Theme changes.
- Backup file generated.
- Restore valid file works.
- Invalid file shows friendly error.
- No cloud backup.

## Out of Scope

- Cloud restore.
- Account sync.
- Remote backup.
