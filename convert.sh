#!/bin/bash -e
# File: convert.sh
# Date: February 8th, 2016
# Time: 01:06:23 +0800
# Author: kn007 <kn007@126.com>
# Blog: https://kn007.net
# Usage: sh convert.sh silk_v3_file output_format
# Requirement: gcc ffmpeg

cur_dir=$(cd `dirname $0`; pwd)

if [ ! -r "$cur_dir/silk/decoder" ] ; then
	echo 'Silk v3 Decoder is not found, compile it.'
	cd $cur_dir/silk
	make && make decoder
	echo '========= Compile Finish ========='
fi

cd $cur_dir
$cur_dir/silk/decoder $1 $1.pcm
ffmpeg -f s16le -ar 24000 -ac 1 -i $1.pcm $1.$2
rm $1.pcm
echo "Convert $1 To $1.$2 Finish."
