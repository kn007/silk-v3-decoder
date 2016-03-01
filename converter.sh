#!/bin/bash
# File: converter.sh
# Date: March 1th, 2016
# Time: 23:59:27 +0800
# Author: kn007 <kn007@126.com>
# Blog: https://kn007.net
# Usage: sh converter.sh silk_v3_file/input_folder output_format/output_folder flag
# Flag: not define   ----  not define, convert a file
#       other value  ----  format, convert a folder, batch conversion support
# Requirement: gcc ffmpeg

# Colors
RED="\e[31;1m"
GREEN="\e[32;1m"
YELLOW="\e[33;1m"
WHITE="\e[37;1m"
RESET="\e[0m"

# Main
cur_dir=$(cd `dirname $0`; pwd)

if [ ! -r "$cur_dir/silk/decoder" ] ; then
	echo -e "${WHITE}[Notice]${RESET} Silk v3 Decoder is not found, compile it."
	cd $cur_dir/silk
	make && make decoder
	[ ! -r "$cur_dir/silk/decoder" ]&&echo -e "${RED}Silk v3 Decoder Compile False, Please Check Your System For GCC."&&exit
	echo -e "${WHITE}========= Silk v3 Decoder Compile Finish ========="
fi

cd $cur_dir

while [ $3 ]; do
	[ ! -d "$1" ]&&echo -e "${RED}[Error]${RESET} Input folder not found, please check it."&&exit
	[ ! -d "$2" ]&&mkdir "$2"&&echo -e "${WHITE}[Notice]${RESET} Output folder not found, create it."
        ls $1 | while read line; do
                $cur_dir/silk/decoder "$1/$line" "$2/$line.pcm" > /dev/null 2>&1
		[ ! -f "$2/$line.pcm" ]&&echo -e "${YELLOW}[Warning]${RESET} Convert $line false, maybe not a silk v3 encoded file."&&continue
                ffmpeg -y -f s16le -ar 24000 -ac 1 -i "$2/$line.pcm" "$2/$line.$3" > /dev/null 2>&1 &
		while pidof /usr/bin/ffmpeg; do sleep 1; done > /dev/null
		rm "$2/$line.pcm"
		echo -e "${GREEN}[OK]${RESET} Convert $line To $line.$3 Finish."
        done
	exit
done

$cur_dir/silk/decoder "$1" "$1.pcm" > /dev/null 2>&1
[ ! -f "$1.pcm" ]&&echo -e "${YELLOW}[Warning]${RESET} Convert $1 false, maybe not a silk v3 encoded file."&&exit
ffmpeg -y -f s16le -ar 24000 -ac 1 -i "$1.pcm" "$1.$2"  > /dev/null 2>&1
rm "$1.pcm"
echo -e "${GREEN}[OK]${RESET} Convert $1 To $1.$2 Finish."
exit
