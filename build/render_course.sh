#!/bin/bash

## 20220111 This creation script will use a dataset as long as desired, the
## working mechanism consist of two parts: the fixed data (NAME + INDEX), and
## the variable one (the rest). The second part will be handled systematically
## until the end of the record (each line in the dataset

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


INDEX_FILE="${CURRENT_FOLDER}/course_index.md"
INDEX_LINK="..\/course_index.md"

VIDEO_EMBED_PREFIX='<iframe src="'
VIDEO_EMBED_SUFFIX='" width="640" height="564" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>'

HEADER_DONE=0

LICENSE_EMBED='<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.\n\n*2021, 2022 D. Cuartielles for Malmo University, Sweden*'

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## Create the folder for the destination if it doesn't exist
[ ! -d "${DEST_FOLDER}" ] && mkdir ${DEST_FOLDER}

## Copy the config folder to the destination to ease the work
cp -R ${SETUP_FOLDER} ${DEST_FOLDER}

## Work from the destination folder
cd ${DEST_FOLDER}

## Create the other folders
[ ! -d "${SRC_FOLDER}" ] && mkdir "${SRC_FOLDER}"
[ ! -d "${COURSE_FOLDER}" ] && mkdir "${COURSE_FOLDER}"
[ ! -d "${CURRENT_FOLDER}" ] && mkdir "${CURRENT_FOLDER}"
[ ! -d "${IMG_FOLDER}" ] && mkdir "${IMG_FOLDER}"

## Init arrays
declare -a CONFIG_KEYS=()
declare -a CONFIG_VALUES=()

## Read all fields in a record as an array
while read -ra array; do

    ## Collect the data from the header records 
    ## Extract the keys from the header
    if [[ "$HEADER_DONE" -eq 0 ]]; then
        
        echo -e "Collect keys"
        
        for i in "${!array[@]}"
        do :         
            CONFIG_KEYS+=(${array[$i]})
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
                echo -e "\n****************************************"
                echo -e   " Working out example $name"
                echo -e   "****************************************\n"

                ## Fix the filename
	            filename="$number-$name"
               
                ## Work out the local folder for images
	            [ ! -d "${IMG_FOLDER}/$filename" ] && mkdir "${IMG_FOLDER}/$filename";

                ## Work out the code for the example
                ## So far, code has no localisation features, thus no use of the locale folder here
                ## TODO: enhance this to allow multiple types of code
	            [ ! -d "${SRC_FOLDER}/$filename" ] && mkdir "${SRC_FOLDER}/$filename";
	            if [ -f "${SRC_FOLDER}/${filename}/${filename}.ino" ]; then
                    echo "${SRC_FOLDER}/${filename}/${filename}.ino exists. Changing properties."
                else 
                    echo "${SRC_FOLDER}/${filename}/${filename}.ino does not exist. Creating it."

                	cp "${SETUP_FOLDER}/templates/code/template.ino" "${SRC_FOLDER}/${filename}/${filename}.ino";
                fi
                
                ## Fix the code's title
	            TITLE_TEMP="${filename//-/: }"
	            TITLE="${TITLE_TEMP//_/ }"
	            sed -i "s/\[NAME\]/Exercise $TITLE/" "${SRC_FOLDER}/${filename}/${filename}.ino"

                ## Work out the text for the example
	            [ ! -d "${CURRENT_FOLDER}/$filename" ] && mkdir "${CURRENT_FOLDER}/$filename";
	            if [ -f "${CURRENT_FOLDER}/${filename}/${filename}.md" ]; then
                    echo "${CURRENT_FOLDER}/${filename}/${filename}.md exists. Changing properties."
                else 
                    echo "${CURRENT_FOLDER}/${filename}/${filename}.md does not exist. Creating it."

                	cp "${SETUP_FOLDER}/templates/exercises/${LOCALE_FOLDER}/template.md" "${CURRENT_FOLDER}/${filename}/${filename}.md";
                fi

                ## Fix title
                if grep -Fq "[NAME]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                then
	                TITLE_TEMP="${filename//-/: }"
	                TITLE="${TITLE_TEMP//_/ }"
	                sed -i "s/\[NAME\]/Exercise $TITLE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                else
                    echo "Code [NAME] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                fi
            fi

            ## Go for the whole rest of the fields, which are always structured as:
            ## FIELD_CONTENT | FIELD_PROPERTIES
            if [ "$i" -gt 3 ]; then
            
                ## Collect the data in pairs, operate only when $i is even
                (( i % 2 )) && FIELD_CONTENT="${array[$i]}"
                (( (i % 2) - 1 )) && FIELD_PROPERTIES="${array[$i]}"
                
                ## TODO: evaluate properties, if it is code, video, images, etc it requires
                ##       specific rendering tricks. Therefore, there is still a lot to do here
                if [ $((i % 2)) == 0 ]; then
                    if [[ $FIELD_CONTENT != "" ]]; then
                        echo -e "* Working with: ${CONFIG_KEYS[$i-1]}, value: ${CONFIG_VALUES[$i-1]}, content: ${FIELD_CONTENT}, properties: ${FIELD_PROPERTIES}"
                        if [[ $FIELD_PROPERTIES == true ]]; then
                            if grep -Fq "[${CONFIG_KEYS[$i-1]}]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                            then
                            	CONTENT="${FIELD_CONTENT//$'\/'/\\\/}"
                            	CONTENT="${CONTENT//\//\\\/}" 
	                            sed -i "s/\[${CONFIG_KEYS[$i-1]}\]/$CONTENT/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                            else
                                echo "Code [${CONFIG_KEYS[$i-1]}] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                            fi
                        fi
                    else
                        echo -e "No ${CONFIG_KEYS[$i-1]} in this record, removing it from template"
                        sed -i "s/\[${CONFIG_KEYS[$i-1]}\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                        sed -i "s/${CONFIG_VALUES[$i-1]}//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

                    fi                    
                fi
                
            fi
 
        done

        ## Clean double EOLs created by removing fields from the template
        sed -i '$!N; /^\(.*\)\n\1$/!P; D' "${CURRENT_FOLDER}/${filename}/${filename}.md"
                
        ## Exit the while here
        continue
    fi
    
