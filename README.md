SoapUI-Util
-----------

Use soapui assertions in ruby!

Leverage soapui's powerful assertion methods in ruby to validate soap messages against the wsdl

To use this gem, the following environment variables must be set:

    `JAVA_HOME: <java home directory> # example: /opt/jdk1.7.0_04
    LD_LIBRARY_PATH: <java home directory>/lib  # example: /opt/jdk1.7.0_04/lib`

To validate against a WSDL stored in a file pass in: 'file:&lt;path to file&gt;'


TODO:
-------
  * [done] fix java unit tests wsdlMessageValidatorTest
  * wsdlMessageValidator.java, line 146: fix parsing out body tag from message to be more friendly
  * fix: NameError: uninitialized constant MessageValidator::WsdlMessageValidatorFaultException,
    which occurs when the soap xml is malformed
  * validate soap faults as well
  * add ability to disable soapui lib logging (console log messages and log files)
    * added 'soapui-log4j.xml' to root to control log4j, still some console info logging left
      * ref: http://sourceforge.net/p/soapui/feature-requests/239/?page=0
      * ref: http://forum.soapui.org/viewtopic.php?t=7052
  * add missing license files
  * add travis.yml support
  * clean up gemspec
  * setting JAVA_HOME, read from config.yml?
    * easy fix: add support for java_home to watirmark configuration?
  * add more tests to spec
    * find wsdl variations here: https://github.com/savonrb/savon/tree/master/spec/fixtures/wsdl
  * reduce javalib dependencies
  * create rake task to build gem