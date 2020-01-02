#!/bin/bash

STATUS=0
VSTRING="[0-9]\+\.[0-9]\+\.[0-9]\+"
CHANGELOG_VSTRING="## \[$VSTRING\]"
VER_CHANGELOG=`grep CHANGELOG.md -m 1 -oe "$CHANGELOG_VSTRING" | grep -oe "$VSTRING"`


# Check the versions in the license header of files
DIFFERENT_FILES=$(grep -r -i -e "Version: $VSTRING" ./merlin | grep -v " $VER_CHANGELOG\.")
if [ "$DIFFERENT_FILES" ] ; then
    echo "Error: Mismatched version in files:"
    echo "$DIFFERENT_FILES"
    STATUS=1
fi


# Check the module __version__ variable
if grep "__version__ =" merlin/__init__.py | grep -qv "$VER_CHANGELOG"; then
    echo "Error: merlin/__init__.py __version__ does not match CHANGELOG.md"
    STATUS=1
fi


# Ensure CHANGELOG version and merlin/__init__.py version are equal
MVER=`grep merlin/__init__.py -m 1 -o -e "$VSTRING"`
if [[ $VER_CHANGELOG != $MVER ]]
then
    echo "Error: merlin/__init__.py version (${MVER}) different from CHANGELOG.md verison (${VER_CHANGELOG})"
    STATUS=1
fi


# Ensure CHANGELOG version and git tag version are equal
TAGVER=`git tag | grep "." | tail -1`
if [[ $TAGVER != $VER_CHANGELOG ]]
then
    echo "Error: CHANGELOG.md verison (${VER_CHANGELOG}) different from most recent git tag (${TAGVER})"
    STATUS=1
fi


# Ensure CHANGELOG has changed
if ! [[ $(git diff HEAD..master -- CHANGELOG.md) ]]
then
    echo "Error: CHANGELOG.md has not been updated"
    STATUS=1
fi


# Ensure __init__.py has changed (before merging to master)
if ! [[ $(git diff HEAD..master -- merlin/__init__.py) ]]
then
    echo "Error: merlin/__init__.py has not been updated (version?)"
    STATUS=1
fi


exit $STATUS
