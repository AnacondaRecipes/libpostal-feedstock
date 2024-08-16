#! /bin/bash

set -eu

./bootstrap.sh

# We have pre-downloaded the data files.  bin/libpostal_data will
# update these files if necessary which you can verify by removing the
# --disable-data-download from configure, below.

mkdir -p ${PREFIX}/share/libpostal_data
mv __upstream/share/libpostal_data/libpostal ${PREFIX}/share/libpostal_data

# XXX if the data_version file is wrong it will delete all of the
# libpostal data
for vf in data_version ; do
    vfile=${PREFIX}/share/libpostal_data/libpostal/${vf}
    # Where does "v1" come from?  grep LIBPOSTAL_DATA_DIR_VERSION_STRING configure*
    # Also LIBPOSTAL_SENZING_DATA_DIR_VERSION_STRING
    echo v1 > ${vfile}
done
for vf in base_data_file_version \
	      parser_model_file_version \
	      language_classifier_model_file_version ; do
    vfile=${PREFIX}/share/libpostal_data/libpostal/${vf}
    # v1.0.0 is the recipe's package.version
    echo v1.0.0 > ${vfile}
done

# sse2 seems to be being enabled on ARM64
conf_args=()
case "${target_platform}" in
linux-64|linux-aarch64|osx-arm64|linux-s390x)
    conf_args+=( --disable-sse2 )
    ;;
esac

./configure \
    --disable-data-download \
    --datadir=$PREFIX/share/libpostal_data \
    --prefix=$PREFIX \
    "${conf_args:+${conf_args[@]}}"

make -j${CPU_COUNT}

# We might normally try to run this tester in the test section but it
# is extremely reluctant to be copied (it complains about missing .o
# and .so files)
case "${target_platform}" in
linux-s390x)
    # test/test_libpostal -l to get a list of suites & tests
    test/test_libpostal -s expansion
    # s390x mixes up city_district/suburb/city/state in a dozen parser
    # tests: us gb im nz fr es mx cn jp kr za nl da ro ru.  That list
    # suggests that the Senzing model (improved US, UK and SG) will
    # not help
    #test/test_libpostal -s parser
    test/test_libpostal -s transliteration
    test/test_libpostal -s numex
    test/test_libpostal -s string_utils
    test/test_libpostal -s trie
    test/test_libpostal -s crf_context
    ;;
*)
    test/test_libpostal
    ;;
esac

make install
