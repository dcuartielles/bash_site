#!/bin/bash

LOCALE=$1
DEST_FOLDER=$2
SETUP_FOLDER=$3
SETUP_FILE=$4

DATA_FILE="${SETUP_FOLDER}/${SETUP_FILE}"

COURSE_FOLDER="course"
LOCALE_FOLDER=${LOCALE}
CURRENT_FOLDER="${COURSE_FOLDER}/${LOCALE_FOLDER}"
SRC_FOLDER="src"
IMG_FOLDER="img"

INDEX_FILE="${CURRENT_FOLDER}/course_index.md"
INDEX_LINK="..\/course_index.md"

VIDEO_EMBED_PREFIX='<iframe src="'
VIDEO_EMBED_SUFFIX='" width="640" height="564" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>'

HEADER_DONE=0

LICENSE_EMBED='<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.\n\n*2021, 2022 D. Cuartielles for Malmo University, Sweden*'

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS='¤'
##IFS=$'\n'

mkdir ${DEST_FOLDER}
cp -R ${SETUP_FOLDER} ${DEST_FOLDER}

cd ${DEST_FOLDER}

mkdir ${SRC_FOLDER}
mkdir ${COURSE_FOLDER}
mkdir ${CURRENT_FOLDER}
mkdir ${IMG_FOLDER}

