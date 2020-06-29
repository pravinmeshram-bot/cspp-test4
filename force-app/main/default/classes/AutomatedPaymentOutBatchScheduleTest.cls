/**
 * Name			:		AutomatedPaymentOutBatchScheduleTest
 * Date			:		10/03/2019
 * Author		:		Amit Goyal
 * Description	:		Created for S20-396
*/

@isTest
public class AutomatedPaymentOutBatchScheduleTest {
    @testSetup static void setup() {
        Portfolio__c portfolio = new Portfolio__c(Name='Carolina Legal Services', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
       nu_dse__Processor__c processor = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processor;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processor.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Name;
        tradeline.nu_dse__Current_Stage__c='Payment Plan Active';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'Accepted';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Summon__c sfsCase = new Summon__c();
        sfsCase.Tradeline__c = tradeline.Id;
        sfsCase.Subject__c = 'Test Subject';
        sfsCase.Case_Status__c = 'New';
        insert sfsCase;
        
        String settlementRTId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
      list<nu_dse__Payment__c> paymentList = new list<nu_dse__Payment__c>();
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = settlementRTId,nu_dse__Payment_Type__c = 'withdrawal', nu_dse__Transaction_Status__c = 'Unknown', 
                                              nu_dse__Schedule_Date__c=System.Today().addDays(1), nu_dse__Offer__c=offer.Id,
                                              nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = settlementRTId,nu_dse__Payment_Type__c = 'withdrawal', nu_dse__Transaction_Status__c = 'Unknown', 
                                              nu_dse__Schedule_Date__c=System.Today().addDays(2), nu_dse__Offer__c=offer.Id,
                                              nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        paymentList.add(new nu_dse__Payment__c(RecordTypeId = settlementRTId,nu_dse__Payment_Type__c = 'withdrawal', nu_dse__Transaction_Status__c = 'Unknown', 
                                               nu_dse__Offer__c=offer.Id, nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        insert paymentList;
        
        Id ppOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Settlement');
        Id feeRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Fee');
        list<Program_Payment_Out_In__c> ppoList = new list<Program_Payment_Out_In__c>();
        ppoList.add(new Program_Payment_Out_In__c(RecordTypeId=ppOutRTId, PROGRAM_UUID__c=testProgram.Id, PROGRAM_NUM__c=testProgram.Name,PMT_PROCESSOR__c = 'GCS - Stonepoint', SCHEDULED_DATE__c=System.Today().addDays(1), AMOUNT__c=0));
        ppoList.add(new Program_Payment_Out_In__c(RecordTypeId=feeRTId, PROGRAM_UUID__c=testProgram.Id,PMT_PROCESSOR__c = 'RAMS - BEDROCK', PROGRAM_NUM__c=testProgram.Name, AMOUNT__c=0));
        insert ppoList;
    }
    
    public static testMethod void testExecution() {
		Test.StartTest();
        AutomatedPaymentOutBatchSchedule s=new AutomatedPaymentOutBatchSchedule();
        s.execute(null);
        Test.StopTest();
    }
    
	public static testMethod void testschedule() {
		Test.StartTest();
        	AutomatedPaymentOutBatchSchedule.scheduleMe();
        Test.StopTest();
    }
}