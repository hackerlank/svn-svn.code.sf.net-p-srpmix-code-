#!/usr/bin/env perl

use JavaScript::Minifier qw(minify);
open(INPUT, $ARGV[0]) or die "failed in open()";

minify(input => *INPUT, 
       outfile => *STDOUT, 
       copyright => $ARGV[1]);

close(INPUT);
close(STDOUT);

0;


