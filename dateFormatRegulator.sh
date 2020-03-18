#!/bin/bash

# dateFormatConverter.sh
# By Allan Taylor
# 03/18/2020
#
#v1.0
#
# Usage: To scan and convert the names of files in a given directory containing various date formats
#  to a single consistent format

### General program area variable definition - these variables are used in the main program after the function definitions
validFileName="false"
isNotInitialRun="false"
generalInputValid="false"
correctedFileName=""
dateFormat=""
normalizedDate=""
menuInput=0
helpSelection=""


### Begin function definitions ###

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
    printf "4) Exit \n\n"

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
    if [ "${prefixValue,,}" = "attendance" ] || [ "${prefixValue,,}" = "list" ] || [ "${prefixValue,,}" = "attendancelist" ]; then
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

    #test the prefix and date parts passed
    validPrefix=$(eval "verifyValidPrefix ${prefixValue}")
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
    printf "4) Exit \n\n"
}

verifyExit() {    #exit verification function - operates directly on general variables finalProgramExit and isNotInitialRun: will refactor in update
    local exitValue='n'

    printf "Are you sure? (type y to exit) \n"

    read exitValue
    finalProgramExit=$exitValue
    if [ "${exitValue}" != "y" ]; then isNotInitialRun="false"; fi
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

    newFileName="attendance_${newDate}"

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
        echo "%b%d%Y"
    elif [ "${customSelection}" = "h" ]; then
       echo "%b_%d_%Y"
    else
       echo "%b_%d_%Y"
    fi
}