done < $DATA_FILE

## TODO: lacks the whole index generation work in here
## Create index file
echo "# Course Index" > $INDEX_FILE 

## Reset the header check
HEADER_DONE=0

## Use index file 
echo -e "** CREATE INDEX ** \n$INDEX_FILE"

## Add links to all articles
while read -ra array; do

    ## Remove headers 
    if [[ "$HEADER_DONE" -lt 2 ]]; then
        HEADER_DONE=$HEADER_DONE+1
        continue
    fi

    ## fix the leading zeros in the number variable
    number=$(printf "%02d" ${array[0]})

    ## set the filename
    filename="$number-${array[1]}"

    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $filename"
    echo -e   "****************************************\n"

    ## Append text at the end of the file
    echo "* [${filename}](${filename}/${filename}.md)" >> $INDEX_FILE
    
done < $DATA_FILE

## Generate bottom links in content files
PREVIOUS_LINK=""
CURRENT_LINK=""
FOLLOWING_LINK=""
PREVIOUS_FILE=""
CURRENT_FILE=""
FOLLOWING_FILE=""

## Reset the header check
HEADER_DONE=0

## Read all fields in a record as an array
while read -ra array; do

    ## Remove headers 
    if [[ "$HEADER_DONE" -lt 2 ]]; then
        HEADER_DONE=$HEADER_DONE+1
        continue
    fi

    ## fix the leading zeros in the number variable
    number=$(printf "%02d" ${array[0]})

    ## set the filename
    filename="$number-${array[1]}"

    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $filename"
    echo -e   "****************************************\n"

    ## Set following file
    FOLLOWING_LINK="..\/${filename}\/${filename}.md"
    FOLLOWING_FILE="${CURRENT_FOLDER}/${filename}/${filename}.md"

    ## Usual case: we have current and following links not empty
    if [[ $CURRENT_LINK != "" ]]
    then
        if grep -Fq "[FOLLOWINGARTICLE]" "${CURRENT_FILE}"
        then
            echo -e "processing following link"
            sed -i "s/\[FOLLOWINGARTICLE\]/\[Next\]\(${FOLLOWING_LINK}\)/" "${CURRENT_FILE}"
        else
            echo "Code [FOLLOWINGARTICLE] not found in ${CURRENT_FILE}"
        fi
        
        if grep -Fq "[PREVIOUSARTICLE]" "${CURRENT_FILE}"
        then
            echo -e "processing previous link"
            if [[ $PREVIOUS_LINK != "" ]]
            then
	            sed -i "s/\[PREVIOUSARTICLE\]/\[Prev\]\(${PREVIOUS_LINK}\) \| /" "${CURRENT_FILE}"
	        else
	            sed -i "s/\[PREVIOUSARTICLE\]//" "${CURRENT_FILE}"
	        fi
        else
            echo "Code [PREVIOUSARTICLE] not found in ${CURRENT_FILE}"
        fi
        
        if grep -Fq "[INDEX]" "${CURRENT_FILE}"
        then
            echo -e "processing index link"
            sed -i "s/\[INDEX\]/\[Index\]\(${INDEX_LINK}\) \| /" "${CURRENT_FILE}"
        else
            echo "Code [INDEX] not found in ${CURRENT_FILE}"
        fi
         
    fi
 
    ## Move the links to the next batch   
    PREVIOUS_LINK=$CURRENT_LINK
    CURRENT_LINK=$FOLLOWING_LINK
    PREVIOUS_FILE=$CURRENT_FILE
    CURRENT_FILE=$FOLLOWING_FILE

done < $DATA_FILE

## Closing edge case: If the links are the same, and not
## empty, we are at the end of the list of files, therefore 
## issue no following link
if [[ $CURRENT_LINK != "" ]]
then
    if grep -Fq "[FOLLOWINGARTICLE]" "${CURRENT_FILE}"
    then
        sed -i "s/\[FOLLOWINGARTICLE\]//" "${CURRENT_FILE}"
    else
        echo "Code [FOLLOWINGARTICLE] not found in ${CURRENT_FILE}"
    fi

    if grep -Fq "[PREVIOUSARTICLE]" "${CURRENT_FILE}"
    then
        sed -i "s/\[PREVIOUSARTICLE\]/\[Prev\]\(${PREVIOUS_LINK}\) \| /" "${CURRENT_FILE}"
    else
        echo "Code [PREVIOUSARTICLE] not found in ${CURRENT_FILE}"
    fi
    
    if grep -Fq "[INDEX]" "${CURRENT_FILE}"
    then
        sed -i "s/\[INDEX\]/\[Index\]\(${INDEX_LINK}\)/" "${CURRENT_FILE}"
    else
        echo "Code [INDEX] not found in ${CURRENT_FILE}"
    fi    
fi

## Delete the config folder
rm -fR ${SETUP_FOLDER}

## Return to where you were before
cd ..

IFS=$OFS