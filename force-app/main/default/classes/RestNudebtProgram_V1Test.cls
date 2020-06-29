/**
* @File Name          : RestNudebtProgram_V1Test.cls
* @Description        : 
* @Author             : anmol@fsDev
* @Group              : 
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    4/13/2020   anmol@fsDev     Initial Version
**/
//DV-541/DV-540 new class created

@isTest
public class RestNudebtProgram_V1Test {
    
    @testSetup
    public static void createTestData(){
    Id clientID = [Select id from RecordType where sObjectType='Account' and DeveloperName = 'Client' limit 1].Id;
        Id creditorId = [Select id from RecordType where sObjectType='Account' and DeveloperName = 'Creditor' limit 1].Id;
        Id draftId = [select id from RecordType where sObjectType='nu_dse__Payment__C' and developerName='Draft' limit 1 ].id;
        
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings();         
        insert settings; 
        
        nu_dse__Data_Mapping__c datamapping = TestRecordCreator.createDataMapping('Salesforce','Velocify','VelocifyLead');       
        insert datamapping; 
        
        nu_dse__Data_Mapping__c datamapping2 = TestRecordCreator.createDataMapping('Salesforce','Velocify','VelocifyLeadPayments');        
        insert datamapping2; 
        
        nu_dse__Field_mapping__c fieldMapping = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__First_Name__c','119');
        
        nu_dse__Field_mapping__c fieldMapping2 = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__Last_name__c','120');
        
        nu_dse__Field_mapping__c fieldMapping3 = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__Program_Length__c','136');
        
        nu_dse__Field_mapping__c fieldMapping4 = TestRecordCreator.createFieldMapping(datamapping2.id,'Payment 1 Date','119');
        
        nu_dse__Field_mapping__c fieldMapping5 = TestRecordCreator.createFieldMapping(datamapping2.id,'Payment 1 Amount','120');
        
        nu_dse__Field_mapping__c fieldMapping6 = TestRecordCreator.createFieldMapping(datamapping2.id,'Debt Submitted Changed Amount','136');

        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>(); 
        
        fieldMappingList.add(fieldMapping);
        fieldMappingList.add(fieldMapping2);
        fieldMappingList.add(fieldMapping3);
        fieldMappingList.add(fieldMapping4);
        fieldMappingList.add(fieldMapping5);
        fieldMappingList.add(fieldMapping6);
        
        insert fieldMappingList; 
        
        nu_dse__Processor__C processor = TestRecordCreator.createProcessor('GCS');
        processor.nu_dse__Type__c = 'GCS';
        insert processor; 
        
        Account a1 = TestRecordCreator.createAccount('TestLN', clientID); //Mayur
        //Commented by Mayur to avoid Package Validation to fire
        //  a1.nu_dse__Active_Creditor__c = true;        
        insert a1; 
        
        //Below code was added and then commented by Mayur because we commented line 59 and so do not need this code.
  /*      nu_dse__Creditor_Processor_Info__c CreditPro = new nu_dse__Creditor_Processor_Info__c();
      //  CreditPro.Name = 'Test';
        CreditPro.nu_dse__Account__c = a1.Id;
        Insert CreditPro;
        
        a1.nu_dse__Active_Creditor__c = true;
        a1.nu_dse__GCS_Synced__c = true;
        update a1; */
     
     //Below code was added by Mayur as Person account needs First and last Name to populate and not just Name
        
   //     Account a = TestRecordCreator.createAccountPer('TestLN', clientId); Commented by Mayur to avoid deploying TestRecordCreator
    //  a.nu_dse__Active_Creditor__c = true; commented by Mayur as this field is not in prod
   //     insert a; //Commented to avoid TestRecordCreator deployment.
        
        nu_dse__Program__c p = TestRecordCreator.createProgram(a1.ID, processor.id);
        p.nu_dse__Payment_Frequency__c = 'Monthly'; 
        p.DNL_Status__c = 'NONE';
        p.Draft_Plan_ID__c = '6997142';
        insert p; 
        
        nu_dse__Tradeline__c t = new nu_dse__Tradeline__c();
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        t.nu_dse__Program__c = p.id;
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Applicant';
        t.isNewTrade__c=false;
        //Below line is commented by Mayur to avoid Package Validation on Original Creditor Field filter.
   //     t.nu_dse__Original_Creditor__c = a1.id;
        t.nu_dse__Original_Account_Number__c = '12345434';
        insert t;
        
        nu_dse__Offer__c Offer = new nu_dse__Offer__c();
        Offer.nu_dse__TradeLine__c = t.Id;
        offer.FileNumber__c = '1234';
        offer.nu_dse__Status__c = 'Accepted';
        offer.nu_dse__Program__c = p.id;
        insert offer;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
    }
    
    @isTest
    private static void testServiceHandlerPostMethod(){
        
        
        nu_dse__Program__c prog = [SELECT Id, Name
                                   , DNL_Status__c
                                   , Estimated_Loan_Amount__c
                                   , Estimated_Financed_Amount__c
                                   , Estimated_Number_of_Payments__c
                                   , Loan_Repayment_Frequency__c
                                   , Estimated_Loan_Start_Date__c
                                   FROM nu_dse__Program__c];
        
        List<nu_dse__Tradeline__c> tradelines = [SELECT Id, Name
                                      , DNL_Estimated_Settlement_Percentage__c
                                      , DNL_Estimated_Settlement_Amount__c
                                      , nu_dse__Program__c 
                                      FROM nu_dse__Tradeline__c 
                                      WHERE nu_dse__Program__c = :prog.id];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/v1/UpdateNuDebtProgram/*';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '[{"tradelines":[{"tradelineId":"'+tradelines.get(0).id+'","DNL_Estimated_Settlement_Percentage":70.00,"DNL_Estimated_Settlement_Amount":6538.00}],"programId":"'+prog.id+'","Loan_Repayment_Frequency":"Twice-a-Month","Estimated_Number_of_Payments":76,"Estimated_Loan_Start_Date":"2019-08-08","Estimated_Loan_Amount":20090.86,"Estimated_Financed_Amount":19134.21,"DNL_Status":"Pre-TILA Signed"}]';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RestNuDebtProgram_V1.updateProgram();       
        Test.stopTest(); 
    } 

}