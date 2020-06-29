@isTest
public class Test_Attorney_PopulateFeeItem {

    @isTest
    public Static void testMethod1(){
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_PopulateFeeItemCategory';
        insert bd;
        
        nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
        ft.Name = 'SUMMIT-Under 30000-81880-50-9-Summit - LDP';
        //u_dse__Settlement_Fee_Percentage__c = 0;
        ft.nu_dse__Settlement_Pct__c = 50;
        ft.nu_dse__GCS_Fee_Group_Id__c = '81880';
        ft.Portfolio_Name__c = 'SUMMIT';
        ft.Debt_Amount__c = 'Under 30000';
        ft.Service_Fee_Percentage__c = 9;
        ft.Program_Type__c = 'Summit - LDP';
        insert ft;
        
        nu_dse__Program__c objOldProgram = new nu_dse__Program__c();
            objOldProgram.nu_dse__Program_Status__c = 'Active Client';
        objOldProgram.Attorney__c = true;
        objOldProgram.Draft_Plan_ID__c = '2323';
        objOldProgram.nds_EstimatedSettlement_Amount__c = 32432;
        objOldProgram.nds_EstimatedProgram_Fee__c = 32432;
        objOldProgram.nds_Program_Savings__c = 32432;
        objOldProgram.nds_Retainer_Fee__c = 32432;
        objOldProgram.nds_Retainer_Fee_Total__c = 32432;
        objOldProgram.nds_Total_Program_Cost__c = 32432;
        objOldProgram.nds_Trust_Fee_Monthly__c = 32432;
        objOldProgram.Cancellation_Date__c = System.today();
        objOldProgram.Import_ID__c = '111';
        objOldProgram.nds_Current_Debt_Payments__c = 3243;
        objOldProgram.nds_Estimated_Total_Debt__c = 32432;
        objOldProgram.NSF_Draft_Date__c = System.today()+1;
        objOldProgram.nds_Maxprogram_length__c = 'MaxProgram';
        objOldProgram.nds_NSF_Draft_Amount__c = 32432;
        objOldProgram.nds_NSF_Reason__c = 'NSFReason';
        objOldProgram.nu_dse__Program_Length__c = 3;
        objOldProgram.Program_Type__c = 'Summit - LDP';
        objOldProgram.nu_dse__Reoccurring_Debit_Day__c = 3;
        objOldProgram.nu_dse__Twice_Monthly_Reoccuring_Day__c = 3;
        objOldProgram.Sales_Rep__c = 'TestSales rep';
        objOldProgram.Sales_Rep_Email__c = 'Test@Test.com';
        objOldProgram.nu_dse__Fee_Template__c = ft.id;
        objOldProgram.nu_dse__Total_Debt_Included__c= 30001;
        objOldProgram.GCS_Policy_Group__c = '81880';
        objOldProgram.Settlement_Fee__c = 9;
        objOldProgram.Estimated_Settlement__c = 50;
    insert objOldProgram;
        
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Program__c = objOldProgram.Id;
        objPayment.Attorney_Payment_Id__c= '123456';
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
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
        objPayment.nu_dse__Admin_Fee__c = 100;
        objPayment.nu_dse__Is_Makeup_Payment_Created__c = false;
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = True;
        objPayment.Draft_Plan_Id__c = '232';
        Database.Insert(objPayment);
        
        nu_dse__Payment__c objPayment1 = new nu_dse__Payment__c();
        objPayment1.RecordTypeId = DraftPlanRecId;
        objPayment1.nu_dse__Program__c = objOldProgram.Id;
        objPayment1.Attorney_Payment_Id__c= '12345';
        objPayment1.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment1.nu_dse__Amount__c = 134;
        objPayment1.nu_dse__Transaction_Status__c = 'Cleared';
    objPayment1.nu_dse__Fee_Item_Category__c = 'Type I';
        objPayment1.Status_Reason__c = 'TestReaso';
        objPayment1.nu_dse__Payment_Type__c = 'Deposit';
        objPayment1.Payment_Type_Data__c = 'TestType1';
        objPayment1.Draft_Split__c = 213.3;
        objPayment1.Legal_Split__c = 123;
        objPayment1.Reserve_Split__c = 2;
        objPayment1.Retainer_Split__c = 223;
        objPayment1.Service_Split__c = 23;
        objPayment1.Trust_Split__c = 23;
        objPayment1.Refund_Payment__c = true;
        objPayment1.nu_dse__Monthly_Maintenance_Fee__c =200;
        objPayment1.nu_dse__Admin_Fee__c = 100;
        objPayment1.nu_dse__Is_Makeup_Payment_Created__c = false;
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = True;
        Database.Insert(objPayment1);
        
        Attorney_PopulateFeeItemCategorySche obj= new Attorney_PopulateFeeItemCategorySche();
        obj.execute(null);
        Attorney_PopulateFeeItemCategory.fakeMethod();
    }
    
}