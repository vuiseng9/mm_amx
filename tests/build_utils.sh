
# This build utility is based on ../init.sh,
#  we modify COMMON_OPTS to exclude oneDNN

export CXX=g++
#https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../

export NCORE_PER_SOCKET=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')

export OUTDIR=outdir
mkdir -p $OUTDIR

# export LD_LIBRARY_PATH
function build() {
    source=$1
    basename=$(basename $source | sed 's/\(.*\)\..*/\1/')

    if ! test -f "${source}"; then
        echo "cannot find input source cpp file: '$source'"
        return
    fi
    target=$OUTDIR/$basename.out

    # MARCH_OPTS="-mno-avx256-split-unaligned-load -mno-avx256-split-unaligned-store"
    MARCH_OPTS=""
    # COMMON_OPTS="-DENABLE_NUMA -I$SCRIPT_DIR/include -Ithirdparty/oneDNN/build/install/include -Ithirdparty/xbyak/xbyak -Lthirdparty/oneDNN/build/install/lib64 -lpthread -ldnnl -march=native -std=c++14 -lstdc++ -lnuma -fopenmp $MARCH_OPTS"
    COMMON_OPTS="-DENABLE_NUMA -I$SCRIPT_DIR/include -I$SCRIPT_DIR/thirdparty/xbyak/xbyak -lpthread -march=native -std=c++14 -lstdc++ -lnuma -fopenmp $MARCH_OPTS"

    $CXX $source -O2 $COMMON_OPTS -S -masm=intel -fverbose-asm  -o $OUTDIR/_${basename}_main.s &&
    cat $OUTDIR/_${basename}_main.s | c++filt > $OUTDIR/${basename}_main.s &&
    $CXX $source -O2 $COMMON_OPTS -o $target &&
    $CXX $source -O0 $COMMON_OPTS -g -DJIT_DEBUG -o $OUTDIR/${basename}_debug.out &&
    echo $target is generated &&
    echo $OUTDIR/${basename}_main.s is generated &&
    echo $OUTDIR/${basename}_debug.out is generated &&
    echo ""
    echo ======== test begin========== &&
    echo Running CLI: sudo -E env numactl  -N1 --localalloc -C${NCORE_PER_SOCKET} $target &&
    sudo -E env CLFLUSH=1 numactl -N1 --localalloc -C${NCORE_PER_SOCKET} $target
}

function run_binary() {
    sudo -E env CLFLUSH=1 numactl -N1 --localalloc -C${NCORE_PER_SOCKET} $1
}
