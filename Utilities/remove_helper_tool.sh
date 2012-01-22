#!/bin/bash

# a simple utility for removing the Tedium helper app
# *must* be run as root

launchctl unload -F /Library/LaunchDaemons/com.dustinrue.Tedium.plist
rm /Library/LaunchDaemons/com.dustinrue.Tedium.plist
rm /Library/PrivilegedHelperTools/com.dustinrue.Tedium
