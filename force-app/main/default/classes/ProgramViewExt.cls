public with sharing class ProgramViewExt {
 public Account acc{get;set;}
 public nu_dse__Program__c prgm{get;set;}
 public list<nu_dse__Payment__c> Paymentlist{get;set;}
 public list<nu_dse__TradeLine__c> Tradelinelist{get;set;}
 public list<nu_dse__Offer__c> offerlist{get;set;} 
 public list<nu_dse__Offer__c> offerlistview{get;set;}
 public Organization orgDetails {get;set;}
 public string selectedoffer{get;set;}
 public BusinessHours bh{get;set;}
 public string usertype{get;set;}
 public string userId{get;set;}
 public string accid;
    public ProgramViewExt(ApexPages.StandardController controller) {
        userId = UserInfo.getUserId();
        usertype = UserInfo.getUserType();
        system.debug('----usertype ------------'+usertype);
        if(usertype == 'CspLitePortal'){
            accid = [SELECT Username,firstname,lastname,MobilePhone,phone,email,Address,ContactId, Contact.Name,Contact.AccountId, Contact.Account.Name FROM User WHERE Id = :userId].Contact.AccountId;
            system.debug('---accid-----'+accid);
        }else{
            accid = ApexPages.currentPage().getParameters().get('id');
        }
        system.debug('---accid-----'+accid);
        if(accid != null || accid != ''){
            List<Account> lstAccount = [select id,firstname,lastname,phone,PersonEmail,nu_dse__Work_Phone__c,PersonHomePhone,nu_dse__Cell_phone__c,BillingStreet,BillingState,BillingCity,Billingpostalcode,BillingCountry,ShippingStreet,ShippingState,ShippingCity,Shippingpostalcode,ShippingCountry,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingpostalcode,PersonMailingcountry from account where id=:accid];
            if(lstAccount != null && lstAccount.size() > 0)
                acc = lstAccount[0];
            List<nu_dse__Program__c> lstProgram = [select id,name,nu_dse__Payment_Frequency__c,nu_dse__Processor_Status__c,nu_dse__Program_Status__c,nu_dse__Disposition__c,nu_dse__Program_Length__c,nu_dse__Total_Debt__c,nu_dse__Last_Disposition__c from nu_dse__Program__c where nu_dse__Account__c=:accid];
            if(lstProgram != null && lstProgram.size() > 0)
              prgm = lstProgram[0];
           if(prgm != null && String.isNotBlank(prgm.Id)){
              Tradelinelist = [select id,name,nu_dse__Original_Account_Number__c ,nu_dse__Original_Debt__c,nu_dse__Current_Stage__c ,nu_dse__Current_Balance__c,nu_dse__New_Creditor__r.name ,nu_dse__Original_Creditor__r.name,nu_dse__New_Account_Number__c,createddate from nu_dse__TradeLine__c where nu_dse__Program__c = :prgm.id];           
              Paymentlist = [select id,nu_dse__Monthly_Maintenance_Fee__c ,nu_dse__Processor_Fee__c,nu_dse__Amount__c ,nu_dse__Monthly_Third_Party_Fees__c ,nu_dse__Monthly_Other_Fee__c ,nu_dse__Transaction_Status__c ,nu_dse__Payment_Type__c,name,createddate from nu_dse__Payment__c where nu_dse__program__c = :prgm.id and nu_dse__Transaction_Status__c != 'Tentative'];
              offerlistview = [select id,name,createddate,nu_dse__Offer_Type__c,nu_dse__TradeLine__r.name,nu_dse__TradeLine__r.nu_dse__Original_Creditor__r.name,nu_dse__Offer_Amount__c ,nu_dse__Number_of_Payments__c,nu_dse__First_Payment_Date__c,nu_dse__Status__c  from nu_dse__Offer__c where nu_dse__program__c =:prgm.id order by createddate Desc];
              offerlist = [select id,name,createddate,nu_dse__TradeLine__r.name,nu_dse__Offer_Type__c,nu_dse__Offer_Amount__c ,nu_dse__Number_of_Payments__c,nu_dse__First_Payment_Date__c,nu_dse__Status__c from nu_dse__Offer__c where nu_dse__program__c =:prgm.id order by createddate Desc limit 1];
            }
            List<Organization> lstOrganization = [SELECT Id,name,phone,fax,street,state,country,postalcode,LanguageLocaleKey FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
            if(lstOrganization != null && lstOrganization.size() > 0)
              orgDetails = lstOrganization[0];
            List<BusinessHours> lstBusinessHours = [select id,TimeZoneSidKey,FridayEndTime,FridayStartTime,MondayEndTime,MondayStartTime,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,ThursdayEndTime,ThursdayStartTime,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime from businesshours where IsDefault=true];
            if(lstBusinessHours != null && lstBusinessHours.size() > 0)
              bh = lstBusinessHours[0];
        }
    }
    
    public void ShowOffer(){
    system.debug('----selectedoffer -----'+selectedoffer );
       if(selectedoffer != null || selectedoffer != ''){
          system.debug('entered');
           offerlist  = [select id,name,createddate,nu_dse__Offer_Type__c,nu_dse__TradeLine__r.name,nu_dse__Offer_Amount__c ,nu_dse__Number_of_Payments__c,nu_dse__First_Payment_Date__c,nu_dse__Status__c from nu_dse__Offer__c where id=:selectedoffer limit 1];
                  system.debug('----offerlist  -----'+offerlist);

       }
    }

}