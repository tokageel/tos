#!/bin/sh
# "skinset"を含むファイルの一覧を抽出し、指定したディレクトリ配下へコピーする.

# ToSのルートパス. ${SRC_BASE_DIR}/data/ui.ipf/のような構成となっていること
SRC_BASE_DIR="/path/to/tosroot/"
# 出力先ディレクトリ
DEST_BASE_DIR="./dest"
# 一時ファイル
TMP_LIST_FILE="/tmp/skinset_list.txt"

#"skinset"を含むファイル一覧を取得
grep -rw skinset "${SRC_BASE_DIR}" | sed -e "s/:.*//g" | sort | uniq > "${TMP_LIST_FILE}"

#それぞれのファイルをコピー
for srcfile in `cat ${TMP_LIST_FILE}`
do
    destfile=`echo ${srcfile} | sed -e "s#^${SRC_BASE_DIR}#${DEST_BASE_DIR}/#"`
    mkdir -p `dirname ${destfile}`
    echo "${srcfile} -> ${destfile}"
    cp ${srcfile} ${destfile}
done
