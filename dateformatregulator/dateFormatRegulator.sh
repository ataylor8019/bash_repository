#!/bin/bash

# dateFormatRegulator.sh
# By Allan Taylor
# 03/18/2020
#
#v1.45
#
# Usage: To scan and convert the names of files in a given directory containing various date formats
#  to a single consistent format
#
#
################################################################################
#
#
# Updates:
# 04/13/2020: Updated function validateDayMonthInput, separated it into two
# functions: validateDayInput and validateMonthInput. Added regex to each to 
# properly test for proper month and day inputs - before the script would just
# gracefully fail if an impossible value were put in. Now the script queries the
# user for a proper value if a clearly impossible month or day is input. Note:
# context is ignored with regard to days: the program won't check to see if the
# day is impossible in a given month - values like 02/30 and 04/31 won't be
# flagged as errors by the updated functions, they will just fail in the date
# conversion and return no values.
#
# Updated function verifyExit, so as to properly handle the null value entry
# case. Before it would fail with a urnary operator error, now it continually
# queries the user to enter the proper value so as to prevent the error. Also
# converts all values to lowercase, so "Y" is converted to "y" in the comparison.
#
#
# 5/17/2020: Updated commented name to match name in Github, rest of program.
#
### General program area variable definition - these variables are used in the main program after the function definitions
validFileName="false"
isNotInitialRun="false"
generalInputValid="false"
correctedFileName=""
menuInput=0
helpSelection=""


### Begin function definitions ###




#Help sections not commented, display functions only, purpose is self explanatory
helpOverview() {
    printf "This option provides information on usage of this program. Run with -h and\n"
    printf "no arguments to see a list of arguments that will give you information on\n"
    printf "specific program functions.\n\n"

    printf "mainmenu: describes the main menu and acceptable inputs\n"
    printf "dataconversion: describes the data file name conversion prompt, method, and requirements\n"
    printf "datesearch: describes the data file date search screen and acceptable inputs\n"
    printf "initialsetup: describes the initial setup screen and process\n"
    printf "scanlocation: an alias for initial setup, describes the same thing\n"
}

helpInitialSetup() {
    printf "Upon starting the program, or selecting option 3 from the main menu, you will be asked to choose a location to scan files in,\n"
    printf "with the below prompt:\n\n"

    printf "\n\nInput location of attendance files\n"

    printf "Press enter to scan default location (currently [program location]):\n\n"

    printf "The default location to scan is the location where the program is currently residing. This changes if you update the location\n"
    printf "and reenter the menu - the default location becomes the updated location.\n"
    
}

helpMainMenu() {
    printf "After having selected a run location at the initial setup screen, you will be presented\n"
    printf "with the system menu, as displayed below:\n\n"

    printf "System Menu\n"
    printf "________________________________________________________________________________"
    printf "\n\n\n"
    printf "1) Perform file name format correction \n"
    printf "2) Read data files \n"
    printf "3) Change file scan location\n"
    printf "4) View help and usage information\n"
    printf "5) Exit \n\n"

    printf "Press one of the listed number keys to be taken to the appropriate prompt or\n"
    printf "action.\n\n"

    printf "Note: pressing any non numeric key, or an empty button press, will cause the\n"
    printf "program to repeat the prompt and request. If you wish to exit without further\n"
    printf "prompting, press Control+C.\n\n"
}

helpDateConversion() {
    printf "Selecting option 1 will take you to the date conversion menu. You will be asked\n"
    printf "to select one of the following formats below:\n\n"

    printf "a) January 01, 2020\n"
    printf "b) January012020\n"
    printf "c) Jan 01, 2020\n"
    printf "d) Jan012020\n"
    printf "e) 01-01-2020\n"
    printf "f) 01.01.2020\n"
    printf "g) 01012020\n"
    printf "h) 01_01_2020\n\n"

    printf "The format you select will be the format that all date sections of valid attendance\n"
    printf "files will be converted to. The default format is format h.\n\n"

    printf "Note: entering anything other than one of the accepted letters or an empty Enter\n"
    printf "key press will cause the program to repeat the above question. If you wish to exit\n"
    printf "at this point in the program, input Control+C.\n\n"

}

