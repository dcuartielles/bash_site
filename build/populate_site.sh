#!/bin/bash

## 20220130 The populate_site script is going to interactively ask you
## about the type of data you want to add to each record

LOCALE=$1
DEST_FOLDER=$2
SETUP_FOLDER=$3
SETUP_FILE=$4

SITE_FOLDER="site"      ## was "course"
PAGES_FOLDER="pages"    ## was "exercises"
LOCALE_FOLDER=${LOCALE}
CURRENT_FOLDER="${SITE_FOLDER}/${LOCALE_FOLDER}"
TEMP_FOLDER="tmp"
TEMP_OUTPUT_FILE="pages.tmp"

DATA_TYPES=("text" "html" "image" "code" "video" "license")
DEFAULT_PROPERTIES=("true" "true" "true" "true" "true" "true")
CODE_TYPES=("C" "C++" "Arduino" "Processing" "p5js" "Python" "HTML")
IMAGE_TYPES=("local" "remote")

## Variables
HEADER_DONE=0

DATA_FILE="${SETUP_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${LOCALE_FOLDER}/${SETUP_FILE}"
[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

SEPARATOR='¤'
PARAMETER_SEPARATOR=','

## 1. Create a temporary folder
[ ! -d "${TEMP_FOLDER}" ] && mkdir "${TEMP_FOLDER}"

## 2. Create a temporary file in the temporary folder
touch "${TEMP_FOLDER}/${TEMP_OUTPUT_FILE}"

## 3. Open the temporary file, load the types of templates into an array
OFS=$IFS
IFS=$SEPARATOR

## Init arrays
declare -a TEMPLATE_TYPES=()
declare -a CONFIG_KEYS=()
declare -a CONFIG_VALUES=()

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
      CONFIG_KEYS+=(${array[$i]})
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
      CONFIG_VALUES+=(${array[$i]})
    done

    let HEADER_DONE++

    ## Exit the while here
    continue
  fi

  ## The header is over
  if [[ "$HEADER_DONE" -gt 2 ]]; then
    ## Do nothing
    continue
  fi

done < $DATA_FILE

## 4. Ask for how many pages should be included in the file
echo -e "How many pages do you want in the site?"
read NUM_PAGES

## 5. Loop the following:
for (( i=0; i<=NUM_PAGES-1; i++ )); do

  pageRecord=""

  ## 5.1. Ask for the template to use
  templates=""
  for j in "${!TEMPLATE_TYPES[@]}"
  do
    templates="$templates(${j}) ${TEMPLATE_TYPES[$j]} "
  done
  echo -e "Available templates:\n$templates"
  read -e -p "Choose template: " -i "0" pageTemplate
  echo -e "Chosen the ${TEMPLATE_TYPES[$pageTemplate]} template"

  pageRecord="${pageRecord}${TEMPLATE_TYPES[$pageTemplate]}${SEPARATOR}"

  ## 5.2. Ask for the name of the page
  read -e -p "Choose the page's name: " -i "Insert name" pageName
  echo -e "Given the name: $pageName"

  ## 5.3. Iterate through the different fields and ask for the parameters

  ## 5.3.1 Pick up the proper template structure
  currentTemplate="${CONFIG_KEYS[$pageTemplate]}"
  echo -e "Current template used: $currentTemplate"

  ## 5.3.2 Iterate through the template structure
  ## push the template into an array
  readarray -td, THE_TEMPLATE < <(printf '%s' "$currentTemplate"); declare -p THE_TEMPLATE &>/dev/null;

  TEMP_IFS=$IFS
  IFS=","

  ## Global variables needed for field processing
  fieldType=""
  pageField=""
  dataTypeIndex=0

  ## The iterator
  for k in "${!THE_TEMPLATE[@]}"
  do
    ## Jump over the first three fields (NUMBER,NAME,INDEX)
    ## Render the number of the article
    if [[ "$k" -eq 0 ]]; then
      pageNumber=$(printf "%02d" ${i})
      pageRecord="${pageRecord}${pageNumber}${SEPARATOR}"
    fi

    ## Render the name of the article
    if [[ "$k" -eq 1 ]]; then
      pageRecord="${pageRecord}${pageName}${SEPARATOR}"
    fi

    ## Render the index of the article
    if [[ "$k" -eq 2 ]]; then
      ## TODO: revise what happens with the index
      ## for now we fill this in here, but the template is
      ## handling this, so it should remain empty
      PAGE_INDEX="[PREVIOUSARTICLE] [INDEX] [FOLLOWINGARTICLE]"
      pageRecord="${pageRecord}${PAGE_INDEX}${SEPARATOR}"
    fi

    ## Render the different fields asking for some input
    if [[ "$k" -gt 2 ]]; then

      ## Work the data in pairs
      if (( k % 2 )); then
        ##pageField="Left empty"
        echo -e "\n** Working with field ${TEMPLATE_TYPES[$pageTemplate]}->${THE_TEMPLATE[$k]} **"
        dataTypes=""
        for l in "${!DATA_TYPES[@]}"
        do
          dataTypes="$dataTypes(${l}) ${DATA_TYPES[$l]} "
        done
        echo -e "Available data types:\n$dataTypes"
        read -e -p "Choose data type: " -i "0" dataTypeIndex
        fieldType="${DATA_TYPES[$dataTypeIndex]}"

        echo -e "Chosen type: ${fieldType}"

        read -e -p "Content for field: ${THE_TEMPLATE[$k]} -> " -i "Fill in by hand" pageField
      fi
      if (( (k % 2) - 1 )); then
        ## TODO: change this to ask which type of content it is and use
        ## templates for different types of content to populate it
        blockProperties="${DEFAULT_PROPERTIES[$dataTypeIndex]}${PARAMETER_SEPARATOR}"

        ## Handle code blocks
        codeType=""
        if [[ "${fieldType}" == "code" ]]; then
          codeTypes=""
          for l in "${!CODE_TYPES[@]}"
          do
            codeTypes="$codeTypes(${l}) ${CODE_TYPES[$l]} "
          done
          echo -e "Available code types:\n$codeTypes"
          read -e -p "Choose code type: " -i "0" codeTypeIndex
          codeType="${PARAMETER_SEPARATOR}${CODE_TYPES[$codeTypeIndex]}"
        fi

        ## Handle image blocks
        imageType=""
        if [[ "${fieldType}" == "image" ]]; then
          imageTypes=""
          for l in "${!IMAGE_TYPES[@]}"
          do
            imageTypes="$imageTypes(${l}) ${IMAGE_TYPES[$l]} "
          done
          echo -e "Available image types:\n$imageTypes"
          read -e -p "Choose image type: " -i "0" imageTypeIndex
          imageType="${PARAMETER_SEPARATOR}${IMAGE_TYPES[$imageTypeIndex]}"
        fi

        ## Read the actual properties
        read -e -p "Parameters for ${fieldType} field: ${THE_TEMPLATE[$k]} -> " -i "${blockProperties}${fieldType}${codeType}${imageType}" propertiesField

        ## At the end of the properties of the last field, add everything to the CSV
        pageRecord="${pageRecord}${pageField}${SEPARATOR}${propertiesField}${SEPARATOR}"

      fi
    fi


  done
  IFS=$TEMP_IFS

  ## 5.4. Eventually fill in the license (TBD)

  ## 5.5. Append the record at the end of the temporary file
  echo "${pageRecord}" >> "${TEMP_FOLDER}/$TEMP_OUTPUT_FILE"
done

## 6. Concatenate the records file at the end of the headers one
cat "${DATA_FILE}" "${TEMP_FOLDER}/${TEMP_OUTPUT_FILE}" > "${TEMP_FOLDER}/${TEMP_OUTPUT_FILE}.out"

## 7. Move the file to overwrite the original but first make a backup
mv "${DATA_FILE}" "${DATA_FILE}.bak"
mv "${TEMP_FOLDER}/${TEMP_OUTPUT_FILE}.out" "${DATA_FILE}"

## 8. Delete the temporary folder
rm -fR tmp

## 9. Done
echo -e "** Done"
