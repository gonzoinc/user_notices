#!/bin/sh

APATH=`pwd -P`

HOOK=pre-commit
if [ ! -f $APATH/.git/hooks/$HOOK ]
then
    echo "Installing git $HOOK hook..."
    sed "s|%%APP_PATH%%|$APATH|" $APATH/scripts/hooks/pre-commit-hook.tmpl > $APATH/.git/hooks/$HOOK
    chmod +x $APATH/.git/hooks/$HOOK
    echo "Completed installing $HOOK hook."
fi
