# Build the project

## Build the templates

Prior to creating a course, you need to define the templates you will be using. The call for the template generation goes as follows:

./create_templates.sh config config templates.csv

and you have to call it inside the *build* folder. It will create a series of subfolders inside the *config* folder. First it will try to create *config* folder itself; this is done to allow testing the script. Next it will create a subfolder called *templates*. Inside that one, it will create a folder called *exercises*, and inside that one, it will create one subfolder for each locale such as *en*, *es*, etc.

The different templates can be defined in the *CSV* file *templates.csv*. Creating a new template structure and thus a new course for a new translation is as easy as adding a new record to the file.

## Build the course

Once the templates have been created, build the basic structure of the course by simply calling:

./create_folders.sh en .. config exercises.csv

inside the *build* folder. It will create all of the folders, *MD*, and *INO* files based on templates. From there you will have to add your own content. Use the editor of your choice.

The parameters for the *create_folders.sh* script are:

* locale: en, es, etc.
* name of the folder with templates and the like, typically *config*
* name of the *CSV* file containing the course

You will have to call it once per locale, which also means you should need the actual *CSV* file for the corresponding language.

## Note

* The *CSV* separator in use is the **¤** symbol in order to have commas within the text
* Current version of the code does not entertain the idea of localised code (but might happen)
