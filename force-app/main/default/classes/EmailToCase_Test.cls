@isTest
public class EmailToCase_Test{
    
    @isTest
    public static void handleInboundEmail_Test() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Summon__c summonInstance1 = [SELECT Id, Name From Summon__c LIMIT 1];
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = '[' + summonInstance1.Name + ']';
        email.fromName = 'test test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye';
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'user@acme.com';
        

        Test.startTest();
            
        // setup controller object
        EmailToCase catcher = new EmailToCase();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        
        Test.stopTest();
        
        List<Summon__c> summonList = [SELECT Id, Description__c From Summon__c LIMIT 1];
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals('Hello, this a test email body. for testing purposes only.Phone:123456 Bye', summonList[0].Description__c );
    }
    
    @isTest
    public static void handleInboundEmail_Test1() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = '[SFS Case';
        email.fromName = 'test test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye';
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'user@acme.com';
        

        Test.startTest();
            
        // setup controller object
        EmailToCase catcher = new EmailToCase();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        
        Test.stopTest();
        
        List<Summon__c> summonList = [SELECT Id, Status__c From Summon__c WHERE Id != :summonInstance.Id LIMIT 1];
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals('New', summonList[0].Status__c);
    }
}