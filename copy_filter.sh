#!/bin/bash

PATH="/Users/qinmin/Documents/学习/GPUImage博客集/GPUImageFilter-09/framework/Source"
cd $PATH

# 先添加key值
/usr/libexec/PlistBuddy -c 'Add :Filters array' ~/Desktop/com.sample.plist

for file in ./*; do
	if [[ ${file:0-8} == "Filter.h" ]]; then
		tmpFile=${file:2}
        name=${tmpFile%.h}
		# 添加value值
		/usr/libexec/PlistBuddy -c 'Add :Filters:'${name}':name string '${name} ~/Desktop/com.sample.plist

		HaderFile=$PATH/$file
		for line in $(cat $HaderFile); do
			echo $line
		done

	fi
done
