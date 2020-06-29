@isTest
public class TwiMl_Test{
            
    static testMethod void testTwiMl() {
        
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        programInstance.Portfolio__c = portfolio.Id;
        insert programInstance;
        
        nu_dse__Payment__c payment = TestRecordCreator.createPayments(programInstance.Id);
        insert payment;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(null, programInstance.Id);
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        insert offerInstance;
        
        nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('Voice Broadcast');
        communicationTemp.nu_dse__TwiML__c = 'Test Message';
        communicationTemp.nu_dse__Action_Type__c = 'Voice Broadcast';
        insert communicationTemp;
        
        List<Voice_Recordings__c> voiceRecs = new List<Voice_Recordings__c>{
            new Voice_Recordings__c(
                Communication_Template__c = communicationTemp.Id,
                twilio_answer_type__c = 'human',
                External_Id__c = 'a02k34bbj2h34',
                Recording_Name__c = 'my_document',
                Portfolio__c = portfolio.Id
            ),
            new Voice_Recordings__c(
                Communication_Template__c = communicationTemp.Id,
                twilio_answer_type__c = 'machine',
                External_Id__c = 'a02ghg7g2h34',
                Recording_Name__c = 'my_document',
                Portfolio__c = portfolio.Id
            )
        };
        
        insert voiceRecs;
        
        Task taskInstance = TestRecordCreator.createTask(programInstance.Id);
        taskInstance.Subject = 'Pending Client Approval (Voice)';
        taskInstance.nu_dse__Communication_Template__c = communicationTemp.Id;
        insert taskInstance;
        
        Task taskInstance1 = TestRecordCreator.createTask(payment.Id);
        taskInstance1.Subject = 'Pending Client Approval (SMS)';
        taskInstance1.nu_dse__Communication_Template__c = communicationTemp.Id;
        insert taskInstance1;
        
        Task taskInstance2 = TestRecordCreator.createTask(offerInstance.Id);
        taskInstance2.Subject = 'Pending Client Approval (Email)';
        taskInstance2.nu_dse__Communication_Template__c = communicationTemp.Id;
        insert taskInstance2;
        
        List<Folder> lstFolder = [Select Id From Folder Where Name = 'Recordings' ];
                
        if (lstFolder.isEmpty() == False && lstFolder.size() > 0) {
        
            Document documentInst = new Document(FolderId = lstFolder[0].Id, Name='Test Name',Keywords = 'Test', DeveloperName = 'my_document');
            insert documentInst;
            
            Document documentInst1 = new Document(FolderId = lstFolder[0].Id, Name='Test Name2',Keywords = 'Test', DeveloperName = 'my_document1');
            insert documentInst1;
        }

        Test.startTest();
            //ApexPages.currentPage().getParameters().put('Digits', '8986565676');
            ApexPages.currentPage().getParameters().put('AnsweredBy', 'human');
            ApexPages.currentPage().getParameters().put('taskId', taskInstance1.Id);
            TwiMl twimlClass = new TwiMl();
            twimlClass.getResponse();
            
            ApexPages.currentPage().getParameters().put('Digits', '1');
            ApexPages.currentPage().getParameters().put('taskId', taskInstance.Id);
            twimlClass.getResponse();
            
            try {
            
                ApexPages.currentPage().getParameters().put('AnsweredBy', 'machine_start');
                ApexPages.currentPage().getParameters().put('taskId', taskInstance2.Id);
                twimlClass.getResponse();
            } catch (Exception e) {
            
            }
            try {
            
                List<Voice_Recordings__c> voiceRecsList = [SELECT Id FROM Voice_Recordings__c];
                delete voiceRecsList;
                
                ApexPages.currentPage().getParameters().put('AnsweredBy', 'human');
                ApexPages.currentPage().getParameters().put('taskId', taskInstance.Id);
                twimlClass.getResponse();
            } catch (Exception e) {
                
            }
            
            try {
            
                List<Portfolio__c > portfolioList = [SELECT Id FROM Portfolio__c ];
                delete portfolioList;
                
                twimlClass.getResponse();
            } catch (Exception e) {
                
            }
        Test.stopTest();  
    }
}