@isTest
Public class    Test_CreateGroupTaskWhenOfferisActive{


private static testMethod void testNew1() {
        //Call Mock for thr Client data
        
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
       // nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c limit 1];
       
       
        
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
        Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        //objNewCreditorAccount.PersonMailingState = 'CA';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
       // Database.Insert(objNewCreditorAccount);
        
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
       // objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        //objTradeline.Import_id__c = '11111111';
        objTradeLine.SFS_Current_Balance__c=1234;
        //ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
         objTradeLine.nu_dse__Status__c='Pending Creation';
        Database.Insert(objTradeLine);
       
        
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
        objOffer.nu_dse__Program__c =objProgram.id;
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
       
        list<id> offerid= new list<id>();
        offerid.add(objOffer.id);
         System.AssertnotEquals( offerid,null);
         Id RecordTypeIdpayment = Schema.SObjectType.nu_dse__Payment__c .getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
         nu_dse__Payment__c p = new nu_dse__Payment__c();
         
         p.recordtypeid= RecordTypeIdpayment;
         
         p.nu_dse__Program__c =objProgram.id;
         p.nu_dse__Offer__c=objOffer.id;
         p.nu_dse__Schedule_Date__c=date.today();
         insert p;
         system.debug('line 106'+ p);
        Test.startTest();
        
        CreateGroupTaskWhenOfferisActive.createGroupTask(offerid);
         test.stopTest();
        
        
      }
     }
    }