public with sharing class Attorney_BankAccountHandler{
    public static void CreateOrUpdateNDSBankAccount(List<nu_dse__Bank_Account__c> bankAcctLst, Map<Id,nu_dse__Bank_Account__c> bankAccOldMap){
        List<nu_dse__Bank_Account__c> updateBankAccountList = new List<nu_dse__Bank_Account__c>();
        Map<String,String> bankAccUpdMap = new Map<String,String>();
        Boolean apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()].attorney_admin__c;
        system.debug('rameshapi' +apiuser);
        for(nu_dse__Bank_Account__c bankAcc: bankAcctLst){
            if(bankAcc.isAttorney__c && !apiuser && (  
                bankAcc.nu_dse__Holder_s_Name__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Holder_s_Name__c
                ||bankAcc.nu_dse__Account_Type__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Account_Type__c
                ||bankAcc.nu_dse__Bank_Account_Number__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Bank_Account_Number__c
                ||bankAcc.nu_dse__City__c != bankAccOldMap.get(bankAcc.Id).nu_dse__City__c
                ||bankAcc.nu_dse__Bank_Name__c!= bankAccOldMap.get(bankAcc.Id).nu_dse__Bank_Name__c
                ||bankAcc.nu_dse__Telephone__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Telephone__c
                ||bankAcc.nu_dse__Routing_Number__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Routing_Number__c
                ||bankAcc.nu_dse__State__c != bankAccOldMap.get(bankAcc.Id).nu_dse__State__c
                ||bankAcc.nu_dse__Zip__c != bankAccOldMap.get(bankAcc.Id).nu_dse__Zip__c  
                ||bankAcc.Bank_Street_Address__c!= bankAccOldMap.get(bankAcc.Id).Bank_Street_Address__c)){
                    
                    bankAccUpdMap = new Map<String,String>();
                    bankAccUpdMap.put('AccountOwnerName',String.valueOf(bankAcc.nu_dse__Holder_s_Name__c));
                    if(bankAcc.nu_dse__Account_Type__c!= null && bankAcc.nu_dse__Account_Type__c != '' && bankAcc.nu_dse__Account_Type__c == 'CHECKING')
                    {
                                        bankAccUpdMap.put('AccountType','Checking');

                    }
                    
                    else if(bankAcc.nu_dse__Account_Type__c!= null && bankAcc.nu_dse__Account_Type__c != '' && bankAcc.nu_dse__Account_Type__c == 'SAVING')
                    {
                                        bankAccUpdMap.put('AccountType','Savings');

                    }
                    else
                    {
                    bankAccUpdMap.put('AccountType',String.valueOf(bankAcc.nu_dse__Account_Type__c));
                    }
                    bankAccUpdMap.put('BankAccountNumber',String.valueOf(bankAcc.nu_dse__Bank_Account_Number__c));
                    bankAccUpdMap.put('BankCity',String.valueOf(bankAcc.nu_dse__City__c));
                    bankAccUpdMap.put('BankName',String.ValueOf(bankAcc.nu_dse__Bank_Name__c));
                    bankAccUpdMap.put('BankPhone',String.ValueOf(bankAcc.nu_dse__Telephone__c));
                    bankAccUpdMap.put('BankRoutingNumber',String.ValueOf(bankAcc.nu_dse__Routing_Number__c));
                                        bankAccUpdMap.put('BankStreetAddress',String.ValueOf(bankAcc.Bank_Street_Address__c));

                    bankAccUpdMap.put('BankState',String.ValueOf(bankAcc.nu_dse__State__c));
                    bankAccUpdMap.put('BankZipCode',String.ValueOf(bankAcc.nu_dse__Zip__c));
                    system.debug('###bankAccUpdMap::'+bankAccUpdMap);
                    if(!bankAccUpdMap.isEmpty())
                    {
                        calloutToNDS(bankAccUpdMap, bankAcc.campaignId__c, bankAcc.Import_ID__c);
                        
                        //Sync Update - Integration Status to Initiated
                        nu_dse__Bank_Account__c objBankAccountUpd = new nu_dse__Bank_Account__c(Id=bankAcc.Id);
                        setIntegrationFields(objBankAccountUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null);
                        updateBankAccountList.add(objBankAccountUpd);
                        
                    }
                }
            
        }
        
        update updateBankAccountList;
    }
    
     public static void setIntegrationFields(nu_dse__Bank_Account__c ObjBankAccount,string IntegrationStatus,string IntegrationReason)
    {
        ObjBankAccount.Integration_Status__c = IntegrationStatus;
        ObjBankAccount.Integration_Reason__c = IntegrationReason;
    }
    
    @future(callout=TRUE)
    public static void calloutToNDS(Map<String,String> bankAccUpdMap, String campaignId, String FileNumber){
        leadtracNetClient.ClientServiceSoap soap = new leadtracNetClient.ClientServiceSoap();
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        leadtracNetClient.ArrayOfClientProperty propertyArray;
        leadtracNetClient.ClientProperty property;
        List<leadtracNetClient.ClientProperty> propLst;
        propLst = new List<leadtracNetClient.ClientProperty>();
        propertyArray = new leadtracNetClient.ArrayOfClientProperty();
        property = new leadtracNetClient.ClientProperty();
        property.Name = 'FileNumber';
        property.Value = FileNumber;
        propLst.add(property);
        for(String str: bankAccUpdMap.keySet()){
            if(bankAccUpdMap.containsKey(Str)){
                property = new leadtracNetClient.ClientProperty();
                property.Name = str;
                property.Value = bankAccUpdMap.get(str);
                propLst.add(property);    
            }
        }
        propertyArray.ClientProperty = propLst;
      
       
        String retunedString = soap.CreateOrUpdateClient(credentials.UserName__c, credentials.Password__c,campaignId,propertyArray);        
        system.debug('###result::'+retunedString);
    }
}