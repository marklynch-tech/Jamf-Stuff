#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# This script is for a Jamf Pro Extension Attribute design to check for apps that do not
# have an executable architecture of arm64, indicating that it is not a Universal app.
# This can be used to identify apps which may presently require Rosetta 2 if deployed
# on a Mac with Apple Silicon.
#
## REQUIREMENTS:
#           - Jamf Pro
#
## IMPORTANT ## You shoud test!
# This Extension Attribute is tested on macOS Catalina and Big Sur. This script is provided
# without guarantee or warranty. As with any script, it is recommended to test prior to mass
# deployment in a production environment.
#
# This script involves the creation of files and iteration through those files to create
# the final result to be used in the results of the Extension Attribute.
# Please know this may result in performance hits on the Jamf Pro server side, on client
# side, or possibly even in the network. Again, Test! Test! Test!
#
## Written by: Mark Lynch | Jamf
#
# Based very loosely on: https://www.jamf.com/blog/how-to-find-remaining-32-bit-applications-on-macos/
#
# Utilizes knowledge from
# MacAdmins on Twitter: https://scriptingosx.com/2021/01/weekly-news-summary-for-admins-2021-01-22/
#
## Revision History
# 2021-05-25: Created Script
# 2021-05-26: Made Public
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## Things you can set
#Do you want to EXCLUDE paths to apps? Enter "no" for optionIncludePath.
#Default optionIncludePath="yes"
optionIncludePath="yes"

#Report app QUANTITY instead of App List
#Default optionReportQuantityOnly="no"
optionReportQuantityOnly="no"

#Keep result file on client computer after script is ran
#Default optionRetainResultFile="yes"
optionRetainResultFile="yes"

#Target directory for output of txt file(s).
#Keep permissions in mind when configuring this! Include the final /.
#Default targetDirectory="/Users/Shared/NotArmReady/"
targetDirectory="/Users/Shared/NotArmReady/"


##Things start happening here

#Make the targetDirectory if it doesn't exist
if [[ ! -e $targetDirectory ]]; then
    mkdir $targetDirectory
elif [[ ! -d $targetDirectory ]]; then
    echo "$targetDirectory already exists but is not a directory" 1>&2
fi

# set Internal Field Separator (IFS) to newline
# this accomodates app titles/directories with spaces
IFS=$'\n'

# perform `mdfind` search; save it to "SEARCH_OUTPUT"
SEARCH_OUTPUT="$(/usr/bin/mdfind "kMDItemExecutableArchitectures != '*arm64*' && \
kMDItemContentType == "com.apple.application-bundle" && \
kMDItemKind == 'Application'")"

printf "%s\n" "${SEARCH_OUTPUT[@]}" > ${targetDirectory}"Results.txt"

# Create an empty array to save the app names to
APPS=()

#Remove all apps that start in the /System/ directory, because we can't do anything about those anyways and macOS takes care of it.
grep -v "/System/" ${targetDirectory}"Results.txt" > tmpfile && mv tmpfile ${targetDirectory}"Results.txt"

#Load that ouput back in
SEARCH_OUTPUT=$(<${targetDirectory}"Results.txt")

# loop through the search output; add the applications to the array
# If optionIncludePath is anything but "yes", use `basename` to strip out the directory path
if [[ "$optionIncludePath" = "yes" ]]; then
    for i in $SEARCH_OUTPUT; do
    b=$i
    APPS+=("$b")
    done

#Output all apps to file location
    printf "%s\n" "${APPS[@]}" > ${targetDirectory}"Results.txt"

else
    # use `basename` to strip out the directory path
    for i in $SEARCH_OUTPUT; do
    b=$( /usr/bin/basename -a "$i" )
    APPS+=("$b")
    done

#Output all apps to file location
    printf "%s\n" "${APPS[@]}" > ${targetDirectory}"Results.txt"

fi

# Extension Attribute. Load the results. If the list is empty, report "0". If the APPS array is not empty, check if optionReportQuantityOnly is yes, and report quantity of list of apps in extension attribute.
Results=$(<${targetDirectory}"Results.txt")

if [ ${#APPS[@]} == 0 ]; then
    echo "<result>0</result>"
else
    if [[ "$optionReportQuantityOnly" = "yes" ]]; then
        echo "<result>${#APPS[@]}</result>"
    else 
        echo "<result>${Results}</result>"
    fi
fi

# Clean up by removing the Results.txt from the directory. This isn't really necessary, since the file shouldn't be that big.
if [[ "$optionRetainResultFile" == "no" ]]; then
    rm ${targetDirectory}"Results.txt"
fi