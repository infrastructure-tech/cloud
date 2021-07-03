#!/bin/bash

cloudDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

linkPaths=( 
    "$cloudDir/home:$HOME"
    #"$cloudDir/opt:/opt" 
)

usage()
{
    echo "usage: ${BASH_SOURCE[0]} [-t, -h]"
    echo "Links the following folders from the same directory as *this script"
    echo "to their respective locations within the file system."
    echo ""
    echo "   Arguments: none"
    echo "   Dependencies: none"
    echo "   Options:"
    echo "       -t  Test only (dry run). Does not edit any files."
    echo "       -h  Show usage"
    echo ""
    echo "   Folders to be linked:"
    for i in "${linkPaths[@]}" ; do
        linkFrom=${i%%:*}
        linkTo=${i#*:}
        echo "$linkFrom -> $linkTo"
    done
    exit 1
}

# Prints error message and usage, then exits
# ARGUMENTS: error_message
error()
{
    echo "ERROR: $1"
    echo ""
    usage
}

replace()
{
    dir=$1
    target=$2
    test_opt=$3
    if [ ! -d "$dir" ]; then
        error "$dir does not exist"
    fi
    cd $dir
    for d in * ; do
        #echo "replacing $d"
        if [ $test_opt == "-t" ]; then
            echo "test: rm -vf $target/$d"
            echo "test: ln -vs $dir/$d $target/"
        else
            rm -vf $target/$d
            ln -vs $dir/$d $target/
        fi
    done
    for d in .* ; do
        if [ $d == ".." -o $d == "." ]
        then
            echo "Skipping $d"
        else
            #echo "replacing $d"
            if [ $test_opt == "-t" ]; then
                echo "test: rm -vf $target/$d"
                echo "test: ln -vs $dir/$d $target/"
            else
                rm -vf $target/$d
                ln -vs $dir/$d $target/
            fi
        fi
    done
}

if [ $1 == "-h" ]; then
    usage
fi

testOnly=$1

if [ -z "$testOnly" ]
then
    testOnly="n"
fi

for i in "${linkPaths[@]}" ; do
    linkFrom=${i%%:*}
    linkTo=${i#*:}
    replace $linkFrom $linkTo $testOnly
done
