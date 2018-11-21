#!/bin/sh
ADDON_NAME="tkgbrowser"
VERSION="v0.0.2"
UNICODE=🦎

rm -r build/*

intermediates="build/${ADDON_NAME}/addon_d.ipf/${ADDON_NAME}"
mkdir -p ${intermediates}
cp src/* ${intermediates}/

pushd .
cd build
ipf_file="_${ADDON_NAME}-${UNICODE}-${VERSION}.ipf"
ipf ${ipf_file} ${ADDON_NAME}
cp ${ipf_file} ../bin/
popd
