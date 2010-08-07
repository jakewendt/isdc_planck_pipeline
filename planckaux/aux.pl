#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -s

use lib "$ENV{PIPELINES}/plancklib/";
use PLIB;


&Error ( "No trigger file given!  Nothing to process!" )
	unless ( $trigger );

my $triggerbase = "$ENV{AUX_INPUT}";
my $triggerwork = "$ENV{AUX_INPUT}.work";
my $triggerbad  = "$ENV{AUX_INPUT}.bad";
my $triggerdone = "$ENV{AUX_INPUT}.done";

system ( "mkdir -p $ENV{L1_ARCHIVE}/logs/" ) unless ( -e "$ENV{L1_ARCHIVE}/logs/" );
$ENV{COMMONLOGFILE} = "$ENV{L1_ARCHIVE}/logs/$trigger.log";
open LOG, ">> $ENV{COMMONLOGFILE}";
select LOG;

&Message ( "Starting aux pipeline on $trigger\n" );

system ( "mkdir -p $triggerwork" ) unless ( -e $triggerwork );
&Error ( "$triggerwork was not made." ) unless ( -e $triggerwork );
system ( "mv       $triggerbase/$trigger $triggerwork/" );
&Error ( "$triggerwork/$trigger does not exist." ) unless ( -e "$triggerwork/$trigger" );

system ( "mkdir -p $ENV{L1_ARCHIVE}/aux/" )      unless ( -e "$ENV{L1_ARCHIVE}/aux/" );
&Error ( "$ENV{L1_ARCHIVE}/aux/ was not made." ) unless ( -e "$ENV{L1_ARCHIVE}/aux/" );

&RunCom ( "aux_extraction AHF_File=$triggerwork/$trigger" );

&RunCom ( "echo fits2dmc" );

#system ( "chmod -R -w ??????" ); 	#	don't know what to write protect

system ( "mkdir -p $triggerdone" ) unless ( -e $triggerdone );
&Error ( "$triggerdone was not made." ) unless ( -e $triggerdone );
system ( "mv       $triggerwork/$trigger $triggerdone/" );

close LOG;

exit;

#	last line
