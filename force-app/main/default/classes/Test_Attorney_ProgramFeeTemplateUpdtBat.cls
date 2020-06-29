@isTest
public class Test_Attorney_ProgramFeeTemplateUpdtBat {
    @isTest public static void testMethod1(){
        nu_dse__Program__c program = new nu_dse__Program__c();
        program.Attorney__c = true;
        program.GCS_Policy_Group__c ='Test';
        program.Estimated_Settlement__c = 200;
        program.Settlement_Fee__c = 200;
        program.Program_Type__c = 'Anchor';
        program.nu_dse__Total_Debt_Included__c = 200;
program.Import_ID__c= 'HLG0013919753';
        insert program;
        
        nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
        ft.Portfolio_Name__c = 'ANCHOR'; 
        ft.nu_dse__Settlement_Pct__c = 200;
        ft.Service_Fee_Percentage__c = 200;
        ft.nu_dse__GCS_Fee_Group_Id__c = 'Test';
        ft.Debt_Amount__c = 'Over 30000';
        ft.nu_dse__RAMS_Fee_Group_Id__c = 'Test';
        insert ft;
        
        Database.executeBatch(new Attorney_ProgramFeeTemplateUpdateBatch());
    }
}