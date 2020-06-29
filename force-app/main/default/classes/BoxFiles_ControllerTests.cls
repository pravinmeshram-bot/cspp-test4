@isTest
public class BoxFiles_ControllerTests implements HttpCalloutMock {

    public static testMethod void BoxFiles_ControllerMethod() {
    
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'box';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        //acc.sharedLink__c = 'Test';
        acc.BoxFolderId__c = '1313';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program;
        
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxFiles_ControllerTests());
        ApexPages.currentPage().getParameters().put('id', program.Id);
         ApexPages.currentPage().getParameters().put('pid', program.Id);
        BoxFiles_Controller boxFileCtrl = new BoxFiles_Controller();
        ApexPages.StandardController sc = new ApexPages.StandardController(program);
        BoxFiles_Controller boxFileCtrl1 = new BoxFiles_Controller(sc);
        boxFileCtrl.FilesharingLink();
        Test.stopTest();
    }
    
    public HTTPResponse respond(HTTPRequest req) {
     
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         //res.setBody('');
         res.setStatusCode(300);
         res.setStatus('OK');
         return res;
     }
}