validateDayMonthInput() {
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^[0-9]{2}$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

validateYearInput() {
local inputValue=${1}

if echo "${inputValue}" | grep -E '(^[0-9]{4}$)|(^$)' ; then
    printf "true"
else
    printf "false"
fi
}

validateNumericInput() {
local inputValue=${1}

if echo "${inputValue}" | grep -E '^[0-9]{1}$' ; then
    printf "true"
else
    printf "false"
fi
}

validateAlphaInput() {
local inputValue=${1}

if echo "${inputValue}" | grep -E '^[a-zA-Z]{1}$' ; then
    printf "true"
else
    printf "false"
fi
}


scanFile() {
    local dateSearchMode=${1}
    local dateSearchPattern=${2}
    local customSelection
    local validInput="false"

    local matchedFileCount=0

    clear
    if [ "${dateSearchMode}" ]; then 
        printf "The following files match your date search query:\n\n"
   else
        while [ "${validInput}" = "false" ]; do
            customDateMenu
            read customSelection
            validInput=$(eval validateAlphaInput ${customSelection})
        done
        dateFormat=$(eval customDateFormatString "${customSelection}")
   fi

    for fileName in *
    do        # Run the fileName through sed, get the possible prefix and date parts
        coreDateData=$(printf "${fileName}" | sed -En 's/([\w]*)[._ ]?([Jj]anuary|[Ff]ebruary|[Mm]arch|[Aa]pril|[Mm]ay|[Jj]une|[Jj]uly|[Aa]ugust|[Ss]eptember|[Oo]ctober|[Nn]ovember|[Dd]ecember|[Jj]an|[Ff]eb|[Mm]ar|[Aa]pr|[Jj]un|[Jj]ul|[Aa]ug|[Ss]ep|[Oo]ct|[Nn]ov|[Dd]ec|[0-9]{2})[ _,.-]?([0-9]{2})[ _,.-]?\s?([0-9]{4})[^\.]*/\1 \2 \3 \4 /p')
        read -ra dateComponents <<< $coreDateData        # arrayify the variable we just filled
        validFileName=$(eval "verifyValidFileName ${dateComponents[0]} ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]}")    # Check against rules for valid file name entries
        if [ "${validFileName}" = "true" ]; then        # If here, it is valid
            normalizedDate=$(eval 'normalizeDate  ${dateComponents[1]} ${dateComponents[2]} ${dateComponents[3]}')    #return date string that we can feed to 'date' program
             
            if [ -z "${dateSearchMode}" ]; then    #if nothing in dateSearchMode, we are doing file renames
                correctedFileName=$(eval fileRename  ${normalizedDate} "'${dateFormat}'")    #feed normalizedDate, dateFormat to fileRename to fileRename function
                mv -T "${fileName}" "${correctedFileName}" #file rename and standard check for success of rename
                if [ $? -eq 0 ]; then
                    printf "Renamed %s to %s\n" "${fileName}" "${correctedFileName}"
                    matchedFileCount=$((matchedFileCount + 1))
                else
                    printf "Failed to rename %s to %s, continuing to next file\n" "${fileName}" "${correctedFileName}"
                fi
            else
               dateLocated=$(eval 'userFileSearchMatch ${normalizedDate} "${dateSearchPattern}"')
                if [ "${dateLocated}" = "true" ]; then 
                    printf "${fileName}\n"
                    matchedFileCount=$((matchedFileCount + 1))
                fi
            fi
        else
            continue
        fi
    done

    if [ ${matchedFileCount} -eq 0 ]; then  #if here, nothing matched, print message so user knows work was attempted, there was just nothing to work on
        if [ -z "${dateSearchMode}" ]; then
            printf "\nNo files having convertable date formats were found\n"
        else
            printf "\nNo files having matching date formats were found\n"
        fi
    else
        printf "\n"
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
    
    while [ "${inputValid}" = "false" ]; do
        printf "Enter month in numeric format (01: January...12: December) \n"
        read inputMonth
        inputValid=$(eval validateDayMonthInput ${inputMonth})
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
        inputValid=$(eval validateDayMonthInput ${inputDay})
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
    scanFile "d" "${convertedSearchDate}"
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
        :
    else
        cd ${targetDirectory}
        currentDirectory=$(pwd)
        if [ "${currentDirectory}" != "${targetDirectory}" ]; then    #Test for successful directory change, print error and exit on failure
            printf "Unable to locate desired target directory.\n"
            printf "Ensure target directories and files exist before performing file name conversions.\n"
            printf "Exiting program.\n"
            exit
        fi 
    fi
}

setupRoutine() {

    setupPrompt
    setupDirectory
}


### End function definitions ###


### Begin main program execution ###
clear



while getopts ":h:" opt
do
    case "${opt}" in
        h )
            helpSelection="${OPTARG}"
            ;;
        : )
            helpOverview
            exit
            ;;
        \? ) 
            printf "Invalid option, use dateFormatRegulator.sh -h to find acceptable\n"
            printf "options and arguments.\n"
            printf "Exiting program\n\n"
            exit
            ;;
    esac
done

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
fi

printTitle
printAuthor
setupRoutine
clear

finalProgramExit='n'

while [ ${finalProgramExit} != 'y' ]; do
    printTitle
    printMenu



    while [ "${generalInputValid}" = "false" ]; do
        if [ "${isNotInitialRun}" = "true" ]; then
            printf "\nWould you like to continue? Press 4 to quit, or any other key to continue: \n"
        else
            printf "\nPress 4 to quit, or any other key to continue:\n"
        fi
        read menuInput
        generalInputValid=$(eval validateNumericInput ${menuInput})
    done
    generalInputValid="false"

    if [ ${menuInput} -eq 1 ]; then
        clear
        printTitle
        scanFile "" ""
    elif [ ${menuInput} -eq 2 ]; then
        clear
        printTitle
        searchFilter
    elif [ ${menuInput} -eq 3 ]; then
        clear
        printTitle
        setupRoutine
    elif [ ${menuInput} -eq 4 ]; then
        clear
        printTitle
        verifyExit
    elif [ ${menuInput} -eq 0 ]; then
        clear
        exit
    else
        continue
    fi
    isNotInitialRun="true"
#    clear
done

### End main program execution ###