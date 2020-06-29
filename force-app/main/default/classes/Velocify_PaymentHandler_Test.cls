/*This test class covers Velocify_PaymentHandler class*/
@isTest
public class Velocify_PaymentHandler_Test{

    static testMethod void TestVelocify_PaymentHandler() {
  
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        VelocifyLeadStatusMapping__c Customsetting1 = new VelocifyLeadStatusMapping__c();
        Customsetting1.Name='GoodFaithCleared';
        Customsetting1.Status__c = 251;
        insert Customsetting1;
        
        VelocifyLeadStatusMapping__c Customsetting2 = new VelocifyLeadStatusMapping__c();
        Customsetting2.Name='1Cleared';
        Customsetting2.Status__c = 39;
        //Customsetting2.Amount_field_Id__c = 649;
        insert Customsetting2;
        
        VelocifyCredentials__c Cred1 = new VelocifyCredentials__c();
        Cred1.UserName__c = 'test.test@test.com';
        Cred1.Password__c = 'test';
        Cred1.Name='VelocifyCredentials';
        insert Cred1;
        
        Account a = new Account();
        a.Name= 'Test';
        a.Phone = '1234567890';
        insert a;
        
        Portfolio__c p = new Portfolio__c();
        p.Name = 'Royal';
        p.Active_Status__c = true;
        insert p;
        
        Test.startTest();
        
        nu_dse__Program__c Program1= new nu_dse__Program__c();
        Program1.Array_Status__c='37799';
        Program1.External_Id__c = '1234';
        Program1.Program_Type__c = 'Royal';
        Program1.nu_dse__Account__c = a.Id;
        Program1.nu_dse__Program_Status__c ='Active Client';
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert Program1;
        
        nu_dse__Payment__c PaymentRec1= new nu_dse__Payment__c();
        PaymentRec1.nu_dse__Transaction_Status__c = 'Cleared';
        PaymentRec1.nu_dse__Is_Good_Faith_Payment__c = false;  
        PaymentRec1.nu_dse__Amount__c = 20;
        PaymentRec1.nu_dse__schedule_Date__c = system.today();
        PaymentRec1.nu_dse__Program__c= Program1.Id;
        PaymentRec1.RecordTypeId = DraftRecordTypeId;
        PaymentRec1.Payment_Status__c = 'Cleared';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec1;
        
       // PaymentRec1.nu_dse__Transaction_Status__c = 'Completed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec1;        
        
        
        nu_dse__Payment__c PaymentRec2= new nu_dse__Payment__c();
        PaymentRec2.nu_dse__Transaction_Status__c = 'Cleared';
        PaymentRec2.nu_dse__Amount__c = 50;
        PaymentRec2.nu_dse__Is_Good_Faith_Payment__c = true;
        PaymentRec2.nu_dse__schedule_Date__c = system.today();
        PaymentRec2.nu_dse__Program__c= Program1.Id;
        PaymentRec2.RecordTypeId = DraftRecordTypeId;
        PaymentRec2.Payment_Status__c = 'Pending';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec2;
        
//        PaymentRec2.nu_dse__Transaction_Status__c = 'Completed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec2;
        
        Test.stopTest();
        
        
    }
    
