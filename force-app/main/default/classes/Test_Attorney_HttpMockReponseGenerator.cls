/***********************************
*@Class Name :Test_Attorney_HttpMockReponseGenerator
*@Purpose:It is Used to to create the mock response for the test classes
************************************/
@isTest
Global with sharing  class Test_Attorney_HttpMockReponseGenerator {
    //Mock Class for the NDS Program
   global with sharing class programInterface implements WebServiceMock  {
        
       /* global void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType){
          
          LeadtracNetDebt.CreateOrUpdateClientResponse_element respElement =new LeadtracNetDebt.CreateOrUpdateClientResponse_element();
          response.put('response_x', respElement);
        }*/
       
       global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        
        leadtracNetClient.SearchByStatusHistoryResponse_element SearchByStatusHistoryResponse_element = new leadtracNetClient.SearchByStatusHistoryResponse_element ();
        SearchByStatusHistoryResponse_element.SearchByStatusHistoryResult = DateTime.Now ();
        
        leadtracNetClient.GetClientsByPhoneNumberResult GetClientsByPhoneNumberResult = new leadtracNetClient.GetClientsByPhoneNumberResult ();
        leadtracNetClient.ArrayOfClient ArrayOfClient = new leadtracNetClient.ArrayOfClient ();
        leadtracNetClient.client client = new leadtracNetClient.client ();
        leadtracNetClient.ArrayOfClientStatus ArrayOfClientStatus = new leadtracNetClient.ArrayOfClientStatus ();
        
        List <leadtracNetClient.ClientStatus> clientStatusArray = new List <leadtracNetClient.ClientStatus> ();
        leadtracNetClient.ClientStatus ClientStatus = new leadtracNetClient.ClientStatus ();
        clientStatus.WorkflowName = 'test';
        clientStatus.Name = 'test';
        clientStatus.UpdatedOn = DateTime.now ();
        clientStatusArray.add (clientStatus );
        
        ArrayOfClientStatus.ClientStatus = clientStatusArray;
        
        client.FileNumber = '1';
        client.CampaignId = '1';
        client.CreatedOn = DateTime.now ();
        client.UpdatedOn = DateTime.now ();
        client.UpdatedBy = 'test';
        client.CurrentStatus = ArrayOfClientStatus;
        List <leadtracNetClient.Client> clientList = new List <leadtracNetClient.Client> ();
        clientList.add (client);
        ArrayOfClient.client = clientList;

        GetClientsByPhoneNumberResult.ClientList = ArrayOfClient;
        leadtracNetClient.GetClientsByPhoneNumberResponse_element GetClientsByPhoneNumberResponse_element = new leadtracNetClient.GetClientsByPhoneNumberResponse_element ();
        GetClientsByPhoneNumberResponse_element.GetClientsByPhoneNumberResult = GetClientsByPhoneNumberResult;        
        
        leadtracNetClient.SearchByStatusHistoryResponse_element response_x = new leadtracNetClient.SearchByStatusHistoryResponse_element ();
        response_x.SearchByStatusHistoryResult = SearchByStatusHistoryResponse_element.SearchByStatusHistoryResult;
        //response_x.GetClientsByPhoneNumberResult = GetClientsByPhoneNumberResponse_element.GetClientsByPhoneNumberResponse_element;
        
        response.put('response_x', response_x);
           }
    }
 
    
}