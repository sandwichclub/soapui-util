require_relative 'spec_helper'

ENV['JAVA_HOME'] = '/Library/Java/Home'

describe 'using soapui-util methods' do

  before (:all) do
    @wsdl = get_wsdl_file
  end

  specify 'is_schema_compliant should not contain errors when passed a valid soap message' do

    message_string = '<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:spy="spyne.examples.hello">
  <soapenv:Header/>
  <soapenv:Body>' +
    '<spy:say_helloResponse>
      <spy:say_helloResult></spy:say_helloResult>
    </spy:say_helloResponse>
  </soapenv:Body>
</soapenv:Envelope>'

    SoapuiUtil.is_schema_compliant(message_string, @wsdl).should be_true
  end

  specify 'is_schema_compliant should contains errors when passed a malformed soap message' do

    message_string = '<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:spy="spyne.examples.hello">
  <soapenv:Header/>
  <soapenv:Body>' +
    '<spy:say_helloResponse>
      <spy:say_helloResult>
        <badNode>bad info</badNode>
      </spy:say_helloResult>
    </spy:say_helloResponse>
  </soapenv:Body>
</soapenv:Envelope>'

    SoapuiUtil.is_schema_compliant(message_string, @wsdl).should be_false
  end

  specify 'validate_schema_compliance response should contain multiple errors' do

    message_string = '<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:spy="spyne.examples.hello">
  <soapenv:Header/>
  <soapenv:Body>' +
    '<spy:say_helloResponse>
      <spy:say_helloResult>
        <badNode>bad info</badNode>
        <badNode2>bad info</badNode2>
      </spy:say_helloResult>
    </spy:say_helloResponse>
  </soapenv:Body>
</soapenv:Envelope>'

    results = SoapuiUtil.validate_schema_compliance(message_string, @wsdl)
    results.length.should == 2
    results.should == ["line 6: Expected element 'string@spyne.examples.hello' instead of 'badNode' here in element say_helloResult@spyne.examples.hello",
                       "line 7: Expected element 'string@spyne.examples.hello' instead of 'badNode2' here in element say_helloResult@spyne.examples.hello"]
  end

  specify 'validate_schema_compliance response returns true for soap faults (temp hack!)' do
    #TODO: add validation of faults

    message_string = '<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>' +
    '<soap:Fault>
      <faultcode> 99999 </faultcode>
      <faultstring> dummy fault message </faultstring>
      <faultactor></faultactor>
    </soap:Fault>
  </soap:Body>
</soap:Envelope>'

    SoapuiUtil.is_schema_compliant(message_string, @wsdl).should be_true
  end

end