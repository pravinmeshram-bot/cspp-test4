@isTest
public class uploadBoxFilesNewTests implements HttpCalloutMock {

    public static testMethod void uploadBoxFilesNewMethod1() {
        
        Document doc1;
        doc1= new Document();
        doc1.Body = Blob.valueOf('enterpriseId:123121');
        doc1.ContentType = 'application/xml';
        doc1.DeveloperName = 'Box_Cred_Test1';
        doc1.IsPublic = true;
        doc1.Name = 'Box Cred';
        doc1.FolderId = [select id,name from folder where name= 'Shared Documents'].id;
        insert doc1;
        
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'Daily Report Test';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        acc.boxfolderid__c = '88909878909';
        acc.sharedlink__c = 'www.test.com';
        acc.Phone = '1234567890';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__account__c = acc.Id;
        insert program;
        
        ApexPages.currentPage().getParameters().put('pid', program.Id);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new uploadBoxFilesNewTests());
        uploadBoxFilesNew uploadBoxFilesNewInstnace = new uploadBoxFilesNew();
        //uploadBoxFilesNewInstnace.getAccessToken();
        
        Test.stopTest();
    }
    
    public static testMethod void uploadBoxFilesNewMethod2() {
    
        Document doc2;
        doc2= new Document();
        doc2.Body = Blob.valueOf('enterpriseId:123121');
        doc2.ContentType = 'application/xml';
        doc2.DeveloperName = 'Box_Cred_Test2';
        doc2.IsPublic = true;
        doc2.Name = 'Box Cred';
        doc2.FolderId = [select id,name from folder where name= 'Shared Documents'].id;
        insert doc2;
        
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'Daily Report Test';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        acc.boxfolderid__c = '88909878909';
        acc.Phone = '1234567890';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program;
        
        ApexPages.currentPage().getParameters().put('pid', program.Id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new uploadBoxFilesNewTests());
        uploadBoxFilesNew uploadBoxFilesNewInstnace = new uploadBoxFilesNew();
        uploadBoxFilesNewInstnace.getAccessToken();
        Test.stopTest();
    }
    
    public HTTPResponse respond(HTTPRequest req) {
     
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setStatusCode(300);
         res.setStatus('OK');
         return res;
     }
  }