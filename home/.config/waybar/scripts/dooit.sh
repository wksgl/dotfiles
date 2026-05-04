#!/bin/bash
DB="$HOME/.local/share/dooit/dooit.db"

PENDING=$(sqlite3 "$DB" "SELECT COUNT(*) FROM todo WHERE pending = 1;" 2>/dev/null || echo 0)
OVERDUE=$(sqlite3 "$DB" "SELECT COUNT(*) FROM todo WHERE pending = 1 AND due IS NOT NULL AND due < datetime('now');" 2>/dev/null || echo 0)
TODAY=$(sqlite3 "$DB" "SELECT COUNT(*) FROM todo WHERE pending = 1 AND due IS NOT NULL AND date(due) = date('now');" 2>/dev/null || echo 0)

if [ "$OVERDUE" -gt 0 ]; then
    CLASS="overdue"
    ICON=""
elif [ "$TODAY" -gt 0 ]; then
    CLASS="today"
    ICON=""
elif [ "$PENDING" -gt 0 ]; then
    CLASS="pending"
    ICON=""
else
    CLASS="empty"
    ICON=""
fi

TOOLTIP="OVERDUE:$OVERDUE TODAY:$TODAY PENDING:$PENDING"

echo "{\"text\": \"$ICON $PENDING\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
