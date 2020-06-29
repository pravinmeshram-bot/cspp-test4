@isTest
public class Test_Velocify_serviceLeads360Com {

    @isTest static void webServiceTest () {
    	clientWebservice ();
        serviceLeads360Com.ClientServiceSoap respElement = new serviceLeads360Com.ClientServiceSoap ();
    
        Test.setMock (WebServiceMock.class, new Test_Velocify_serviceLeads360Com.ModifyLeadStatusMock ());
        respElement.ModifyLeadStatus ('test', 'test', 1234567890,13213);
        
        Test.setMock (WebServiceMock.class, new Test_Velocify_serviceLeads360Com.ModifyLeadFieldMock ());
        respElement.ModifyLeadField ('test', 'test', 1234567890,13213,'sdcvsdv');
    }

    public class ModifyLeadStatusMock implements WebServiceMock {
        public void doInvoke (
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                serviceLeads360Com.ModifyLeadStatusResponse_element respElement = new serviceLeads360Com.ModifyLeadStatusResponse_element ();
                respElement.ModifyLeadStatusResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class ModifyLeadFieldMock implements WebServiceMock {
        public void doInvoke (
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                serviceLeads360Com.ModifyLeadFieldResponse_element respElement = new serviceLeads360Com.ModifyLeadFieldResponse_element ();
                respElement.ModifyLeadFieldResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    static void clientWebservice () {
        serviceLeads360Com.ModifyLeadStatusResult_element StatusResultElement = new serviceLeads360Com.ModifyLeadStatusResult_element ();
        serviceLeads360Com.Response_Element responseElement = new serviceLeads360Com.Response_Element ();
        serviceLeads360Com.Modifications_Element ModificationsElement = new serviceLeads360Com.Modifications_Element ();
        serviceLeads360Com.lead_element lead_element = new serviceLeads360Com.lead_element ();
        serviceLeads360Com.Field_element Field_element = new serviceLeads360Com.Field_element ();
        serviceLeads360Com.ModifyLeadFieldResult_element ModifyLeadFieldResult_element = new serviceLeads360Com.ModifyLeadFieldResult_element ();
        serviceLeads360Com.status_element status_element = new serviceLeads360Com.status_element ();
    }

}