#!/bin/bash

## 20220118 This analysis script will take a dataset as long as desired, and
## render the amount of fields, records, and other relevant data to be found in it

LOCALE=$1
DEST_FOLDER=$2
SETUP_FOLDER=$3
SETUP_FILE=$4

COURSE_FOLDER="course"
LOCALE_FOLDER=${LOCALE}
CURRENT_FOLDER="${COURSE_FOLDER}/${LOCALE_FOLDER}"
SRC_FOLDER="src"
IMG_FOLDER="img"

DATA_FILE="${SETUP_FOLDER}/${COURSE_FOLDER}/exercises/${LOCALE_FOLDER}/${SETUP_FILE}"

SEPARATOR='¤'

DATA_TYPES=("text","html","image","code","video","license")

HEADER_DONE=0
FIELDS=0
RECORDS=0
RECORDS_ACTIVE=0
IMAGE_BLOCKS=0
IMAGE_BLOCKS_LOCAL=0
CODE_BLOCKS=0
TEXT_BLOCKS=0
VIDEO_BLOCKS=0
LICENSE_BLOCKS=0

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## XXX: Run a check on the data file: how many exercises, how many fields, total images,
## total code blocks, types of code detected, etc

## Read all fields in a record as an array, count the total amount of records

## Iterate through the records and count fields and types of fields

## Report back to CLI

## Init arrays
declare -a CONFIG_KEYS=()
declare -a CONFIG_VALUES=()
declare -a REPORT_FOLDERS=()
declare -a CODE_BLOCKS_TYPES=()

## Check the different folders to be used
[ ! -d "${DEST_FOLDER}" ] && REPORT_FOLDERS+=("The destination folder ${DEST_FOLDER} doesn't exist")
[ ! -d "${SETUP_FOLDER}" ] && REPORT_FOLDERS+=("The configuration folder ${SETUP_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${COURSE_FOLDER}" ] && REPORT_FOLDERS+=("The course folder ${COURSE_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${CURRENT_FOLDER}" ] && REPORT_FOLDERS+=("The locale's course folder ${CURRENT_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${IMG_FOLDER}" ] && REPORT_FOLDERS+=("The image folder ${IMG_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${SRC_FOLDER}" ] && REPORT_FOLDERS+=("The source code folder ${SRC_FOLDER} doesn't exist")