helpDateSearch() {
    printf "Selecting option 2 will take you to the Data File Date Scan mode. This mode \n"
    printf "performs a file search and returns those file names matching the month,\n"
    printf "date, and year entered.\n\n"

    printf "The following prompts will be presented: \n\n"
    printf "Enter month in numeric format (01: January...12: December) \n"
    printf "Enter day of month (as two digits - pad with zeros if necessary - i.e. 1 = 01) \n"
    printf "Enter full year \n\n"

    printf "All date sections must be entered in decimal numeric format. This will not\n"
    printf "affect the query results: the program will find full month names and \n"
    printf "abbreviations matching the numeric value of the month selected. IE\n"
    printf "10 = Oct = October\n\n"

    printf "Any date section left null acts as a wild card: the program finds all files\n"
    printf "where that date section matches _any_ value.\n\n"

    printf "Note: entering anything other than a decimal number or an empty Enter\n"
    printf "key press will cause the program to repeat the current date section query\n"
    printf "until a valid value is given. If you wish to exit at this point in the program,\n"
    printf "input Control+C\n\n"
}

verifyValidPrefix() {
    local prefixValue=${1}
    
    #test to see if the passed value matches
    if [ "${prefixValue,,}" = "attendance" ] || [ "${prefixValue,,}" = "list" ] || [ "${prefixValue,,}" = "attendancelist" ] || [ "${prefixValue,,}" = "attendancelog" ]; then
        printf "true"
    else
        printf "false"
    fi
}

verifyValidDate() {
    local monthPart=${1}
    local dayPart=${2}
    local yearPart=${3}

    #test to see if the values passed are not null, and the year isn't over 2037 - date doesn't format or work past Jan 2037
    if [ -n "${monthPart}" ] && [ -n "${dayPart}" ] && [ -n "${yearPart}" ]; then
        if [ ${yearPart} -le 2037 ]; then printf "true"; fi
    else
        printf "false"
    fi
}

verifyValidFileName() {
    local validDate="false"
    local validPrefix="false"
    local prefixValue=${1}
    local monthPart=${2}
    local dayPart=${3}
    local yearPart=${4}
    local readPrefix="${5}"

    #test the prefix and date parts passed
    if [ "${readPrefix}" = "true" ]; then
        validPrefix=$(eval "verifyValidPrefix ${prefixValue}")
    else
        validPrefix="true"
    fi
    validDate=$(eval "verifyValidDate ${monthPart} ${dayPart} ${yearPart}")

    #if both pass the test, file name is valid by our standards
    if [ "${validPrefix}" = "true" ] && [ "${validDate}" = "true" ]; then
        printf "true"
    else
        printf "false"
    fi
}

printTitle() {     #Display function, exists to seperate display concerns from input gathering functions, allows us to move around menus without having to reconfigure input reads
    printf "Date Format Regulator 1.0\n"
}

printAuthor() {     #Display function, exists to seperate display concerns from input gathering functions, allows us to move around menus without having to reconfigure input reads
printf "By Allan Taylor\n"
}

printMenu() {  #Display function, exists to seperate display concerns from input gathering functions, allows us to move around menus without having to reconfigure input reads
    printf "\n"
    printf "System Menu\n"
    printf "________________________________________________________________________________"
    printf "\n\n\n"
    printf "1) Perform file name format correction \n"
    printf "2) Read data files \n"
    printf "3) Change file scan location\n"
    printf "4) View help and usage information\n"
    printf "5) Exit \n\n"
}

