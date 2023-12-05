# ESP IDF SBOM Vulnerability Scan Action

This action scans manifest files with CPE info in repository for possible
vulnerabilities and optionaly sends message to a Mattermost channel.

## Secrets

## `SBOM_MATTERMOST_WEBHOOK`

If the `SBOM_MATTERMOST_WEBHOOK` environment variable is set and not null, a
brief status message containing the job link will automatically be dispatched
to the Mattermost webhook. Author of the message is set as
`${GITHUB_REPOSITORY}@${INPUT_REF:-$GITHUB_REF_NAME}`, where `INPUT_REF` may
be set via action inputs.

## Inputs

## `ref`

Reference name. If not set `GITHUB_REF_NAME` is used by default. Can be used
to explicitly set the reference in the Mattermost message user name.

## Outputs

## `vulnerable`

Set to 1 if vulnerability was found, 0 otherwise.

## Example usage

    jobs:
      vulnerability-scan:
        name: Vulnerability scan
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repository
            uses: actions/checkout@v4

          - name: Vulnerability scan
            env:
              SBOM_MATTERMOST_WEBHOOK: ${{ secrets.SBOM_MATTERMOST_WEBHOOK }}
            uses: espressif/esp-idf-sbom-action@master
