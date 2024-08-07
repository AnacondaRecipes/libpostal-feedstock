set -ex
./bootstrap.sh

# sse2 seems to be being enabled on ARM64
conf_args=()
case "$(uname -m)" in
arm64|aarch64)
    conf_args+=( --disable-sse2 )
    ;;
esac

./configure \
    --datadir=$PREFIX/share/libpostal_data \
    --prefix=$PREFIX \
    "${conf_args[@]}"

make -j${CPU_COUNT}
make install
