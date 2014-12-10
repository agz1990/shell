#!/bin/sh
find -type f | xargs  file   | awk -F':[ \t]+' '/ELF 32-bit LSB (relocatable|shared|executable)/ {print $1 }' | sed 's|^\./||'
