package com.soapuiutil.wsdlvalidator;

import java.util.HashMap;
import java.util.Map;

import javax.wsdl.Definition;
import javax.wsdl.factory.WSDLFactory;
import javax.xml.namespace.QName;

import org.apache.commons.lang.StringUtils;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xmlsoap.schemas.soap.envelope.Envelope;

import com.soapuiutil.wsdlvalidator.WsdlMessageValidatorException;
import com.soapuiutil.wsdlvalidator.WsdlMessageValidatorFaultException;
import com.eviware.soapui.impl.WsdlInterfaceFactory;
import com.eviware.soapui.impl.wsdl.WsdlInterface;
import com.eviware.soapui.impl.wsdl.WsdlOperation;
import com.eviware.soapui.impl.wsdl.WsdlProject;
import com.eviware.soapui.impl.wsdl.WsdlProjectFactory;
import com.eviware.soapui.impl.wsdl.mock.WsdlMockOperation;
import com.eviware.soapui.impl.wsdl.mock.WsdlMockResponse;
import com.eviware.soapui.impl.wsdl.mock.WsdlMockService;
import com.eviware.soapui.impl.wsdl.panels.mockoperation.WsdlMockResponseMessageExchange;
import com.eviware.soapui.impl.wsdl.support.wsdl.WsdlContext;
import com.eviware.soapui.impl.wsdl.support.wsdl.WsdlValidator;
import com.eviware.soapui.model.iface.Operation;
import com.eviware.soapui.model.testsuite.AssertionError;

import com.eviware.soapui.impl.wsdl.support.soap.SoapVersion;

import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlObject;

//import org.apache.log4j.Logger;

/**
 * Class which contains methods that can be used to determine message validity against the wsdl.  Schema compliance
 * for example.
 * @author kchan
 *
 */
public class WsdlMessageValidator {
	
	final private static String BODY = "Body";
	final private static String ENVELOPE = "Envelope";
	final private static String SERVICE_NAME = "SERVICE NAME";
	final private static String NO_TYPE = "Message type could not be determined";
	
	private Map<String, WsdlMockOperation> typeOperationMap = new HashMap<String, WsdlMockOperation>();
	private WsdlValidator wsdlValidator;
    private SoapVersion soapVersion;
	
	/**
	 * Sets up Exception
	 * @param wsdlUrl
	 * @throws WsdlMessageValidatorException
	 */
	@SuppressWarnings({ "unchecked" })
	public WsdlMessageValidator(String wsdlUrl) throws WsdlMessageValidatorException {
		final WsdlContext wsdlContext = new WsdlContext(wsdlUrl);
		wsdlValidator = new WsdlValidator(wsdlContext);
		
		try {
			final WsdlProject wsdlProject = new WsdlProjectFactory().createNew();
			final WsdlInterface[] wsdlInterfaces = WsdlInterfaceFactory.importWsdl(wsdlProject, wsdlUrl, true);
			if (wsdlInterfaces.length > 0) {
			    soapVersion = wsdlInterfaces[0].getSoapVersion();
			}

			final WSDLFactory factory = WSDLFactory.newInstance();
			final Definition def = factory.newWSDLReader().readWSDL(wsdlUrl);
			final Map<String, String> namespaceMap = (Map<String, String>)def.getNamespaces();
			final Map<String, String> reverseNamespaceMap = new HashMap<String, String>();
			for(String key: namespaceMap.keySet()) {
				reverseNamespaceMap.put(namespaceMap.get(key), key);
			}

			final WsdlMockService mockServ = wsdlProject.addNewMockService(SERVICE_NAME);

			for(final WsdlInterface wsdlInterface:  wsdlInterfaces) {
				for(final Operation operation: wsdlInterface.getOperationList()) {
					final WsdlOperation wsdlOperation = wsdlInterface.getOperationByName(operation.getName());
					final QName requestQname = wsdlOperation.getRequestBodyElementQName();
					final QName responseQname = wsdlOperation.getResponseBodyElementQName();
					final WsdlMockOperation mockOper = mockServ.addNewMockOperation((WsdlOperation)operation);
					typeOperationMap.put(requestQname.getLocalPart(), mockOper);
					typeOperationMap.put(responseQname.getLocalPart(), mockOper);
				}
			}

		} catch(final Exception e) {
			throw new WsdlMessageValidatorException(e);
		}
	}

