#!/bin/bash

## 20220127 analyse site is a script made to gather information about a site
## departing from the pages.csv file

## Run a check on the data file: how many pages, how many fields, total images,
## total code blocks, types of code detected, etc
## Read all fields in a record as an array, count the total amount of records
## Iterate through the records and count fields and types of fields
## Supports multiple templates for pages
## Report back to CLI


LOCALE=$1
DEST_FOLDER=$2
SETUP_FOLDER=$3
SETUP_FILE=$4

SITE_FOLDER="site"
PAGES_FOLDER="pages"    ## was "exercises"
LOCALE_FOLDER=${LOCALE}
CURRENT_FOLDER="${SITE_FOLDER}/${LOCALE_FOLDER}"
SRC_FOLDER="src"
IMG_FOLDER="img"

DATA_FILE="${SETUP_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${LOCALE_FOLDER}/${SETUP_FILE}"

SEPARATOR='¤'

DATA_TYPES=("text","html","image","code","video","license") ## Not used
CODE_SUFFIX=("c" "cpp" "ino" "pde" "js" "py" "html")
CODE_TYPES=("C" "C++" "Arduino" "Processing" "p5js" "Python" "HTML")
CODE_STYLE=("c_cpp" "c_cpp" "c_cpp" "java" "javascript" "python" "html")
## Get code styles from https://github.com/github/linguist/blob/master/lib/linguist/languages.yml

HEADER_DONE=0
FIELDS_COUNT=0
RECORDS_COUNT=0
TEMPLATES_COUNT=0
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

## Init arrays
declare -a TEMPLATES_TYPES=()
declare -a TEMPLATES=()
declare -a CONFIG_KEYS=()
declare -a CONFIG_VALUES=()
declare -a REPORT_FOLDERS=()
declare -a CODE_BLOCKS_TYPES=()

## Functions
elementIn () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

elementInWhere () {
  index=0
  local e match="$1"
  shift
  for e
  do :
    [[ "$e" == "$match" ]] && return index;
    let index++
  done
  return -1
}

## Check the different folders to be used
[ ! -d "${DEST_FOLDER}" ] && REPORT_FOLDERS+=("The destination folder ${DEST_FOLDER} doesn't exist")
[ ! -d "${SETUP_FOLDER}" ] && REPORT_FOLDERS+=("The configuration folder ${SETUP_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${SITE_FOLDER}" ] && REPORT_FOLDERS+=("The site folder ${SITE_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${CURRENT_FOLDER}" ] && REPORT_FOLDERS+=("The locale's site folder ${CURRENT_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${IMG_FOLDER}" ] && REPORT_FOLDERS+=("The image folder ${IMG_FOLDER} doesn't exist")
[ ! -d "${DEST_FOLDER}/${SRC_FOLDER}" ] && REPORT_FOLDERS+=("The source code folder ${SRC_FOLDER} doesn't exist")

## Read all fields in a record as an array
while read -ra array; do

    ## Collect the data from the header records
    ## Extract the template names from the header
    if [[ "$HEADER_DONE" -eq 0 ]]; then

        echo -e "Collect templates"

        for i in "${!array[@]}"
        do :
            TEMPLATES_TYPES+=(${array[$i]})
            let TEMPLATES_COUNT++
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
          TEMP_IFS=$IFS
          IFS=","
          for j in ${array[$i]}
          do
            CONFIG_KEYS+=($j)
            let FIELDS_COUNT++
          done
          IFS=$TEMP_IFS
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
          TEMP_IFS=$IFS
          IFS=","
          for j in ${array[$i]}
          do
            CONFIG_VALUES+=($j)
          done
          IFS=$TEMP_IFS
        done

        let HEADER_DONE++

        ## Exit the while here
        continue
    fi

    ## Work out the actual contents
    ## Fixed positions are NUMBER | NAME | INDEX with locations 0 | 1 | 2
    if [[ "$HEADER_DONE" -gt 2 ]]; then

        let RECORDS_COUNT++

        for i in "${!array[@]}"
        do :
          ## Extract the template and count how many pages use
          ## that specific template (this is pure statistical porn)
          if [ "$i" -eq 0 ]; then
              template=${array[$i]}
              index=$(elementInWhere "${template}" "${TEMPLATES[@]}")
              if [ $index >= 0 ]; then
                let TEMPLATES_COUNT[$index]++
              fi
          fi

          ## Fix the leading zeros in the number variable
          if [ "$i" -eq 1 ]; then
              number=$(printf "%02d" ${array[$i]})
          fi

          ## Extract the name
          if [ "$i" -eq 2 ]; then
              name=${array[$i]}

              ## Notify what is going on
              echo -e   "+ Analysing record number: $number, name: $name, using template: $template"

          fi

          ## Go for the whole rest of the fields, which are always structured as:
          ## FIELD_CONTENT | FIELD_PROPERTIES
          if [ "$i" -gt 3 ]; then

              ## Collect the data in pairs, operate only when $i is even
              (( (i % 2) - 1 )) && FIELD_CONTENT="${array[$i]}"
              (( i % 2 )) && FIELD_PROPERTIES="${array[$i]}"

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
                              ## Was: if [[ ! " ${CODE_BLOCKS_TYPES[*]} " =~ " ${PROPERTIES[2]} " ]]; then
                              if elementIn "${PROPERTIES[2]}" "${CODE_BLOCKS_TYPES[@]}"; then
                                  CODE_BLOCKS_TYPES+=(${PROPERTIES[2]})

                                  ## Check if there is a template for this type of code, first get the
                                  ## file extension given the type of code
                                  index=-1
                                  for j in "${!CODE_TYPES[@]}"
                                  do :
                                      ## echo -e "+ Checking ${PROPERTIES[2]} against ${CODE_TYPES[$j]}"
                                      if [[ "${CODE_TYPES[$j]}" = "${PROPERTIES[2]}" ]];
                                      then
                                          index=$j
                                          break
                                      fi
                                  done

                                  [ ! -d "${SRC_FOLDER}/${PROPERTIES[2]}" ] && REPORT_FOLDERS+=("The source folder ${SRC_FOLDER}/${PROPERTIES[2]} doesn't exist");
                                  if [ ! -f "${SETUP_FOLDER}/templates/code/${PROPERTIES[2]}/template.${CODE_SUFFIX[$index]}" ]; then
                                      REPORT_FOLDERS+=("** Error** There is no template for the ${PROPERTIES[2]} code type.")
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
echo -e "* Fields in the dataset: ${FIELDS_COUNT}"
echo -e "* List of fields:"
printf '  %s ' "${CONFIG_KEYS[@]}"
echo -e "\n* Templates used in the dataset: ${TEMPLATES_COUNT}"
echo -e "* List of templates:"
printf '  %s \t' "${TEMPLATES_TYPES[@]}"
printf '  %s \t' "${TEMPLATES[@]}"
echo -e "\n* Records (wo headers): ${RECORDS_COUNT}"
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
