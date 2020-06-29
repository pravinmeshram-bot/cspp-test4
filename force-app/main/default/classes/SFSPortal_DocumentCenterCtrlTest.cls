/**********************************************************************************************************************************************
*  Name        :  SFSPortal_DocumentCenterCtrlTest                                                                                            *
*  Date        :  05/05/2020                                                                                                                  *
*  Description :  This class is used as Test apex for SFSPortal_DocumentCenterCtrl class                                                      *
*  Version     :  v1.0                                                                                                                        * 
*  Author      :  MindzCloud                                                                                                                  *                                    
**********************************************************************************************************************************************/
@isTest
public class SFSPortal_DocumentCenterCtrlTest {
    @testSetup static void testDataFactory() {
        // Create common test accounts
        Account objAccount = SFSPortal_TestRecordCreator.createAccount('Test Account',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        objAccount.BoxFolderId__c = '101053062907';
        insert objAccount; 
        System.assertEquals(objAccount.BoxFolderId__c, '101053062907');
        //fetch contact record
        Contact contactRec = [SELECT Id,AccountId FROM Contact WHERE AccountId =: objAccount.Id];
        System.assertEquals(contactRec.AccountId , objAccount.Id);
        //create test user instance
        User objUser = SFSPortal_TestRecordCreator.createCommunityUser(contactRec.Id);
        insert objUser;
        System.assertEquals(objUser.ContactId, contactRec.Id);
        //create a portfolio instance with PhoneNumber as parameter
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        System.assertEquals(portfolioInstance.Support_Phone_Number__c, '7523698416');
        //create a program instance fro associate portfolio and account
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(objAccount.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        System.assertEquals(programInstance.Portfolio__c , portfolioInstance.Id);
        //insert box config setting
        Box_settings__c boxInstance = SFSPortal_TestRecordCreator.createBoxsettings();
        insert boxInstance ;
        System.assertEquals(boxInstance.name, 'box');
        //inert mapping settings
        Portal_Box_Document_Mapping__c objMapSetting = new Portal_Box_Document_Mapping__c();
        objMapSetting.Name = 'Bank Information';
        objMapSetting.Box_Folder_Names__c = 'Bank Info';
        insert objMapSetting;
        System.assertEquals(objMapSetting.name, 'Bank Information');
    }
    @isTest static void doCoverSelectedFolderSchema(){
        Account cuurentAcc = [select name,BoxFolderId__c from Account where BoxFolderId__c = '101053062907' LIMIT 1];
        nu_dse__Program__c objProgram = [select nu_dse__Account__c,name from nu_dse__Program__c where nu_dse__Account__c =:cuurentAcc.Id];        
        Contact contactRec = [SELECT Id,AccountId FROM Contact WHERE AccountId =: cuurentAcc .Id];
        System.assertEquals(contactRec.AccountId , cuurentAcc.Id);
        user objCurrentUser = [select name, contactid,  Contact.AccountId, email, profileId, username, MobilePhone from User where ContactId = : contactRec.id LIMIT 1];
        System.assertEquals(objCurrentUser.contactid, contactRec.Id);      
        System.runAs(objCurrentUser){ //run the test block for this specific user instance
            Test.setMock(HttpCalloutMock.class, new SFSPortal_DocumentCenterCtrlCalloutMock()); // Set mock callout class 
            Map<String, String> accoutMapTest = SFSPortal_Utility.getAccountIdFromCurrentUser();
            system.debug('accoutMapTest ---'+accoutMapTest);
            SFSPortal_DocumentCenterCtrl.accountIdMap  = accoutMapTest ;
            Test.StartTest();
                SFSPortal_DocumentCenterCtrl.boxGlobalAccessToken = CreateParentAndSubFoldersInBox.getAccessToken();
                SFSPortal_DocumentCenterCtrl.getSelectedFolderSchema(); //get All subfolder and do mapping
            Test.StopTest();    
        }    
        
    }
    //test function for download functionality
    @isTest static void doCoverDownloadSelectedFile(){
        Account cuurentAcc = [select name,BoxFolderId__c from Account where BoxFolderId__c = '101053062907' LIMIT 1];
        System.assertEquals(cuurentAcc.BoxFolderId__c , '101053062907');
        nu_dse__Program__c objProgram = [select nu_dse__Account__c,name from nu_dse__Program__c where nu_dse__Account__c =:cuurentAcc.Id];        
        System.assertEquals(objProgram.nu_dse__Account__c , cuurentAcc.Id);
        Contact contactRec = [SELECT Id,AccountId FROM Contact WHERE AccountId =: cuurentAcc .Id];
        System.assertEquals(contactRec.AccountId , cuurentAcc.Id);
        user objCurrentUser = [select name, contactid,  Contact.AccountId, email, profileId, username, MobilePhone from User where ContactId = : contactRec.id LIMIT 1];
        System.assertEquals(objCurrentUser.contactid, contactRec.Id);      
        System.runAs(objCurrentUser){ //run the test block for this specific user instance
            Test.setMock(HttpCalloutMock.class, new SFSPortal_DocumentCenterCtrlCalloutMock()); // Set mock callout class 
            Test.StartTest();
                SFSPortal_DocumentCenterCtrl.downloadSelectedFile('12345678'); //get download a file
            Test.StopTest();    
        }    
    }
    //test function for welcome material functionality
    @isTest static void doCoverGetWelcomeMaterial(){
        Account cuurentAcc = [select name,BoxFolderId__c from Account where BoxFolderId__c = '101053062907' LIMIT 1];
        System.assertEquals(cuurentAcc.BoxFolderId__c , '101053062907');
        nu_dse__Program__c objProgram = [select nu_dse__Account__c,name from nu_dse__Program__c where nu_dse__Account__c =:cuurentAcc.Id];        
        System.assertEquals(objProgram.nu_dse__Account__c , cuurentAcc.Id);
        Contact contactRec = [SELECT Id,AccountId FROM Contact WHERE AccountId =: cuurentAcc .Id];
        System.assertEquals(contactRec.AccountId , cuurentAcc.Id);
        user objCurrentUser = [select name, contactid,  Contact.AccountId, email, profileId, username, MobilePhone from User where ContactId = : contactRec.id LIMIT 1];
        System.assertEquals(objCurrentUser.contactid, contactRec.Id);      
        System.runAs(objCurrentUser){ //run the test block for this specific user instance
            Test.setMock(HttpCalloutMock.class, new SFSPortal_DocumentCenterCtrlCalloutMock()); // Set mock callout class 
            Test.StartTest();
                SFSPortal_DocumentCenterCtrl.getWelcomeMaterial(); //get welcome materials
            Test.StopTest();    
        }    
    }
}