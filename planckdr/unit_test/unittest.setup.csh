#!/bin/csh -f


echo "#######"
echo "####### -v- Sourcing unittest.setup.csh to setup the basic pipeline unit test environment"
echo "#######"

echo "#######     Current user is ${USER}"
set OS = `uname -s`

set ECHO = "echo"
echo "#######     Current OS is ${OS}"
if ( $OS =~ SunOS ) then
   set osdir = "sparc_solaris"
	if ( -x /usr/ucb/echo ) set ECHO  = "/usr/ucb/echo"
else
   set osdir = "linux"
	if ( -x /bin/echo ) set ECHO  = "/bin/echo"
endif

$ECHO    "#######     Using echo : $ECHO"
$ECHO -n "#######     Current machine is "
uname -n
$ECHO -n "#######     Using perl : "
which perl
echo "#######     "

##  Check that I haven't run gen_diff_entry without updating tar file yet:
if (-d "outref.new") then
   echo "#######     ERROR:  outref.new exists;  please update tar file."
   exit 1
endif


#  Apparently need this to make it work within "make test" command:
setenv SHELL /bin/csh



echo "#######     "
echo "#######     You will probably see the following error message..."
echo "#######        SHELL=sh: Command not found."
echo "#######        export: Command not found."
echo "#######     This is OK."
echo "#######     "

source op_lin_init


echo "#######     WORK_ENV is now $WORK_ENV "

echo "#######     ROOTSYS is now $ROOTSYS "

echo "#######     PFILES is now $PFILES "

echo "#######     CFITSIO_INCLUDE_FILES is now $CFITSIO_INCLUDE_FILES "

#	This is different for the unit tests
setenv L1_ARCHIVE ${PWD}/test_data/
echo "#######     L1_ARCHIVE is now $L1_ARCHIVE "

#	Since this variable contains a non-default variable, we must reset it.
eval `envv set LOG_DIR   ${L1_ARCHIVE}/logs`
eval `envv set AUX_INPUT ${L1_ARCHIVE}/ifts/inbox`
eval `envv set TM_INPUT  ${L1_ARCHIVE}/tm/trigger`


eval `/usr/bin/envv del PERL5LIB /isdc/integration/isdc_int/Linux/all_sw/prod/opus/pipeline_lib`
eval `/usr/bin/envv del PERL5LIB /isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib`
echo "#######     PERL5LIB is now ..."
echo $PERL5LIB | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'


eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib`
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/sw/dev/prod/opus/nrtrev`
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/Linux/all_sw/prod/bin/ac_stuff`
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/Linux/all_sw/prod/bin`
echo "#######     PATH is now ..."
echo $PATH | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'
rehash

eval `/usr/bin/envv del LD_LIBRARY_PATH /isdc/integration/isdc_int/Linux/all_sw/prod/lib`
echo "#######     LD_LIBRARY_PATH is now ..."
echo $LD_LIBRARY_PATH | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'

eval `/usr/bin/envv set TEST_DATA_DIR /isdc/integration/isdc_int/data/unit_test`
echo "#######     TEST_DATA_DIR is now $TEST_DATA_DIR "



env | /bin/sort > env_dump.txt

echo "#######"
echo "####### -^- Done with unittest.setup.csh"
echo "#######"

