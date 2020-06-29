@isTest
public class ProspectHandler_Test {

    @testsetup
    public static void testData(){
        
        Id clientID = [Select id from RecordType where sObjectType='Account' and  DeveloperName='Client' and ispersonType=true limit 1].Id;
        Id draftId = [select id from RecordType where sObjectType='nu_dse__Payment__C' and developerName='Draft' limit 1 ].id;
        
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings(); 
        
        insert settings; 
        
        nu_dse__Data_Mapping__c datamapping = TestRecordCreator.createDataMapping('VelocifyLead','Velocify','VelocifyLead');
        
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
        
        processor.External_Id__c = '12345';
        
        insert processor; 
        
        Account a = TestRecordCreator.createAccount('TestLN', clientId );
        
        insert a; 
        
        nu_dse__Program__c p = TestRecordCreator.createProgram(a.ID, processor.id);
        p.nu_dse__Payment_Frequency__c = 'Monthly'; 
        
        insert p; 
        
        nu_dse__Prospect__c l = TestRecordCreator.createProspect();
        insert l; 
        
        
        nu_dse__Payment__c p1 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId, null);
        p1.nu_dse__Prospect__c= l.id; 
                      
        nu_dse__Payment__C p2 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
         p2.nu_dse__Prospect__c= l.id;
        
        nu_dse__Payment__C p3 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
         p3.nu_dse__Prospect__c= l.id;
        
        nu_dse__Payment__c p4 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId, null);
         p4.nu_dse__Prospect__c= l.id;
        
        nu_dse__Payment__C p5 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
         p5.nu_dse__Prospect__c= l.id;
        
        nu_dse__Payment__C p6 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
         p6.nu_dse__Prospect__c= l.id;
        
        List<nu_dse__Payment__C> payments = new List<nu_dse__Payment__C>();
        
        payments.add(p1);
        payments.add(p2);
        payments.add(p3);
        payments.add(p4);
        payments.add(p5);
        payments.add(p6);
               
        insert payments; 
        
    }
    
    public static testmethod void test1(){
        
        nu_dse__Prospect__c lead = [select id,nu_dse__First_Name__C,nu_dse__Last_name__c from nu_dse__Prospect__c limit 1];
        
        lead.nu_dse__Last_name__c = 'Testing2'; 
        lead.Upd_External_Id__c = 'asdfasdfllkjadsf'; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
        
        update lead; 
        
        nu_dse__Program__C program = [select id,nu_dse__Total_Debt_Included__c from nu_dse__Program__C limit 1];
        
        program.nu_dse__Total_Debt_Included__c = 10000.00; 
        program.External_Id__c = '56789';
        
        update program; 
        
        List<nu_dse__Payment__C> payments = [select id,nu_dse__Transaction_Status__c from nu_dse__Payment__C ];
        List<nu_dse__Payment__C> updatedPayments = new list<nu_dse__Payment__C>(); 
        
        for(nu_dse__Payment__C p: payments){
            
            p.nu_dse__Transaction_Status__c = 'Completed';
            
            updatedPayments.add(p);
        }
       
        System.test.startTest();
        
            update updatedPayments; 
        
        System.test.stopTest();
    }
 /*-   
    public static testmethod void cancelledPrograms(){
        
        
        nu_dse__Program__C program = [select id,nu_dse__Total_Debt_Included__c from nu_dse__Program__C limit 1];
        
        program.nu_dse__Program_Status__c = 'Cancelled';
        program.External_Id__c = '56789';
        
        update program; 
        
        List<nu_dse__Payment__C> payments = [select id,nu_dse__Transaction_Status__c from nu_dse__Payment__C ];
        List<nu_dse__Payment__C> updatedPayments = new list<nu_dse__Payment__C>(); 
        
        for(nu_dse__Payment__C p: payments){
            
            p.nu_dse__Transaction_Status__c = 'Completed';
            
            updatedPayments.add(p);
        }
       
        System.test.startTest();
        
            update updatedPayments; 
        
        System.test.stopTest();
    } -*/
}