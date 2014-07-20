#!/bin/sh
# builds the jar file: blackbaud-wsdl-validator.jar file into the javalib directory.
# That file should be included in the java classpath when compiling the java code.

javalib_directory="javalib/"
jar_directory=$javalib_directory*.jar
src_directory="com/soapuiutil/wsdlvalidator"
jar_cp=""
jarfile_name="soapui-util.jar"

cd ../..

current_path=$(pwd)

echo "Removing old soapui-util.jar file..."
rm $javalib_directory$jarfile_name
echo "Generating java classpath..."
for f in $jar_directory
do
  jar_cp=$jar_cp":$current_path/$f"
done
jar_cp=$jar_cp":current_path/log4j.properties"

cd java-source/src/main
echo "Building java class..."
javac -classpath $jar_cp $src_directory/*.java
echo "Generating jar file..."
jar cf $current_path/$javalib_directory$jarfile_name $src_directory/*.class
echo "Cleaning up generated class files..."
rm $src_directory/*.class
