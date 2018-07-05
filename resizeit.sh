#!/bin/bash
#check if have a parameter
if [ "x""$1" = "x" ];
then
    echo " -- ERROR --"
    echo "Please specify a folder with images to be converted"
    exit 1
fi

#check if its a valid parameter
if [[ $(ls -A $1 2> /dev/null ) ]]; then
    echo "Files found...continuing"
else
    echo "No files found or folder not found"
    exit 1
fi

#Help message
if [ "$1" = "-h" ];
then
    echo "Usage is ./resizeit.sh Path/to/image/folder"
    echo "This script will create the following folders and the resized images inside them"
    echo "  Mogrify_images"
    echo "  Convert_images"
    echo "  ScaleMogrify_images"
    echo "  KeepAspectRatio_images"
    echo "  GM_images"
    echo "and a file with log information Files.csv"
    exit 1
fi

#check if gm is installed
if [ $(which gm | wc -l) -eq 0 ]; then
        echo "GraphicsMagick is missing from your system. Please download the latest version:"
        echo "OS X: brew install graphicsmagick"
	    echo "Debian/Ubuntu: apt-get install graphicsmagick"
	    echo "RedHat/CentOS: yum install graphicsmagick"
        exit
fi

#check if imageconvert is installed
if [ $(which convert | wc -l) -eq 0 ]; then
        echo "ImageMagick is missing from your system. Please download the latest version:"
        echo "OS X: brew install imagemagick"
	    echo "Debian/Ubuntu: apt-get install imagemagick"
	    echo "RedHat/CentOS: yum install imagemagick"
        exit
fi

#Check files with spaces
cd $1
for f in *\ *; do mv "$f" "${f// /__}" 2> /dev/null ; done

#Create folders
echo "Creating DIRs..."
mkdir -p Mogrify_images
mkdir -p Convert_images
mkdir -p ScaleMogrify_images
mkdir -p KeepAspectRatio_images
mkdir -p GM_images

#Get the files
files=($(ls -p | grep -v / ))

#get information about the files
echo "file_name,file_type,file_size,convert_TimeReal,mogrify_TimeReal,Scale_Mogrify_TimeReal,AspectRatio_convert_TimeReal,GM_TimeReal" > ../Files.csv
echo "Converting Files..."
for file in "${files[@]}"
do
	filename=$(identify $file | cut -f1 -d ' ')
	filetype=$(identify $file | cut -f2 -d ' ')
	filesize=$(identify $file | cut -f3 -d ' ')

#convert using convert	
	times=$( { time convert $file -resize 500x500! Convert_images/$file ;} 2>&1)
	treal=$(echo $times | cut -f2 -d ' ')

#convert using mogrify
	motimes=$( { time mogrify -resize 500x500! -path Mogrify_images $file ;} 2>&1)
	motreal=$(echo $motimes | cut -f2 -d ' ')

#convert using mogrify with scale
	smotimes=$( { time mogrify -scale 500x500! -path ScaleMogrify_images $file ;} 2>&1)
	smotreal=$(echo $smotimes | cut -f2 -d ' ')

#convert keeping aspect ratio  and using scale+filter point
	artimes=$( { time convert -filter point $file -scale 500x500 KeepAspectRatio_images/$file ;} 2>&1)
	artreal=$(echo $artimes | cut -f2 -d ' ')

#convert using gm with size and scale option
    gmtimes=$( { time gm convert -size 500x500! $file -scale 500x500! GM_images/$file ; } 2>&1)
	gmtreal=$(echo $gmtimes | cut -f2 -d ' ')


	echo $filename,$filetype,$filesize,$treal,$motreal,$smotreal,$artreal,$gmtreal >> ../Files.csv
done
cd ..
echo "Done."
