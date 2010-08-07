#!/bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -w

use strict;
use lib "$ENV{PIPELINES}/plancklib/";
use PLIB;


system ( "$mymkdir -p $ENV{CRON_LOGS}" ) unless ( -e $ENV{CRON_LOGS} );
open LOG, ">> $ENV{CRON_LOGS}/dr-cronlog";
select LOG;

print "\n";
print `$mydate`;

system ( "echo tm_request" );


#	if tm_request retrieved something, process it
#	otherwise, we're done.


#	tm_merge will create all necessary triggers 
system ( "echo tm_merge" );


close LOG;

#	last line
