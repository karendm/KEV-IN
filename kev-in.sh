#!/bin/bash

#===================================#
#												#
#	kev ingestor script					#
#	author: karen miller					#
#												#
#===================================#


### DISPLAY HELP MENU ###

Help() {
   echo "KNOWN EXPLOITED VULNERABILITY INGESTOR"
   echo
   echo "This script parses one Nessus CSV file at a time to identify vulnerabilities that map to the CISA Known Exploited Vulnerabilities (KEV) Catalog and outputs the mappings to a new CSV file."
   echo
   echo "Note: While exporting the CSV file from Nessus, ensure that the References field is included, or this tool will not be able to identify KEVs accurately."
   echo 
   echo "Syntax:"
   echo "   ./kev-in.sh -i /path/to/input.csv -o /path/to/output.csv"
   echo
   echo "Example:"
   echo "   ./kev-in.sh -i ~/Downloads/Nessus-Scan_abcdef.csv -o KnownExploitedVulnerabilities.csv"
   echo
   echo "Options:"
   echo "   -h			Print this help menu."
   echo "   -i			Point to a single Nessus CSV file to parse."
   echo "   -o			Set the output file name (e.g., out.csv)."
   echo
}

input=""
output=""
ERROR="\033[0;31m"
BLUE="\033[0;36m"
GRAY="\033[0;37m"
NC="\033[0m"
BOLD=$(tput bold)
NB=$(tput sgr0)

while getopts "hi:o:" option; do
	case $option in
		h)
			Help
			exit;;
		i)
			input=$OPTARG;;
		o)
			output=$OPTARG;;
		\?)
			printf "${ERROR}[!] ERROR: An invalid option was specified.${NC}\n"
			Help
			exit;;
	esac
done


### INSTALL CSVTOOL START ###

install=$(which csvtool)

if [[ $install == "" ]]; then
	apt-get install csvtool
fi

### INSTALL CSVTOOL END ###


### PARSE KEVS START ###

if [[ ! -f known_exploited_vulnerabilities.csv ]]; then
	wget https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv
fi
cat known_exploited_vulnerabilities.csv | cut -d ',' -f1 | cut -d '"' -f2 > cves.txt

### PARSE KEVS END ###


### PARSE INPUT/OUTPUT START ###

ofile="${output#/*/*/}"
opath="${output%/$file}"
ifile="${input#/*/*/}"

if [[ $opath == $ofile ]]; then
	opath=$(pwd)
fi

### PARSE INPUT/OUTPUT END ###


### ERROR HANDLING START ###

if [[ ${#input} -lt 5 ]] || [[ $input != *.csv ]]; then
	printf "${ERROR}[!] ERROR: A valid input file path, name, and/or extension was not specified.${NC}\n"
	exit 1

elif [ ! -f $input ]; then
	printf "${ERROR}[!] ERROR: The input file entered does not exist and/or the file path is incorrect.${NC}\n"
	exit 1

elif [[ ${#output} -lt 5 ]] || [[ $ofile != *.csv ]]; then
	printf "${ERROR}[!] ERROR: A valid output file name was not specified (be sure to specify .csv as the file extension).${NC}\n"
	exit 1

elif [ ! -d $opath ]; then
	printf "${ERROR}[!] ERROR: The specified output file directory does not exist.${NC}\n"
	exit 1

elif [ ! -w $opath ]; then
	printf "${ERROR}[!] ERROR: You do not have permissions to write to this directory. Please run this script under the context of a user with adequate permissions or choose a different output file path.${NC}\n"
	exit 1
fi

### ERROR HANDLING END ###


### PARSE CSV FILE START ###

printf "\n${BLUE}======================================================${NC}\n\n"
printf "\n${BLUE}[*] PARSING: ${GRAY}$ifile${NC}\n\n"

echo Name,CVE,Hosts > $output
csvtool namedcol Name,CVE,Host,XREF $input | grep CISA | sort | uniq >> tmp.csv

# PRINT NUMBER OF VULNERABILITY CATEGORIES #
printf "${BOLD}[-] VULNERABILITY CATEGORIES: ${NB}"
cut -d ',' -f1 tmp.csv | sort | uniq | wc -l

# REMOVE CVES THAT AREN'T IN KEV CATALOG #
awk 'FNR==NR {a[$0];next} {for (i in a) if (i~$1) print i}' tmp.csv cves.txt >> tmp2.csv

# PRINT NUMBER OF AFFECTED HOSTS #
printf "${BOLD}[-] AFFECTED HOSTS: ${NB}"
cut -d ',' -f3 tmp2.csv | sort | uniq | wc -l

# AGGREGATE HOSTS BY UNIQUE CVE #
awk -F, ' {a[$1","$2]=a[$1","$2]?a[$1","$2] OFS $3:$3} END{for (i in a) print i FS a[i]} ' OFS=";" tmp2.csv | sort | uniq >> $output

# PRINT NUMBER OF CVES #
printf "${BOLD}[-] CVES MAPPED TO KEVS: ${NB}"
awk 'END { print NR - 1 }' $output

# CLEAN UP #
rm tmp.csv
rm tmp2.csv

printf "\n${BLUE}[*] KEVS SAVED TO: ${GRAY}$output${NC}\n\n"
printf "\n${BLUE}======================================================${NC}\n\n\n"

### PARSE CSV FILE END ###
