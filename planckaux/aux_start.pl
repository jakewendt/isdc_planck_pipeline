#!/bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -s

use lib "$ENV{PIPELINES}/plancklib/";
use PLIB;


system ( "$mymkdir -p $ENV{CRON_LOGS}" ) unless ( -e $ENV{CRON_LOGS} );
open LOG, ">> $ENV{CRON_LOGS}/aux-cronlog";
select LOG;

print "\n";
print `$mydate`;
print "Checking for an AUX trigger in $ENV{AUX_INPUT}\n";

if ( -e $ENV{AUX_INPUT} ) {
	my @trigs = `$myls -1 $ENV{AUX_INPUT}`;

	if ( @trigs ) {
		chomp ( my $trigger = $trigs[0] );
		print "Running $ENV{PIPELINES}/planckaux/aux.pl -trigger=$trigger\n\n";
		close LOG;
		exec ( "$ENV{PIPELINES}/planckaux/aux.pl -trigger=$trigger" );
	} else {
		print "No triggers found.\n\n";
	}
} else {
	print "$ENV{AUX_INPUT} does not exist.\n\n";
}
close LOG;

#	last line
