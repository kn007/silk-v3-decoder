## Description
Decode silk v3 audio files (like wechat amr files, qq slk files).
Batch conversion support.

<a href="https://github.com/kn007/silk-v3-decoder/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>

```
silk-v3-decoder       (Decode Silk V3 Audio Files)
  |
  |---  silk          (Skype Silk Codec)
  |
  |---  LICENSE       (License)
  |
  |---  README.md     (Readme)
  |
  |---  converter.sh  (Converter Shell Script)
```

## Requirement

* gcc
* ffmpeg

## How To Use

```
sh converter.sh silk_v3_file/input_folder output_format/output_folder flag(format)
```
E.g., convert a file:
```
sh converter.sh 33921FF3774A773BB193B6FD4AD7C33E.slk mp3
```
Notice: the `33921FF3774A773BB193B6FD4AD7C33E.slk` is an audio file you need to convert, the `mp3` is a format you need to output.
***
If you need to convert all audio files in one folder, now batch conversion support, using like this:
```
sh converter.sh input ouput mp3
```
Notice: the `input` folder is content the audio files you need to convert, the `output` folder is content the audio files after conversion finished, the `mp3` is a format you need to output.

## About

[kn007's blog](http://kn007.net) 
