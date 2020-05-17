# bash_repository
repository of bash scripts for my repository

General usage:

dateFormatRegulator.sh [-h] (mainmenu | initialsetup | dateconversion | datesearch)

Inputs:

text files, labeled in one of the following formats:

[attendanceprefix][date]

where attendance prefix is one of the following:
attendancelist
attendance
list

and date is in one of the following formats

January-1-2020
January-01-2020
January_1_2020
January_01_2020
Jan-1-2020
Jan-01-2020
Jan_1_2020
Jan_01_2020
01-01-2020
01_01_2020
01.01.2020
01012020


Setup:
when dateFormatRegulator is run, the desired directory should be entered in the initial setup screen prompt. If for some reason the user is unwilling or unable to enter the directory information in the initial setup screen, the program should be placed in the same directory as the date files to be scanned and/or modified.