#!/bin/bash
# File: converter.sh
# Date: March 1th, 2016
# Time: 20:33:51 +0800
# Author: kn007 <kn007@126.com>
# Blog: https://kn007.net
# Usage: sh converter.sh silk_v3_file/input_folder output_format/output_folder flag
# Flag: not define   ----  not define, convert a file
#       other value  ----  format, convert a folder, batch conversion support
# Requirement: gcc ffmpeg

cur_dir=$(cd `dirname $0`; pwd)

if [ ! -r "$cur_dir/silk/decoder" ] ; then
	echo 'Silk v3 Decoder is not found, compile it.'
	cd $cur_dir/silk
	make && make decoder
	echo '========= Silk v3 Decoder Compile Finish ========='
fi

while [ $3 ]; do
        cd $cur_dir
	[ ! -d "$1" ]&&echo 'Input folder not found, please check it.'&&exit
	[ ! -d "$2" ]&&mkdir "$2"&&echo 'Output folder not found, create it.'
        ls $1 | while read line; do
                $cur_dir/silk/decoder "$1/$line" "$2/$line.pcm"
                ffmpeg -f s16le -ar 24000 -ac 1 -i "$2/$line.pcm" "$2/$line.$3" &
		while pidof /usr/bin/ffmpeg; do sleep 1; done >/dev/null
		rm "$2/$line.pcm"
		echo "Convert $line To $line.$3 Finish."
        done
	exit
done

cd $cur_dir
$cur_dir/silk/decoder "$1" "$1.pcm"
ffmpeg -f s16le -ar 24000 -ac 1 -i "$1.pcm" "$1.$2"
rm "$1.pcm"
echo "Convert $1 To $1.$2 Finish."
exit