normalizeDate() {    #Take the parts fed to it, make a date in YYYYMMDD format
    local oldFileMonth=${1}
    local fileDay=${2}
    local fileYear=${3}

    local newfilePrefix
    local newFileMonth
    local newFileName
    local newDate
    local dateFriendlyString=""
    local matchedDate

    # look for month values, either full month or abbreviations, convert them to numeric months
    if [ "${oldFileMonth,,}" = "january" ] || [ "${oldFileMonth,,}" = "jan" ]; then
        newFileMonth="01"
    elif [ "${oldFileMonth,,}" = "february" ] || [ "${oldFileMonth,,}" = "feb" ]; then
        newFileMonth="02"
    elif [ "${oldFileMonth,,}" = "march" ] || [ "${oldFileMonth,,}" = "mar" ]; then
        newFileMonth="03"
    elif [ "${oldFileMonth,,}" = "april" ] || [ "${oldFileMonth,,}" = "apr" ]; then
        newFileMonth="04"
    elif [ "${oldFileMonth,,}" = "may" ]; then
        newFileMonth="05"
    elif [ "${oldFileMonth,,}" = "june" ] || [ "${oldFileMonth,,}" = "jun" ]; then
        newFileMonth="06"
    elif [ "${oldFileMonth,,}" = "july" ] || [ "${oldFileMonth,,}" = "jul" ]; then
        newFileMonth="07"
    elif [ "${oldFileMonth,,}" = "august" ] || [ "${oldFileMonth,,}" = "aug" ]; then
        newFileMonth="08"
    elif [ "${oldFileMonth,,}" = "september" ] || [ "${oldFileMonth,,}" = "sep" ]; then
        newFileMonth="09"
    elif [ "${oldFileMonth,,}" = "october" ] || [ "${oldFileMonth,,}" = "oct" ]; then
        newFileMonth="10"
    elif [ "${oldFileMonth,,}" = "november" ] || [ "${oldFileMonth,,}" = "nov" ]; then
        newFileMonth="11"
    elif [ "${oldFileMonth,,}" = "december" ] || [ "${oldFileMonth,,}" = "dec" ]; then
        newFileMonth="12"
    else
        newFileMonth="${oldFileMonth}"
    fi

    #Append our new file datevvalues to each other in the desired order, printf to return value
    dateFriendlyString="${fileYear}${newFileMonth}${fileDay}"

    printf "${dateFriendlyString}"
}

fileRename() {    #Create a new date string using the date program and the desired file format
    local dateFriendlyString=${1}
    local customFileFormat="${2}"

    if [ -n "${customFileFormat}" ]; then
        newDate=$(eval date -d ${dateFriendlyString} +"'${customFileFormat}'")
    else
        newDate=$(eval date -d ${dateFriendlyString} +%m_%d_%Y)
    fi

    newFileName="attendancelog_${newDate}.txt"

    printf "${newFileName}"
}

userFileSearchMatch() {    #tells us if date passed is matched by pattern passed to sed - might be more efficient with grep, will test in next update
    local dateFriendlyString=${1}
    local datePatternToFind=${2}

    local matchedDate
    local newDate

     newDate=$(eval date -d ${dateFriendlyString} +%m_%d_%Y)
     matchedDate=$(printf "${newDate}" | sed -En "s/${datePatternToFind}/\1 \2 \3 /p")

     if [ -n "${matchedDate}" ]; then
         echo "true"
     else
         echo "false"
     fi
}

customDateMenu() {    #Display function, exists to seperate display concerns from input gathering functions, allows us to move around menus without having to reconfigure input reads

    printf "Data File Date Format Conversion Mode\n"
    printf "________________________________________________________________________________"
    printf "\n\n\n"

    printf "Choose a date format - all files having recognizable dates in their names will have those dates converted to the format chosen:\n\n"
    printf "a) January 01, 2020\n"
    printf "b) January012020\n"
    printf "c) Jan 01, 2020\n"
    printf "d) Jan012020\n"
    printf "e) 01-01-2020\n"
    printf "f) 01.01.2020\n"
    printf "g) 01012020\n"
    printf "h) 01_01_2020\n\n"

    printf "Enter a letter above, or just press enter for the default format (01_01_2020):"

}

customDateFormatString() {    #Display function, exists to seperate display concerns from input gathering functions, allows us to move around menus without having to reconfigure input reads
    local customSelection=${1}

    if [ "${customSelection}" = "a" ]; then
        echo "%B %d, %Y"
    elif [ "${customSelection}" = "b" ]; then
        echo "%B%d%Y"
    elif [ "${customSelection}" = "c" ]; then
        echo "%b %d, %Y"
    elif [ "${customSelection}" = "d" ]; then
        echo "%b%d%Y"
    elif [ "${customSelection}" = "e" ]; then
        echo "%m-%d-%Y"
    elif [ "${customSelection}" = "f" ]; then
        echo "%m.%d.%Y"
    elif [ "${customSelection}" = "g" ]; then
        echo "%m%d%Y"
    elif [ "${customSelection}" = "h" ]; then
       echo "%m_%d_%Y"
    else
       echo "%m_%d_%Y"
    fi
}



