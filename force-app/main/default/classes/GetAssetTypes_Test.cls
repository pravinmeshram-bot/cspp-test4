@isTest
public class GetAssetTypes_Test {
    
   @isTest static void testGetAssetTypes() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        DocType__c docType = new DocType__c(Name = 'Test');
        insert docType; 
        
        Test.startTest();
        List<String> str = GetAssetTypes.doget();
        Test.stopTest();  
        
        List<DocType__c> docList = [SELECT Name FROM DocType__c WHERE Id =:docType.Id];
        System.assertEquals(docList[0].Name, str[0]);  
        
    }
}