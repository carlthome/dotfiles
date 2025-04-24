#!/usr/bin/env bash

# Run Lynis audit and save the report to a temporary file.
REPORT_FILE="/tmp/lynis-report-$(date +%Y%m%d).dat"
echo "Lynis audit started at $(date)"
lynis audit system --report-file "$REPORT_FILE"
echo "Lynis audit completed at $(date)"

# Extract suggestions and warnings from the report.
WARNINGS=$(grep "warning" "$REPORT_FILE" | sort | uniq)
SUGGESTIONS=$(grep "suggestion" "$REPORT_FILE" | sort | uniq)
NUM_WARNINGS=$(echo "$WARNINGS" | grep -cv "^$")
NUM_SUGGESTIONS=$(echo "$SUGGESTIONS" | grep -cv "^$")

# Create a summary message.
TITLE="Lynis found $NUM_WARNINGS warnings and $NUM_SUGGESTIONS suggestions"
MESSAGE="Warnings:\n$(echo "$WARNINGS" | head -5)\n\nSuggestions:\n$(echo "$SUGGESTIONS" | head -5)"
if [ "$NUM_WARNINGS" -gt 5 ] || [ "$NUM_SUGGESTIONS" -gt 5 ]; then
	MESSAGE+="\n\n(Additional items in full report)"
fi

# Send notification based on available tools.
if command -v terminal-notifier; then
	echo "Sending notification using terminal-notifier"
	terminal-notifier -title "$TITLE" -message "$MESSAGE" -open "file://$REPORT_FILE"
elif command -v osascript; then
	echo "Sending notification using osascript"
	osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
elif command -v notify-send; then
	echo "Sending notification using notify-send"
	notify-send -u normal "$TITLE" "$MESSAGE"
fi
