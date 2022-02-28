# LOGS

Read here the full design logs, day by day, for the Bash Site Creator from the day the project started.

## 2022 February

See what happened in the second month of the year.

### 20220227: added PDF export to export_site

* included the *PDF* export feature
* TODO: include offline images for both *HTML* and *PDF* exports   
* TODO: include screencap of video file for PDFs + clickable URL

### 20220226: added index correction to export_site in HTML

* *export_site.sh* is now looking into all of the files and linking to *HTML* files instead of Markdown ones, this removes the possibility of having files with the extension *\*.md*
* TODO: create a nice CSS for this ... maybe extract the one from Github pages

### 20220225: scripting pandoc

* *pandoc* is now officially a dependency to this project, therefore I have updated *BUILD.md* to include dependencies
* created *export_site.sh*, a script to wrap the operations with *pandoc* after making all the needed preparations to the Markdown files
* worked out the basic operations for exporting as *HTML*

### 20220224: testing pandoc

* *pandoc* has some serious superpowers, it can use your own CSS, it can generate the TOC in a PDF, etc
* this also means that, after some testing, I will need to produce a tool which will be searching for materials and produce a preliminary file that could be sent to *pandoc*, e.g. I cannot put a video in a PDF, I will have to extract a screenshot of the video and add the clickable URL as a caption. Yet another example, I might have to locally download remote images with *Curl* prior to producing a compressed file in HTML with all of the assets for offline distribution of the content (which is one of my goals)
* PDF files should be created from a single massive Markdown file, where contents should be sorted for *pandoc* to create the TOC
* rendering HTML will require making my own tool looking for all *\*.md* files in a folder structure to be rendered as HTML

### 20220223: research on exporting

