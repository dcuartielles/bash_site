#!/bin/bash

## 20220130 This creation script will use a dataset as long as desired, the
## working mechanism consist of two parts: the fixed data (TEMPLATE + NAME +
## INDEX), and the variable one (the rest). The second part will be handled
## systematically until the end of the record (each line in the dataset)

## The possible parameters are:
## ** -l: locale (default en)
## ** -r: render folder (default .. a.k.a. root)
## ** -c: config / setup folder (default config)
## ** -f: data file (default pages.csv)

## Load utils file
UTILS_PATH='./utils.sh'

## Include the functions
source "${UTILS_PATH}"

## Load config file (https://wiki.bash-hackers.org/howto/conffile#secure_it)
CONFIG_PATH='./config/config.conf'

## Check for malformed config instructions
configReturn=(checkConfigFile)

## Otherwise go on and source it:
source "${CONFIG_PATH}"

while getopts ":l:r:c:f:" opt; do
  case $opt in
    l) LOCALE="$OPTARG"
    ;;
    r) RENDER_FOLDER="$OPTARG"
    ;;
    c) SETUP_FOLDER="$OPTARG"
    ;;
    f) PAGES_FILE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done



## Folders used
LOCALE_FOLDER=${LOCALE}
CURRENT_FOLDER="${SITE_FOLDER}/${LOCALE_FOLDER}"

## Data and index files
DATA_FILE="${SETUP_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${LOCALE_FOLDER}/${PAGES_FILE}"
INDEX_FILE="${CURRENT_FOLDER}/${SITE_INDEX}"
INDEX_LINK="..\/${SITE_INDEX}"