validateMonthInput() {    #Validate that input is 2 digits, and that no one is trying to pass garbage to perform injections
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^1[0-2]$|^0[1-9]$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

validateDayInput() {    #Validate that input is 2 digits, and that no one is trying to pass garbage to perform injections
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^0[1-9]$|^[12][0-9]$|^3[01]$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

validateYearInput() {    #Validate that input is a year, 4 digits, and that no one is trying to pass garbage to perform injections
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^[0-9]{4}$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

validateNumericInput() {    #Validate that input is one number, 0-9, upper or lowercase
local inputValue=${1}

if echo "${inputValue}" | grep -E '^[0-9]{1}$' ; then
    printf "true"
else
    printf "false"
fi
}

validateAlphaInput() {    #Validate that input is one letter, a-z, upper or lowercase
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^[a-zA-Z]{1}$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

verifyExit() {    #exit verification function - operates directly on general variables finalProgramExit and isNotInitialRun: will refactor in update
    local exitValue='n'
    local validInput="false"

    while [ "${validInput}" = "false" ] || [ -z "${exitValue}" ]; do
    printf "Are you sure? (type y to exit) \n"

    read exitValue
    validInput=$(eval validateAlphaInput ${exitValue})
    done

    finalProgramExit="${exitValue,,}"
    if [ "${finalProgramExit}" != "y" ]; then isNotInitialRun="false"; fi
}

fileRenameCycle() {    #Refactored out of scanFile, only detects dates of files and returns valid matches
    local dateFormat
    local dateLocated
    local coreDateData
    local dateComponents
    local customSelection
    local validFileName="false"
    local validInput="false"

    local matchedFileCount=0

    while [ "${validInput}" = "false" ]; do
        customDateMenu
        read customSelection
        validInput=$(eval validateAlphaInput ${customSelection})
    done
    
    dateFormat=$(eval customDateFormatString "${customSelection}")

    for fileName in *
    do        # Run the fileName through sed, get the possible prefix and date parts
        coreDateData=$(printf "${fileName}" | sed -En 's/([\w]*)[._ ]?([Jj]anuary|[Ff]ebruary|[Mm]arch|[Aa]pril|[Mm]ay|[Jj]une|[Jj]uly|[Aa]ugust|[Ss]eptember|[Oo]ctober|[Nn]ovember|[Dd]ecember|[Jj]an|[Ff]eb|[Mm]ar|[Aa]pr|[Jj]un|[Jj]ul|[Aa]ug|[Ss]ep|[Oo]ct|[Nn]ov|[Dd]ec|[0-9]{2})[ _,.-]?([0-9]{2})[ _,.-]?\s?([0-9]{4})[^\.]*/\1 \2 \3 \4 /p')
        read -ra dateComponents <<< $coreDateData        # arrayify the variable we just filled
        validFileName=$(eval "verifyValidFileName ${dateComponents[0]} ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]} 'true'")    # Check against rules for valid file name entries

        if [ "${validFileName}" = "true" ] && [ "${fileName}" != "dateFormatRegulator.sh" ] && [ "${fileName}" != "archivedAttendance" ] && [ "${fileName}" != "badFormatFiles" ]; then        # If here, it is valid
            normalizedDate=$(eval 'normalizeDate  ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]}')    #return date string that we can feed to 'date' program
            correctedFileName=$(eval fileRename  ${normalizedDate} "'${dateFormat}'")    #feed normalizedDate, dateFormat to fileRename to fileRename function
            cp "${fileName}" archivedAttendance
            if [ $? -eq 0 ]; then
                mv -T "${fileName}" "${correctedFileName}" #file rename and standard check for success of rename
                if [ $? -eq 0 ]; then
                    printf "Renamed %s to %s\n" "${fileName}" "${correctedFileName}"
                    matchedFileCount=$((matchedFileCount + 1))
                else
                    printf "Failed to rename %s to %s, continuing to next file\n" "${fileName}" "${correctedFileName}"
                fi
            else
                printf "Failed to copy %s to archivedAttendance, system will not rename uncopyable file - continuing to next file\n" "${fileName}"
            fi
        elif [ "${fileName}" != "dateFormatRegulator.sh" ] && [ "${fileName}" != "archivedAttendance" ] && [ "${fileName}" != "badFormatFiles" ]; then    #Extra test data is to ensure that we don't move the program file or any work folders in the location we are in
            cp "${fileName}" badFormatFiles
            if [ $? -eq 0 ]; then
                rm -f "${fileName}"
            else
                printf "Failed to copy %s to badFormatFiles, system will not delete uncopyable file" "${fileName}"
            fi
        else
            continue
        fi
    done
            
   printf "\n"

    if [ ${matchedFileCount} -eq 0 ]; then  #if here, nothing matched, print message so user knows work was attempted, there was just nothing to work on
        printf "\nNo files having convertable date formats were found\n"
    fi        
}

fileDisplayCycle() {    #Refactored out of scanFile, only changes names of files that match valid file format
    local dateSearchPattern=${1}
    local dateLocated
    local coreDateData
    local dateComponents
    local matchedFileCount=0

    printf "The following files match your date search query:\n\n"

    for fileName in *
    do        # Run the fileName through sed, get the possible prefix and date parts
        coreDateData=$(printf "${fileName}" | sed -En 's/([\w]*)[._ ]?([Jj]anuary|[Ff]ebruary|[Mm]arch|[Aa]pril|[Mm]ay|[Jj]une|[Jj]uly|[Aa]ugust|[Ss]eptember|[Oo]ctober|[Nn]ovember|[Dd]ecember|[Jj]an|[Ff]eb|[Mm]ar|[Aa]pr|[Jj]un|[Jj]ul|[Aa]ug|[Ss]ep|[Oo]ct|[Nn]ov|[Dd]ec|[0-9]{2})[ _,.-]?([0-9]{2})[ _,.-]?\s?([0-9]{4})[^\.]*/\1 \2 \3 \4 /p')
        read -ra dateComponents <<< $coreDateData        # arrayify the variable we just filled
        validFileName=$(eval "verifyValidFileName ${dateComponents[0]} ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]} 'false'")    # Check against rules for valid file name entries
        if [ "${validFileName}" = "true" ]; then        # If here, it is valid
            normalizedDate=$(eval 'normalizeDate  ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]}')    #return date string that we can feed to 'date' program
            dateLocated=$(eval 'userFileSearchMatch ${normalizedDate} "${dateSearchPattern}"')
            if [ "${dateLocated}" = "true" ]; then 
                printf "${fileName}\n"
                matchedFileCount=$((matchedFileCount + 1))
            fi
        else
            continue
        fi
    done

    printf "\n"

    if [ ${matchedFileCount} -eq 0 ]; then  #if here, nothing matched, print message so user knows work was attempted, there was just nothing to work on
        printf "\nNo files having matching date formats were found\n"
    fi
}

searchFilter() {    #function to get input for file search by date, executed when option 2 is selected in the main menu

    #Get month, day, year input, replace each with regular expression piece if it is null
    local inputMonth
    local inputDay
    local inputYear

    local convertedSearchDate=""    #The final search string/regular expression
    local inputValid="false"    #Allows us to test for valid input, loop until the input becomes valid

    printf "Data File Scan Mode\n"
    printf "________________________________________________________________________________"
    printf "\n\n\n"
    

    # 
    while [ "${inputValid}" = "false" ]; do
        printf "Enter month in numeric format (01: January...12: December) \n"
        read inputMonth
        inputValid=$(eval validateMonthInput ${inputMonth})
    done
    inputValid="false"

    
    
    if [ -n "${inputMonth}" ]; then
        convertedSearchDate="(${inputMonth})"
    else
        convertedSearchDate="([0-9]{2})"
    fi 

    while [ "${inputValid}" = "false" ]; do
        printf "Enter day of month (as two digits - pad with zeros if necessary - i.e. 1 = 01) \n"
        read inputDay
        inputValid=$(eval validateDayInput ${inputDay})
    done
    inputValid="false"

    if [ -n "${inputDay}" ]; then
        convertedSearchDate="${convertedSearchDate}_(${inputDay})"
    else
        convertedSearchDate="${convertedSearchDate}_([0-9]{2})"
    fi 

    while [ "${inputValid}" = "false" ]; do
        printf "Enter full year \n"
        read inputYear
        inputValid=$(eval validateYearInput ${inputYear})
    done

    if [ -n "${inputYear}" ]; then
        convertedSearchDate="${convertedSearchDate}_(${inputYear})"
    else
        convertedSearchDate="${convertedSearchDate}_([0-9]{4})"
    fi
    fileDisplayCycle "${convertedSearchDate}"
}

setupPrompt() {
    local currentDirectory=$(pwd)
    printf "\n\nInput location of attendance files\n"

    printf "Press enter to scan default location (currently %s):" "${currentDirectory}"
}

setupDirectory() {    #Specifically ask the user for the desired directory, notify of current direction
    local targetDirectory
    local currentDirectory=$(pwd)

    read targetDirectory

    if [ -z "${targetDirectory}" ]; then
        mkdir archivedAttendance
        mkdir badFormatFiles
    else
        cd ${targetDirectory}
        currentDirectory=$(pwd)
        if [ "${currentDirectory}" != "${targetDirectory}" ]; then    #Test for successful directory change, print error and exit on failure
            printf "Unable to locate desired target directory.\n"
            printf "Ensure target directories and files exist before performing file name conversions.\n"
            printf "Exiting program.\n"
            exit
        fi 
        mkdir archivedAttendance
        mkdir badFormatFiles
    fi
}

setupRoutine() {

    setupPrompt
    setupDirectory
}


### End function definitions ###


### Begin main program execution ###
clear



while getopts ":h:" opt    #scan options and arguments passed to the program
do
    case "${opt}" in
        h )
            helpSelection="${OPTARG}"    #Get helpSelection value from passed argument
            ;;
        : )
            helpOverview    #Passed with just -h, print general help overview, exit
            exit
            ;;
        \? ) 
            printf "Invalid option, use dateFormatRegulator.sh -h to find acceptable\n"    #Bad option passed, give error message, exit
            printf "options and arguments.\n"
            printf "Exiting program\n\n"
            exit
            ;;
    esac
done

if [ -n "${helpSelection}" ]; then    #All of the below only applies if something is in helpSelection. If it's empty, no need to print help messages or errors about such, continue on
    #Print one of the help menus based on the value passed to helpSelection
    if [ "${helpSelection}" = "mainmenu" ]; then
        helpMainMenu
        exit
    elif [ "${helpSelection}" = "initialsetup" ] || [ "${helpSelection}" = "scanlocation" ]; then
        helpInitialSetup
        exit
    elif [ "${helpSelection}" = "dateconversion" ]; then
        helpDateConversion
        exit
    elif [ "${helpSelection}" = "datesearch" ]; then
        helpDateSearch
        exit
    else
        printf "Invalid argument, use dateFormatRegulator.sh -h to find acceptable\n"    #Bad argument passed, give error message, exit
        printf "options and arguments.\n"
        printf "Exiting program\n\n"
    fi
fi

#First run through, print the title, author, initial data gathering prompt
printTitle
printAuthor
setupRoutine
clear    #clear the screen, the previous functions print menus that we want cleared going to the next execution stage

finalProgramExit='n' #Setup for program loop below

#While we haven't said yes to finalProgramExit
while [ ${finalProgramExit} != 'y' ]; do
    printTitle    #Print the title screen
    printMenu    #Print the general menu screen



    while [ "${generalInputValid}" = "false" ]; do    #Loop until we don't get garbage anymore
        if [ "${isNotInitialRun}" = "true" ]; then    #If here, we have run the program loop through at least once, print the appropriate message
            printf "\nWould you like to continue? Press 5 to quit, or any other key to continue: \n"
        else    #if here, we haven't run the program loop through at least once yet, print the appropriate message
            printf "\nPress 5 to quit, or any other key to continue:\n"
        fi
        read menuInput
        generalInputValid=$(eval validateNumericInput ${menuInput})    #Verifies that our input is acceptable, not garbage
    done
    generalInputValid="false"    #Set this variable to false, we will be using it again in the program

    #In all of the below options, the screen is cleared, and printTitle executed to maintain visual continuity between menu and execution screens
    if [ ${menuInput} -eq 1 ]; then
        clear
        printTitle
        fileRenameCycle    #If here, we are doing a file rename
    elif [ ${menuInput} -eq 2 ]; then
        clear
        printTitle
        searchFilter    #If here, we are going to do a file date search, go into searchFilter to get the date data
    elif [ ${menuInput} -eq 3 ]; then
        clear
        printTitle
        setupRoutine    #If here, we are going to change the location we are working in
    elif [ ${menuInput} -eq 4 ]; then
        clear
        helpOverview
    elif [ ${menuInput} -eq 5 ]; then
        clear
        printTitle
        verifyExit    #If here, we are going to exit, verify exit
    elif [ ${menuInput} -eq 0 ]; then
        clear
        exit    #If here, exit immediately (used for debugging purposes)
    else
        continue    #If here, it's not one of the above, continue the loop
    fi
    isNotInitialRun="true"    #We've run through the loop at least once, mark the variable accordingly for conditional statements above
done

### End main program execution ###
