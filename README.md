# Introduction to Interactive Prototyping for anyone

This is an introductory course to microcontrollers, sensors, and actuators using Arduino Nano 33 BLE Sense. Originally created for Malmo University students in the Spring term 2021.

## Why the Arduino Nano 33 BLE Sense

The Arduino Nano 33 BLE Sense comes with embedded sensors, BLE connectivity, and enough computing power to perform edge machine learning operations.

![Official Arduino Nano 33 BLE pinout](https://docs.arduino.cc/static/c18e027f826663ba9f16ffd94b60500f/ABX00031-pinout.png)

## Access the content

Content will be populated as time goes by. Check:

[THE INDEX FILE](course/en/course_index.md)

## Build the content

The content's scaffolding is created by running the build process. Check:

[THE BUILD FILE](BUILD.md)

## Updates

### 20220121: encoding HTML in bash

* OMG Stackoverflow to the rescue, how to use a singe *sed* to easily encode *HTML* files so that they can be added as code examples, now this is rocking the house (full credit to: )
* Tested the rendering with an HTML example to see that it works (Note: I am still only checking things locally, not pushing to Github pages)
* TODO: when code files are generated, they include the exercise number. That has to be removed or it will not allow for sorting things differently and code will get lost  

### 20220120: code templates 

* Created a series of code templates for the different types of code blocks that could be part of the tutorials and hosted them in the *config/templates/code*, these will be called by the tutorial generation system when needed
* New templates for: C (.c), C++ (.cpp), Processing (.pde), p5js (.js), Python (.py), HTML (.html)
* Moved the templates into their own subfolders, changed the rendering code to support them
* TODO: check whether the HTML block needs to be encoded to avoid errors upon rendering 

### 20220119: DeOldify

* Spent the coding evening trying out DeOldify in my computer to rescue some old pix from the family, did I ever tell you my grandfather was a hair-dresser? Check the pic, he's the guy on the left:

<img src="https://github.com/dcuartielles/Intro-Arduino-Nano-BLE-33-Sense/raw/main/docs/img/20221220_jc_in_the_50s.jpg" width=25%>

### 20220118: analytics are fun

* Based on yesterday's work, implemented the analytics script. Decided to develop it as a separate script called *analyse_course.sh* to keep the code clean, for now
* Silenced the properties array declaration in the *render_course.sh* script for a better output
* TODO: figure out a way to use *analyse_course.sh* for an early error detection (so far only detects the lack of code templates)
* TODO: add detection of template for current locale

### 20220117: transitional day

* Cleaned up all of the TODOs in the *render_course.sh* script
* Drafted an analysis tool to check on an exercise file to extract some basic information from it, such as: number of blocks of code, local images, etc.

### 20220116: fixed the code issue

* Fixed the issue with the code having && or & in it. It turnd out to be an issue with the way *awk* handles this reserve character, and it cannot be escaped properly

### 20220115: tiny things make a difference

* Removed the exercise from code examples, what will allow to easily rearranging examples without having to renumber the code blocks BY HAND :-O
* FIXME: Adding already existing code including the special character **&** (as in a logical *AND* operation) will insert the *INSERTCODEHERE* tag undesirely in the code
* Added property to images to determine whether they are local or not. When local it will create a folder to host them for that specific exercise. If there are no local images, they will be banned from the content. Examples of parameters are: "true,image,local" or "true,image,remote"
* Made *render_course.sh* the official rendering script for the course

### 20220114: do the do only when needed

* Create the empty code blocks using templates, but make sure you only create those which are going to be used, do not even create a folder, otherwise
* Code will now be under the folder structure: *src/[extension]/[exercise_name]*
* Create folders for images when detected in code --> TODO: add property indicating whether it is a local image to avoid creating empty folders

### 20220113: adding properties instead of booleans

* Decided to go for properties fields for the repetitive fields
* Stored properties into an array containing: "visibility,type,typeProperty1,typeProperty2"
* Example of property array for a piece of Arduino code (*c_cpp*), which has extension (*ino*): "true,code,c_cpp,ino"
* Example of property array for an image: "true,image"
* Added the possibility of having textual introduction to code blocks

### 20220112: baked a cake

* Learned how to make frosting for a cake for my kid's birthday, not really programming related, but fun
* Extended the rendering script with the missing features of index generation 
* Added navigation menu in all examples
* Added code section to clean blanks from the final exercise markdon files


### 20220111: back to the roots

* Reworked the original script, now called *render_course.sh* to get it to work with endlessly long records (IOW, with as many fields as wanted)
* TODO: properties, currently called *hasWHATEVER* should be comma separated arrays containing whether something should be rendered, and some other aspects like type of data (code, image, etc), subtype (e.g. programming language codes for github)
* Tested with the template rendering script and populated with the Arduino Nano 33 BLE Sense course
* **Important**: the *CSV* files now have a format including two header rows with field names, and whether data should be used or not, need to make sure the first two fields in the second row get filled with zeros


### 20220110: exercises file generator

* Moved the location of the *index* section in the template generator to facilitate the creation of the exercise generator. The first 4 fields are reserved and thus not used for the exercise generator
* TODO: place the *index* section in a floating *DIV* to allow moving it around via *CSS*
* Created the exercise generator aka *create_exercises.sh* to automatically create exercise *CSV* files for each locale (filling them up with content is YOUR thing)
* New format for exercise files including *VARIABLE* and *hasVARIABLE* to allow for both a general inclusion of a field and a more granular one exercise to exercise
* The new format can be as long as you want
* TODO: test these exercise files with the previous rendering script
* TODO: simplify the rendering script to include just three different parts: title addition, index addition (and index file creation), and general content field handling
* This opens the possibility of adding multiple images per project, multiple code inserts, multiple programming languages, etc


### 20220109: template generator

* De:bug the objectives were not checked, but the parts when rendering objectives. FIXED
* De:bug the header detection was only working the first time, now works also the other two times it shows up in the code. FIXED
* License removed from template as text and made into a variable. In the future it will be taken from a config file (like, most likely, all of the other variables like folder names and the like)
* Add *locale* folder for templates, opening the work towards courses with multiple translations
* Revised the *BUILD* file to reflect the addition of locales in the render
* NEW: added a template generator from a *CSV* file. This will allow for super simple localisation of the course structure, you will still need to translate the content, though ;-)

