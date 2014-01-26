#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )";
cd "$DIR";

SRC="data";
DST="publish"
HEAD="head.macos"
TMP="_tmp"
TARGET="_all"

xelatex_pdf()
{
    src="$1"
    cat="$2";
    data="$3";
    cd "$src/$cat/$data";
    echo "start xelatex $src/$cat/$data";
    rm -rf "$TMP.tex";
    cat "../../../$HEAD" "data.tex" >> "$TMP.tex";
    # do twice to make sure generate reference
    xelatex "$TMP.tex" > /dev/null 2>&1;
    xelatex "$TMP.tex" > /dev/null 2>&1;
    mv "$TMP.pdf" "../../../$DST/$cat/$data.pdf";
    rm -rf "$TMP.log" "$TMP.aux" "$TMP.tex" "$TMP.out";
    echo "complete xelatex $src/$cat/$data";
    echo -e "\n";
    cd "$DIR"
}

# loop data
do_xelatex()
{
    if [ $TARGET = "_all" ]; then
        echo -e "start to xelatex all...\n"
        for cat in `ls $SRC`
        do
            if [ -d "$SRC/$cat" ];
                then
                    mkdir -p "$DST/$cat";
                    for data in `ls $SRC/$cat`
                    do
                        xelatex_pdf "$SRC" "$cat" "$data"
                    done
            fi
        done
    else
        if [ -d "$TARGET" ]; then
            src=`echo $TARGET | awk -F"/" '{print $1}'`
            cat=`echo $TARGET | awk -F"/" '{print $2}'`
            data=`echo $TARGET | awk -F"/" '{print $3}'`
            if [ -d "$src/$cat/$data" ]; then
                xelatex_pdf "$src" "$cat" "$data"
                exit 0
            fi
        fi
        echo -e "$TARGER not found fail\n"
    fi
}

while getopts "d:h" arg
do
    case $arg in
        d) echo -e "target: $OPTARG\n"
           TARGET=$OPTARG
           ;;
        h) echo -e "usage:\n\t./build.sh <-d target> <-h>"
           exit 1
           ;;
        ?) echo -e "usage:\n\t./build.sh <-d target> <-h>"
           exit 1
           ;;
    esac
done

do_xelatex
