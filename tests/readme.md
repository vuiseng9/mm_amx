### Quick start for building codes in tests folder

## Dependency
```bash
# g++
sudo apt-get install build-essential
```
## Build
```bash
git clone https://github.com/vuiseng9/mm_amx
cd mm_amx/tests
git submodule update --init --recursive

source build_utils.sh

# order according to the main writeup
# build does run the program right after compilation
build tile-load.cpp
build amx-l2.cpp
build amx-ddr.cpp
build amx-mm.cpp
build amx-mlp.cpp
build cross-core-read.cpp
build interleave-write.cpp
```

## Run
```bash
source build_utils.sh

# run_binary <*.out>
run_binary outdir/tile-load.out
```