* I want mainly two different kinds of exports: HTML (in order to make the system independent from Github when publishing), and PDF (because a lot of people use it to distribute materials to their students). I came to just two possible solutions: *cmark* and *pandoc*
* [*cmark*](https://github.com/commonmark/cmark) is a C tool, thus the fastest one currently existing capable of converting Markdown to HTML, it is considered the standard tool to benchmark your own against. The issue is that it does not produce PDFs
* [*pandoc*](https://pandoc.org/) is the Swiss knife of format conversions from CLI, does not only HTML and PDF, but also LaTeX, AsciiDoc, Docx, etc.
* I think I have to sacrifice performance for versatility, mainly because I will otherwise have to produce my own PDF export tool. The disavantage is obvious: I will need Linux to run my tool (which I do anyway, since I made things in *bash* ¯\\_(ツ)\_/¯)

### 20220222 (or 22022022): pre-alpha Twosday release

* this is the very first release, pre-alpha 0.0.1 of the **Bash Site Generator**, it has been two months of work to make it to this point with small developments day after day
* added the *DEFAULT_TEMPLATE* property to the *populate_site.sh* script to simplify the creation of sites with all-equal pages
* modified *create_site.sh* to add simple parameters as input, such as the amount of pages in the the site and the default type of template to use
* remember: to make CLI captures without showing my username: `export PS1="\[\e]2;>>> DEMO >>>\a\e[32;1m\]>\[\e[0m\] "`

### 20220221: changed repo

* cleaned up the house, moved from the original repo to *dcuartielles/bash_site*. This repo can now easily be forked as a way to create new repositories. Once I am done cleaning up everything, I will use it again to create the *Introduction to Arduino Nano 33 BLE Sense* I was planning to create in the first place
* removed backup and legacy folders towards a pre-alpha release

### 20220220: revised readme

* made *README.md* into a more comprehensive file liking to the different available files

### 20220219: separate logs from readme

* moved the *LOGS* and the *TODOs* in their own separate files inside *docs*
* moved *BUILD.md* and *DOGMA.md* into the *docs* folder

### 20220218: verbose is popular

* added verbose to *populate_site.sh* as a way to keep the debug information I added the last days (and remove it at will). This adds a new parameter *-v* which can take values 1 and 0 for on or off
* TODO: allow *populate_site* to have one new argument to set the default template for an automatic or semiautomatic *pages.csv* generation
* TODO: still need to fix the index generation for *render_site.sh*
* TODO: add verbose to *render_site.sh*
* TODO: fix the URL for local images in *populate_site.sh*

### 20220217: it was about time to have utils

* created *utils.sh* to include functions that are used at all scripts such as the array search and others that might show as the project keeps on growing
* TODO: fix index generation for *render_site.sh*, found out that the edge case of one single page generates an index with *Prev*, IOW it links to an empty previous page

### 20220216: we need docs

* created a *config/docs* folder to start pushing some documentation in it. I realised how complex things were becoming when I could not remember the different properties I had created and in which order they had to be placed
* the obvious consequence was to start documenting things, thus I made a [PROPERTIES](config/docs/PROPERTIES.md) file to list the properties and possible values for each type of field

### 20220215: populate the site resurrections

* after a couple of days fighting the code, I managed to finish *populate_site.sh* it now checks the titles of the descriptions against the *DEFAULT_PROPERTIES* array as well as uses different default content for each type of data, making it easier to fill in the default template by implementing some placeholders of sorts

### 20220214: day of love

* done some work with *populate_site.sh* while eating heart-shaped candy, was good. I am far from done, this script is getting complicated

### 20220213: render site reloaded IV

* forth day working with *render_site.sh* dealing with massive bug fixes and addressing the different open TODOs
* TODO: still need to fix the *populate_site.sh* script

### 20220212: render site reloaded III

* third day working with *render_site.sh*. This time the general loop is finished. The indexing part seems to work but there are issues with parameter handling.
* TODO: revise *populate_site.sh* since it fills in all fields in the same way making no distinction for video, images, etc. Thus it produces the wrong parameters
* TODO: figure out why it is not navigating through the whole list of parameters, half of them are not in there

### 20220211: render site reloaded II

* second day working with the *render_site.sh* revamp. Had to give quite a thought to the file naviation as I noticed how *populate_site.sh* was totally capable of rendering a Markdown file without the intermediate need of having templates to be copied into folders ... but then I remembered that some people just want to go into folders and manually change files, so ... I went for the good old method

### 20220210: render site reloaded

* first attack to the issue of fixing the *render_site.sh* script after having changed the format for all of the content
* added config file and unsorted parameter handling features
* TODO: currently I only embed videos from Vimeo, what about inserting Youtube ones?

### 20220209: a single creation script

* made a single script to create sites, thus called *create_site.sh* from a single execution avoiding mistakes happening in step-by-step instructions
* also, corrected a bug in *empty_site.sh* provoked during the migration to a single configuration file

### 20220208: a config file to rule them all

* unify all configuration variables into a single file *config/config.conf*
* used some basic whitelisting protection to avoid calls in the config file to anything that is not a variable declaration

### 20220207: arguments always come back

* implemented unsorted arguments for the *create_templates.sh*, the *empty_site.sh*, and the *analyse_site.sh* scripts
* the *empty_site.sh* script includes the following list of parameters now:
  * -l: locale (default en)
  * -c: config / setup folder (default config)
  * -f: data file
  * -d: destination folder
  * -s: site subfolder where to store templates
  * -f: pages subfolder
  * -o: destination file for each locale
* the *create_templates.sh* script includes the following list of parameters now:
  * -d: destination folder
  * -c: config / setup folder
  * -f: data file
  * -p: pages folder
* the *analyse_site.sh*, while it has to be revised to accommodate the new configuration of the *pages.csv* file, has also been revamped to use unsorted parameters such as:
  * -l: locale
  * -c: config / setup folder
  * -f: data file
  * -d: destination folder
  * -s: site subfolder where to store templates
  * -f: pages subfolder

### 20220206: arguments should be unsorted

* revised *populate_site.sh* to use unsorted parameters for the win. The possible parameters are:
  * -l: locale
  * -c: config / setup folder
  * -f: data file
  * -n: amount of pages
  * -m: mode
* added default parameters for the script
* the fastest way to generate a site with 10 pages is now `./populate_site.sh -n 10`
* corrected *BUILD.md* to cover this new way of calling the script
* TODO: will have to make this same work for all of the other scripts

### 20220205: dialog for the win

* I spent some time reading about Linux' command *dialog* which I will try out as a way to beautify the whole installation process. Read more about [dialog here](https://linuxcommand.org/lc3_adv_dialog.php).

### 20220203 - 20220204: covid times

* Ok, I am not a robot, I do not have super powers, after three shots of the vaccine, I got a flu -or so I thought- that ended up being covid and put me down for a couple of days. I caught up with a bunch of TV shows. Now I know, CSI Vegas ends with a kiss

### 20220202: a magical day

* in the second day with most 2s I will ever witness in my life, I went back to work with *populate_site.sh* adding an `automatic` mode that will allow to quickly fill up everything instead of going through every single field like until now
* added also the `semiautomatic` mode for the script to request just the template for each page and automatically filled up everything else (recommended)
* added information about *populate_site.sh* to *BUILD.md*

### 20220201: fill up the dataset III

* merged the original header file *pages.csv* and the generated dataset *pages.tmp* and deleted temporary files
* TODO (aha moment): what if I made a mod of *populate_site.sh* that would be slightly more clever and would open a file and let you add fields, edit existing ones, etc?

## 2022 January


### 20220131: fill up the dataset II

* worked with *populate_site.sh* for it to detect templates, types of fields, types of code, types of images, etc
* it is now a full interactive script that can help you create a CSV file with all the content needed to render a site
* WARNING: I have changed the order of the properties back and forth, this may or not affect the new version of *render_site.sh* I am currently working with
* TODO: do the final merging of the new data generated with the original *pages.csv* in order to have a full working output file

### 20220130: fill up the dataset

* fixed an issue with the *create_template.sh* script, it was somehow creating weird filenames out of the records in *templates.csv*
* populated the *pages.csv* file generated by the *empty_site.sh* script to be able of experimenting with all of the new formats. For this created a new script *populate_site.sh* which uses *pages.csv* as a paramter, as well as the locale and will ask you for the amount of pages to include and then iterate to help you to automatically fill in the dataset with the most basic information (you will have to later edit the *CSV* file to put in the rest of the information)
* created *render_site.sh* as a copy of the legacy script *render_course.sh*, nothing done with it just yet
* TODO: *populate_site.sh* needs some more love

### 20220129: clean the house

* having two versions of the software is starting to be an issue. I created a folder with the old stuff and separated the new stuff
* to make things easy, I renamed build into *build_legacy* and created a new *build* folder where to store things

### 20220128: the Dogma

* got the booster shot against covid-19, the dude who push the vaccine into my arm told me not to go to gym in 24h (haha), coding requires moving fingers, so I will go light on bash today
* created a [Dogma file](DOGMA.md) to let you know, dear reader, about the limitiations of this software
* revised the *BUILD.md* file to reflect the new workflow
* TODO: in the notes I write about *render_site.sh* a script which does not exist, yet. I need to redo the old *render_course.sh* to support the modifications made to the scaffolding files

### 20220127: multiple small things

* modified *create_templates.sh* to support different types of sites, this allows using *pages* or *exercises* by simply changing a variable
* corrected *emtpy_site.sh* for it not to start with and empty line, that would create undesired behaviours in subsequent scripts
* even if it is legacy by now, corrected *create_templates.sh* from the same empty line bug
* created *analyse_site.sh* as a way to revise the previous script dedicated to check on the contents of a site. It is made to support the latest dataset structure
* TODO: the site analysis script has not been tested against a real dataset, so for now works, but who knows once there is data in it

### 20220126: empty course script

* Based on yesterday's work, I created a script called *empty_site.sh* which takes the amount of pages as a parameter to generate a *CSV*
* Note how this is an entirely different approach to the one I used with *create_exercises.sh* that was built around the idea of having a single template for all pages
* It will also require a different structure for the header rows in the *exercises.csv* files (which, BTW, I will start calling *pages.csv*) since I now have to declare a non-determined amount of templates as well as fields. There are two ways around it: including the templates on top of the *CSV* file one after the next, or to have them as comma-separated fields at the beginning of every page. The second solution will make the file larger, but will also be easier to handle programmatically, so I go for that
* TODO: need to add the right parameters for each type of the blocks. It could be done by hand, but it would be so much better to do so programmatically
* TODO: revise the *analyse_course.sh* script to support this new form of data storage

### 20220125: flexible page templates

* From now on I will call pages ... pages. Before I was referring only to exercises, but by taking this step -calling them pages- I am broadening the scenario of use of this tool
* Intial step towards flexible templates: created different template types, have named them in the templates CSV to be able of calling them when generating the exercises *CSV*
* Modified *create_templates.sh* to now create templates using the template type in its file name
* TODO: in order to modify the course generation to support multiple templates, I will have to go through an inbetween step since I will need to declare the course's length, and the type of template to use with each exercise

### 20220124: multiple listings for code

* You made your own code and want multiple listings with different names for a single exercise? There is now a property for that
* Properties for code now look like *true,code,Arduino,true*, where the last property indicates whether the creation system should generate the code or not using the exercise name
* If this new property happens to be *false* the rendering script will instead use the *CODE* field as the name of the program to be created. This will allow to potentially have an endless amount of different pieces of code in a single example
* The example folder will also be created using this same name
* The field that was used for code description will now have to be substituted in the templates by a dedicate textfield

### 20220123: remove exercise numbers from the code files

* Revised the file generation of code for not to include numbers, this was forgotten in a previous iteration of code. Remember that having file numbers in the code, while desireable, makes it hard for things to be sorted out in case the exercise numbers change
* Revised folders for local images as well
* TODO: add a property to avoid code generation upon course creation, to help those making their own code and not needing this service
* TODO: code is starting to get big, I should plan for a day dedicated to cleaning and considering options

### 20220122: fix analytics script

* The changes to the properties of code, affected the script *analyse_course.sh*, added a bunch of code to be able of checking the code types and checking whether templates are available
* Fixed an issue with the way different types of code were calculated

### 20220121: encoding HTML in bash

* OMG Stackoverflow to the rescue, how to use a singe *sed* to easily encode *HTML* files so that they can be added as code examples, now this is rocking the house ([full credit here](https://stackoverflow.com/questions/12873682/short-way-to-escape-html-in-bash))
* Tested the rendering with an HTML example to see that it works (Note: I am still only checking things locally, not pushing to Github pages)
* TODO: when code files are generated, they include the exercise number. That has to be removed or it will not allow for sorting things differently and code will get lost  

### 20220120: code templates

* Created a series of code templates for the different types of code blocks that could be part of the tutorials and hosted them in the *config/templates/code*, these will be called by the tutorial generation system when needed
* New templates for: C (.c), C++ (.cpp), Processing (.pde), p5js (.js), Python (.py), HTML (.html)
* Moved the templates into their own subfolders, changed the rendering code to support them
* TODO: check whether the HTML block needs to be encoded to avoid errors upon rendering

### 20220119: DeOldify

* Spent the coding evening trying out DeOldify in my computer to rescue some old pix from the family, did I ever tell you my grandfather was a hair-dresser? Check the pic, he's the guy on the left:

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/20221220_jc_in_the_50s.jpg" width=25%>

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
