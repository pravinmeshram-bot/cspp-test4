@isTest
public class Test_ServiceLeads360 {
    public static String paymentSObj = nu_dse__Payment__c.sObjectType.getDescribe().getName();
    
    @testSetup
    static void setupTestData(){
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        nu_dse__Field_mapping__c fieldMapping = new nu_dse__Field_mapping__c();
        
        Portfolio__c pp = new Portfolio__c();
        pp.name='TestPortfolio';
        pp.boxfolderid__c = '12312312312';
        insert pp;
        
        List<nu_dse__Prospect__c> newProspect = new List<nu_dse__Prospect__c>();
        nu_dse__Prospect__c proIns = new nu_dse__Prospect__c();
        proIns.nu_dse__First_Name__c = 'Test1';
        proIns.nu_dse__Last_name__c = 'test';
        proIns.portfolio__c = pp.id;
        proIns.upd_External_Id__c='4321'; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
        newProspect.add(proIns);
        insert newProspect;
        
        List<nu_dse__Data_Mapping__c> dataMappings = new List<nu_dse__Data_Mapping__c>{
            new nu_dse__Data_Mapping__c(Name = 'VelocifyLead', nu_dse__Source_sObject__c = 'Group_Task__c', nu_dse__Target_sObject__c = 'Task')
        }; 
        insert dataMappings;
        
        List<nu_dse__Field_mapping__c> fieldMappings = new List<nu_dse__Field_mapping__c>{
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'Id', nu_dse__Target_Field__c = 'nu_dse__Group_Task__c'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Subject__c', nu_dse__Target_Field__c = 'Subject'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Status__c', nu_dse__Target_Field__c = 'Status')
        };
        insert fieldMappings;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        List<RecordType> rectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Draft' AND 
                       SObjectType =: paymentSObj AND isActive = True];
        
        Lead l = new Lead();
        l.NDS_File_Number__c = '1234';
        l.lastName = 'test';
        l.Cash_in_Dedicated_Account__c = 1234;
        l.Addnl_Months_with_Loan__c = 1234;
        l.Loan_Amount__c = 1234;
        l.Loan_Term__c = 123;
        l.Status = 'DNL New Lead';
        l.Sub_Status__c = 'New Lead';
        l.Origination_Fee__c = 200;
        l.Unpaid_Program_Fees__c = 200;
        insert l;
    }
    
    @isTest static void webServiceTest () {
        list<Lead> leadList = [Select Id, LastName From Lead Where LastName='test' limit 1];
        ServiceLeads360 ctrl = new ServiceLeads360();
        ctrl.getLeadByIdRequest(leadList[0].Id);
        
        List<nu_dse__Prospect__c> prospects = [Select Id, Name , upd_External_Id__c From nu_dse__Prospect__c]; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
        ctrl.modifyLeads(prospects);
        
        List<nu_dse__Program__c> programs = [Select Id, Name, External_Id__c From nu_dse__Program__c];
        ctrl.modifyPrograms(programs);
        
        list<ServiceLeads360.FieldValues> sl360fls = new list<ServiceLeads360.FieldValues>();
        sl360fls.add(new ServiceLeads360.FieldValues('a', 'a'));
        sl360fls.add(new ServiceLeads360.FieldValues('b', 'b'));
        
        list<ServiceLeads360.Lead> sl360Leads = new list<ServiceLeads360.Lead>();
        sl360Leads.add(new ServiceLeads360.Lead('1233', sl360fls));
        ctrl.modifyLeadPayments(sl360Leads);
        
        Map<string,string> leadId_statusId = new Map<string,string>();
        LeadId_statusId.put('a', 'a');
        LeadId_statusId.put('b', 'b');
        ctrl.modifyLeadStatus(leadId_statusId);
    }
}