## Create files, add titles, add video if it exists
while read -r number hasCode hasCircuit file video objectives parts circuit introduction description more; do

    ## Remove the first line (containing headers) 
    if [ $HEADER_DONE == 0 ]; then
        HEADER_DONE=1
        continue
    fi

    ## fix the leading zeros in the number variable
    number=$(printf "%02d" $number)

    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $file"
    echo -e   "****************************************\n"
 
    ## Fix the filename
	filename="$number-$file"
   
    ## Work out the local folder for images
	mkdir "${IMG_FOLDER}/$filename";
    
    ## Work out the code for the example
    ## So far, code has no localisation features, thus no use of the locale folder here
	mkdir "${SRC_FOLDER}/$filename";
	if [ -f "${SRC_FOLDER}/${filename}/${filename}.ino" ]; then
        echo "${SRC_FOLDER}/${filename}/${filename}.ino exists. Changing properties."
    else 
        echo "${SRC_FOLDER}/${filename}/${filename}.ino does not exist. Creating it."

    	cp "${SETUP_FOLDER}/templates/code/template.ino" "${SRC_FOLDER}/${filename}/${filename}.ino";
    fi
	TITLE_TEMP="${filename//-/: }"
	TITLE="${TITLE_TEMP//_/ }"
	sed -i "s/\[NAME\]/Exercise $TITLE/" "${SRC_FOLDER}/${filename}/${filename}.ino"

    ## Work out the text for the example
	mkdir "${CURRENT_FOLDER}/$filename";
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
    
    ## Fix objectives
    if [[ $objectives != "" ]]
    then
        if grep -Fq "[OBJECTIVES]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        OBJECTIVES="${objectives//\/\\}"
	        sed -i "s/\[OBJECTIVES\]/$OBJECTIVES/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [OBJECTIVES] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No objectives in this record, removing it from template"
        sed -i "s/\[OBJECTIVES\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Objectives//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi
    
    ## Fix parts
    if [[ $parts != "" ]]
    then
        if grep -Fq "[PARTS]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        ##PARTS="${parts//\/\\}"
        	PARTS="${parts//$'\/'/\\\/}"
        	PARTS="${PARTS//\//\\\/}" 
	        sed -i "s/\[PARTS\]/$PARTS/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [PARTS] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No parts in this record, removing it from template"
        sed -i "s/\[PARTS\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Parts//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi

    ## Fix introduction
    if [[ $introduction != "" ]]
    then
        if grep -Fq "[INTRODUCTION]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        ##PARTS="${parts//\/\\}"
        	INTRODUCTION="${introduction//$'\/'/\\\/}"
        	INTRODUCTION="${INTRODUCTION//\//\\\/}" 
	        sed -i "s/\[INTRODUCTION\]/$INTRODUCTION/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [INTRODUCTION] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No introduction in this record, removing it from template"
        sed -i "s/\[INTRODUCTION\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Introduction//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi

    ## Fix description
    if [[ $description != "" ]]
    then
        if grep -Fq "[DESCRIPTION]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        ##PARTS="${parts//\/\\}"
        	DESCRIPTION="${description//$'\/'/\\\/}"
        	DESCRIPTION="${DESCRIPTION//\//\\\/}" 
	        sed -i "s/\[DESCRIPTION\]/$DESCRIPTION/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [DESCRIPTION] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No description in this record, removing it from template"
        sed -i "s/\[DESCRIPTION\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Description//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi

    ## Fix more
    if [[ $more != "" ]]
    then
        if grep -Fq "[MORE]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        ##PARTS="${parts//\/\\}"
        	MORE="${more//$'\/'/\\\/}"
        	MORE="${MORE//\//\\\/}" 
	        sed -i "s/\[MORE\]/$MORE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [MORE] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No 'Where to learn more' information in this record, removing it from template"
        sed -i "s/\[MORE\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Where to learn more//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi

    ## Fix video
    if [[ $video != "" ]]
    then
        VIDEO=${VIDEO_EMBED_PREFIX}${video}${VIDEO_EMBED_SUFFIX}
    	VIDEO="${VIDEO//$'\"'/\\\"}"
    	VIDEO="${VIDEO//\//\\\/}" 
        echo -e "** VIDEO ** \n$VIDEO"
        if grep -Fq "[VIDEO]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        sed -i "s/\[VIDEO\]/$VIDEO/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [VIDEO] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No video link, removing it from template"
        sed -i "s/\[VIDEO\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Video tutorial//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi
	
	## Fix circuit ...
	## This will be an image stored in the folders names /img/filename/name.extention
    if [[ $circuit != "" ]]
    then
	    if [[ $hasCircuit == "Y" ]]
        then
        	CIRCUIT="${circuit//$'\"'/\\\"}"
        	CIRCUIT="${CIRCUIT//\//\\\/}" 
            echo -e "** CIRCUIT ** \n$CIRCUIT"
            if grep -Fq "[CIRCUIT]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
            then
	            sed -i "s/\[CIRCUIT\]/\!\[$filename\]\($CIRCUIT\)/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
            else
                echo "Code [CIRCUIT] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
            fi
        fi
    else
        echo -e "No circuit link, removing it from template"
        sed -i "s/\[CIRCUIT\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Circuit//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
    fi
        
	## Fix code ...
	if [[ $hasCode == "Y" ]]
    then

	    CODE=`cat ${SRC_FOLDER}/${filename}/${filename}.ino`
	    CODE="${CODE//$'\n'/\\n}"
	    CODE="\\\`\\\`\\\`c_cpp\\n\/\/$filename\\n$CODE\\n\\\`\\\`\\\`"
	    ##echo -e "** CODE ** \n$CODE"
        if grep -Fq "[CODE]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
            ## This is a hack to respect the square brackets in the template file
            sed -i "s/\[CODE\]/INSERTCODEHERE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"

        else
            echo "Overwritting old code in ${CURRENT_FOLDER}/${filename}/${filename}.md"
             SEARCH='```c_cpp\n\/\/'$filename'\(.*\)```'
	        echo -e "** SEARCH ** \n${SEARCH}"
            sed -z -i 's/```c_cpp\n\/\/'"$filename"'\(.*\)```/INSERTCODEHERE/g' "${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
        ## And now, do the substitution in a very elegant way
        awk -i inplace  -v cuv1="INSERTCODEHERE" -v cuv2="$CODE" '{gsub(cuv1,cuv2); print;}' "${CURRENT_FOLDER}/${filename}/${filename}.md"
    else
        echo -e "No code in this example, removing it from template"
        sed -i "s/\[CODE\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## Code//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi

    ## Fix license
    if [[ $LICENSE_EMBED != "" ]]
    then
        if grep -Fq "[LICENSE]" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        then
	        ##LICENSE_EMBED="${LICENSE_EMBED//\/\\}"
        	LICENSE_EMBED_HERE="${LICENSE_EMBED//$'\"'/\\\"}"
        	LICENSE_EMBED_HERE="${LICENSE_EMBED_HERE//\//\\\/}" 
	        sed -i "s/\[LICENSE\]/$LICENSE_EMBED_HERE/" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        else
            echo "Code [LICENSE] not found in ${CURRENT_FOLDER}/${filename}/${filename}.md"
        fi
    else
        echo -e "No license in this record, removing it from template"
        sed -i "s/\[LICENSE\]//" "${CURRENT_FOLDER}/${filename}/${filename}.md"
        sed -i "s/## License//" "${CURRENT_FOLDER}/${filename}/${filename}.md"

    fi
    
    ## Clean double EOLs created by removing fields from the template
    sed -i '$!N; /^\(.*\)\n\1$/!P; D' "${CURRENT_FOLDER}/${filename}/${filename}.md"

done < $DATA_FILE

## Create index file
echo "# Course Index" > $INDEX_FILE 

## Reset the header check
HEADER_DONE=0

## Use index file 
echo -e "** CREATE INDEX ** \n$INDEX_FILE"

## Add links to all articles
while read -r number hasCode hasCircuit file video objectives parts circuit introduction description more; do

    ## Remove the first line (containing headers) 
    if [ $HEADER_DONE == 0 ]; then
        HEADER_DONE=1
        continue
    fi

    ## fix the leading zeros in the number variable
    number=$(printf "%02d" $number)

    ## set the filename
    filename="$number-$file"

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

## Iterate through the content
while read -r number hasCode hasCircuit file video objectives parts circuit introduction description more; do

    ## Remove the first line (containing headers) 
    if [ $HEADER_DONE == 0 ]; then
        HEADER_DONE=1
        continue
    fi

    ## fix the leading zeros in the number variable
    number=$(printf "%02d" $number)

    ## set the filename
    filename="$number-$file"

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