    static testMethod void TestVelocify_PaymentHandler1() {
  
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        VelocifyLeadStatusMapping__c Customsetting1 = new VelocifyLeadStatusMapping__c();
        Customsetting1.Name='GoodFaithCleared';
        Customsetting1.Status__c = 251;
        insert Customsetting1;
        
        VelocifyLeadStatusMapping__c Customsetting2 = new VelocifyLeadStatusMapping__c();
        Customsetting2.Name='1Cleared';
        Customsetting2.Status__c = 39;
        //Customsetting2.Amount_field_Id__c = 649;
        insert Customsetting2;
        
        VelocifyCredentials__c Cred1 = new VelocifyCredentials__c();
        Cred1.UserName__c = 'test.test@test.com';
        Cred1.Password__c = 'test';
        Cred1.Name='VelocifyCredentials';
        insert Cred1;
        
        Account a = new Account();
        a.Name= 'Test';
        a.Phone = '1234567890';
        insert a;
        
        Portfolio__c p = new Portfolio__c();
        p.Name = 'Royal';
        p.Active_Status__c = true;
        insert p;
        
        nu_dse__Program__c Program1= new nu_dse__Program__c();
        Program1.Array_Status__c='37799';
        Program1.External_Id__c = '1234';
        Program1.nu_dse__Account__c = a.Id;
        Program1.Program_Type__c= 'Royal';
        Program1.nu_dse__Program_Status__c ='Active Client';
        insert Program1;
        
        nu_dse__Payment__c PaymentRec1= new nu_dse__Payment__c();
        PaymentRec1.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec1.nu_dse__Is_Good_Faith_Payment__c = false;  
        PaymentRec1.nu_dse__Amount__c = 20;
        PaymentRec1.nu_dse__schedule_Date__c = system.today();
        PaymentRec1.nu_dse__Program__c= Program1.Id;
        PaymentRec1.RecordTypeId = DraftRecordTypeId;
        PaymentRec1.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec1;
        
        //PaymentRec1.nu_dse__Transaction_Status__c = 'Cleared';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec1;
                
        nu_dse__Payment__c PaymentRec2= new nu_dse__Payment__c();
        PaymentRec2.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec2.nu_dse__Amount__c = 50;
        PaymentRec2.nu_dse__Is_Good_Faith_Payment__c = true;
        PaymentRec2.nu_dse__schedule_Date__c = system.today();
        PaymentRec2.nu_dse__Program__c= Program1.Id;
        PaymentRec2.RecordTypeId = DraftRecordTypeId;
        PaymentRec2.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec2;
        
        PaymentRec2.nu_dse__Transaction_Status__c = 'Completed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec2;
        
        test.startTest();
        
        nu_dse__Payment__c PaymentRec3= new nu_dse__Payment__c();
        PaymentRec3.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec3.nu_dse__Amount__c = 50;
        PaymentRec3.nu_dse__Is_Good_Faith_Payment__c = False;
        PaymentRec3.nu_dse__schedule_Date__c = system.today();
        PaymentRec3.nu_dse__Program__c= Program1.Id;
        PaymentRec3.RecordTypeId = DraftRecordTypeId;
        PaymentRec3.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =true;
        insert PaymentRec3;
        
        PaymentRec3.nu_dse__Transaction_Status__c = 'Failed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec3;
        
        nu_dse__Payment__c PaymentRec4= new nu_dse__Payment__c();
        PaymentRec4.nu_dse__Transaction_Status__c = 'Cleared';
        PaymentRec4.nu_dse__Is_Good_Faith_Payment__c = false;  
        PaymentRec4.nu_dse__Amount__c = 20;
        PaymentRec4.nu_dse__schedule_Date__c = system.today();
        PaymentRec4.nu_dse__Program__c= Program1.Id;
        PaymentRec4.Payment_Status__c = 'Cleared';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        PaymentRec4.RecordTypeId = DraftRecordTypeId;
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =true;
        insert PaymentRec4;
       
        Program1.External_Id__c = '123456';   
        Program1.nu_dse__Program_Status__c ='Client Cancelled';
        Program1.nu_dse__Cancellation_Reason__c = 'test';
        Program1.nds_Cancellation_Reason__c = 'test';
        Velocify_ProgramHandler.VelocifyExecuted =false;
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        update Program1;
        
        Test.stopTest();
    }
    
