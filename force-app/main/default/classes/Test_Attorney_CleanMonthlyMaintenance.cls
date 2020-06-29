@isTest
public class Test_Attorney_CleanMonthlyMaintenance {
    
    @isTest
    public static void testMethod1(){
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Program__c = objProgram.Id;
        objPayment.Attorney_Payment_Id__c= '12345';
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 122;
        objPayment.nu_dse__Amount__c = 134;
        objPayment.nu_dse__Transaction_Status__c = 'Cleared';
        objPayment.Statused_On__c = System.today()+6;
        objPayment.Status_Reason__c = 'TestReaso';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType1';
        objPayment.Draft_Split__c = 213.3;
        objPayment.Legal_Split__c = 123;
        objPayment.Reserve_Split__c = 2;
        objPayment.Retainer_Split__c = 223;
        objPayment.Service_Split__c = 23;
        objPayment.Trust_Split__c = 23;
        objPayment.Refund_Payment__c = true;
        objPayment.nu_dse__Monthly_Maintenance_Fee__c =200;
        objPayment.nu_dse__Admin_Fee__c = 0;
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = True;
        Database.Insert(objPayment);
        
        Attorney_CleanMonthlyMaintenaceFeeSch obj= new Attorney_CleanMonthlyMaintenaceFeeSch();
        obj.execute(null);
    }
    
}