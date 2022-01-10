#!/bin/bash

## 20220110 creates the exercise file for a locale
## uses a CSV file as the point of departure and creates a set of 
## exercise files in as many languages as records in the file

## Parameters
DEST_FOLDER=$1
SETUP_FOLDER=$2
SETUP_FILE=$3

SEPARATOR='¤'

DATA_FILE="${SETUP_FOLDER}/${SETUP_FILE}"

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## Create the folder for the exercises if it doesn't exist
[ ! -d "${DEST_FOLDER}" ] && mkdir ${DEST_FOLDER}
[ ! -d "${DEST_FOLDER}/course" ] && mkdir "${DEST_FOLDER}/course"
[ ! -d "${DEST_FOLDER}/course/exercises" ] && mkdir "${DEST_FOLDER}/course/exercises"

## Read all fields in a record as an array
while read -ra array; do

    ## Create the folder for the locale, which is the first field
    mkdir "${DEST_FOLDER}/course/exercises/${array[0]}"
    
    ## Create the exercises file
    echo -e "** CREATE EXERCISE FILE FOR LOCALE: ${array[0]} ** \n"
    EXERCISES_FILE="${DEST_FOLDER}/course/exercises/${array[0]}/exercises.csv"
    ##echo "" > $TEMPLATE_FILE 
    
    TEXT_LINE=""
    VALUE_LINE=""
    
    for i in "${!array[@]}"
    do :      
        ## Take the chance to create the file when reading a new locale
        if [ "$i" -eq 0 ]; then
            echo "" > $EXERCISES_FILE
        fi

        ## The first field contains the name
        ## TODO: This is hardcoded, should be fixed later to take NAME from "# [NAME]"
        if [ "$i" -eq 1 ]; then
            TEXT_LINE="NUMBER${SEPARATOR}NAME${SEPARATOR}"
            VALUE_LINE="${SEPARATOR}${SEPARATOR}"
        fi

        ## The second field contains the title to the index
        if [ "$i" -eq 2 ]; then
            TEXT_LINE="${TEXT_LINE}INDEX${SEPARATOR}"
            VALUE_LINE="${VALUE_LINE}${array[$i]}${SEPARATOR}"
        fi

        ## The even lines are values, the odd ones are field names
        ## We add boolean fields for all fields, by default we activate them to true   
        if [ "$i" -gt 3 ]; then
            ## Remove []
            INSERT="${array[$i]//\[/}"
            INSERT="${INSERT//\]/}"
            
            ## Concatenate strings
            (( i % 2 )) && TEXT_LINE="${TEXT_LINE}${INSERT}${SEPARATOR}has${INSERT}${SEPARATOR}"
            (( (i % 2) - 1 )) && VALUE_LINE="${VALUE_LINE}${array[$i]}${SEPARATOR}true${SEPARATOR}"
        fi
        
    done
    
    ## Print out the two lines
    echo "${TEXT_LINE}" >> $EXERCISES_FILE
    echo "${VALUE_LINE}" >> $EXERCISES_FILE

done < $DATA_FILE

## Done
echo -e "** Done generating exercise files"
