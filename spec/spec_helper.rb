#lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
#$: << File.expand_path(lib_dir)

require 'soapui-util'

begin
  puts "LOG: current JAVA_HOME = #{ENV['JAVA_HOME']}"
  java_home = %x(which java)
  puts "LOG: setting JAVA_HOME to: #{java_home}"
  ENV['JAVA_HOME'] ||= java_home
rescue
  puts "WARN: Problem setting JAVA_HOME to: '#{java_home}'"
end

@use_local_host=false
def get_wsdl_file
  @use_local_host ? 'http://localhost/api/soap?wsdl' : 'file:' + File.join(File.dirname(File.expand_path(__FILE__)), 'wsdl/spyne.wsdl')
end

