@isTest
public class UpdateFolderId_Test {
    
    @testsetup
    public static void testdata(){
        
       id clientRecID = [select id from recordType where sObjectType='Account' and Developername='Client' limit 1].id;
        
       nu_dse__Processor__c processor = TestRecordCreator.createProcessor('CFT');
        
       Account act = TestRecordCreator.createAccount(clientRecID);
       
        insert act; 
        
       nu_dse__Program__c program = TestRecordCreator.createProgram(act.id, processor.Id);
        
       insert program;
        
    }
    
    
    public static testmethod void test1(){
        
        Account act = [select id, Box_Folder_Name__c from Account limit 1];
        RestRequest req = new RestRequest();
        req.params.put('clientId', act.Box_Folder_Name__c);
        req.params.put('folderId','test123');
        
         RestContext.request = req;
        
        System.test.startTest(); 
           
            UpdateFolderId.doPost(); 
        
        System.Test.stopTest();
    }

}