#!/usr/bin/env sh

die () {
	echo "$@" >&2
	exit 1
}

notify_mattermost () {
	test -n "${SBOM_MATTERMOST_WEBHOOK+x}" || return

	if test $1 -eq 0
	then
		MSG=":large_green_circle: No vulnerabilities found"
	else
		MSG=":red_circle: New vulnerabilities found"
	fi

	JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
	USER_NAME="${GITHUB_REPOSITORY}@${GITHUB_REF_NAME}"
	curl --no-progress-meter -i -X POST -H 'Content-Type: application/json'\
		-d "{\"username\": \"${USER_NAME}\", \"text\": \"${MSG} ${JOB_URL}\"}"\
		"$SBOM_MATTERMOST_WEBHOOK"
	test $? -eq 0 || die
}

pip install esp-idf-sbom
test $? -eq 0 || die

python -m esp_idf_sbom manifest check /github/workspace
SCAN_RESULT=$?
echo "vulnerable=$SCAN_RESULT" >> $GITHUB_OUTPUT

notify_mattermost $SCAN_RESULT
