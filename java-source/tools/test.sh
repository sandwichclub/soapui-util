#!/bin/sh
current_path=$(pwd)
javalib_directory="javalib/"
jar_directory=$javalib_directory*.jar
src_directory="com/soapuiutil/wsdlvalidator"
jar_cp=""
jarfile_name="soapui-util.jar"
#echo $current_path | grep -qE "/bin"
if "$current_path" | sed '$//bin' ]; then
  cd ..
  current_path=$(pwd)
fi

echo $current_path