## Read all fields in a record as an array
while read -ra array; do

    ## Collect the data from the header records 
    ## Extract the keys from the header
    if [[ "$HEADER_DONE" -eq 0 ]]; then
        
        echo -e "Collect keys"
        
        for i in "${!array[@]}"
        do :         
            CONFIG_KEYS+=(${array[$i]})
            let FIELDS++
        done
        
        HEADER_DONE=$HEADER_DONE+1
        
        ## Exit the while here
        continue
    fi

    ## Extract the values from the header
    if [[ "$HEADER_DONE" -eq 1 ]]; then
        
        echo -e "Collect values"
        
        for i in "${!array[@]}"
        do :         
            CONFIG_VALUES+=(${array[$i]})
        done
        
        HEADER_DONE=$HEADER_DONE+1
        
        ## Exit the while here
        continue
    fi

    ## Work out the actual contents
    ## Fixed positions are NUMBER | NAME | INDEX with locations 0 | 1 | 2
    if [[ "$HEADER_DONE" -gt 1 ]]; then
    
        let RECORDS++
        
        for i in "${!array[@]}"
        do :         
            ## Fix the leading zeros in the number variable
            if [ "$i" -eq 0 ]; then
                number=$(printf "%02d" ${array[$i]})
            fi
            
            ## Extract the name (in the original file was "file"
            if [ "$i" -eq 1 ]; then
                name=${array[$i]}

                ## Notify what is going on
                echo -e   "+ Analysing record number: $number, name: $name"

            fi

            ## Go for the whole rest of the fields, which are always structured as:
            ## FIELD_CONTENT | FIELD_PROPERTIES
            if [ "$i" -gt 3 ]; then
            
                ## Collect the data in pairs, operate only when $i is even
                (( i % 2 )) && FIELD_CONTENT="${array[$i]}"
                (( (i % 2) - 1 )) && FIELD_PROPERTIES="${array[$i]}"
                
                ## Evaluate properties, if it is code, video, images, etc it requires
                ## specific rendering tricks. Therefore, there is still a lot to do here
                if [ $((i % 2)) == 0 ]; then
                    ##echo -e "* Working with: ${CONFIG_KEYS[$i-1]}, value: ${CONFIG_VALUES[$i-1]}, content: ${FIELD_CONTENT}, properties: ${FIELD_PROPERTIES}"
                        
                    ## Extract the properties array
                    readarray -td, PROPERTIES < <(printf '%s' "$FIELD_PROPERTIES"); declare -p PROPERTIES &>/dev/null;

                    if [[ "${PROPERTIES[0]}" == "true" ]]; then
                        let RECORDS_ACTIVE++
                    fi
                    
                    if [[ $FIELD_CONTENT != "" ||  "${PROPERTIES[0]}" == "true" ]]; then
                        ## echo -e ${PROPERTIES[0]}
                        if [[ "${PROPERTIES[0]}" == "true" ]]; then
                        
                            ## Prepare content to be rendered (note, order matters!!)
                            ## Read the data by default, we'll modify it later
                            CONTENT=${FIELD_CONTENT}
                            if [[ "${PROPERTIES[1]}" == "text" ]]; then  
                                let TEXT_BLOCKS++                      
                            fi
                            if [[ "${PROPERTIES[1]}" == "video" ]]; then  
                                let VIDEO_BLOCKS++                      
                            fi
                            if [[ "${PROPERTIES[1]}" == "license" ]]; then  
                                let LICENSE_BLOCKS++                      
                            fi
                            if [[ "${PROPERTIES[1]}" == "image" ]]; then  
                                let IMAGE_BLOCKS++                      

                                ## Create the local folder for images, only if there is 
                                ## going to be an image and doesn't exist, yet
	                            [[ "${PROPERTIES[2]}" == "local" ]] && let IMAGE_BLOCKS_LOCAL++;
                            fi
                            if [[ "${PROPERTIES[1]}" == "code" ]]; then    
                                let CODE_BLOCKS++
                                   
                                ## Add the value to the array only if it doesn't exist yet
                                if [[ ! " ${CODE_BLOCKS_TYPES[*]} " =~ " ${PROPERTIES[3]} " ]]; then
                                    CODE_BLOCKS_TYPES+=(${PROPERTIES[3]})

                                    ## Check if there is a template for this type of code
	                                [ ! -d "${SRC_FOLDER}/${PROPERTIES[3]}" ] && REPORT_FOLDERS+=("The source folder ${SRC_FOLDER}/${PROPERTIES[3]} doesn't exist");
	                                if [ ! -f "${SETUP_FOLDER}/templates/code/template.${PROPERTIES[3]}" ]; then
                                        REPORT_FOLDERS+=("** Error** There is no template for the ${PROPERTIES[3]} code type.")
                                    fi
                                fi
                                                            
                            fi                            
                        fi
                    fi                    
                fi
                
            fi
 
        done

        ## Exit the while here
        continue
    fi
    
done < $DATA_FILE

IFS=$OFS

echo -e "\n** SUMMARY **"
echo -e "* Fields in the dataset: ${FIELDS}"
echo -e "* List of fields:"
printf '  %s ' "${CONFIG_KEYS[@]}"
echo -e "\n* Records (wo headers): ${RECORDS}"
echo -e "* Records (active): ${RECORDS_ACTIVE}"
echo -e "* Blocks of text: ${TEXT_BLOCKS}"
echo -e "* Blocks of images: ${IMAGE_BLOCKS}"
echo -e "* Local images: ${IMAGE_BLOCKS_LOCAL}"
echo -e "* Blocks of video: ${VIDEO_BLOCKS}"
echo -e "* Blocks of license: ${LICENSE_BLOCKS}"
echo -e "* Blocks of code: ${CODE_BLOCKS}"
echo -e "* Types of code:"
printf '  %s ' "${CODE_BLOCKS_TYPES[@]}"
echo -e "\n* Folders' analysis:"
printf '  %s\n' "${REPORT_FOLDERS[@]}"
echo -e "** Done"
