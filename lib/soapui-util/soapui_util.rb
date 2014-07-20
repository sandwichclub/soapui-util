module SoapuiUtil

  def self.is_schema_compliant(message, wsdl_url)
    MessageValidator.new(wsdl_url).is_schema_compliant(message)
  end

  def self.validate_schema_compliance(message, wsdl_url)
    MessageValidator.new(wsdl_url).validate_schema_compliance(message)
  end

  def self.get_java_home
    SoapuiEnv.new.check_java_home
  end

end