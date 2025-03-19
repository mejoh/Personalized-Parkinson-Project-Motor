#!/bin/bash

# 1mm template
#x=`echo "$1 * -1 + 90" | bc`
#y=`echo "$2 * 1 + 126" | bc`
#z=`echo "$3 * 1 + 72" | bc`
# 2mm template
x=`echo "$1 * -1 + 45" | bc`
y=`echo "$2 * 1 + 63" | bc`
z=`echo "$3 * 1 + 36" | bc`

echo $x 1 $y 1 $z 1
