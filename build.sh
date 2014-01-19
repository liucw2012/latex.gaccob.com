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
    rm "./$TMP*";
    cat "../../../$HEAD" "data.tex" >> "$TMP.tex";

    # fork call
    ../../../build_pdf.sh "$TMP" 2>&1;
    mv "$TMP.pdf" "../../../$DST/$cat/$data.pdf";
    rm "./$TMP*";
    echo "complete xelatex $SRC/$cat/$data";
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

