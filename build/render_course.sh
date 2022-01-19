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

DATA_TYPES=("text","html","image","code","video","license")

VIDEO_EMBED_PREFIX='<iframe src="'
VIDEO_EMBED_SUFFIX='" width="640" height="564" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>'

HEADER_DONE=0

LICENSE_EMBED='<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.\n\n*2021, 2022 D. Cuartielles for Malmo University, Sweden*'

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=$SEPARATOR

## XXX: Run a check on the data file: how many exercises, how many fields, total images,
## total code blocks, types of code detected, etc

## Read all fields in a record as an array, count the total amount of records

## Iterate through the records and count fields and types of fields

## Report back to CLI

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
            
            ## Extract the name (in the original file was "file")
            if [ "$i" -eq 1 ]; then
                name=${array[$i]}

                ## Notify what is going on
                echo -e "\n****************************************"
                echo -e   " Working out example $name"
                echo -e   "****************************************\n"

                ## Fix the filename
	            filename="$number-$name"
               
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
                
                ## Evaluate properties, if it is code, video, images, etc it requires
                ## specific rendering tricks. Therefore, there is still a lot to do here
                if [ $((i % 2)) == 0 ]; then
                    echo -e "* Working with: ${CONFIG_KEYS[$i-1]}, value: ${CONFIG_VALUES[$i-1]}, content: ${FIELD_CONTENT}, properties: ${FIELD_PROPERTIES}"
                        
                    ## Extract the properties array in a silent fashion
                    readarray -td, PROPERTIES < <(printf '%s' "$FIELD_PROPERTIES"); declare -p PROPERTIES &>/dev/null;
                    
                    if [[ $FIELD_CONTENT != "" ||  "${PROPERTIES[0]}" == "true" ]]; then
                        ## echo -e ${PROPERTIES[0]}
                        if [[ "${PROPERTIES[0]}" == "true" ]]; then
                        
                            ## Prepare content to be rendered (note, order matters!!)
                            ## Read the data by default, we'll modify it later
                            CONTENT=${FIELD_CONTENT}
                            if [[ "${PROPERTIES[1]}" == "video" ]]; then  
                                CONTENT=${VIDEO_EMBED_PREFIX}${CONTENT}${VIDEO_EMBED_SUFFIX}                      
                            fi
                            if [[ "${PROPERTIES[1]}" == "license" ]]; then  
                                CONTENT=${LICENSE_EMBED}                      
                            fi
                            if [[ "${PROPERTIES[1]}" == "image" ]]; then  
                                CONTENT="![$filename](${CONTENT})"                      

                                ## Create the local folder for images, only if there is 
                                ## going to be an image and doesn't exist, yet
	                            [[ "${PROPERTIES[2]}" == "local" ]] && [ ! -d "${IMG_FOLDER}/$filename" ] && mkdir "${IMG_FOLDER}/$filename";
                            fi
                            if [[ "${PROPERTIES[1]}" == "code" ]]; then       
                                ## Create the code for the example only if there is such a
                                ## block in the exercise and it doesn't exist, yet. You will
                                ## have to change it by hand
                                ## So far, code has no localisation, thus no use of the locale folder 
	                            [ ! -d "${SRC_FOLDER}/${PROPERTIES[3]}" ] && mkdir "${SRC_FOLDER}/${PROPERTIES[3]}";
	                            [ ! -d "${SRC_FOLDER}/${PROPERTIES[3]}/$filename" ] && mkdir "${SRC_FOLDER}/${PROPERTIES[3]}/$filename";
	                            if [ -f "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}" ]; then
                                    echo "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]} exists. Changing properties."
                                else 
                                    echo "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]} does not exist. Creating it."

                                	cp "${SETUP_FOLDER}/templates/code/template.${PROPERTIES[3]}" "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}";
                                    ## Fix the code's title
                                    ## It does NOT include the exercise number
	                                ## Was: TITLE="${filename//-/: }"
	                                ##      TITLE="${TITLE//_/ }"
	                                ##      sed -i "s/\[NAME\]/Exercise $TITLE/" "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}"
	                                TITLE="${name//_/ }"
	                                sed -i "s/\[NAME\]/Exercise: $TITLE/" "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}"
                                fi
                

                                ## Include the code file in the exercise 
	                            CONTENT=`cat ${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}`
	                            ## Avoid problems with the && logical operation in sed by escaping each & into \&
	                            CONTENT=$(echo "${CONTENT}" | sed -e 's.&.\\\&.g' )
	                            ## Add prefix and suffix to the code block, this is the official markdown formatting
	                            CONTENT="\\\`\\\`\\\`${PROPERTIES[2]}\\n\/\/$name\\n$CONTENT\\n\\\`\\\`\\\`"
	                            ## Add code description if any
	                            if [[ ${FIELD_CONTENT} != "" ]]; then 
	                                CONTENT="${FIELD_CONTENT}\n\n${CONTENT}"
	                            fi
	                            CONTENT="${CONTENT//$'\n'/\\n}"
                                if grep -Fq "[${CONFIG_KEYS[$i-1]}]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                                then
                                    ## This is a hack to respect the square brackets in the template file
                                    sed -i "s/\[${CONFIG_KEYS[$i-1]}\]/INSERTCODEHERE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"

                                else
                                    echo "Overwritting old code in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                                    sed -z -i 's/```'"$PROPERTIES[2]"'\n\/\/'"$name"'\(.*\)```/INSERTCODEHERE/g' "${CURRENT_FOLDER}/${filename}/${filename}.md"
                                fi
                                
                                ## And now, do the substitution in a very elegant way
                                ## Issue with && is fixed according to https://stackoverflow.com/questions/43172002/awk-gsub-ampersands-and-unexpected-expansion
                                awk -i inplace -v old="INSERTCODEHERE" -v new="$CONTENT" 's=index($0,old){$0=substr($0,1,s-1) new substr($0,s+length(old))} 1' "${CURRENT_FOLDER}/${filename}/${filename}.md"

                            fi
                            if [[ "${PROPERTIES[1]}" != "code" ]]; then                        
                            	CONTENT="${CONTENT//$'\/'/\\\/}"
                            	CONTENT="${CONTENT//\//\\\/}" 
                            	CONTENT="${CONTENT//$'\"'/\\\"}"
                            	CONTENT="${CONTENT//$'\!'/\\\!}"
                            	CONTENT="${CONTENT//$'\['/\\\[}"
                            	CONTENT="${CONTENT//$'\]'/\\\]}"
                            	CONTENT="${CONTENT//$'\('/\\\(}"
                            	CONTENT="${CONTENT//$'\)'/\\\)}"
                            	CONTENT="${CONTENT//$'\`'/\\\`}"

                                if grep -Fq "[${CONFIG_KEYS[$i-1]}]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                                then
	                                sed -i "s/\[${CONFIG_KEYS[$i-1]}\]/$CONTENT/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                                else
                                    echo "Code [${CONFIG_KEYS[$i-1]}] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                                fi

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
