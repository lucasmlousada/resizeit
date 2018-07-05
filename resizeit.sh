#!/bin/bash

if [ "x""$1" = "x" ];
then
    echo " -- ERROR --"
    echo "Please specify a folder with images to be converted"
    exit 1
fi

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

if [ $(which gm | wc -l) -eq 0 ]; then
        echo "GraphicsMagick is missing from your system. Please download the latest version:"
        echo "OS X: brew install graphicsmagick"
	    echo "Debian/Ubuntu: apt-get install graphicsmagick"
	    echo "RedHat/CentOS: yum install graphicsmagick"
        exit
fi

if [ $(which convert | wc -l) -eq 0 ]; then
        echo "ImageMagick is missing from your system. Please download the latest version:"
        echo "OS X: brew install imagemagick"
	    echo "Debian/Ubuntu: apt-get install imagemagick"
	    echo "RedHat/CentOS: yum install imagemagick"
        exit
fi

#Create folders
mkdir -p Mogrify_images
mkdir -p Convert_images
mkdir -p ScaleMogrify_images
mkdir -p KeepAspectRatio_images
mkdir -p GM_images
#Check files with spaces
cd $1
for f in *\ *; do mv "$f" "${f// /__}"; done
cd ..
#Get the files
files=($(ls $1))

#get information about the files
echo "file_name,file_type,file_size,convert_TimeReal,mogrify_TimeReal,Scale_Mogrify_TimeReal,AspectRatio_convert_TimeReal,GM_TimeReal" > Files.csv
for file in "${files[@]}"
do
	filename=$(identify $1/$file | cut -f1 -d ' ')
	filetype=$(identify $1/$file | cut -f2 -d ' ')
	filesize=$(identify $1/$file | cut -f3 -d ' ')

#convert using convert	
	times=$( { time convert $1/$file -resize 500x500! Convert_images/$file ;} 2>&1)
	treal=$(echo $times | cut -f2 -d ' ')

#convert using mogrify
	motimes=$( { time mogrify -resize 500x500! -path Mogrify_images $1/$file ;} 2>&1)
	motreal=$(echo $motimes | cut -f2 -d ' ')

#convert using mogrify with scale
	smotimes=$( { time mogrify -scale 500x500! -path ScaleMogrify_images $1/$file ;} 2>&1)
	smotreal=$(echo $smotimes | cut -f2 -d ' ')

#convert keeping aspect ratio  and using scale+filter point
	artimes=$( { time convert -filter point $1/$file -scale 500x500 KeepAspectRatio_images/$file ;} 2>&1)
	artreal=$(echo $artimes | cut -f2 -d ' ')

#convert using gm with size and scale option
    gmtimes=$( { time gm convert -size 500x500! $1/$file -scale 500x500! GM_images/$file ; } 2>&1)
	gmtreal=$(echo $gmtimes | cut -f2 -d ' ')


	echo $filename,$filetype,$filesize,$treal,$motreal,$smotreal,$artreal,$gmtreal >> Files.csv
done
