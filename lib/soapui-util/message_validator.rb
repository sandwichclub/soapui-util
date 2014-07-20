require_relative 'soapui_env'

module SoapuiUtil
  class MessageValidator

    def initialize(wsdl_url)
      SoapuiEnv.new.check_java_home

      java_libs_path = File.join(File.dirname(File.expand_path(__FILE__)),'..', '..', 'javalib')
      java_libs_array = Dir.entries(java_libs_path)

      # build classpath
      java_libs_array.map! { |lib| File.join(java_libs_path, lib) }
      jars = java_libs_array.join(File::PATH_SEPARATOR)

      Rjb::load(classpath=jars, jvmargs=['-Djava.awt.headless=true'])
      # create java class instance
      @validator = Rjb::import('com.soapuiutil.wsdlvalidator.WsdlMessageValidator').new(wsdl_url)
    end

    def is_schema_compliant(message)
      # assert that java array is empty (ie. no error returned)
      validate_schema_compliance(message).size == 0
    end

    def validate_schema_compliance(message)
      begin
        @java_array = @validator.validateSchemaCompliance(message)
        return @java_array
      rescue WsdlMessageValidatorFaultException => e
        #TODO: eating Fault exceptions so SchemaCompliance doesn't fail on faults
        return []
      end
    end

  end
end