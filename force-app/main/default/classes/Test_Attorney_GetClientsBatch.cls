@isTest
public class Test_Attorney_GetClientsBatch {
    static List <Account> accList = new List <Account> ();
    static List <FileNumberData__c> dataList = new List <FileNumberData__c> ();
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
        
        nu_dse__Program__c program = new nu_dse__Program__c ();
        program.Import_ID__c = '1';
        insert program;
        
        nu_dse__Bank_Account__c bankAcc = new nu_dse__Bank_Account__c ();
        bankAcc.Import_ID__c = '1';
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
        accList.add (acc);
        
        FileNumberData__c data = new FileNumberData__c ();
        data.Type__c = 'Client';
        data.completed__c = FALSE;
        insert data;
        dataList.add (data);
        
    }
    @isTest static void batchTest () {
        init ();
        Test.startTest ();
            Database.QueryLocator ql;
            Database.BatchableContext bc;
            Attorney_GetClientsBatch clientsObj = new Attorney_GetClientsBatch (DateTime.Now (), DateTime.Now ());
            clientsObj.start (bc);
            try {
                clientsObj.execute (bc, dataList );
            }
            catch (Exception e) {}
            clientsObj.finish (bc);
        Test.stoptest ();
        
    }
    
   
    
    
}