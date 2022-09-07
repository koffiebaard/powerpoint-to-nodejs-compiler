#!/bin/bash
verbose=1

# Validate filename parameter before proceeding
if [[ ! -n $1 ]] || [[ ! -f "$1" ]]; then
  echo "Error. Provide a valid pptx filename to compile.";
  exit 1;
fi

filename="$1"
slide_amount=$(unzip -l "$filename" ppt/slides/slide*.xml | awk '{print $2}' | tail -1);
code=""

[ $verbose -eq 1 ] && printf "Filename: $filename\nSlide count: $slide_amount\n\n"

# Parse each slide and gather all that delicious code
for slide_number in `seq 1 $slide_amount`; do

  [ $verbose -eq 1 ] && echo "- Parsing slide $slide_number / $slide_amount"

  code_on_slide=$(unzip -qc "$filename" ppt/slides/slide$slide_number.xml | perl -e 'while(<>) {  if (@list = ($_ =~ m/\<a:t\>(.+?)\<\/a:t\>/g)) { print "$_\n" for @list } }' | tr -d "\n");
  code="$code $code_on_slide";
done

[ $verbose -eq 1 ] && printf "\n------------------------\n\n"

# Execute all code we find. What's the worst that could happen?
node -e "$code"
