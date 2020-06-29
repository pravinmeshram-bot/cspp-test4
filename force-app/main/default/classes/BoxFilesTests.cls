@isTest
public class BoxFilesTests implements HttpCalloutMock {

    public static testMethod void BoxFilesMethod1() {
    
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'BoxDocs';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        acc.boxfolderid__c = '88909878909';
        acc.sharedlink__c = 'www.test.com';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__account__c = acc.Id;
        insert program;
        
        ApexPages.currentPage().getParameters().put('pid', program.Id);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BoxFilesTests());
        BoxFiles boxFilesInstnace = new BoxFiles();
        //boxFilesInstnace.FilesharingLink();
        
        Test.stopTest();
    }
    
    public static testMethod void BoxFilesMethod2() {
    
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'BoxDocs';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        acc.sharedLink__c = '';
        acc.boxfolderid__c = '88909878909';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program;
        
        ApexPages.currentPage().getParameters().put('pid', program.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BoxFilesTests());
        BoxFiles boxFilesInstnace = new BoxFiles();
        boxFilesInstnace.sharedlink = null;
        boxFilesInstnace.FilesharingLink();
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