#!/bin/bash

## 20220225 This export script takes the rendered website and uses pandoc
## to convert to other formats such as HTML or PDF

## The possible parameters are:
## ** -l: locale (default en)
## ** -t: type of file (default HTML)
## ** -r: render folder (default .. a.k.a. root)
## ** -p: pandoc parameters
## ** -e: export folder (default export)

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

while getopts ":l:t:r:p:e:" opt; do
  case $opt in
    l) LOCALE="$OPTARG"
    ;;
    t) TYPE_FILE="$OPTARG"
    ;;
    r) RENDER_FOLDER="$OPTARG"
    ;;
    p) PANDOC_PARAMETERS="$OPTARG"
    ;;
    e) EXPORT_FOLDER="$OPTARG"
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
CURRENT_FOLDER="${RENDER_FOLDER}/${SITE_FOLDER}/${LOCALE_FOLDER}"
CURRENT_EXPORT_FOLDER="${EXPORT_FOLDER}/${SITE_FOLDER}/${LOCALE_FOLDER}"
IMAGE_FOLDER="${RENDER_FOLDER}/${IMG_FOLDER}"

## Data and index files
INDEX_FILE="${CURRENT_FOLDER}/${SITE_INDEX}"

## Step 1: check the type of file to work with, exit if not in the list
typeExists=$(elementInWhere "${TYPE_FILE}" "${EXPORT_TYPES[@]}")
[[ $? -ne 0 ]] && { echo "$TYPE_FILE file format not supported"; exit 99; }

## Step 1.1: Copy the render folder to a temporary one to ease the work
## But first, create the folder if it doesn't exist
[ ! -d "${TEMP_FOLDER}" ] && mkdir ${TEMP_FOLDER}
[ ! -d "${TEMP_FOLDER}/${SITE_FOLDER}" ] && mkdir ${TEMP_FOLDER}/${SITE_FOLDER}
cp -R ${CURRENT_FOLDER} ${TEMP_FOLDER}/${SITE_FOLDER}
cp -R ${IMAGE_FOLDER} ${TEMP_FOLDER}

## Since you are at it, create the export folder and add the images there
[ ! -d "${EXPORT_FOLDER}" ] && mkdir ${EXPORT_FOLDER}
[ ! -d "${EXPORT_FOLDER}/${SITE_FOLDER}" ] && mkdir ${EXPORT_FOLDER}/${SITE_FOLDER}
[ ! -d "${CURRENT_EXPORT_FOLDER}" ] && mkdir ${CURRENT_EXPORT_FOLDER}
cp -R ${IMAGE_FOLDER} ${EXPORT_FOLDER}

## Step 2: if HTML, search for all Markdown files and convert them one by one
if [[ ${TYPE_FILE} == "HTML" ]]; then
  ## List all of the Markdown files into an array
  markdownFiles=$(find "${TEMP_FOLDER}" | grep "\.md$")
  readarray -t MARKDOWN_FILES <<<"$markdownFiles"

  ## Iterate through the array
  for fileIndex in "${!MARKDOWN_FILES[@]}"
  do :
    echo -e "** Converting: ${MARKDOWN_FILES[$fileIndex]}"

    ## Extract file name without extension
    filename=$(basename -- "${MARKDOWN_FILES[$fileIndex]}")
    filename="${filename%.*}"
    ## extension="${filename##*.}"
    ##echo -e "** Filename: ${filename}"

    ## Extract the path to the file
    fileFolder=$(dirname "${MARKDOWN_FILES[$fileIndex]}")

    ## Remove the first folder block
    fileFolder=${fileFolder#$TEMP_FOLDER}

    ## Add the export folder name
    fileFolder=$EXPORT_FOLDER/$fileFolder

    ## Fix the index block to link to HTML files
    ## TODO: this will not allow me to include links to ANY Markdown Files
    ##       It could be a good idea to rethink this in the future
    ##if [[ "${filename}.md" == "${SITE_INDEX}" ]]; then
      sed -i "s/.md)/.html)/g" "${MARKDOWN_FILES[$fileIndex]}"
    ##fi

    ## Create the page folder, this trick allows two levels of depth
    ## such as the created by the generator, having more depth would
    ## require a different subfolder generator capable of detecting how
    ## many subfolders to create along the way
    [ ! -d "${fileFolder}" ] && mkdir ${fileFolder}
    ##[ ! -d "${CURRENT_EXPORT_FOLDER}/${filename}" ] && mkdir ${CURRENT_EXPORT_FOLDER}/${filename}

    pandoc -s ${MARKDOWN_FILES[$fileIndex]} --metadata pagetitle="${filename}" -o ${fileFolder}/${filename}.html
    ##pandoc ${MARKDOWN_FILES[$fileIndex]} -o ${CURRENT_EXPORT_FOLDER}/${filename}/${filename}.html
  done
fi

## Step 3: if PDF, remove the indexing part of all files and compose them together
if [[ ${TYPE_FILE} == "PDF" ]]; then
  ## List all of the Markdown files into an array
  markdownFiles=$(find "${TEMP_FOLDER}" | grep "\.md$")
  readarray -t MARKDOWN_FILES <<<"$markdownFiles"

  ## Iterate through the array
  for fileIndex in "${!MARKDOWN_FILES[@]}"
  do :
    ## Work only if not dealing with the index file, which should be
    ## left out of the PDF generation

    ## Extract file name without extension
    filename=$(basename -- "${MARKDOWN_FILES[$fileIndex]}")
    filename="${filename%.*}"

    if [[ "${filename}.md" != "${SITE_INDEX}" ]]; then
      echo -e "** Adding: ${MARKDOWN_FILES[$fileIndex]}"

      ## Append the file at the bottom of the temp file
      cat "${MARKDOWN_FILES[$fileIndex]}" >> "${TEMP_FOLDER}/${TEMP_EXPORT_FILE}"
    fi
  done

  ## Remove all of the index blocks
  ## TODO: fix this to work with other locales by using information from the
  ##       template.csv file instead of having it hardcoded in here
  ##sed -z -i 's/## Index\(.*\)##/##/g' "${TEMP_FOLDER}/${TEMP_EXPORT_FILE}"
  sed -i '/## Index/,/##/{//!d}' "${TEMP_FOLDER}/${TEMP_EXPORT_FILE}"
  sed -z -i 's/## Index//g' "${TEMP_FOLDER}/${TEMP_EXPORT_FILE}"

  ## TODO: deal with the video blocks by searching for a screenshot

  pandoc "${TEMP_FOLDER}/${TEMP_EXPORT_FILE}" --pdf-engine=xelatex -o "${EXPORT_FOLDER}/${PDF_EXPORT_FILE}"

  ## Open the file for inspection
  xdg-open "${EXPORT_FOLDER}/${PDF_EXPORT_FILE}"
fi

## XXX

## We finished, delete the temporary folder
[ -d "${TEMP_FOLDER}" ] && rm -fR ${TEMP_FOLDER}

## Done
echo -e "** Done"