## Check whether the data file is there for us
[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

## navigation variables
HEADER_DONE=0
OFS=$IFS
IFS=$SEPARATOR

## START

## Create the folder for the destination if it doesn't exist
[ ! -d "${RENDER_FOLDER}" ] && mkdir ${RENDER_FOLDER}

## Copy the config folder to the destination to ease the work
cp -R ${SETUP_FOLDER} ${RENDER_FOLDER}

## Work from the destination folder
cd ${RENDER_FOLDER}

## Create the other folders
[ ! -d "${SRC_FOLDER}" ] && mkdir "${SRC_FOLDER}"
[ ! -d "${SITE_FOLDER}" ] && mkdir "${SITE_FOLDER}"
[ ! -d "${CURRENT_FOLDER}" ] && mkdir "${CURRENT_FOLDER}"
[ ! -d "${IMG_FOLDER}" ] && mkdir "${IMG_FOLDER}"

## Init arrays
declare -a TEMPLATE_TYPES=()
declare -a CONFIG_KEYS_ARRAY=()
declare -a CONFIG_VALUES_ARRAY=()

## Read all fields in a record as an array
while read -ra array; do

  ## Collect the data from the header records
  ## Extract the template names from the header
  if [[ "$HEADER_DONE" -eq 0 ]]; then

    echo -e "Collect templates"

    for i in "${!array[@]}"
    do :
        TEMPLATE_TYPES+=(${array[$i]})
    done

    let HEADER_DONE++

    ## Exit the while here
    continue
  fi

  ## Extract the keys from the header
  ## Keys are now comma separated arrays, one record per template
  if [[ "$HEADER_DONE" -eq 1 ]]; then

    echo -e "Collect keys"

    for i in "${!array[@]}"
    do :
      CONFIG_KEYS_ARRAY+=(${array[$i]})
    done

    let HEADER_DONE++

    ## Exit the while here
    continue
  fi

  ## Extract the values from the header
  if [[ "$HEADER_DONE" -eq 2 ]]; then

    echo -e "Collect values"

    for i in "${!array[@]}"
    do :
      CONFIG_VALUES_ARRAY+=(${array[$i]})
    done

    let HEADER_DONE++

    ## Exit the while here
    continue
  fi

  ## The header is over
  if [[ "$HEADER_DONE" -gt 2 ]]; then

    ## Declare some global variable for field processing
    currentTemplate=""
    currentValues=""
    declare -a CONFIG_KEYS=()
    declare -a CONFIG_VALUES=()

    for j in "${!array[@]}"; do :

      ## Extract the template and see which is its index number
      if [[ "$j" -eq 0 ]]; then
        templateName="${array[$j]}"
        pageTemplate=$(elementInWhere "${templateName}" "${TEMPLATE_TYPES[@]}")

        ## Extract the structure of the template
        currentTemplate="${CONFIG_KEYS_ARRAY[$pageTemplate]}"
        currentValues="${CONFIG_VALUES_ARRAY[$pageTemplate]}"
        ## DEBUG: echo -e "Working with template: ${templateName}, structure:\n --> ${currentTemplate}"

        ## And push the template into an array
        readarray -td, CONFIG_KEYS < <(printf '%s' "$currentTemplate"); declare -p CONFIG_KEYS &>/dev/null;
        readarray -td, CONFIG_VALUES < <(printf '%s' "$currentValues"); declare -p CONFIG_VALUES &>/dev/null;
      fi

      ## Extract the page number
      if [[ "$j" -eq 1 ]]; then
        ## was: pageNumber="${array[$j]}"
        ## that would not work if you edited the pages.csv file by hand
        ## thus, back to the basics
        pageNumber=$(printf "%02d" ${array[$j]})
      fi

      ## Extract the page name
      if [[ "$j" -eq 2 ]]; then
        pageName="${array[$j]}"
        imageSubfolder="${pageName// /_}"
        codeFileName="${pageName// /_}"

        ## Fix the filename
        filename="$pageNumber-$pageName"
        filename="${filename// /_}"

        ## Copy the right template into the destination folder
        ## Notify what is going on
        echo -e "\n****************************************"
        echo -e   " Working out example $filename"
        echo -e   "****************************************\n"

        ## Create the page folder and copy the corresponding template into it
        [ ! -d "${CURRENT_FOLDER}/$filename" ] && mkdir "${CURRENT_FOLDER}/$filename";
        if [ -f "${CURRENT_FOLDER}/${filename}/${filename}.md" ]; then
          echo "${CURRENT_FOLDER}/${filename}/${filename}.md exists. Changing properties."
        else
          echo "${CURRENT_FOLDER}/${filename}/${filename}.md does not exist. Creating it."

          cp "${SETUP_FOLDER}/templates/${PAGES_FOLDER}/${LOCALE_FOLDER}/template_${templateName}.md" "${CURRENT_FOLDER}/${filename}/${filename}.md";
        fi

        ## Fix title
        if grep -Fq "[NAME]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
          sed -i "s/\[NAME\]/$pageName/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [NAME] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
      fi

      ## Extract the indexing structure
      ## XXX: very likely not needed
      if [[ "$j" -eq 3 ]]; then
        pageIndex="${array[$j]}"
      fi

      ## Iterate through the rest of the record
      if [[ "$j" -gt 3 ]]; then
        ## First build the iterator for parameters
        TEMP_IFS=$IFS
        IFS=$PARAMETER_SEPARATOR

        ## Render the different fields
        ## Go for the whole rest of the fields, which are always structured as:
        ## FIELD_CONTENT | FIELD_PROPERTIES
        ## Collect the data in pairs, operate only when $i is even
        (( (j % 2) - 1 )) && FIELD_CONTENT="${array[$j]}"
        (( j % 2 )) && FIELD_PROPERTIES="${array[$j]}"

        ## Evaluate properties, if it is code, video, images, etc it requires
        ## specific rendering tricks. Therefore, there is still a lot to do here
        if [ $((j % 2)) == 1 ]; then
          ## Experimenting here
          indexKey=$j-2

          ## DEBUG: echo -e "* Working with: ${CONFIG_KEYS[$indexKey]}| value: ${CONFIG_VALUES[$indexKey]}| content: ${FIELD_CONTENT}| properties: ${FIELD_PROPERTIES}"

          echo -e "* Working with: ${CONFIG_KEYS[$indexKey]}| value: ${CONFIG_VALUES[$indexKey]}| content: ${FIELD_CONTENT}| properties: ${FIELD_PROPERTIES}"

          ## Extract the properties array in a silent fashion
          readarray -td, PROPERTIES < <(printf '%s' "$FIELD_PROPERTIES"); declare -p PROPERTIES &>/dev/null;

          if [[ $FIELD_CONTENT != "" ||  "${PROPERTIES[0]}" == "true" ]]; then
              ## echo -e ${PROPERTIES[0]}
              if [[ "${PROPERTIES[0]}" == "true" ]]; then

                  ## Prepare content to be rendered (note, order matters!!)
                  ## Read the data by default, we'll modify it later
                  CONTENT=${FIELD_CONTENT}
                  if [[ "${PROPERTIES[1]}" == "video" ]]; then
                    CONTENT=${VIMEO_EMBED_PREFIX}${CONTENT}${VIMEO_EMBED_SUFFIX}
                    ## but that part is now handled by populate_site.sh
                    ## was: CONTENT=${CONTENT}
                  fi
                  if [[ "${PROPERTIES[1]}" == "license" ]]; then
                      CONTENT=${LICENSE_EMBED}
                  fi
                  if [[ "${PROPERTIES[1]}" == "image" ]]; then
                      CONTENT="![$filename](${CONTENT})"

                      ## Create the local folder for images, only if there is
                      ## going to be an image and doesn't exist, yet
                    [[ "${PROPERTIES[2]}" == "local" ]] && [ ! -d "${IMG_FOLDER}/$imageSubfolder" ] && mkdir "${IMG_FOLDER}/$imageSubfolder";
                  fi
                  if [[ "${PROPERTIES[1]}" == "code" ]]; then
                      ## Create the code for the example only if there is such a
                      ## block in the page and it doesn't exist, yet. You will
                      ## have to change it by hand
                      ## So far, code has no localisation, thus no use of the locale folder

                      ## Step 1: where in the index can I find the type of code?
                      ## TODO: change for the elementInWhere function at some point
                      index=-1

                      for k in "${!CODE_TYPES[@]}"
                      do :
                          echo -e "+ Checking ${PROPERTIES[2]} against ${CODE_TYPES[$k]}"
                          if [[ "${CODE_TYPES[$k]}" = "${PROPERTIES[2]}" ]];
                          then
                              index=$j
                              break
                          fi
                      done

                      ## Step 2: report about the code type
                      if [ $index -gt -1 ]; then
                          echo -e "Index of the code type: ${PROPERTIES[2]}, in Array is : $index"
                          echo -e "Code suffix is: ${CODE_SUFFIX[$index]}"
                          echo -e "Code style is: ${CODE_STYLE[$index]}"
                          echo -e "The code should have the same name as the page: ${PROPERTIES[3]}"
                      else
                          echo "Code type ${PROPERTIES[2]} is not declared as a type of code."; exit 99;
                      fi

                      ## Step 2.5: decide which will be the name of the piece of code
                      ## Copy the code from the template only if requested
                      if [[ "${PROPERTIES[3]}" == "true" ]]; then
                        codeName=${codeFileName}
                      else
                        codeName=${FIELD_CONTENT}
                      fi

                      ## Step 3: create folders and such
                    [ ! -d "${SRC_FOLDER}/${PROPERTIES[2]}" ] && mkdir "${SRC_FOLDER}/${PROPERTIES[2]}";
                    [ ! -d "${SRC_FOLDER}/${PROPERTIES[2]}/$codeName" ] && mkdir "${SRC_FOLDER}/${PROPERTIES[2]}/$codeName";
                    if [ -f "${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]}" ]; then
                          echo "${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]} exists. Changing properties."
                    else
                      echo "${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]} does not exist. Creating it."

                      cp "${SETUP_FOLDER}/templates/code/${PROPERTIES[2]}/template.${CODE_SUFFIX[$index]}" "${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]}";
                      ## Fix the code's title
                      ## It does NOT include the page number
                      ## Was: TITLE="${filename//-/: }"
                      ##      TITLE="${TITLE//_/ }"
                      ##      sed -i "s/\[NAME\]/Page $TITLE/" "${SRC_FOLDER}/${PROPERTIES[3]}/${filename}/${filename}.${PROPERTIES[3]}"
                      TITLE="${pageName//_/ }"
                      CODE_LISTING="${codeName//_/ }"
                      sed -i "s/\[NAME\]/Page: $TITLE\\n   Listing:  $CODE_LISTING/" "${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]}"
                    fi


                    ## Step 4: Include the code file in the page
                    CONTENT=`cat ${SRC_FOLDER}/${PROPERTIES[2]}/${codeName}/${codeName}.${CODE_SUFFIX[$index]}`
                    ## Do the magic HTML encoding needed to show this type of code
                    [[ "${PROPERTIES[2]}" == "HTML" ]] && CONTENT=$(echo "${CONTENT}" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
                    ## Avoid problems with the && logical operation in sed by escaping each & into \&
                    [[ "${PROPERTIES[2]}" != "HTML" ]] && CONTENT=$(echo "${CONTENT}" | sed -e 's.&.\\\&.g' )
                    ## Add prefix and suffix to the code block, this is the official markdown formatting
                    CONTENT="\\\`\\\`\\\`${CODE_STYLE[$index]}\\n\/\/$codeName\\n$CONTENT\\n\\\`\\\`\\\`"
                    ## Add code description if any --> 20220124: THIS SHOULD NOW BE A DEDICATED TEXT FIELD
                    ##if [[ ${FIELD_CONTENT} != "" ]]; then
                    ##    CONTENT="${FIELD_CONTENT}\n\n${CONTENT}"
                    ##fi
                    CONTENT="${CONTENT//$'\n'/\\n}"
                    if grep -Fq "[${CONFIG_KEYS[$indexKey]}]" "${CURRENT_FOLDER}/${filename}/${filename}.md"; then
                        ## This is a hack to respect the square brackets in the template file
                        sed -i "s/\[${CONFIG_KEYS[$indexKey]}\]/INSERTCODEHERE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                    else
                        echo "Overwritting old code in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                        sed -z -i 's/```'"${CODE_STYLE[$index]}"'\n\/\/'"$codeName"'\(.*\)```/INSERTCODEHERE/g' "${CURRENT_FOLDER}/${filename}/${filename}.md"
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

                    if grep -Fq "[${CONFIG_KEYS[$indexKey]}]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                    then
                      sed -i "s/\[${CONFIG_KEYS[$indexKey]}\]/$CONTENT/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
                    else
                        echo "Code [${CONFIG_KEYS[$indexKey]}] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
                    fi

                  fi

              fi
          else
              echo -e "No ${CONFIG_KEYS[$indexKey]} in this record, removing it from template"
              sed -i "s/\[${CONFIG_KEYS[$indexKey]}\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
              sed -i "s/${CONFIG_VALUES[$indexKey]}//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

          fi

        fi

        ## Clean double EOLs created by removing fields from the template
        sed -i '$!N; /^\(.*\)\n\1$/!P; D' "${CURRENT_FOLDER}/${filename}/${filename}.md"

        ## Return to the previous iterator
        IFS=$TEMP_IFS

        ## Do nothing else
        continue

        ## XXX: we are here now, need to: render content to template based on properties
      fi
    done
  fi
done < $DATA_FILE

## Create index file
echo "# Site Index" > $INDEX_FILE

## Reset the header check
HEADER_DONE=0

## Use index file
echo -e "** CREATE INDEX ** \n$INDEX_FILE"

## Add links to all articles
while read -ra array; do

    ## Remove headers
    if [[ "$HEADER_DONE" -lt 3 ]]; then
        let HEADER_DONE++
        continue
    fi

    ## fix the leading zeros in the number variable
    ## was: pageNumber="${array[1]}"
    ## that would not work if you edited the pages.csv file by hand
    ## thus, back to the basics
    pageNumber=$(printf "%02d" ${array[1]})

    ## set the filename
    pageName="${array[2]}"
    filename="$pageNumber-$pageName"
    filename="${filename// /_}"

    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $filename"
    echo -e   "****************************************\n"

    ## Append text at the end of the file
    echo "* [${pageNumber}-${pageName}](${filename}/${filename}.md)" >> $INDEX_FILE

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
    if [[ "$HEADER_DONE" -lt 3 ]]; then
        let HEADER_DONE++
        continue
    fi

    ## fix the leading zeros in the number variable
    ## was: pageNumber="${array[1]}"
    ## that would not work if you edited the pages.csv file by hand
    ## thus, back to the basics
    pageNumber=$(printf "%02d" ${array[1]})

    ## set the filename
    pageName="${array[2]}"
    filename="$pageNumber-$pageName"
    filename="${filename// /_}"

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
