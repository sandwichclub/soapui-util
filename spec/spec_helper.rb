#lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
#$: << File.expand_path(lib_dir)

require 'soapui-util'

begin
  java_path =  %x(which java)
  puts "LOG: which java returned: #{java_path}"
  java_home = %x(echo $JAVA_HOME)
  puts "LOG: JAVA_HOME: '#{java_home}'"
  ENV['JAVA_HOME'] = java_home
rescue
  puts "WARN: Problem setting JAVA_HOME to: '#{java_home}'"
end

@use_local_host=false
def get_wsdl_file
  @use_local_host ? 'http://localhost/api/soap?wsdl' : 'file:' + File.join(File.dirname(File.expand_path(__FILE__)), 'wsdl/spyne.wsdl')
end

