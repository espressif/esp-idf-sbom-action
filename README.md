# ESP IDF SBOM Vulnerability Scan Action

This action scans manifest files with CPE info in
repository for possible vulnerabilities.

## Secrets

## `SBOM_MATTERMOST_WEBHOOK`

If the `SBOM_MATTERMOST_WEBHOOK` environment variable is set, a brief status message
containing the job link will automatically be dispatched to the Mattermost
webhook.

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
