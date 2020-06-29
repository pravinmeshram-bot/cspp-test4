@isTest
public class Test_Attorney_GetPaymentsBatch {
    
    static List <FileNumberData__c> fileList = new List <FileNumberData__c> ();
    static void init () {
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        insert batchJobTimings;
        
        FileNumberData__c file = new FileNumberData__c();
        file.Completed__c = false;
        file.Name = '1';
        file.Type__c = 'Draft';
        file.isFirstPayment__c = true;
        insert file;
        fileList.add(file);
        
        FileNumberData__c file1 = new FileNumberData__c();
        file1.Completed__c = false;
        file1.Name = '1';
        file1.Type__c = 'Draft';
        file1.isFirstPayment__c = false;
        insert file1;
        fileList.add(file1);
        
        nu_dse__Program__c program = new nu_dse__Program__c ();
        program.Import_ID__c = '1';
        insert program;
        
        nu_dse__Bank_Account__c bankAcc = new nu_dse__Bank_Account__c ();
        bankAcc.Import_ID__c = '1';
        bankAcc.nu_dse__Bank_Account_Number__c = '123';
        insert bankAcc;
        
        WorkFlow__c workFlowRec = new WorkFlow__c ();
        workFlowRec.FileNumber__c = '1';
        insert workFlowRec;
        
        nu_dse__Group_Task__c grouptask = new nu_dse__Group_Task__c ();
        groupTask.FileNumber__c = '1';
        groupTask.Subject_Picklist__c = '1099c on File';
        insert groupTask;
        
        Task taskRec = new Task ();
        taskRec.FileNumber__c = '1';
        taskRec.subject = 'test';
        insert taskRec;
        
        Account acc = new Account ();
        acc.Name = 'Test';

        acc.NDS_File_Number__c = '1';
        
        insert acc;
        
    }
    @isTest static void batchTest () {
        init ();
        Test.startTest ();
            Database.QueryLocator ql;
            Database.BatchableContext bc;
            Attorney_GetPaymentsBatch clientsObj = new Attorney_GetPaymentsBatch (System.Now ()-1, System.Now ());
            Database.executeBatch(clientsObj);
            clientsObj.finish (bc);
            clientsObj.execute (bc, fileList);
            
        Attorney_GetPaymentsBatch1 clientsObj1 = new Attorney_GetPaymentsBatch1 (System.Now ()-1, System.Now ());
            Database.executeBatch(clientsObj1);
        
        Test.stoptest ();
        
    }
    
    
}