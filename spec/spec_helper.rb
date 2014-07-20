#lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
#$: << File.expand_path(lib_dir)

require 'soapui-util'

@use_local_host=false
def get_wsdl_file
  @use_local_host ? 'http://localhost/api/soap?wsdl' : 'file:' + File.join(File.dirname(File.expand_path(__FILE__)), 'wsdl/spyne.wsdl')
end