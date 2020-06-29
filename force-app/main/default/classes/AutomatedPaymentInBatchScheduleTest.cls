/**
 * Name			:		AutomatedPaymentInBatchScheduleTest
 * Date			:		10/09/2019
 * Author		:		Amit Goyal
 * Description	:		Created for S20-397
*/

@isTest
public class AutomatedPaymentInBatchScheduleTest {
	@testSetup static void setup() {
        Portfolio__c portfolio = new Portfolio__c(Name='Carolina Legal Services', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.Test_Program__c=false;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'Management Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Summon__c sfsCase = new Summon__c();
        sfsCase.Tradeline__c = tradeline.Id;
        sfsCase.Subject__c = 'Test Subject';
        sfsCase.Case_Status__c = 'New';
        insert sfsCase;
        
        String draftRTId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        list<nu_dse__Payment__c> paymentList = new list<nu_dse__Payment__c>();
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = draftRTId, nu_dse__Transaction_Status__c = 'Unknown', 
                                              nu_dse__Schedule_Date__c=System.Today().addDays(1), 
                                              nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = draftRTId, nu_dse__Transaction_Status__c = 'Unknown', 
                                              nu_dse__Schedule_Date__c=System.Today().addDays(2), 
                                              nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = draftRTId, nu_dse__Transaction_Status__c = 'Unknown', 
                                              nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        insert paymentList;
        
        Id ppInRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Draft');
        list<Program_Payment_Out_In__c> ppoList = new list<Program_Payment_Out_In__c>();
        ppoList.add(new Program_Payment_Out_In__c(RecordTypeId=ppInRTId, PROGRAM_UUID__c=testProgram.Id, PROGRAM_NUM__c=testProgram.Name, SCHEDULED_DATE__c=System.Today().addDays(1), AMOUNT__c=0));
        ppoList.add(new Program_Payment_Out_In__c(RecordTypeId=ppInRTId, PROGRAM_UUID__c=testProgram.Id, PROGRAM_NUM__c=testProgram.Name, AMOUNT__c=0));
        insert ppoList;
    }
    
    public static testMethod void testExecution() {
		Test.StartTest();
        AutomatedPaymentInBatchSchedule s=new AutomatedPaymentInBatchSchedule();
        s.execute(null);
        Test.StopTest();
    }
    
	public static testMethod void testschedule() {
		Test.StartTest();
        	AutomatedPaymentInBatchSchedule.scheduleMe();
        Test.StopTest();
    }
}