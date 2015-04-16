#!/bin/bash

cat | sed -e 's/N\/A[ 	]*//' | tr "," "\012" | sed -e 's/  *//g' | tr "[A-Z]" "[a-z]" | sed -e 's/^www\.//'

