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

