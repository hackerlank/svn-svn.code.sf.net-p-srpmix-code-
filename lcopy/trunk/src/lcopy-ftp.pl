#!/usr/bin/evn perl

use Net::FTP;


$ftp = Net::FTP -> new("*.*.*.*");
$ftp -> login("user","pass");
$ftp -> ascii;
$ftp -> cwd ("/tmp");
$ftp -> put ("/data/test");
$ftp -> quit;

exit(0);
