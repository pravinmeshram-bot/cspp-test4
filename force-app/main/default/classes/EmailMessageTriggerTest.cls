@isTest
public class EmailMessageTriggerTest{
    static testMethod void emailMessaging(){
        //Inserting account
        Account acc = new Account();
        acc.FirstName= 'New test account';
        acc.LastName = 'last name';
        system.debug('###'+Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId());
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        acc.PersonEmail = 'test@email.com';
        Insert acc;
        
        //Create case with test data
        Case Cas= new Case();
        Cas.Subject= 'testsubject';
        Cas.Status = 'New';
        Cas.Origin = 'Email';
        Cas.AccountId = acc.Id;
        insert Cas;
        
        //Creating Incoming Email Message 
        EmailMessage incomingMail = new EmailMessage();
        incomingMail .fromaddress='test@email.com';
        incomingMail .toAddress = 'test@test.com';
        incomingMail .subject = 'Test Message';
        incomingMail .TextBody= 'This is the message body ';
        incomingMail .parentid=Cas.id;
        incomingMail .incoming=true;
        insert incomingMail ;      
    }
}