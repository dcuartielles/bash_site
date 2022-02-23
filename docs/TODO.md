# TODO

This file shows a list of the things I would like to include in this project. Items are **NOT** listed by priority. I do first what I consider more important based on my personal needs and then ones of those using the software.

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

### PDF renderer for the whole course

Render the whole course as a book of sorts

### PDF renderer for exercises

Render an exercise as a PDF

### HTML renderer for exercises

Render an exercise as an HTML file

### Download full course

Puts the whole course into a single compressed file and adds it as a download at the bottom of the index site

### Download compressed exercise block

New block that compresses the markdown version of an exercise, its images and code and puts them into a zip file, adding it inside the article

### Empty course generation script

Add the amount of exercises, the default template, a string with template names for some exercises, and see how the scaffolding of a course grows in front of your eyes
