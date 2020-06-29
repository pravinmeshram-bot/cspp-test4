@isTest
public class Test_Attorney_NoteHandler {

    @isTest
    public Static void testMethod1(){
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        //objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        objTradeLine.nu_dse__Original_account_number__c = '123';
        objTradeline.applicant_type__c = 'Joint';
        objTradeline.Import_ID__c = '1234';
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        Database.Insert(objTradeLine);
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted =false;
        
        
        Note n = new Note();
        n.Title = 'Test';
        n.Body = 'Test';
        n.ParentId = objTradeline.id;
        insert n;
        
        n.Title = 'Test**(24534)';
        Update n;
    }
    
}