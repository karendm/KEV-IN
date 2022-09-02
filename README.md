# KEV-IN
The KEV-IN bash script can be used to extract CISA Known Exploited Vulnerabilities from Nessus CSV files.

## Description
The Known Exploited Vulnerability Ingestor (abbreviated KEV-IN) is a tool that extracts CVEs contained in the [Known Exploited Vulnerabilities (KEV) Catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) from Nessus CSV files. The purpose is to provide recipients of penetration testing services with a focused list of KEVs for prioritized mitigation, since KEVs pose a higher risk to environments based on the threat landscape.

KEV-IN is meant to be a temporary solution until a more streamlined process for deriving KEVs from scan results is implemented. The tool should be run in Kali and used on each Nessus scan CSV during an engagement. The output CSV file can be shared with stakeholders in the event that KEVs were identified.

## Usage

### Dependencies
The KEV-IN script has only been tested in Kali Linux. KEV-IN requires internet connectivity the first time it is run in an environment to pull down the most up-to-date KEV data and install 'csvtool' (if it is not already installed in the environment). Alternatively, the KEV CSV can be manually retrieved from the [CISA website](https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv), but needs to maintain the same naming convention (known_exploited_vulnerabilities.csv) and the 'csvtool' dependency can be manually installed by running the following command:

```sh
> apt-get install csvtool
```

KEV-IN ingests Nessus CSV files and requires that the 'References' parameter be selected when the CSV file is exported. Once a Nessus scan is complete, export the CSV for a given scan, ensuring the 'References' option is checked.

### Help Menu

```sh
> ./kev-in.sh -h
```

```
    
    KNOWN EXPLOITED VULNERABILITY INGESTOR

    This script parses one Nessus CSV file at a time to identify vulnerabilities that map to the CISA Known Exploited Vulnerabilities (KEV) Catalog and outputs the mappings to a new CSV file.

    Note: While exporting the CSV file from Nessus, ensure that the References field is included, or this tool will not be able to identify KEVs accurately.

    Syntax:
        ./kev-in.sh -i /path/to/input.csv -o /path/to/output.csv

    Example:
        ./kev-in.sh -i ~/Downloads/Nessus-Scan_abcdef.csv -o KnownExploitedVulnerabilities.csv

    Options:
        -h                   Print this help menu.
        -i                   Point to a single Nessus CSV file to parse.
        -o                   Set the output file name (e.g., out.csv).
        
```

### KEV Extraction

```sh
> ./kev-in.sh -i /path/to/Nessus_abcdef.csv -o KnownExploitedVulnerabilities.csv
```

```

    ======================================================


    [*] PARSING: /path/to/Nessus_abcdef.csv

    [-] VULNERABILITY CATEGORIES: 12
    [-] AFFECTED HOSTS: 27
    [-] CVES MAPPED TO KEVS: 8

    [*] KEVS SAVED TO: KnownExploitedVulnerabilities.csv


    ======================================================

```
