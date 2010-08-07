
package PLIB;

sub PLIB::Gunzip;
sub PLIB::Gzip;
sub PLIB::Message;
sub PLIB::Error;
sub PLIB::RemoveDirsIfEmpty;
sub PLIB::RunCom;

#	next 3 statements required for use without using PLIB:: to prefix
#	cannot use with "use strict;"
use Exporter();
@ISA = qw ( Exporter );
@EXPORT = qw ( 
	$mytar    
	$mycp     
	$myrm     
	$myln     
	$mychmod  
	$mymkdir  
	$mymv     
	$myls     
	$mygzip   
	$mygunzip 
	$myecho   
	$mytouch  
	$mycat    
	$mywc     
	$myawk    
	$mysed    
	$myfind   
	$mybc     
	$myhead     
	$mytail 
	$mygrep 
	$myw 
	$mydate 
	$myps 
	$myrsh 
	$myssh 
	$myptree 
	$mypstree 
	$myuname 
	$prefix
	&Message 
	&Error 
	&RemoveDirsIfEmpty 
	&RunCom
	);

$| = 1; #	disable output buffering

$root     = "/bin/";				#	050412 - Jake - SCREW 1704
$mytar    = $root."tar";
$mycp     = $root."cp";
$myrm     = $root."rm";
$myln     = $root."ln";
$mychmod  = $root."chmod";
$mymkdir  = $root."mkdir";
$mymv     = $root."mv";
$myls     = $root."ls";
$mygzip   = $root."gzip";
$mygunzip = $root."gunzip";
$myecho   = $root."echo";
$mytouch  = $root."touch";
$mycat    = $root."cat";
$myawk    = $root."awk";
$mysed    = $root."sed";
$mygrep   = $root."grep";
$mydate   = $root."date";		#	050412 - Jake - SCREW 1704
$myrsh    = $root."rsh";		#	050412 - Jake - SCREW 1704
$myuname  = $root."uname";		#	050414 - Jake

$root    = "/usr/bin/";			#	050301 - Jake - SCREW 1667
$myw      = $root."w";			#	050412 - Jake - SCREW 1704
$mywc     = $root."wc";
$mybc     = $root."bc";
$myfind   = $root."find";
$myhead   = $root."head";
$mytail   = $root."tail";
$myptree  = $root."ptree";		#	050414 - Jake - Solaris only
$mypstree = $root."pstree";	#	050414 - Jake - Linux only

$root    = "/usr/ucb/";			#	050916 - Jake
$myps     = $root."ps";			#	050916 - Jake

$myssh    = "ssh";				#	050802 - Jake - NO SCREW - NO CONSISTANT LOCATION


$prefix = "Log_0  ";

########################################################################### 
#
#			Gzip
#
#		safety wrapper around the obvious executable
#
########################################################################### 

sub Gzip {
	my @filelist;
	my @errors;

#	print ( "$prefix -------------------------------------------------------------\n$prefix\n" );
#	print ( "$prefix Running Gzip on \n$prefix\t".join("\n$prefix\t",@_)."\n$prefix\n" );

	&Message ( "-------------------------------------------------------------" );
	&Message ( "Running Gzip on ",@_ );

	foreach ( @_ ) {
		push @filelist, glob ( $_ );	#	this allows PLIB::Gzip ( "somedir/*" );
	}

	foreach my $file ( @filelist ) {
		if ( -e $file ) {
			unless ( -e "$file.gz" ) {
				`$mygzip $file`;
				if ( $? ) {
					&Message ( "$mygzip $file failed" );
					push @errors, $file;
				}
			} else {
				&Message ( "$file.gz already exists" );
				push @errors, $file;
			}
		} else {
			&Message ( "$file does not exist" );
			push @errors, $file;
		}
	}

	die ( "There was a problem gzipping the following files:\n\t".join("\n\t",@errors)."\n" )if ( @errors );

}

########################################################################### 
#
#			Gunzip
#
#		safety wrapper around the obvious executable
#
########################################################################### 

