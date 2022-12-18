#/bin/bash

export CLANG_VERSION=14

clang-format-$CLANG_VERSION --sort-includes -i **/*.cpp **/*.h --verbose
clang-format-$CLANG_VERSION --sort-includes -i **/**/*.cpp **/*.h --verbose

