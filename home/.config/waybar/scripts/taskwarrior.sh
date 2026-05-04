#!/bin/bash
PENDING=$(task +PENDING count 2>/dev/null || echo 0)
OVERDUE=$(task +OVERDUE count 2>/dev/null || echo 0)
TODAY=$(task +TODAY count 2>/dev/null || echo 0)

if [ "$PENDING" -eq 0 ]; then
    echo '{"text": "", "class": "empty"}'
    exit 0
fi

if [ "$OVERDUE" -gt 0 ]; then
    CLASS="overdue"
    ICON=""   # fa-warning
elif [ "$TODAY" -gt 0 ]; then
    CLASS="today"
    ICON=""   # fa-bell
else
    CLASS="pending"
    ICON=""   # fa-tasks
fi

TOOLTIP="OVERDUE:$OVERDUE TODAY:$TODAY PENDING:$PENDING"

echo "{\"text\": \"$ICON $PENDING\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
