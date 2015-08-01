#!/bin/bash

VERSION_pillow=${VERSION_pillow:-2.9.0}
URL_pillow=https://pypi.python.org/packages/source/P/Pillow/Pillow-$VERSION_pillow.tar.gz
DEPS_pillow=(png jpeg python setuptools)
MD5_pillow=46f1729ece27981d54ec543ad5b37d14
BUILD_pillow=$BUILD_PATH/pillow/$(get_directory $URL_pillow)
RECIPE_pillow=$RECIPES_PATH/pillow

DEBUG_pillow="DEBUG"
if [ -z "$DEBUG_pillow" ]; then
    DEBUG_repo=$HOME/study/python/pillow
fi

if [ -n "$DEBUG_pillow" ]; then
    echo "debug"
    BUILD_pillow=$DEBUG_repo
    echo $DEBUG_repo
fi

function prebuild_pillow() {
        if [ -n "$DEBUG_pillow" ]; then
            # no patching on DEBUG, since we're targetting the branch
            # we use to generate patches from.
            return
        fi

	cd $BUILD_pillow

	# check marker in our source build
	if [ -f .patched ]; then
		# no patch needed
		return
	fi

	try cp setup.py setup.py.tmpl
	# try patch -p1 < $RECIPE_pillow/patches/fix-path.patch

	LIBS="$SRC_PATH/obj/local/$ARCH"
	try cp setup.py.tmpl setup.py
	try $SED s:_LIBS_:$LIBS: setup.py
	try $SED s:_JNI_:$JNI_PATH: setup.py
	try $SED s:_NDKPLATFORM_:$NDKPLATFORM: setup.py

	# try patch -p1 < $RECIPE_pillow/patches/disable-tk.patch

	# everything done, touch the marker !
	touch .patched
}

function shouldbuild_pillow() {
	if [ -d "$SITEPACKAGES_PATH/pillow" ]; then
		DO_BUILD=0
	fi
}

function build_pillow() {
	cd $BUILD_pillow
        echo "DEBUG_pillow $DEBUG_pillow"
        echo "DEBUG_repo $DEBUG_repo"
        echo "pwd $PWD"
        echo "build_pillow dir: $BUILD_pillow"
        echo "obj dir: $SRC_PATH/obj/local/$ARCH"
        ls $SRC_PATH/obj/local/$ARCH
	push_arm

	LIBS="$SRC_PATH/obj/local/$ARCH"
	export CFLAGS="$CFLAGS -I$JNI_PATH/png -I$JNI_PATH/jpeg -I$JNI_PATH/freetype/include/freetype"
	export LDFLAGS="$LDFLAGS -L$LIBS -lm -lz"
	export LDSHARED="$LIBLINK"
	try $HOSTPYTHON setup.py install -O2

	unset LDSHARED
	pop_arm
}

function postbuild_pillow() {
	true
}
