public with sharing class Attorney_createOrupdateNDSClientHandler{

    public static void populateGCSIdOnProspect(){
        List<Account> AccountList = (List<Account>)Trigger.new;
        Map<Id,Account> AccountOldMap = (Map<Id,Account>)Trigger.oldMap;
        
        List<Id> AccountIds = new List<Id>();
        for(Account a: AccountList){
            if(a.nu_dse__External_GCS_Id__c != null && a.nu_dse__External_GCS_Id__c != AccountOldMap.get(a.Id).nu_dse__External_GCS_Id__c){
                AccountIds.add(a.Id);
            }
        }
        
        if(!AccountIds.isEmpty()){
            List<nu_dse__Tradeline__c> TradelineList = [Select Id, nu_dse__Program__c, nu_dse__Program__r.nu_dse__Account__r.nu_dsE__External_GCS_Id__C,nu_dse__Prospect__c,nu_dsE__Prospect__r.External_GCS_Id__c from nu_dse__Tradeline__c where nu_dse__Program__r.nu_dse__Account__c =: AccountIds AND nu_dse__Prospect__c != null];
            List<nu_dse__Prospect__c> ProspectList = new List<nu_dsE__Prospect__c>();
            for(nu_dse__Tradeline__c Tradeline: TradelineList){
                if(Tradeline.nu_dse__Program__r.nu_dse__Account__r.nu_dsE__External_GCS_Id__C != Tradeline.nu_dse__Prospect__r.External_GCS_Id__c){
                    nu_dse__Prospect__c Prospect = new nu_dse__prospect__c();
                    Prospect.Id = Tradeline.nu_dsE__Prospect__c;
                    Prospect.External_GCS_Id__c = Tradeline.nu_dse__Program__r.nu_dse__Account__r.nu_dsE__External_GCS_Id__C;
                    ProspectList.add(Prospect);
                }
            }
            if(!ProspectList.isEMpty()){
                Update ProspectList;
            }
        }
    }

    public Static boolean TestProgramUpdated = false;
     //By Mayur for S20-578
    public Static void populateTestProgram(){
    
        if(!TestProgramUpdated){
            List<nu_dse__Program__c> ProgramList = new List<nu_dse__Program__c>();
            List<Account> AccountList = (List<Account>)Trigger.new;
            Map<Id, Account> AccountOldMap = (Map<Id, Account>)Trigger.oldMap;
            Map<Id, Account> AccountNewMap = (Map<Id, Account>)Trigger.newMap;
            List<Id> AccountIds = new List<Id>();
            
            for(Account client: AccountList){
                if(Trigger.isInsert || Client.Test_Client__c != AccountOldMap.get(Client.Id).Test_Client__c){
                    AccountIds.add(client.Id);
                }
            }
            
            if(!AccountIds.isEmpty()){
                ProgramList = [Select Id, Test_Program__c, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c=:AccountIds];
                
                for(nu_dse__Program__c Program: ProgramList){
                    Program.Test_program__c = AccountNewMap.get(Program.nu_dse__Account__c).Test_Client__c;
                }
                
                Update ProgramList;
            }
            TestProgramUpdated = true;
        }
    }

    public static void createOrupdateNDSClientMeth(List<Account> accLst, Map<Id,account> accOldMap){
     Boolean apiuser = Attorney_StaticVariableUtility.apiUser;
        Map<String,String> clientUpdMap = new Map<String,String>();
        for(Account acc: accLst){
            if(acc.Attorney__c && !apiuser && (acc.FirstName !=accOldMap.get(acc.Id).FirstName
                ||acc.LastName!=accOldMap.get(acc.Id).LastName
                ||acc.Best_Day__c != accOldMap.get(acc.Id).Best_Day__c
                ||acc.NDS_File_Number__c != accOldMap.get(acc.Id).NDS_File_Number__c
                ||acc.PersonMailingStreet != accOldMap.get(acc.Id).PersonMailingStreet
                ||acc.PersonMobilePhone != accOldMap.get(acc.Id).PersonMobilePhone
                ||acc.PersonMailingCity != accOldMap.get(acc.Id).PersonMailingCity
                ||acc.PersonEmail != accOldMap.get(acc.Id).PersonEmail
                ||acc.PersonHomePhone != accOldMap.get(acc.Id).PersonHomePhone
                ||acc.PersonMailingState != accOldMap.get(acc.Id).PersonMailingState
                ||acc.nu_dse__Work_Phone__c != accOldMap.get(acc.Id).nu_dse__Work_Phone__c
                ||acc.PersonMailingPostalCode != accOldMap.get(acc.Id).PersonMailingPostalCode
                ||acc.Fax != accOldMap.get(acc.Id).Fax
                ||acc.nu_dse__Other_Phone__c != accOldMap.get(acc.Id).nu_dse__Other_Phone__c
                ||acc.Contact_Preference__c != accOldMap.get(acc.Id).Contact_Preference__c
          //      ||acc.nu_dse__Best_Phone__c != accOldMap.get(acc.Id).nu_dse__Best_Phone__c                        
          //      ||acc.nu_dse__CO_Best_Phone__c != accOldMap.get(acc.Id).nu_dse__CO_Best_Phone__c    
          //      ||acc.Sales_Rep__c != accOldMap.get(acc.Id).Sales_Rep__c
                ||acc.Co_Drivers_License__c != accOldMap.get(acc.Id).Co_Drivers_License__c
                ||acc.Co_Drivers_License_State__c != accOldMap.get(acc.Id).Co_Drivers_License_State__c
                ||acc.Employer_Name__c != accOldMap.get(acc.Id).Employer_Name__c
                ||acc.Occupation__c != accOldMap.get(acc.Id).Occupation__c
                ||acc.nu_dse__SSN__c != accOldMap.get(acc.Id).nu_dse__SSN__c
                        //        ||acc.Client_Sticky_Note__c != accOldMap.get(acc.Id).Client_Sticky_Note__c

                ||acc.nu_dse__Co_Address_Line__c != accOldMap.get(acc.Id).nu_dse__Co_Address_Line__c
                ||acc.Best_Time__c != accOldMap.get(acc.Id).Best_Time__c
                ||acc.PersonDoNotCall != accOldMap.get(acc.Id).PersonDoNotCall
                ||acc.PersonHasOptedOutOfEmail != accOldMap.get(acc.Id).PersonHasOptedOutOfEmail
                ||acc.SMS_Opted_Out__c != accOldMap.get(acc.Id).SMS_Opted_Out__c
                ||acc.Nick_Name__c != accOldMap.get(acc.Id).Nick_Name__c
                ||acc.PersonBirthdate != accOldMap.get(acc.Id).PersonBirthdate
                ||acc.Co_Best_Time__c != accOldMap.get(acc.Id).Co_Best_Time__c
                ||acc.nu_dse__CO_Cell_Phone__c != accOldMap.get(acc.Id).nu_dse__CO_Cell_Phone__c
                ||acc.nu_dse__Co_Date_of_Birth__c != accOldMap.get(acc.Id).nu_dse__Co_Date_of_Birth__c
                ||acc.nu_dse__CO_Email_Address__c != accOldMap.get(acc.Id).nu_dse__CO_Email_Address__c
                ||acc.Co_Applicant_Employer_Name__c != accOldMap.get(acc.Id).Co_Applicant_Employer_Name__c
                ||acc.Co_Applicant_FAX_number__c != accOldMap.get(acc.Id).Co_Applicant_FAX_number__c
                ||acc.nu_dse__Co_First_Name__c != accOldMap.get(acc.Id).nu_dse__Co_First_Name__c
                ||acc.nu_dse__CO_Home_Phone__c != accOldMap.get(acc.Id).nu_dse__CO_Home_Phone__c
                ||acc.nu_dse__Co_Last_Name__c != accOldMap.get(acc.Id).nu_dse__Co_Last_Name__c
                ||acc.Co_Occupation__c != accOldMap.get(acc.Id).Co_Occupation__c
                ||acc.nu_dse__Co_SSN__c != accOldMap.get(acc.Id).nu_dse__Co_SSN__c
                ||acc.nu_dse__CO_Work_Phone__c != accOldMap.get(acc.Id).nu_dse__CO_Work_Phone__c
                ||acc.nu_dse__Co_Postal_Code__c != accOldMap.get(acc.Id).nu_dse__Co_Postal_Code__c
                ||acc.Salutation != accOldMap.get(acc.Id).Salutation
            //    ||acc.Sales_Email__c != accOldMap.get(acc.Id).Sales_Email__c
                ||acc.Time_Zone__c != accOldMap.get(acc.Id).Time_Zone__c
                ||acc.Drivers_License__c!= accOldMap.get(acc.Id).Drivers_License__c
                ||acc.Drivers_License_State__c!= accOldMap.get(acc.Id).Drivers_License_State__c
                ||acc.Authorized_User_Email__c!= accOldMap.get(acc.Id).Authorized_User_Email__c
                ||acc.Authorized_User_Name__c!= accOldMap.get(acc.Id).Authorized_User_Name__c
                ||acc.Authorized_User_Phone__c!= accOldMap.get(acc.Id).Authorized_User_Phone__c
                                ||acc.nu_dse__co_city__c!= accOldMap.get(acc.Id).nu_dse__co_city__c

                ||acc.nu_dse__co_state__c!= accOldMap.get(acc.Id).nu_dse__co_state__c

                ||acc.Co_Nick_Name__c!= accOldMap.get(acc.Id).Co_Nick_Name__c)){

                      system.debug('mayur'+String.ValueOf(acc.PersonBirthdate));
                clientUpdMap.put('FirstName',String.valueOf(acc.FirstName));
                clientUpdMap.put('LastName',String.valueOf(acc.LastName));
                clientUpdMap.put('BestDay',String.valueOf(acc.Best_Day__c));
                clientUpdMap.put('FileNumber',String.valueOf(acc.NDS_File_Number__c));
                                clientUpdMap.put('Name2City',String.valueOf(acc.nu_dse__co_city__c));

                clientUpdMap.put('Name2State',String.valueOf(acc.nu_dse__co_state__c));

                clientUpdMap.put('AddressLine1',String.valueOf(acc.PersonMailingStreet));
                clientUpdMap.put('CellNumber',String.valueOf(acc.PersonMobilePhone));
                clientUpdMap.put('City',String.valueOf(acc.PersonMailingCity));
                clientUpdMap.put('Name1Email',String.valueOf(acc.PersonEmail));
                clientUpdMap.put('HomeNumber',String.valueOf(acc.PersonHomePhone));
                
                
        //        clientUpdMap.put('Name1BestNumber',String.valueOf(acc.nu_dse__Best_Phone__c));
        //        clientUpdMap.put('Name2BestNumber',String.valueOf(acc.nu_dse__CO_Best_Phone__c));
               
                
                
                clientUpdMap.put('State',String.valueOf(acc.PersonMailingState));
                clientUpdMap.put('WorkNumber',String.valueOf(acc.nu_dse__Work_Phone__c));
                clientUpdMap.put('ZipCode',String.valueOf(acc.PersonMailingPostalCode));
                clientUpdMap.put('FaxNumber',String.valueOf(acc.Fax));
                clientUpdMap.put('AlternateNumber',String.valueOf(acc.nu_dse__Other_Phone__c));
                clientUpdMap.put('CorrespondencePreference',String.valueOf(acc.Contact_Preference__c));
                
                clientUpdMap.put('AuthPhone',String.valueOf(acc.Authorized_User_Phone__c));
                if(acc.Authorized_User_Name__c != 'Data Clean Up Needed in NDS')
                {
                clientUpdMap.put('AuthName',String.valueOf(acc.Authorized_User_Name__c));
                }
                clientUpdMap.put('AuthEmail',String.valueOf(acc.Authorized_User_Email__c));
                clientUpdMap.put('Name2AKA',String.valueOf(acc.Co_Nick_Name__c));

                
           //     clientUpdMap.put('DebtConsultant',String.valueOf(acc.Sales_Rep__c));
                clientUpdMap.put('Name2DLNumber',String.valueOf(acc.Co_Drivers_License__c));
                clientUpdMap.put('Name2DLState',String.valueOf(acc.Co_Drivers_License_State__c));
                clientUpdMap.put('Name1Employer',String.valueOf(acc.Employer_Name__c));
                clientUpdMap.put('Name1Occupation',String.valueOf(acc.Occupation__c));
                clientUpdMap.put('Name1SSN',String.valueOf(acc.nu_dse__SSN__c));
                      //          clientUpdMap.put('UserDefined',String.valueOf(acc.Client_Sticky_Note__c));

                clientUpdMap.put('Name2AddressLine1',String.valueOf(acc.nu_dse__Co_Address_Line__c));
                clientUpdMap.put('BestTime',String.valueOf(acc.Best_Time__c));
                clientUpdMap.put('DoNotCall',String.valueOf(acc.PersonDoNotCall));
                clientUpdMap.put('DoNotEmail',String.valueOf(acc.PersonHasOptedOutOfEmail));
                clientUpdMap.put('DoNotSMS',String.valueOf(acc.SMS_Opted_Out__c));
                clientUpdMap.put('Name1AKA',String.valueOf(acc.Nick_Name__c));
                system.debug('mayurdatenull'+String.valueOf(acc.PersonBirthdate));
                if(String.ValueOf(acc.PersonBirthdate) != NULL && String.ValueOf(acc.PersonBirthdate) != '')
                {
                String Year = String.ValueOf(acc.PersonBirthdate).left(4);
                String MonthInt = String.ValueOf(acc.PersonBirthdate).Right(5);
                string day = String.ValueOf(acc.PersonBirthdate).right(2);
                String Month = MonthInt.Left(2);
                String FinalDate = Month +'/' +Day +'/' +Year;
                clientUpdMap.put('Name1DOB',FinalDate);
                }
                else
                {
                clientUpdMap.put('Name1DOB','');
                }
               
                clientUpdMap.put('Name2BestTime',String.valueOf(acc.Co_Best_Time__c));
                clientUpdMap.put('Name2CellNumber',String.valueOf(acc.nu_dse__CO_Cell_Phone__c));
                if(String.ValueOf(acc.nu_dse__Co_Date_of_Birth__c) != NULL && String.ValueOf(acc.nu_dse__Co_Date_of_Birth__c) != '')
                {
                
                String Year2 = String.ValueOf(acc.nu_dse__Co_Date_of_Birth__c).left(4);
                String MonthInt2 = String.ValueOf(acc.nu_dse__Co_Date_of_Birth__c).Right(5);
                string day2 = String.ValueOf(acc.nu_dse__Co_Date_of_Birth__c).right(2);
                String Month2 = MonthInt2.Left(2);
                String FinalDate2 = Month2 +'/' +Day2 +'/' +Year2;
               
                clientUpdMap.put('Name2DOB',FinalDate2 );
                }
                else
                {
                                clientUpdMap.put('Name2DOB',String.valueOf(acc.nu_dse__Co_Date_of_Birth__c));

                }
                clientUpdMap.put('Name2Email',String.valueOf(acc.nu_dse__CO_Email_Address__c));
                clientUpdMap.put('Name2Employer',String.valueOf(acc.Co_Applicant_Employer_Name__c));
                clientUpdMap.put('Name2FaxNumber',String.valueOf(acc.Co_Applicant_FAX_number__c));
                clientUpdMap.put('Name2First',String.valueOf(acc.nu_dse__Co_First_Name__c));
                clientUpdMap.put('Name2HomeNumber',String.valueOf(acc.nu_dse__CO_Home_Phone__c));
                clientUpdMap.put('Name2Last',String.valueOf(acc.nu_dse__Co_Last_Name__c));
                clientUpdMap.put('Name2Occupation',String.valueOf(acc.Co_Occupation__c));
                clientUpdMap.put('Name2SSN',String.valueOf(acc.nu_dse__Co_SSN__c));
                clientUpdMap.put('Name2WorkNumber',String.valueOf(acc.nu_dse__CO_Work_Phone__c));
                clientUpdMap.put('Name2ZipCode',String.valueOf(acc.nu_dse__Co_Postal_Code__c));
                clientUpdMap.put('Prefix',String.valueOf(acc.Salutation));
          //      clientUpdMap.put('SalesEmail',String.valueOf(acc.Sales_Email__c));
                clientUpdMap.put('TimeZone',String.valueOf(acc.Time_Zone__c));
                clientUpdMap.put('Name1DLNumber',String.valueOf(acc.Drivers_License__c));
                clientUpdMap.put('Name1DLState',String.valueOf(acc.Drivers_License_State__c));

                system.debug('###clientUpdMap::'+clientUpdMap);
                if(!clientUpdMap.isEmpty())
                    calloutToNDS(clientUpdMap, acc.campaignId__c);
            }
        }
    }
    @future(callout=TRUE)
    public static void calloutToNDS(Map<String,String> clientUpdMap, String campaignId){
        leadtracNetClient.ClientServiceSoap soap = new leadtracNetClient.ClientServiceSoap();
        leadtracNetClient.ArrayOfClientProperty propertyArray;
        leadtracNetClient.ClientProperty property;
        List<leadtracNetClient.ClientProperty> propLst;
        propLst = new List<leadtracNetClient.ClientProperty>();
        propertyArray = new leadtracNetClient.ArrayOfClientProperty();
        
        for(String str: clientUpdMap.keySet()){
            if(clientUpdMap.containsKey(Str)){
                property = new leadtracNetClient.ClientProperty();
                property.Name = str;
                property.Value = clientUpdMap.get(str);
                propLst.add(property);    
            }
        }
        propertyArray.ClientProperty = propLst;
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        String retunedString = soap.CreateOrUpdateClient(credentials.UserName__c, credentials.Password__c,CampaignId,propertyArray);        
        system.debug('###retunedString::'+retunedString);
    } 
}