#!/bin/bash


#Create folders
mkdir -p Mogrify_images
mkdir -p Convert_images
mkdir -p ScaleMogrify_images
mkdir -p KeepAspectRatio_images

#Get the files
files=($(ls $1))

#get information about the files
echo "file_name,file_type,file_size,convert_TimeReal,mogrify_TimeReal,Scale_Mogrify_TimeReal,AspectRatio_convert_TimeReal" > Files.csv
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

	echo $filename,$filetype,$filesize,$treal,$motreal,$smotreal,$artreal >> Files.csv
done
