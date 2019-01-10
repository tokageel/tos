#!/bin/sh
if [ $# -ne 1 ]; then
  echo "Usage: $0 <Name of addon>"
  exit 1
fi

addonName=$1
addonNameLower=`tr "[A-Z]" "[a-z]" <<< ${addonName}`
addonNameUpper=`tr "[a-z]" "[A-Z]" <<< ${addonName}`

baseDir=`dirname $0`
templateDir="${baseDir}/template"
projectDir="${baseDir}/${addonNameLower}"

luaTemplateFile="src/template.lua"
xmlTemplateFile="src/template.xml"
settingsFile="settings.gradle"
luacheckrcFile=".luacheckrc"

if [ -e "${baseDir}/${addonNameLower}" ]; then
  echo "[ERROR] ${addonNameLower} is already exist." >&2
  exit 1
fi

# project directory
cp -r "${templateDir}" "${projectDir}"

# Lua file
rm "${projectDir}/${luaTemplateFile}"
sed -e "s/template/${addonNameLower}/g" -e "s/TEMPLATE/${addonNameUpper}/g" "${templateDir}/${luaTemplateFile}" >> "${projectDir}/src/${addonNameLower}.lua"

# XML file
rm "${baseDir}/${addonNameLower}/${xmlTemplateFile}"
sed -e "s/template/${addonNameLower}/g" -e "s/TEMPLATE/${addonNameUpper}/g" "${templateDir}/${xmlTemplateFile}" >> "${projectDir}/src/${addonNameLower}.xml"

# settings file for gradle
sed -e "s/template/${addonNameLower}/g" -e "s/TEMPLATE/${addonNameUpper}/g" "${templateDir}/${settingsFile}" > "${projectDir}/${settingsFile}"

# .luacheckrc file
sed -e "s/template/${addonNameLower}/g" -e "s/TEMPLATE/${addonNameUpper}/g" "${templateDir}/${luacheckrcFile}" > "${projectDir}/${luacheckrcFile}"

exit 0