    /**
     * Checks if the given SOAP message is a Fault.
     * Adapted from the "isSoapFault" method from the SoapUtils class: http://www.soapui.org/xref/com/eviware/soapui/impl/wsdl/support/soap/SoapUtils.html
     * Difference: Instead of '+ "//env:Fault"', did '+ ".//env:Fault"' (an extra dot before //end)
     **/
    private boolean isSoapFault(String message) throws XmlException {
	if (message == null){
	    return false;
	}
		if( message.indexOf( ":Fault" ) > 0 || message.indexOf( "<Fault" ) > 0 ) {
		    XmlObject xml = XmlObject.Factory.parse( message);		    
		    XmlObject[] paths = xml.selectPath( "declare namespace env='" + soapVersion.getEnvelopeNamespace() + "' .//env:Fault" );

		    if( paths.length > 0 ) {
			return true;
		    }
		}
		return false;
    }

	/**
	 * Validates the message against the wsdl.
	 * @param message
	 * @param wsdlUrl
	 * @return
	 * @throws WsdlMessageValidatorException
	 */
	public String[] validateSchemaCompliance(final String message)
			throws WsdlMessageValidatorException {
		
		WsdlMockOperation wsdlMockOperation = null;
		WsdlMockResponse mockResponse = null;		
		try {

			// parse for body in the response string
			final Envelope envelope = Envelope.Factory.parse(message);
			final Node node = envelope.getDomNode();
			final Node envelopeNode = node.getFirstChild();
			Node bodyNode = envelopeNode.getFirstChild();
			String messageType = null;

			while(BODY.equals(bodyNode.getLocalName()) == false && bodyNode != null) {

				bodyNode = bodyNode.getNextSibling();
			}

			if(ENVELOPE.equals(envelopeNode.getLocalName()) && bodyNode != null && BODY.equals(bodyNode.getLocalName())) {
				final Node nodeType = bodyNode.getFirstChild();
				messageType = nodeType.getLocalName();
			}

			if(StringUtils.isBlank(messageType)) {
				throw new WsdlMessageValidatorException(NO_TYPE);
			}


		    
			wsdlMockOperation = typeOperationMap.get(messageType);

			if(wsdlMockOperation == null) {
			    if(isSoapFault(message)){

				Node nodeType = bodyNode.getFirstChild();
				NodeList faultList = nodeType.getChildNodes();
				String errorMessage = "";
			
				for (int i=0; i < faultList.getLength(); i++){
				    Node current = faultList.item(i);
				    if (current.getLocalName() == "faultstring"){
					current = current.getFirstChild();
					errorMessage = current.getNodeValue();
					break;
				    }
				}
				throw new WsdlMessageValidatorFaultException(errorMessage);
			    } else {
				throw new WsdlMessageValidatorException(NO_TYPE);
			    }
			}
			
			final String type = wsdlMockOperation.getName();
			
			mockResponse = wsdlMockOperation.addNewMockResponse(type, true);
			mockResponse.setResponseContent(message);
			final WsdlMockResponseMessageExchange messageExchange = new WsdlMockResponseMessageExchange(mockResponse);
			final AssertionError[] assertionErrors = wsdlValidator.assertResponse(messageExchange, false);
			final String[] stringErrors = new String[assertionErrors.length];

			for(int i=0; i< assertionErrors.length; i++) {
				stringErrors[i] = assertionErrors[i].toString();
			}

			return stringErrors;
		} catch(final WsdlMessageValidatorException e){
		    throw e;
		}
		catch(final Exception e) {
		    throw new WsdlMessageValidatorException(e);
		} finally {
			if(wsdlMockOperation != null && mockResponse != null) {
				wsdlMockOperation.removeMockResponse(mockResponse);
				
			}
		}
	}
}
