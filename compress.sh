#!/bin/bash

html-minifier --collapse-whitespace --remove-comments --remove-redundant-attributes --remove-tag-whitespace index.html -o _dist/index.html
html-minifier --collapse-whitespace --remove-comments --remove-redundant-attributes --remove-tag-whitespace css/uxbook.css -o _dist/css/uxbook.css

echo done
