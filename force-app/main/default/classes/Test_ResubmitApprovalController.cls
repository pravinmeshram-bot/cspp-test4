@isTest (SeeAllData=true)
Public class    Test_ResubmitApprovalController{


private static testMethod void testNew1() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        
           
        //Create Account Object
        /*Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        //objNewCreditorAccount.PersonMailingState = 'CA';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='To Payment Processing';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Payment Processing Rejected';
ac.ApprovalProcessName='Attorney Settlement Workflow (New) V3_Up';

ac.UpdateApproval();

        } 
     


}

private static testMethod void testNew2() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
      /*  Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='To Payment Processing';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
           
ac.selectedVal='In-House Attorney';
ac.ApprovalProcessName='Attorney Settlement Workflow (New) V3_Up';
ac.UpdateApproval();

        } 
     


}
private static testMethod void testNew3() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
           
           
           
        //Create Account Object
     /*   Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='To Payment Processing';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Obtain Authorization';
ac.ApprovalProcessName='Attorney Settlement Workflow (New) V3_Up';
ac.UpdateApproval();

        } 
     


}
private static testMethod void testNew4() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
       /* Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='Negotiations Associate Review';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Negotiations Associate Review';
ac.ApprovalProcessName='Attorney Settlement Workflow (New) V3_Up';
ac.UpdateApproval();

        } 
     


}
private static testMethod void testNew5() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
       /* Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='Negotiations Associate Review';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Obtain Authorization';
ac.ApprovalProcessName='Timberline Settlement Workflow (New)';
ac.UpdateApproval();

        } 


}
private static testMethod void testNew6() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
      /*  Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='Negotiations Associate Review';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Management Review';
ac.ApprovalProcessName='Timberline Settlement Workflow (New)';
ac.UpdateApproval();

        } 
 }
 private static testMethod void testNew7() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
       /* Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='Negotiations Associate Review';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Payment Processing';
ac.ApprovalProcessName='Timberline Settlement Workflow (New)';
ac.UpdateApproval();

        } 
 }
 private static testMethod void testNew8() {
        //Call Mock for thr Client data
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        //Create Account Object
       /* Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
       /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);*/
       
        
        //objTradeline.Import_id__c = '11111111';
       // Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
     //   objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        objOffer.nu_dse__Status__c='Negotiations Associate Review';
        objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
        //objOffer.IsAttorney__c=true;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
         ApexPages.currentPage().getParameters().put('id',objOffer.Id);

ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
ResubmitApprovalController ac = new ResubmitApprovalController(sc);
ac.selectedVal='Negotiations Associate Review';
ac.ApprovalProcessName='Timberline Settlement Workflow (New)';
ac.UpdateApproval();

        } 
 }
    
    public static testMethod Void testNew9(){
        
        //Call Mock for thr Client data
        Test.startTest();
        // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c where applicant_type__c != 'NULL' limit 1];
        system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
        User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
apiuser.attorney_admin__c = false;
Database.Update(apiuser);*/
        
        
        system.runAs(u1){
            //Create Account Object
            /* Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
Account objNewCreditorAccount = new Account();
objNewCreditorAccount.RecordTypeId = recCreditorID;
objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
objNewCreditorAccount.Name = 'TestAccount';
objNewCreditorAccount.campaignId__c = '3432423';
objNewCreditorAccount.Attorney__c = true;
objNewCreditorAccount.Best_Day__c = 'Sunday';
Database.Insert(objNewCreditorAccount);*/
            
            
            //Create Program Object
            nu_dse__Program__c objProgram = new nu_dse__Program__c();
            objProgram.Attorney__c = true;
            objProgram.Import_Id__c = '11111111';
            Database.Insert(objProgram);
            System.debug('objProgram'+objProgram);
            
            //Create Tradeline Object
            /* nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
objTradeLine.nds_Debt_Type__c = 'TestType';
objTradeLine.nu_dse__Original_Debt__c = 1234;
objTradeLine.nu_dse__Program__c = objProgram.id;
objTradeline.applicant_type__c = 'Joint';
objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
//objTradeline.Import_id__c = '11111111';
ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
Database.Insert(objTradeLine);*/
            
            
            //objTradeline.Import_id__c = '11111111';
            // Database.Update(objTradeLine);
            
            
            //Create Offer Object 
            nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
            objOffer.Approved__c = true;
            objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
            //   objOffer.nu_dse__Status__c = 'Offer Made';
            //objOffer.NDS_Offer_Id__c  = '233';
            objOffer.Suspended_On__c = System.today()+1;
            objOffer.nu_dse__Status__c='Negotiations Associate Review';
            objOffer.Attorney_Settlement_Approval_Status__c='Payment Processing Rejected';
            //objOffer.IsAttorney__c=true;
            
            objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
            objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
            objOffer.Ended_On__c = System.today()+6;
            Database.insert(objOffer);
            ApexPages.currentPage().getParameters().put('id',objOffer.Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(objOffer);
            ResubmitApprovalController ac = new ResubmitApprovalController(sc);
            ac.selectedVal='Payment Processing';
            ac.ApprovalProcessName='Timberline Settlement Workflow (New)';
            ac.Attorney_Settlement_Workflow('Attorney Settlement Workflow (New) V3_Up',' Obtain Authorization');
            //ac.UpdateApproval();
            
        } 
        
        
    }

}