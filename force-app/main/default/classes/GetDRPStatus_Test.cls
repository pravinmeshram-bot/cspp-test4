@isTest
public class GetDRPStatus_Test  {
    
   @isTest static void testGetDRPStatus() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Id clientRecTypeId;
        String message;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        acc.nu_dse__client_number__c = 111222;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        insert acc;
               
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
       List<GetDRPStatus.NuDebtProgramRecordRequest> requestList = new List<GetDRPStatus.NuDebtProgramRecordRequest>();
        GetDRPStatus.NuDebtProgramRecordRequest request = new GetDRPStatus.NuDebtProgramRecordRequest();
        request.ProgramId = Program.Id;
       requestList.add(request);
        String requestStr = JSON.Serialize(requestList);
        req.requestBody = Blob.ValueOf(requestStr);
        
        RestContext.request = req;
        RestContext.response = res;

        
        Test.startTest();
        GetDRPStatus.getProgramStatus();
        Test.stopTest();  
        
    }
}