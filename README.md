# Bash Site Generator

The **Baah Site Generator** is a piece of software to help in the creation of courses which will be rendered as **Markdown** files, including an index, etc.

The generator is a collection of scripts that can be executed step by step to:

1. create a series of localised templates to pages
2. automatically fill in a predefined amount of pages to compose a site
3. generate an index file to help navigating the final site
4. generate a navigation bar in every page with *Next* and *Previous* links
5. store the whole site as a spreadsheet for easier editing
6. render the site from the spreadsheet as a series of markdown files
7. automatically create empty code files for every code block with the right titles for you to fill in
8. visualise the site as part of Github pages
9. includes block for video, images, code, plain text, HTML, and licenses
10. code blocks come with color coding for: C, C++, Processing, JavaScript, Python

## Super simple example

First, open a terminal window, clone the repo, and navigate to the *build* folder.

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/00_create_site.gif">

There will be a lot of data pushed out to the *CLI*, check whether there are any errors.

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/01_explore_system_output.gif">

In this example, we are using a simplified template using just an introduction and a video field (plus license, name, and index fields). Use `less [path]` to see the contents of any of the pages.

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/02_explore_page.gif">

The code will also render an index page with links to all of the pages in the site.

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/03_explore_site_index.gif">

## Why Bash

Bash is a very powerful and simple command line scripting mechanism.

## Access the docs

The documentation to the Bash Site Generator has been made with the Bash Site Generator. Check:

[THE SITE](https://dcuartielles.github.io/bash_site/)

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/04_explore_page_rendered.gif">

[THE INDEX FILE](https://dcuartielles.github.io/bash_site/site/en/site_index.html)

<img src="https://github.com/dcuartielles/bash_site/raw/main/docs/img/05_explore_site_index_rendered.gif">

## Build your own site

The content's scaffolding is created by running the build process. Check:

[THE BUILD FILE](docs/BUILD.md)

## Updates

See [THE LOGS FILE](docs/LOGS.md) for a full day-to-day update of the creation of this project.

## Things I would like to add

Do you wanna know what I have in mind for this project? Read about it in my [TODO LIST](docs/TODO.md)

## Current version

**pre-alpha a.k.a. Twosday edition** published on 22022022

## License

Do you need one? Yepp, I got you covered, [I used CC0](LICENSE).
