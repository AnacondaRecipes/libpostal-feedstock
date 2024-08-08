set -ex
./bootstrap.sh

# sse2 seems to be being enabled on ARM64
conf_args=()
case "${target_platform}" in
linux-64|linux-aarch64|osx-arm64|linux-s390x)
    conf_args+=( --disable-sse2 )
    ;;
esac

./configure \
    --datadir=$PREFIX/share/libpostal_data \
    --prefix=$PREFIX \
    "${conf_args[@]}"

make -j${CPU_COUNT}
make install
