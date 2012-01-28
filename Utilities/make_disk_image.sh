#! /bin/sh

# make_disk_image.sh
# run this from the root project dir!
# ControlPlane
#
# Created by David Symonds on 17/02/07.
# Modified by Dustin Rue on 7/28/2011.
# Modified by Dustin Rue on 9/03/2011.
# 

# Get version number
VERSION=`cat Tedium/Tedium-Info.plist | grep -A 1 'CFBundleShortVersionString' | \
	tail -1 | sed "s/[<>]/|/g" | cut -d\| -f3`

APPNAME=Tedium
IMG=$APPNAME-$VERSION
IMGTMP=Utilities/Tedium-Template
CONFIGURATION=Release
APP=build/$CONFIGURATION/$APPNAME.app

if [ "$1" == "release" ]; then
        cd Utilities
        cd ..
fi

xcodebuild -configuration "$CONFIGURATION" clean build
if [ ! -d "$APP" ]; then
	echo "Something failed in the build process!"
	exit 1
fi

# Create an initial disk image (32 megs)
if [ -f "$IMG" ]; then rm "$IMG"; fi
hdiutil convert $IMGTMP.dmg -format UDSP -o $IMG || exit 1
#hdiutil create -size 32m -fs HFS+ -volname "$APPNAME-$VERSION" "$IMG" || exit 1

# Mount the disk image
echo "attaching disk"
#hdiutil attach "$IMG.sparseimage" || exit 1

# Obtain device information
DEVS=$(hdiutil attach "$IMG.sparseimage" | grep HFS)
DEV=$(echo $DEVS | cut -d ' ' -f 1)
ROOT=$(echo $DEVS | cut -d ' ' -f 3)
echo "done"

# Copy files
echo "$ROOT/$APPNAME"
rm -rf $ROOT/$APPNAME.app/Contents
mkdir $ROOT/$APPNAME.app/Contents
cp -R $APP/Contents/* $ROOT/$APPNAME.app/Contents/
if [ -f "$ICON" ]; then
	cp $ICON $ROOT/.VolumeIcon.icns
	/Developer/Tools/SetFile -a C $ROOT
fi

# Unmount the disk image
hdiutil detach $DEV || exit 1

# Convert the disk image to read-only
#TMP="tmp-${IMG}"
#mv "$IMG" "$TMP"
hdiutil convert "$IMG.sparseimage" -format UDBZ -o "$IMG"
rm "$IMG.sparseimage"


# sign the file for Sparkle
# run a helper script exposing location of private key for Sparkle updates
if [ "$1" == "release" ]; then
        . tedium_pm_env.sh
        ls -l "$IMG.dmg"
        ruby "$SIGNING_SCRIPT" "$IMG.dmg" "$PRIVATE_KEY" 
        mv "$IMG.dmg" "$IMGDEST"
fi

if [ "$1" == "open" ]; then
        open "$IMG.dmg"
fi
