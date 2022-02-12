#!/bin/bash

## 20220209 creates a site with default parameters

## Build the templates
./create_templates.sh

## Create the site's scaffolding
./empty_site.sh

## Build the facade
./populate_site.sh -n 10

## Build the site
##./render_site.sh
