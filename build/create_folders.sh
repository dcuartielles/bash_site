#!/bin/bash

DEST_FOLDER=$1
SETUP_FOLDER=$2
SETUP_FILE=$3

DATA_FILE="${SETUP_FOLDER}/${SETUP_FILE}"

INDEX_FILE="course/en/course_index.md"
INDEX_LINK="..\/course_index.md"

[ ! -f $DATA_FILE ] && { echo "$DATA_FILE file not found"; exit 99; }

OFS=$IFS
IFS=','
##IFS=$'\n'

mkdir ${DEST_FOLDER}
cp -R ${SETUP_FOLDER} ${DEST_FOLDER}

cd ${DEST_FOLDER}

mkdir src
mkdir course
mkdir course/en

## Create files, add titles, add video if it exists
while read -r file video objectives; do
    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $file"
    echo -e   "****************************************\n"
    
    
    ## Work out the code for the example
	mkdir "src/$file";
	if [ -f "src/${file}/${file}.ino" ]; then
        echo "src/${file}/${file}.ino exists. Changing properties."
    else 
        echo "src/${file}/${file}.ino does not exist. Creating it."

    	cp "${SETUP_FOLDER}/templates/template.ino" "src/${file}/${file}.ino";
    fi
	TITLE_TEMP="${file//-/: }"
	TITLE="${TITLE_TEMP//_/ }"
	sed -i "s/\[NAME\]/Exercise $TITLE/" "src/${file}/${file}.ino"

    ## Work out the text for the example
	mkdir "course/en/$file";
	if [ -f "course/en/${file}/${file}.md" ]; then
        echo "course/en/${file}/${file}.md exists. Changing properties."
    else 
        echo "course/en/${file}/${file}.md does not exist. Creating it."

    	cp "${SETUP_FOLDER}/templates/template.md" "course/en/${file}/${file}.md";
    fi

    ## Fix title
    if grep -Fq "[NAME]" "course/en/${file}/${file}.md"
    then
	    TITLE_TEMP="${file//-/: }"
	    TITLE="${TITLE_TEMP//_/ }"
	    sed -i "s/\[NAME\]/Exercise $TITLE/" "course/en/${file}/${file}.md"
    else
        echo "Code [NAME] not found in course/en/${file}/${file}.md"
    fi
    
    ## Fix objectives
    if grep -Fq "[OBJECTIVES]" "course/en/${file}/${file}.md"
    then
	    OBJECTIVES="${objectives//\/\\}"
	    sed -i "s/\[OBJECTIVES\]/$OBJECTIVES/" "course/en/${file}/${file}.md"
    else
        echo "Code [OBJECTIVES] not found in course/en/${file}/${file}.md"
    fi
    
    ## Fix video
    if [[ $video != "" ]]
    then
    	VIDEO="${video//$'\"'/\\\"}"
    	VIDEO="${VIDEO//\//\\\/}" 
        echo -e "** VIDEO ** \n$VIDEO"
        if grep -Fq "[VIDEO]" "course/en/${file}/${file}.md"
        then
	        sed -i "s/\[VIDEO\]/$VIDEO/" "course/en/${file}/${file}.md"
        else
            echo "Code [VIDEO] not found in course/en/${file}/${file}.md"
        fi
    else
        echo -e "No video link, removing it from template"
        sed -i "s/\[VIDEO\]//" "course/en/${file}/${file}.md"
        sed -i "s/## Video tutorial//" "course/en/${file}/${file}.md"

    fi
	
	## Fix code ...
	CODE=`cat src/${file}/${file}.ino`
	CODE="${CODE//$'\n'/\\n}"
	CODE="\\\`\\\`\\\`c_cpp\\n\/\/$file\\n$CODE\\n\\\`\\\`\\\`"
	##echo -e "** CODE ** \n$CODE"
    if grep -Fq "[CODE]" "course/en/${file}/${file}.md"
    then
        ## This is a hack to respect the square brackets in the template file
        sed -i "s/\[CODE\]/INSERTCODEHERE/" "course/en/${file}/${file}.md"

    else
        echo "Overwritting old code in course/en/${file}/${file}.md"
         SEARCH='```c_cpp\n\/\/'$file'\(.*\)```'
	    echo -e "** SEARCH ** \n${SEARCH}"
        sed -z -i 's/```c_cpp\n\/\/'"$file"'\(.*\)```/INSERTCODEHERE/g' "course/en/${file}/${file}.md"
    fi
    ## And now, do the substitution in a very elegant way
    awk -i inplace  -v cuv1="INSERTCODEHERE" -v cuv2="$CODE" '{gsub(cuv1,cuv2); print;}' "course/en/${file}/${file}.md"

done < $DATA_FILE

## Create index file
echo "# Course Index" > $INDEX_FILE 

## Use index file 
echo -e "** CREATE INDEX ** \n$INDEX_FILE"

## Add links to all articles
while read -r file video objectives; do
    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $file"
    echo -e   "****************************************\n"

    ## Append text at the end of the file
    echo "* [${file}](${file}/${file}.md)" >> $INDEX_FILE
    
done < $DATA_FILE

## Generate bottom links in content files
PREVIOUS_LINK=""
CURRENT_LINK=""
FOLLOWING_LINK=""
PREVIOUS_FILE=""
CURRENT_FILE=""
FOLLOWING_FILE=""

## Iterate through the content
while read -r file video objectives; do
    ## Notify what is going on
    echo -e "\n****************************************"
    echo -e   " Working out example $file"
    echo -e   "****************************************\n"

    ## Set following file
    FOLLOWING_LINK="..\/${file}\/${file}.md"
    FOLLOWING_FILE="course/en/${file}/${file}.md"

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
