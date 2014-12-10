#!/bin/sh

find . -name "*.[ch]" | xargs  grep $1

