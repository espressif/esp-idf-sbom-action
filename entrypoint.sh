#!/usr/bin/env bash

die () {
	echo "$@" >&2
	exit 1
}

REPORT_FILE="report.md"

notify_mattermost () {
	test -n "${SBOM_MATTERMOST_WEBHOOK:+x}" || return

	JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
	USER_NAME="${GITHUB_REPOSITORY}@${INPUT_REF:-$GITHUB_REF_NAME}"

	case $1 in
	0)
		MSG=":large_green_circle: No vulnerabilities found ${JOB_URL}"
		;;
	1)
		# Replace newline with escape sequence
		REPORT_MATTERMOST="${2//$'\n'/\\n}"
		MSG=":red_circle: New vulnerabilities found ${JOB_URL}\n\n${REPORT_MATTERMOST}"
		;;
	128)
		MSG=":large_yellow_circle: Vulnerabilities scan failed ${JOB_URL}"
		;;
	*)
		MSG=":large_yellow_circle: Unknown return value ${JOB_URL}"
		;;
	esac

	curl --no-progress-meter -i -X POST -H 'Content-Type: application/json'\
		-d "{\"username\": \"${USER_NAME}\", \"text\": \"${MSG}\"}"\
		"$SBOM_MATTERMOST_WEBHOOK"
	test $? -eq 0 || die
}

pip install esp-idf-sbom
test $? -eq 0 || die

python -m esp_idf_sbom manifest check --format markdown --output-file $REPORT_FILE /github/workspace
SCAN_RESULT=$?
# Remove any empty lines and use just selected columns from the markdown table
# This report is printed in the CI job log
REPORT_FILTERED=$(grep -v "^[[:space:]]*$" $REPORT_FILE | cut -d'|' -f1-5,7,11,14)
# Keep only rows with vulnerability report and header
REPORT_VULNERABLE=$(echo "$REPORT_FILTERED" | grep -v "NO\|EXCLUDED")
echo "vulnerable=$SCAN_RESULT" >> $GITHUB_OUTPUT

echo "$REPORT_FILTERED"
notify_mattermost $SCAN_RESULT "$REPORT_VULNERABLE"
