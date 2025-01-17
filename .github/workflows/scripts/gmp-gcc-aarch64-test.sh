#!/bin/bash

set -ex # stop bash script on error
. .github/workflows/scripts/base.sh

gmp_object_folder="$workspace_folder/build/gmp"

git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
git checkout e46521db0 

sed -i '187s/.*/URL "https:\/\/repo.msys2.org\/msys\/x86_64\/libtool-2.4.6-14-x86_64.pkg.tar.zst"/' scripts/cmake/vcpkg_acquire_msys.cmake
sed -i '188s/.*/SHA512 ba983ed9c2996d06b0d21b8fab9505267115f2106341f130e92d6b66dad87b0f0e82707daf0b676a28966bfaa24f6c41b6eef9e1f9bf985611471024f2b0ac97/' scripts/cmake/vcpkg_acquire_msys.cmake

sed -i '346s/.*/URL "https:\/\/repo.msys2.org\/msys\/x86_64\/msys2-runtime-3.2.0-15-x86_64.pkg.tar.zst"/' scripts/cmake/vcpkg_acquire_msys.cmake
sed -i '347s/.*/SHA512 e054f5e1fc87add7fc3f5cbafd0ff5f3f77a30385073c17d0a8882feb3319a4cba355ccb1cb67ccb9fa704b514c3d05f54c45199011f604c69bb70e52fa33455/' scripts/cmake/vcpkg_acquire_msys.cmake

cat ../.github/workflows/patches/gmp-gcc-vcpkg.patch | sed -e "s/^++runner_workspace=/++runner_workspace=\"${workspace_folder//\//\\/}\"/" | git apply --whitespace=fix
./bootstrap-vcpkg.sh

ssh -i $gcc_identity $gcc_destination 'bash -sx' << ENDSSH
    set -e # stop bash script on error
    [ -d $gmp_object_folder ] && rm -r $gmp_object_folder
    mkdir -p $gmp_object_folder
ENDSSH

./vcpkg.exe install gmp:arm64-windows