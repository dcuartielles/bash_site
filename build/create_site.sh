#!/bin/bash

## 20220209 creates a site with default parameters

## The possible parameters are:
## ** -n: number of pages (default 0)
## ** -t: template (default basic1)

## Read parameters from CLI
while getopts ":n:t:" opt; do
  case $opt in
    n) NUM_PAGES="$OPTARG"
    ;;
    t) DEFAULT_TEMPLATE_ARG="$OPTARG"
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

## Set default parameters
[[ ${NUM_PAGES} == "" ]] && NUM_PAGES=10
[[ ${DEFAULT_TEMPLATE_ARG} == "" ]] && DEFAULT_TEMPLATE_ARG="video1"

## Build the templates
./create_templates.sh

## Create the site's scaffolding
./empty_site.sh

## Build the facade
./populate_site.sh -n "$NUM_PAGES" -t "$DEFAULT_TEMPLATE_ARG"

## Build the site
./render_site.sh

## Done
echo -e "** Done"
