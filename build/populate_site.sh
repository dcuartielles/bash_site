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
TEMP_OUTPUT_FILE="pages.tmp"

HEADER_DONE=0

DATA_FILE="${SETUP_FOLDER}/${SITE_FOLDER}/${PAGES_FOLDER}/${LOCALE_FOLDER}/${SETUP_FILE}"
[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

SEPARATOR='¤'
PARAMETER_SEPARATOR=','

## 1. Create a temporary folder
[ ! -d "tmp" ] && mkdir tmp

## 2. Create a temporary file in the temporary folder
touch "tmp/${TEMP_OUTPUT_FILE}"

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
      pageField="Left empty"

      ## Work the data in pairs
      if (( k % 2 )); then
        read -e -p "Text for field: ${THE_TEMPLATE[$k]} -> " -i "Fill in by hand" pageField
      fi
      if (( (k % 2) - 1 )); then
        ## TODO: change this to ask which type of content it is and use
        ## templates for different types of content to populate it
        read -e -p "Parameters for field: ${THE_TEMPLATE[$k]} -> " -i "true" pageField
      fi

      pageRecord="${pageRecord}${pageField}${SEPARATOR}"
    fi


  done
  IFS=$TEMP_IFS

  ## 5.4. Eventually fill in the license (TBD)

  ## 5.5. Append the record at the end of the temporary file
  echo "${pageRecord}" >> "tmp/$TEMP_OUTPUT_FILE"
done

## 6. Close the original file

## 7. Copy the file to overwrite the original

## 8. Delete the temporary folder
## rm -fR tmp

## 9. Done
echo -e "** Done"
