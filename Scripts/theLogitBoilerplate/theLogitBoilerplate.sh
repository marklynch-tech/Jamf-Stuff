#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# theLogitBoilerplate
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This script is designed to be a boilerplate for other scripts to provide a logging
# framework 
# This can be used to identify apps which may presently require Rosetta 2 if deployed
# on a Mac with Apple Silicon.
#
## REQUIREMENTS:
#           - Script
#
## IMPORTANT ## You should test!
# This script  This script is provided without guarantee or warranty. As with any script, it is 
# recommended to test prior to mass deployment in a production environment. Because this script is
# intended as a boilerplate to be used with other scripts, it is important to test the combined
# script to ensure there aren't any conflicts.
# Again, Test! Test! Test!
#
## FAQ
# Q: Do I need Jamf Pro for this to work?
# A: Nope! There are just some additional considerations for Jamf Pro usage to extend functionality
#
# Q: Will the script variables conflict with my script's variables?
# A: It depends. Consideration was taken to add the word "log" to the start of every varaible in
# this script in an attempt to cut down of possible conflicts. There's no way to guarantee though,
# so make sure to perform adequate testing! You can also check variable names between what's in the
# boilerplate vs what's found in your script or after "#Script starts here"
#
## USAGE
# Configure any necessary varaibles (such as the logDirectory for example).
# Beneath "#Script starts here", place your script or write your script.
# Any time you wish to output to logs, simply call the logit function with something akin to this:
# logit "This is a log item that adds context to the script."
#
## Written by: Mark Lynch | Jamf
#
## Revision History
# 2023-01-10: Created Script
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#Configure These

logTimeStamp=$(date '+%F %T') #Formatted by default as YYYY-MM-DD HH:MM:SS
logLoggedInUser=$(ls -l /dev/console | awk '{ print $3 }')

logScriptName="Generic Logging" #Name of your script. Default: "Generic Logging"
logScriptVersion="0.01" #Version of your script. Use whatever formatting you want. Default: "0.01"
logDirectory=/Users/Shared/Management\ Logging/ #Directory for log files to live. Make sure to end it with a slash / #Default: /Users/Shared/Management\ Logging/
logFileName="managementLogging.log" #Name of the log file. Default: #managementLogging.log

#Policy Script Parameters - Adjust these between 4 and 11 as desired. You may also define these manually lower down insted of using Jamf Pro script parameters.
#Set $logSettingPolicyParams to "false" to disable this
logSettingPolicyParams="true" #Default: "true"
logPolicyNameParam=$4 #Default: $4
logPolicyIDParam=$5 #Default: $5
logPolicyNotesParam=$6 #Default: $6

#Set these if you are not using Jamf Pro policy parameters for these items. Make sure to set $logSettingPolicyParameters to "false" above.
logPolicyName= #Default:
logPolicyID= #Default:
logPolicyNotes= #Default:

#Don't change this
#Combine $logDirectory and $logFileName for easier usage later
logPath="$logDirectory$logFileName"


#Don't change these
#Function for logging items
#Usage in script:
#logit "Log the item here"

function logit() {
	local lineStamp="[$logTimeStamp] - [$logScriptName]"
	echo $lineStamp "${*}" 2>&1 | tee -a "$logPath"
}

#Check for logDirectory and initialize if it doesn't exist
echo $logTimeStamp $logScriptName $logScriptVersion

if [ ! -d "$logDirectory" ]; then
	echo "$logDirectory not found. Initializing..."
	mkdir -p "$logDirectory"
	echo "$logDirectory Initialized."
fi

#Check for logFile and initialize if it doesn't exist

if [[ ! -f $logPath ]]
then
	echo "Set logging path to $logPath"
	echo "Initalizing $logFileName in $logDirectory"
	touch "$logPath"
	logit "$logScriptName $logScriptVersion in $logPath initialized."
fi

#Start off script logging by saying we're doing so

if [[ $logSettingPolicyParams = "true" ]]
	then
		if [[ ! -z $logPolicyNameParam ]]
			then
				if [[ ! -z $logPolicyIDParam ]]
					then
						logit "Policy Name: $logPolicyNameParam - Policy ID: $logPolicyIDParam"
						logit "Policy Notes: $logPolicyNotesParam"
					else
						logit "Policy Name: $logPolicyNameParam"
						logit "Policy Notes: $logPolicyNotesParam"
				fi
		fi
elif [[ ! -z $logPolicyName ]]
	then
		if [[ ! -z $logPolicyIDParam ]]
		then
			logit "Policy Name: $logPolicyName - Policy ID: $logPolicyID"
			logit "Policy Notes: $logPolicyNotes"
		else
			logit "Policy Name: $logPolicyName"
			logit "Policy Notes: $logPolicyNotes"
		fi
fi


logit "Executing $logScriptName $logScriptVersion"

#Script Starts Here

#End of script

#See ya later
exit 0