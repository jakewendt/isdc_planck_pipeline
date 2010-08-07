#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -s

use lib "$ENV{PIPELINES}/plancklib/";
use PLIB;


&Error ( "No trigger file given!  Nothing to process!" )
	unless ( $trigger );

my $triggerbase = "$ENV{TM_INPUT}";
my $triggerwork = "$ENV{TM_INPUT}.work";
my $triggerbad  = "$ENV{TM_INPUT}.bad";
my $triggerdone = "$ENV{TM_INPUT}.done";

#	actual length of "apid" is unknown at the time of this writing
my ( $rr_dddd, $hh_mm_ss, $apid, $vvv ) = ( $trigger =~ /(\d{2}_\d{4})\#([\d_]{8})\#(\d+)\.(\d{3})\.fits$/ );

unless ( $rr_dddd && $hh_mm_ss && $apid && $vvv ) {
	system ( "$mymkdir -p $triggerbad" ) unless ( -e $triggerbad );
	&Error ( "$triggerbad was not made." ) unless ( -e $triggerbad );
	system ( "$mymv $triggerbase/$trigger $triggerbad/" );
	&Error ( "Incorrectly formated trigger file name: $trigger" );
}

system ( "$mymkdir -p $ENV{L1_ARCHIVE}/logs/" ) unless ( -e "$ENV{L1_ARCHIVE}/logs/" );
$ENV{COMMONLOGFILE} = "$ENV{L1_ARCHIVE}/logs/$trigger.log";
open LOG, ">> $ENV{COMMONLOGFILE}";
select LOG;

&Message ( "", "Starting l1 pipeline on $trigger", `$mydate` );
&Message ( "rr_dddd  = $rr_dddd", "hh_mm_ss = $hh_mm_ss", "apid     = $apid", "vvv      = $vvv" );

&Error ( "$triggerwork/$trigger already exists." ) if ( -e "$triggerwork/$trigger" );
&Error ( "$triggerdone/$trigger already exists." ) if ( -e "$triggerdone/$trigger" );
&Error ( "$triggerbad/$trigger already exists."  ) if ( -e "$triggerbad/$trigger" );

system ( "$mymkdir -p $triggerwork" ) unless ( -e $triggerwork );
&Error ( "$triggerwork was not made." ) unless ( -e $triggerwork );
system ( "$mymv       $triggerbase/$trigger $triggerwork/" );
&Error ( "$triggerwork/$trigger does not exist." ) unless ( -e "$triggerwork/$trigger" );
&Error ( "$triggerbase/$trigger still exists."  ) if ( -e "$triggerbase/$trigger" );

&Error ( "$ENV{L1_ARCHIVE}/fits_toi/$rr_dddd/$hh_mm_ss/$apid.$vvv already exists." )
	if ( -e "$ENV{L1_ARCHIVE}/fits_toi/$rr_dddd/$hh_mm_ss/$apid.$vvv/" );

&RunCom ( "tmu TM_FILENAME=$ENV{L1_ARCHIVE}/tm/$rr_dddd/$hh_mm_ss/$apid.$vvv.fits" );

unless ( $ENV{AT_MOC} ) {
	&RunCom ( "hk_conversion DataPath=$ENV{L1_ARCHIVE}/fits_toi/$rr_dddd/$hh_mm_ss/$apid.$vvv/" );

	&RunCom ( "echo limit_check" );

	&RunCom ( "echo report_generation" );

	&RunCom ( "echo fits2dmc" );
}

#	&PLIB::Gzip ( "$ENV{L1_ARCHIVE}/fits_toi/$rr_dddd/$hh_mm_ss/$apid.$vvv/*.fits" );
system ( "$mychmod -R -w $ENV{L1_ARCHIVE}/fits_toi/$rr_dddd/$hh_mm_ss/$apid.$vvv/" );

system ( "$mymkdir -p $triggerdone" ) unless ( -e $triggerdone );
&Error ( "$triggerdone was not made." ) unless ( -e $triggerdone );
system ( "$mymv       $triggerwork/$trigger $triggerdone/" );

&Message ( "", "l1 pipeline on $trigger completed successfully.", `$mydate` );
close LOG;

exit;

#	last line
