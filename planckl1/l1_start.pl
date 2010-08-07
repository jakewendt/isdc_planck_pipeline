#!/bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -s


use lib "$ENV{PIPELINES}/plancklib/";
use PLIB;


system ( "$mymkdir -p $ENV{CRON_LOGS}" ) unless ( -e $ENV{CRON_LOGS} );
open LOG, ">> $ENV{CRON_LOGS}/l1-cronlog";
select LOG;

print "\n";
print `$mydate`;
print "Checking for a TM trigger in $ENV{TM_INPUT}\n";

if ( -e $ENV{TM_INPUT} ) {
	my @trigs = `$myls -1 $ENV{TM_INPUT}`;

	if ( @trigs ) {
		chomp ( my $trigger = $trigs[0] );
		print "Running $ENV{PIPELINES}/planckl1/l1.pl -trigger=$trigger\n\n";
		close LOG;
		exec ( "$ENV{PIPELINES}/planckl1/l1.pl -trigger=$trigger" );
	} else {
		print "No triggers found in $ENV{TM_INPUT}.\n\n";
	}
} else {
	print "$ENV{TM_INPUT} does not exist.\n\n";
}

close LOG;

#	last line
