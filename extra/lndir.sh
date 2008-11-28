#! /bin/sh

# lndir - create shadow link tree
#
# $XConsortium: lndir.sh,v 1.10 92/03/16 17:52:17 gildea Exp $
#
# Used to create a copy of the a directory tree that has links for all
# non-directories (except those named RCS, SCCS or CVS.adm).  If you are
# building the distribution on more than one machine, you should use
# this technique.
#
# If your master sources are located in /usr/local/src/X and you would like
# your link tree to be in /usr/local/src/new-X, do the following:
#
# 	%  mkdir /usr/local/src/new-X
#	%  cd /usr/local/src/new-X
# 	%  lndir ../X

USAGE="Usage: $0 fromdir [todir]"

if [ $# -lt 1 -o $# -gt 2 ]
then
	echo "$USAGE"
	exit 1
fi

DIRFROM="$1"

if [ $# -eq 2 ];
then
	DIRTO="$2"
else
	DIRTO=.
fi

if [ ! -d "$DIRTO" ]
then
	echo "$0: $DIRTO is not a directory"
	echo "$USAGE"
	exit 2
fi

cd "$DIRTO"

if [ ! -d "$DIRFROM" ]
then
	echo "$0: $DIRFROM is not a directory"
	echo "$USAGE"
	exit 2
fi

pwd=`pwd`

frompwd=`(cd "$DIRFROM"; pwd)`
if [ "$frompwd" = "$pwd" ]
then
	echo "$pwd: FROM and TO are identical!"
	exit 1
fi

# parse output of "ls" below more carefully
IFS='
'
for file in `ls -af $DIRFROM`
do
    if [ ! -d "$DIRFROM/$file" ]
    then
	    ln -s "$DIRFROM/$file" .
    else
	    case "$file" in
	        .|..|RCS|SCCS|CVS.adm)
		    continue
		    ;;
	    esac
	    echo "$file:"
	    mkdir "$file"
	    (cd "$file"
	     pwd=`pwd`
	     case "$DIRFROM" in
		     /*) ;;
		     *)  DIRFROM="../$DIRFROM" ;;
	     esac
	     frompwd=`(cd "$DIRFROM/$file"; pwd)`
	     if [ "$frompwd" = "$pwd" ]
	     then
		    echo "$pwd: FROM and TO are identical!"
		    exit 1
	     fi
	     sh $0 "$DIRFROM/$file"
	    )
    fi
done
