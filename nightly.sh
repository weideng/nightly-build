#!/bin/bash

TODAY=`date +%Y-%m-%d`
YESTERDAY=`date -d yesterday +%Y-%m-%d`
CURRENT_DIR=`pwd`

OTORO_SRC="/home/wdeng/work/b2g-otoro"
SP8810EA_SRC="/home/wdeng/work/b2g-sp8810ea"

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
	out_dir=$CURRENT_DIR/out/$TODAY/$2
	if [ ! -d "$out_dir" ]; then
		mkdir -p $out_dir
	fi
 
	cd $1
	git pull > $out_dir/build.log
	./config.sh $2 >> $out_dir/build.log
	./build.sh >> $out_dir/build.log	
	cd $CURRENT_DIR
	./add-commit.py $1 $out_dir/manifest.xml
	./change_notes.py $CURRENT_DIR/out/$YESTERDAY/$2/manifest.xml $out_dir/manifest.xml $1 $out_dir
	cp -rp $1/out/target/product/$2/system.img $out_dir
	cp -rp $1/out/target/product/$2/userdata.img $out_dir
	if [ -f "$1/out/target/product/$2/boot.img"]; then
		cp -rp $1/out/target/product/$2/userdata.img $out_dir
	fi
	cp -rp flash/flash.sh $out_dir
	mv $1/out $1/$TODAY
}

export ANDROIDFS_DIR=/home/wdeng/work/b2g-otoro/android_backup/otoro-ics-0727
build_device $OTORO_SRC otoro

#$1 dir name
make_patches() {
	cd $1
	git apply $CURRENT_DIR/patches/$1/*.patch
	cd ..
}

build_sp8810ea() {
	out_dir=$CURRENT_DIR/out/$TODAY/sp8810ea
	if [ ! -d "$out_dir" ];then
		mkdir -p $out_dir
	fi

	cd $SP8810EA_SRC
	./repo forall -c "git reset --hard HEAD"
	./repo sync > $out_dir/build.log
	make_patches gecko
	make_patches build
	make_patches gonk-misc
	./build.sh >> $out_dir/build.log
	cd $CURRENT_DIR
	./add-commit.py $SP8810EA_SRC $out_dir/manifest.xml
	./change_notes.py $CURRENT_DIR/out/$YESTERDAY/sp8810ea/manifest.xml $out_dir/manifest.xml $SP8810EA_SRC $out_dir
	cp -rp $SP8810EA_SRC/out/target/product/sp8810ea/boot.img $out_dir
	cp -rp $SP8810EA_SRC/out/target/product/sp8810ea/system.img $out_dir
	cp -rp $SP8810EA_SRC/out/target/product/sp8810ea/userdata.img $out_dir
	cp -rp flash/flash.sh $out_dir
	cp -rp patches $out_dir
	mv $SP8810EA_SRC/out $SP8810EA_SRC/$TODAY
}

build_sp8810ea