    static testMethod void TestVelocify_PaymentHandler2() {
  
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        VelocifyLeadStatusMapping__c Customsetting1 = new VelocifyLeadStatusMapping__c();
        Customsetting1.Name='GoodFaithCleared';
        Customsetting1.Status__c = 251;
        insert Customsetting1;
        
        VelocifyLeadStatusMapping__c Customsetting2 = new VelocifyLeadStatusMapping__c();
        Customsetting2.Name='1Cleared';
        Customsetting2.Status__c = 39;
        //Customsetting2.Amount_field_Id__c = 649;
        insert Customsetting2;
        
        VelocifyCredentials__c Cred1 = new VelocifyCredentials__c();
        Cred1.UserName__c = 'test.test@test.com';
        Cred1.Password__c = 'test';
        Cred1.Name='VelocifyCredentials';
        insert Cred1;
        
        Account a = new Account();
        a.Name= 'Test';
        a.Phone = '1234567890';
        insert a;
        
        Portfolio__c p = new Portfolio__c();
        p.Name = 'Royal';
        p.Active_Status__c = true;
        insert p;
        
        nu_dse__Program__c Program1= new nu_dse__Program__c();
        Program1.Array_Status__c='37799';
        Program1.External_Id__c = '1234';
        Program1.nu_dse__Account__c = a.Id;
        Program1.Program_Type__c= 'Royal';
        Program1.nu_dse__Program_Status__c ='Active Client';
        Program1.nu_dse__Payment_Frequency__c = 'Twice Monthly';
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert Program1;
        
        nu_dse__Payment__c PaymentRec1= new nu_dse__Payment__c();
        PaymentRec1.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec1.nu_dse__Is_Good_Faith_Payment__c = false;  
        PaymentRec1.nu_dse__Amount__c = 20;
        PaymentRec1.nu_dse__schedule_Date__c = system.today();
        PaymentRec1.nu_dse__Program__c= Program1.Id;
        PaymentRec1.RecordTypeId = DraftRecordTypeId;
        PaymentRec1.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec1;
        
        //PaymentRec1.nu_dse__Transaction_Status__c = 'Cleared';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec1;
                
        nu_dse__Payment__c PaymentRec2= new nu_dse__Payment__c();
        PaymentRec2.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec2.nu_dse__Amount__c = 50;
        PaymentRec2.nu_dse__Is_Good_Faith_Payment__c = true;
        PaymentRec2.nu_dse__schedule_Date__c = system.today();
        PaymentRec2.nu_dse__Program__c= Program1.Id;
        PaymentRec2.RecordTypeId = DraftRecordTypeId;
        PaymentRec2.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec2;
        
        PaymentRec2.nu_dse__Transaction_Status__c = 'Completed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        update PaymentRec2;
        
        test.startTest();
        
        nu_dse__Payment__c PaymentRec3= new nu_dse__Payment__c();
        PaymentRec3.nu_dse__Transaction_Status__c = 'Pending';
        PaymentRec3.nu_dse__Amount__c = 50;
        PaymentRec3.nu_dse__Is_Good_Faith_Payment__c = False;
        PaymentRec3.nu_dse__schedule_Date__c = system.today();
        PaymentRec3.nu_dse__Program__c= Program1.Id;
        PaymentRec3.RecordTypeId = DraftRecordTypeId;
        PaymentRec3.Payment_Status__c = 'Pending';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =false;
        insert PaymentRec3;
        
        PaymentRec3.nu_dse__Transaction_Status__c = 'Failed';
        Velocify_PaymentHandler.VelocifyExecuted =false;
        update PaymentRec3;
        
        nu_dse__Payment__c PaymentRec4= new nu_dse__Payment__c();
        PaymentRec4.nu_dse__Transaction_Status__c = 'Cleared';
        PaymentRec4.nu_dse__Is_Good_Faith_Payment__c = false;  
        PaymentRec4.nu_dse__Amount__c = 20;
        PaymentRec4.nu_dse__schedule_Date__c = system.today();
        PaymentRec4.nu_dse__Program__c= Program1.Id;
        PaymentRec4.Payment_Status__c = 'Cleared';
        PaymentRec1.nu_dse__Type__c = 'MONTHLY';
        PaymentRec4.RecordTypeId = DraftRecordTypeId;
        Velocify_PaymentHandler.VelocifyExecuted =false;
        Velocify_ProgramHandler.VelocifyExecuted =False;
        insert PaymentRec4;
       
        Program1.External_Id__c = '123456';   
        Program1.nu_dse__Program_Status__c ='Client Cancelled';
        Program1.nu_dse__Cancellation_Reason__c = 'test';
        Program1.nds_Cancellation_Reason__c = 'test';
        Velocify_ProgramHandler.VelocifyExecuted =false;
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        update Program1;
        
        Test.stopTest();
    }
}