sub Gunzip {
	my @filelist;
	my @errors;

#	print ( "$prefix -------------------------------------------------------------\n$prefix\n" );
#	print ( "$prefix Running Gunzip on \n$prefix\t".join("\n$prefix\t",@_)."\n$prefix\n" );

	&Message ( "-------------------------------------------------------------" );
	&Message ( "Running Gunzip on",@_ );

	foreach ( @_ ) {
		push @filelist, glob ( $_ );	#	this allows PLIB::Gunzip ( "somedir/*" );
	}

	foreach my $file ( @filelist ) {
		$file =~ s/.gz$//;

		if ( -e "$file.gz" ) {
			unless ( -e $file ) {
				`$mygunzip $file.gz`;
				if ( $? ) {
					&Message ( "$mygunzip $file.gz failed\n" );
					push @errors, $file;
				}
			} else {
				&Message ( "$file exists already\n" );
				push @errors, $file;
			}
		} else {
			&Message ( "$file.gz does not exist\n" );
			push @errors, $file;
		}
	}

	die ( "There was a problem gunzipping the following files:\n\t".join("\n\t",@errors)."\n" ) if ( @errors );
}

###########################################################################

sub Error {
	my @message = @_;
#	my $logfile = "$ENV{LOG_FILES}/$ENV{OSF_DATASET}.log";
#	my $oldlog;
#
#	if ( -e $logfile ) {
#		open LOG, ">> $logfile";
#		$oldlog = select LOG;
#	}
#	print "$prefix\n";
	#	the array usually adds a trailing \n so may not need it
	foreach ( @message ) { print "$prefix - ERROR : $_\n"; }
	print "$prefix\n";
#	if ( -e $logfile ) {
#		close LOG;
#		select $oldlog;
#	}
	die "\n\n$prefix ERROR : @message\n\n";
	exit 1;
}

###########################################################################

sub Message {
	my @message = @_;
#	my $logfile = "$ENV{LOG_FILES}/$ENV{OSF_DATASET}.log";
#	my $oldlog;
#
#	if ( -e $logfile ) {
#		open LOG, ">> $logfile";
#		$oldlog = select LOG;
#	}
#	print "$prefix\n";
	#	the array usually adds a trailing \n so may not need it
	foreach ( @message ) { print "$prefix $_\n"; }
	print "$prefix\n";
#	if ( -e $logfile ) {
#		close LOG;
#		select $oldlog;
#	}
	return;
}

########################################################################### 


########################################################################### 
#
#			RemoveDirsIfEmpty
#
#	This function takes a list of directories, checks to see if they are
#	empty and then tries to remove them if they are.
#
########################################################################### 

sub RemoveDirsIfEmpty {
	my ( @dirs ) = @_;
   
	foreach my $dir ( @dirs ) {
		print ( "$prefix Checking dir $dir for possible removal.\n" );
		if ( -d $dir ) {
			my @filelist = glob ( "$dir/*" );
			unless ( @filelist ) {
				print ( "$prefix $dir appears to be empty so removing.\n" );
				print `rmdir $dir`;
			} else {
				print ( "$prefix $dir appears to NOT be empty.\n" );
			}
		} elsif ( -e $dir ) {
			print ( "$prefix WARNING: $dir is not a directory????\n" );
		} else {
			print ( "$prefix \`pwd\` : ".`pwd` );
			print ( "$prefix WARNING: $dir does not exist\n" );
		}
	}
}
########################################################################### 



####################################################################################################
#
#	RunCom
#
####################################################################################################

sub RunCom {
	&Message ( "-------------------------------------------------------------" );
	&Message ( "Running @_." );
	my $retval = system ( "@_" );
	
	&Message ( "", "@_ returned $retval." );
	if ( $retval ) {
		$retval = 255 if ( $retval > 255 );		#	because $retval loops (65280 returns 0)
		exit $retval;
	}
}

#	last line
