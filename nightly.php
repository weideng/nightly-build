#!/bin/bash

TODAY=`date +%Y-%m-%d`
YESTERDAY=`date -d yesterday +%Y-%m-%d`
CURRENT_DIR=`pwd`

OTORO_SRC="/home/wdeng/work/B2G-otoro"


GECKO_URL="git://github.com/mozilla/releases-mozilla-central"
GAIA_URL="git://github.com/mozilla-b2g/gaia"

#$1 gecko or gaia
#$2 remote server url
fetch_repositories() {
	cd $1
	git remote add nighly $2
	git fetch nighly
	git checkout -b nighly nighly/master
	cd ..
}

#$1 gecko or gaia
update_repositories() {
	cd $1
	if [ $1 = "gecko" ]; then
		git reset --hard
		git pull
		git apply *.patch
	else
		git pull
	fi
	cd ..
}

#$1 gecko or gaia
#$2 remote server url
check_repositories() {
	if [ -f ".$1url" ]; then
		update_repositories $1
	else
		fetch_repositories $1 $2
		touch .$1url
	fi
#	echo $1
}

#check_repositories gecko $GECKO_URL
#check_repositories gaia $GAIA_URL


#. build.sh

#$1 source code direcotry
#$2 device name otoro, sp8810eabase.. 
build_device() {
	out_dir=$CURRENT_DIR/out/$2/$TODAY
	if [ ! -d "$out_dir" ]; then
		mkdir -p $out_dir
	fi
 
	cd $1
	git pull > $out_dir/build.log
	./config $2 >> $out_dir/build.log
	./build.sh >> $out_dir/build.log	
	cd $CURRENT_DIR
	./add-commit.py $1 $out_dir/manifest.xml
	./change_notes.py $CURRENT_DIR/out/$2/$YESTERDAY/manifest.xml $out_dir/manifest.xml $1 $out_dir
	cp -rp $1/out/target/product/$2/*.img $out_dir
	cp -rp flash/$2-flash.sh $out_dir
	mv $1/out $1/$TODAY
}

export ANDROIDFS_DIR=/home/wdeng/work/B2G-otoro/android_backup/otoro-ics-0727
build_device $OTORO_SRC otoro
