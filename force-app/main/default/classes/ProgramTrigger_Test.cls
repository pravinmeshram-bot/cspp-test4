@istest
public class ProgramTrigger_Test implements HttpCalloutMock {
        
    static testMethod void testCreateProgram(){
        
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createProcessor('CFT');
        newProcessor.nu_dse__Type__c = 'CFT';
        Insert newProcessor;
                                                             
        Account acc = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), Phone  = '9845764876', 
                               PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', PersonMailingCity = 'city', personMailingState = 'AL', 
                               personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', 
                               PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', PersonEmail = 'client@test.com', nu_dse__Co_First_Name__c = 'Test', 
                               nu_dse__Co_Last_Name__c = 'CoClient', nu_dse__Co_SSN__c = '501-96-4554', nu_dse__Co_Date_of_Birth__c = System.Today(), 
                               nu_dse__Co_Phone__c = '7854986587', nu_dse__Co_Address_Line__c = 'Test Street num 1', nu_dse__Co_City__c = 'Clio', 
                               nu_dse__Co_Postal_Code__c = '94406', nu_dse__Co_State__c = 'AL', nu_dse__CO_Email_Address__c = 'test@email.com');   
        
        if (accountRecordTypeMap.containsKey('Client')) {
                               
            acc.RecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        insert acc;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        Portfolio__c portfolio = new Portfolio__c(Name = 'Timberline', Active_Status__c = True);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c (nu_dse__Account__c = acc.Id, nu_dse__Processor__c = newProcessor.Id, 
                                         nu_dse__Processor_Status__c = 'Inactive', Import_ID__c='1232',Attorney__c = true, nu_dse__Fee_Template__c = feeTemp.Id,
                                         Portfolio__c = portfolio.Id);
        insert program;
        
        nu_dse__Bank_Account__c BnkAcc = New nu_dse__Bank_Account__c(nu_dse__Account__c = acc.Id, nu_dse__Bank_Name__c = 'Test Bank', nu_dse__Account_Type__c = 'Saving',
                                                                     nu_dse__Bank_Account_Number__c = '1245225', nu_dse__Routing_Number__c = '41414141',
                                                                     nu_dse__Holder_s_Name__c = 'TestHolderName', nu_dse__Program__c = program.Id);
        insert BnkAcc;
                                                    
        program.nu_dse__Program_Status__c = 'Versara Funding';
        
        Versara_Settings__c versara = new Versara_Settings__c(Client_Id__c = '3MVG9GnaLrwG9TQTvYK5BJ8S7trHi42iv.7aT0YNH4jhOaSHrCF7vEaf5ujgPQaFVrQ.HBAEA.XY8nmomCsiW', 
                                                              Client_Secret__c = '6466670819069587957', 
                                                              Refresh_Token__c = '5Aep861.DwG6akZdKLBczT3KbD9hYa_Y71iKtDKInNHwDhXk3XwicXFNXWELeVqVxU0hyoyfKjEFo4c4oGr2sCE', 
                                                              End_Point_URL__c = 'https://test.salesforce.com/services/oauth2/token');
        insert versara;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new ProgramTrigger_Test());
            update program;
        Test.stopTest();
        
    }
    
    
    static testMethod void testCancelPayment(){
        
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c();
        newProcessor.nu_dse__Type__c = 'RAMS';
        newProcessor.Name = 'RAMS-WHITESTONE';
        insert newProcessor;
                                                             
        Account acc = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), Phone  = '9845764876', 
                               PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', PersonMailingCity = 'city', personMailingState = 'AL', 
                               personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', 
                               PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', PersonEmail = 'client@test.com', nu_dse__Co_First_Name__c = 'Test', 
                               nu_dse__Co_Last_Name__c = 'CoClient', nu_dse__Co_SSN__c = '501-96-4554', nu_dse__Co_Date_of_Birth__c = System.Today(), 
                               nu_dse__Co_Phone__c = '7854986587', nu_dse__Co_Address_Line__c = 'Test Street num 1', nu_dse__Co_City__c = 'Clio', 
                               nu_dse__Co_Postal_Code__c = '94406', nu_dse__Co_State__c = 'AL', nu_dse__CO_Email_Address__c = 'test@email.com');   
        
        if (accountRecordTypeMap.containsKey('Client')) {
                               
            acc.RecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        insert acc;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        Portfolio__c portfolio = new Portfolio__c(Name = 'Timberline', Active_Status__c = True);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c (nu_dse__Account__c = acc.Id, nu_dse__Processor__c = newProcessor.Id, 
                                         nu_dse__Processor_Status__c = 'Inactive', Import_ID__c='1232',Attorney__c = true, nu_dse__Fee_Template__c = feeTemp.Id,
                                         Portfolio__c = portfolio.Id, nu_dse__Program_Status__c = 'NSF', Draft_Plan_ID__c = '987987');
        insert program;
        
        Id draftRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        nu_dse__Payment__c paymentInstance = TestRecordCreator.createPayments(program.Id);
        paymentInstance.RecordTypeId = draftRecordTypeId;
        insert paymentInstance;
        
        nu_dse__Bank_Account__c BnkAcc = New nu_dse__Bank_Account__c(nu_dse__Account__c = acc.Id, nu_dse__Bank_Name__c = 'Test Bank', nu_dse__Account_Type__c = 'Saving',
                                                                     nu_dse__Bank_Account_Number__c = '1245225', nu_dse__Routing_Number__c = '41414141',
                                                                     nu_dse__Holder_s_Name__c = 'TestHolderName', nu_dse__Program__c = program.Id);
        insert BnkAcc;
        
        Versara_Settings__c versara = new Versara_Settings__c(Client_Id__c = '3MVG9GnaLrwG9TQTvYK5BJ8S7trHi42iv.7aT0YNH4jhOaSHrCF7vEaf5ujgPQaFVrQ.HBAEA.XY8nmomCsiW', 
                                                              Client_Secret__c = '6466670819069587957', 
                                                              Refresh_Token__c = '5Aep861.DwG6akZdKLBczT3KbD9hYa_Y71iKtDKInNHwDhXk3XwicXFNXWELeVqVxU0hyoyfKjEFo4c4oGr2sCE', 
                                                              End_Point_URL__c = 'https://test.salesforce.com/services/oauth2/token');
        insert versara;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new ProgramTrigger_Test());
            program.nu_dse__Program_Status__c = 'Active Client';
            update program;
        Test.stopTest();
        
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        system.debug('req--->'+req);
        if( req.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token') {
            
            System.assertEquals('https://test.salesforce.com/services/oauth2/token', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            ProgramHandler.ResponseWrapper responsewrap = new ProgramHandler.ResponseWrapper();
            responsewrap.access_token = '00D2F0000008n5X!AQYAQCN_zhjTsn95ND9sP9ybwXDPlrayBQUFMfRBYNuK6jn2XjOo0ATx7HEUHa.j5T.rmFjyHD3aInkGs5Ko3l6_xhOXNRhz';
            responsewrap.instance_url = 'https://cs91.salesforce.com';
            responsewrap.id = 'https://test.salesforce.com/id/00D2F0000008n5XUAQ/0051I000001N6TsQAK';
            responsewrap.token_type = 'Bearer';
            responsewrap.signature = 'mUK5A4Uc2m22UcslU2fc30NKs5W6fo0TsstzuxroLBM=';
            
            String JSONString = Json.Serialize(responsewrap);
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSONString);
            res.setStatusCode(200);
            return res;
            
        } else if (req.getEndpoint() == 'https://cs70.salesforce.com/services/apexrest/CreateClientDetails') {
            
            System.assertEquals('https://cs70.salesforce.com/services/apexrest/CreateClientDetails', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"code":"200","message":"OK"}');
            res.setStatusCode(200);
            return res;
        }
        return null;
    }
    
    static testMethod void testNSFFlow_UnresponsiveNSF(){
        Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c();
        newProcessor.nu_dse__Type__c = 'RAMS';
        newProcessor.Name = 'RAMS-WHITESTONE';
        insert newProcessor;
                                                             
        Account acc = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), Phone  = '9845764876', 
                               PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', PersonMailingCity = 'city', personMailingState = 'AL', 
                               personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', 
                               PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', PersonEmail = 'client@test.com', nu_dse__Co_First_Name__c = 'Test', 
                               nu_dse__Co_Last_Name__c = 'CoClient', nu_dse__Co_SSN__c = '501-96-4554', nu_dse__Co_Date_of_Birth__c = System.Today(), 
                               nu_dse__Co_Phone__c = '7854986587', nu_dse__Co_Address_Line__c = 'Test Street num 1', nu_dse__Co_City__c = 'Clio', 
                               nu_dse__Co_Postal_Code__c = '94406', nu_dse__Co_State__c = 'AL', nu_dse__CO_Email_Address__c = 'test@email.com');   
        
        if (accountRecordTypeMap.containsKey('Client')) {
                               
            acc.RecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        insert acc;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        Portfolio__c portfolio = new Portfolio__c(Name = 'Timberline', Active_Status__c = True);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c (nu_dse__Account__c = acc.Id, nu_dse__Processor__c = newProcessor.Id, 
                                         nu_dse__Processor_Status__c = 'Inactive', Import_ID__c='1232',Attorney__c = true, nu_dse__Fee_Template__c = feeTemp.Id,
                                         Portfolio__c = portfolio.Id, nu_dse__Program_Status__c = 'NSF', Draft_Plan_ID__c = '987987');
        insert program;
        
        Id draftRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        nu_dse__Payment__c paymentInstance = TestRecordCreator.createPayments(program.Id);
        paymentInstance.RecordTypeId = draftRecordTypeId;
        insert paymentInstance;
        
        nu_dse__Bank_Account__c BnkAcc = New nu_dse__Bank_Account__c(nu_dse__Account__c = acc.Id, nu_dse__Bank_Name__c = 'Test Bank', nu_dse__Account_Type__c = 'Saving',
                                                                     nu_dse__Bank_Account_Number__c = '1245225', nu_dse__Routing_Number__c = '41414141',
                                                                     nu_dse__Holder_s_Name__c = 'TestHolderName', nu_dse__Program__c = program.Id);
        insert BnkAcc;
        
        Versara_Settings__c versara = new Versara_Settings__c(Client_Id__c = '3MVG9GnaLrwG9TQTvYK5BJ8S7trHi42iv.7aT0YNH4jhOaSHrCF7vEaf5ujgPQaFVrQ.HBAEA.XY8nmomCsiW', 
                                                              Client_Secret__c = '6466670819069587957', 
                                                              Refresh_Token__c = '5Aep861.DwG6akZdKLBczT3KbD9hYa_Y71iKtDKInNHwDhXk3XwicXFNXWELeVqVxU0hyoyfKjEFo4c4oGr2sCE', 
                                                              End_Point_URL__c = 'https://test.salesforce.com/services/oauth2/token');
        insert versara;
        
        program.nu_dse__Program_Status__c='UnResponsive NSF';
        update program;
        
        list<Profile> pfList= [Select Id, Name from profile where Name='System Administrator'];
        list<User> sysAdminUser = [Select Id, Name From User Where ProfileId=:pfList[0].Id AND isActive=true AND Attorney_Admin__c=true limit 1];
        
        Test.startTest();
        	program.nds_Cancellation_Reason__c='No Follow Up';
            program.nu_dse__Program_Status__c='Client Cancelled';
        System.runAs(sysAdminUser[0]){
            update program;
        }
        Test.stopTest();
        
    }
    
    static testMethod void testSetLendingApplicationDRPGraduated(){
        
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c();
        newProcessor.nu_dse__Type__c = 'RAMS';
        newProcessor.Name = 'RAMS-WHITESTONE';
        insert newProcessor;
                                                             
        Account acc = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), Phone  = '9845764876', 
                               PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', PersonMailingCity = 'city', personMailingState = 'AL', 
                               personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', 
                               PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', PersonEmail = 'client@test.com', nu_dse__Co_First_Name__c = 'Test', 
                               nu_dse__Co_Last_Name__c = 'CoClient', nu_dse__Co_SSN__c = '501-96-4554', nu_dse__Co_Date_of_Birth__c = System.Today(), 
                               nu_dse__Co_Phone__c = '7854986587', nu_dse__Co_Address_Line__c = 'Test Street num 1', nu_dse__Co_City__c = 'Clio', 
                               nu_dse__Co_Postal_Code__c = '94406', nu_dse__Co_State__c = 'AL', nu_dse__CO_Email_Address__c = 'test@email.com');   
        
        if (accountRecordTypeMap.containsKey('Client')) {
                               
            acc.RecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }
        insert acc;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        Portfolio__c portfolio = new Portfolio__c(Name = 'Timberline', Active_Status__c = True);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c (nu_dse__Account__c = acc.Id, nu_dse__Processor__c = newProcessor.Id, 
                                         nu_dse__Processor_Status__c = 'Inactive', Import_ID__c='1232',Attorney__c = true, nu_dse__Fee_Template__c = feeTemp.Id,
                                         Portfolio__c = portfolio.Id, nu_dse__Program_Status__c = 'NSF', Draft_Plan_ID__c = '987987', DNL_Status__c = 'Pre-TILA Signed',
                                         DNL_Lending_Application_ID__c = 'a1k2f000000FeiZAAS');
        insert program;
        
        Id draftRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        nu_dse__Payment__c paymentInstance = TestRecordCreator.createPayments(program.Id);
        paymentInstance.RecordTypeId = draftRecordTypeId;
        insert paymentInstance;
        
        nu_dse__Bank_Account__c BnkAcc = New nu_dse__Bank_Account__c(nu_dse__Account__c = acc.Id, nu_dse__Bank_Name__c = 'Test Bank', nu_dse__Account_Type__c = 'Saving',
                                                                     nu_dse__Bank_Account_Number__c = '1245225', nu_dse__Routing_Number__c = '41414141',
                                                                     nu_dse__Holder_s_Name__c = 'TestHolderName', nu_dse__Program__c = program.Id);
        insert BnkAcc;
        
        Versara_Settings__c versara = new Versara_Settings__c(Client_Id__c = '3MVG9GnaLrwG9TQTvYK5BJ8S7trHi42iv.7aT0YNH4jhOaSHrCF7vEaf5ujgPQaFVrQ.HBAEA.XY8nmomCsiW', 
                                                              Client_Secret__c = '6466670819069587957', 
                                                              Refresh_Token__c = '5Aep861.DwG6akZdKLBczT3KbD9hYa_Y71iKtDKInNHwDhXk3XwicXFNXWELeVqVxU0hyoyfKjEFo4c4oGr2sCE', 
                                                              End_Point_URL__c = 'https://test.salesforce.com/services/oauth2/token');
        insert versara;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new ProgramTrigger_Test());
            program.nu_dse__Program_Status__c = 'Graduated Program';
            update program;
        Test.stopTest();
        
    }
}