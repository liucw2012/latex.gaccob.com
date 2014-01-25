#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )";
cd "$DIR";

SRC="data";
DST="publish"
HEAD="head.macos"
TMP="_tmp"

xelatex_pdf()
{
    cat="$1";
    data="$2";
    cd "$SRC/$cat/$data";
    echo "start xelatex $SRC/$cat/$data";
    rm -rf "$TMP.tex";
    cat "../../../$HEAD" "data.tex" >> "$TMP.tex";
    # do twice to make sure generate reference
    xelatex "$TMP.tex" > /dev/null 2>&1;
    xelatex "$TMP.tex" > /dev/null 2>&1;
    mv "$TMP.pdf" "../../../$DST/$cat/$data.pdf";
    rm -rf "$TMP.log" "$TMP.aux" "$TMP.tex" "$TMP.out";
    echo "complete xelatex $SRC/$cat/$data";
    echo -e "\n";
    cd "$DIR"
}

# loop data
for cat in `ls $SRC`
do
    if [ -d "$SRC/$cat" ];
        then
            mkdir -p "$DST/$cat";
            for data in `ls $SRC/$cat`
            do
                xelatex_pdf "$cat" "$data"
            done
    fi
done

