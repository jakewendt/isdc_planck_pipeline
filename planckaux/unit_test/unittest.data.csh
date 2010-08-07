#!/bin/csh -f

set StartDir = `pwd`

echo "#######"
echo "####### -v- Sourcing unittest.data.csh to prepare unit test test_data, outref "
echo "#######"

set OS = `uname -s`
echo "#######     Current OS is ${OS}"
if ( $OS =~ SunOS ) then
   set taropts = "xf"
else
   set taropts = "xfk"		#	to preserve the possible link
endif


#	Clean up everything
foreach subdir ( "test_data" "out" "outref"  )
	echo "#######   Checking $subdir status"
	ls $subdir >&/dev/null		#	using this technique instead of -f, -e or -d will actually work on dead links
	@ exit_status = $status
	if ( ! $exit_status ) then
#	if ( -e ${subdir} ) then
		echo "#######     Cleaning up $subdir from previous run"
		# because this tends to error on links, redirect error
		echo "#######       /bin/chmod -R +w $subdir >& /dev/null"
		/bin/chmod -R +w $subdir >& /dev/null
		echo "#######       /bin/rm -rf $subdir"
		/bin/rm -rf $subdir
	else
		echo "#######     No $subdir from previous run found."
	endif
		
	if ( ( $USER =~ isdc_int ) && ( ! $?DO_NOT_USE_LINKS ) ) then
		set tmpdir = "/unsaved_data/isdc_int/opus_unit_tests/$OS/$system/$subdir"
		if ( -e $tmpdir ) then
			echo "#######       Cleaning up $tmpdir from previous run"
			echo "#######         /bin/chmod -R +w $tmpdir >& /dev/null"
			/bin/chmod -R +w $tmpdir >& /dev/null
			echo "#######         /bin/rm -rf $tmpdir"
			/bin/rm -rf $tmpdir
		else
			echo "#######       No $tmpdir from previous run found."
		endif
		echo "#######       Creating new $tmpdir "
		/bin/mkdir -p $tmpdir
		echo "#######       Linking $tmpdir "
		/bin/ln -s $tmpdir
	endif
end


if ( $?TEST_DATA_TGZ ) then
	if ( -r  ${TEST_DATA_DIR}/${TEST_DATA_TGZ} ) then
		echo "#######   Untaring ${TEST_DATA_DIR}/${TEST_DATA_TGZ} with opts $taropts"
		/bin/gunzip -c ${TEST_DATA_DIR}/${TEST_DATA_TGZ} | /bin/tar $taropts -
	else if ( -r  /isdc/testdata/unit_test/${TEST_DATA_TGZ} ) then
		echo "#######   Untaring /isdc/testdata/unit_test/${TEST_DATA_TGZ} with opts $taropts"
		/bin/gunzip -c /isdc/testdata/unit_test/${TEST_DATA_TGZ} | /bin/tar $taropts -
	else
		echo "#######   ERROR:  cannot read ${TEST_DATA_DIR}/${TEST_DATA_TGZ}"
		exit 2
	endif
else
	if ( ! -e test_data ) /bin/mkdir test_data
endif

if ( $?OUTREF_TGZ ) then
	if ( -r  ${TEST_DATA_DIR}/${OUTREF_TGZ} ) then
		echo "#######   Untaring ${TEST_DATA_DIR}/${OUTREF_TGZ} with opts $taropts"
		/bin/gunzip -c ${TEST_DATA_DIR}/${OUTREF_TGZ} | /bin/tar $taropts -
		/bin/chmod -R a-w outref/*
	else if ( -r  /isdc/testdata/unit_test/${OUTREF_TGZ} ) then
		echo "#######   Untaring /isdc/testdata/unit_test/${OUTREF_TGZ} with opts $taropts"
		/bin/gunzip -c /isdc/testdata/unit_test/${OUTREF_TGZ} | /bin/tar $taropts -
		/bin/chmod -R a-w outref/*
	else
		echo "#######   WARNING:  cannot read ${TEST_DATA_DIR}/${OUTREF_TGZ}"
	endif
endif

cd test_data
if ( -e ic_db ) mv ic_db ic_db.old
ln -s /planck/dev/op_testdata/l1_archive/ic_db

cd $StartDir


echo "#######"
echo "####### -^- Done with unittest.data.csh"
echo "#######"

#	exit 1 = isdc_opus_install failed
#	exit 2 = test_data file not accessible
#	exit 3 = ic_master_file not accessible