### 20220108: patching the folders

* Fixed the folder structure from hard-coded to variables to better support portability
* Removed any kind of content being empty from being rendered, this will allow for content to slowly show in the pages as it is being added to the spreadsheet (cool-to-have feature when slowly releasing courses)
* Added extra fields to the dataset to support all remaining information to fill in the templates
* Added code to render the new fields into the template
* Cleaned up multiple EOLs in the exercises appearing upon removal of unused fields

### 20220107: edit from Libreoffice

* Added headers to the data columns, added ability to jump over the header line in the dataset when iterating through the content
* Editing in Libreoffice implies converting numbers with leading zeroes into pure **ints**, this requires adding a leading zero addition to the numbering string when the index is below 10
* Added folder for local images, illustration of circuits, etc
* Added subfolder for images to specific exercises. Just to keep'm tidy


### 20220106: remove repetition

* Remove video prefix and suffix from the *CSV* file and put it into the script as variables. This reduces the dataset's size by 30%
* Tested (successfully) the usage of Libreoffice for editing the *CSV* file, exporting and bringing it back into the workflow

### 20220105: circuit bending

* Remove the circuit component if there is no circuit to show
* Updated the dataset to include the hasCircuit field
* Added an image to test in the breadboard exercise

### 20220104: the big separation

* Modified the separator in the *CSV* file to support text with commas
* Added parts to the exercises and the substitution in the creation script
* Separated exercise number from the filename, which will  allow ordering the articles in different ways by changing the number, sorting the dataset, and rendering the content
* Added a field to determine whether exercises have - or not - Arduino code. If not, removes it from the template

### 20220103: get an objective

* Includes objectives in the articles
* No video link? Remove it entirely from the template

### 20220102: the indexing commit

* Generates an index file
* Generates a navigation bar
* Basic rendering to *dcuartielles.github.io*

### 20220101: initial commit

* Script to render a new course starting from a *CSV* file including information about lecture names and video material
* Uses templates for code files and for articles
* Code is stored in the *src* folder
* Lectures are stored in the *course* folder
* Ready to support multi-language by storing original files under the *course/en* subfolder
* Creation code is under the *build* folder
* Configuration is under the *build/config* folder, including templates and *CSV* files
* Run the creation script if you make changes in the code, it will update the articles without having to copy-paste into the articles
* Fills in title of all code example files
* Fills in title and video information of all lecture materials

## Things I would like to add

### A full test run

Create a script to run a whole creation of a course: 

1. asks about the fields to add to a template, 
2. creates the template *CSV*, 
3. continues with the template generation, 
4. checks whether there are basic templates for the types of code to be included,
5. copies the different files in the proper location,
6. asks how many exercises should be included in the course,
7. creates the course *CSV*, asking for some basic information like exercises names and the like,
8. calls the course rendering script

### Support different amounts of fields per record

What if people do want to create more dynamic sets of exercises where the articles strongly deviate form a basic template? How would code have to look like in this case?

### Image thumbnails of articles

If people want to share specific articles from their course / site, they need to add a bit of HTML love to their headers. More [information here](https://nickcarmont8.medium.com/how-to-add-a-website-thumbnail-for-sharing-your-html-site-on-social-media-facebook-linkedin-12813f8d2618)
