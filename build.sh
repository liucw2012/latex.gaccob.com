#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )";
cd "$DIR";

SRC="data";
DST="publish";
HEAD="head.macos";
TMP="_tmp";
TARGET="_null";
FLAG_SCP=0;

function scp_target()
{
    scp_src="$1";

    # environment varaibles
    pub_host="$VPS_HOST";
    pub_dir="/usr/local/nginx/html";
    pub_usr="$VPS_USR";
    pub_passwd="$VPS_PASSWD";

    expect -c "set timeout -1;
        spawn scp -p -o StrictHostKeyChecking=no -r $DST/$scp_src $pub_usr@$pub_host:$pub_dir/$scp_src;
        expect "*assword:*" { send $pub_passwd\r\n; };
        expect eof {exit;}; "
}

function xelatex_pdf()
{
    src="$1";
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

    echo -e "complete xelatex $src/$cat/$data\n";
    cd "$DIR"
}

# loop data
function do_xelatex()
{
    # all blog files
    if [ $TARGET = "all" ]; then
        echo -e "start to xelatex all...\n"
        for cat in `ls $SRC`
        do
            if [ -d "$SRC/$cat" ]; then
                mkdir -p "$DST/$cat";
                for data in `ls $SRC/$cat`
                do
                    xelatex_pdf "$SRC" "$cat" "$data"
                    if [ $FLAG_SCP = 1 ]; then
                        scp_target "$cat/$data.pdf"
                    fi
                done
            fi
        done

    # set target blog file
    else
        if [ -d "$TARGET" ]; then
            src=`echo $TARGET | awk -F"/" '{print $1}'`
            cat=`echo $TARGET | awk -F"/" '{print $2}'`
            data=`echo $TARGET | awk -F"/" '{print $3}'`
            if [ -d "$src/$cat/$data" ]; then
                mkdir -p "$DST/$cat";
                xelatex_pdf "$src" "$cat" "$data"
                if [ $FLAG_SCP = 1 ]; then
                    scp_target "$cat/$data.pdf"
                fi
            fi
        else
            echo -e "$TARGET not found fail\n"
        fi
    fi
}

# argument --> target
while getopts "d:ahsi" arg
do
    case $arg in
        d) echo -e "target: $OPTARG\n"
           TARGET=$OPTARG
           ;;
        a) echo -e "target: all\n"
           TARGET="all"
           ;;
        s) FLAG_SCP=1
           ;;
        i) scp_target "index.html"
           scp_target "rss.xml"
           exit 1
           ;;
        h) echo -e "usage:\n\t./build.sh <-d target> <-a all> <-h> <-s auto scp> <-i update index&rss only>"
           exit 1
           ;;
        *) echo -e "usage:\n\t./build.sh <-d target> <-a all> <-h> <-s auto scp> <-i update index&rss only>"
           exit 1
           ;;
    esac
done

if [ $TARGET = "_null" ]; then
    echo -e "target not set fail."
    echo -e "usage:\n\t./build.sh <-d target> <-a all> <-h> <-s auto scp>"
    exit 1
fi

do_xelatex
if [ $FLAG_SCP = 1 ]; then
    scp_target "index.html"
    scp_target "rss.xml"
fi
