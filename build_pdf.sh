#!/usr/bin/expect -f

set tex [lindex $argv 0];
set timeout 15;

spawn xelatex "$tex.tex";
expect "*Transcript written on $tex.log*" {exit;};
