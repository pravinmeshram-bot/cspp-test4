trigger versaraPaymentEditaccess on nu_dse__Payment__c (before update) {
    //Returns the context user's profile ID.
   Id profileId= userinfo.getProfileId();
   String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
   //system.debug('ProfileName'+profileName);
    
        // List<String> profileList = new List<String>{'DNL Negotiations Manager','DNL Payments Team Member','System Administrator'};
   // set<string> mySet = new Set<String>{'DNL Negotiations Manager', 'DNL Payments Team Member','System Administrator','DNL Negotiations_SF Platform','DNL Payments Manager','Underwriting Manager - SF Platform','Underwriter','DNL System Admin','DNL Payment Processor','DNL System Administrator','Negotiations Manager','Pre-Sales','NAR Associates'};
        set<string> ConvertedUsers = new Set<String>{'DNL Payments Team Member','System Administrator','DNL Payments Manager','DNL System Admin','DNL Payment Processor','DNL System Administrator'};   //,'Pre-Sales'

            system.debug('Test>>>> '+ConvertedUsers.contains('profileName'));
            for (nu_dse__Payment__c payment : Trigger.new) 
            {
                for(string str : ConvertedUsers)
                {
                   // if(mySet.contains(profileName) && (payment.DNL_Status__c == 'Pre-TILA Signed' || payment.DNL_Status__c == 'Converted')){
                   if(ConvertedUsers.contains(profileName) && (payment.DNL_Status__c == 'Converted')){
                      system.debug('ProfileName '+ConvertedUsers.contains(profileName) +'and '+payment.DNL_Status__c);

                     
    
                 }else{
                   // if((profileName!='DNL Negotiations Manager' && profileName!='DNL Payments Team Member'  && profileName!='DNL Negotiations_SF Platform' && profileName!='DNL Payments Manager' && profileName!='Underwriting Manager - SF Platform' && profileName!='Underwriter') && ( payment.DNL_Status__c != 'Pre-TILA Signed' && payment.DNL_Status__c != 'Converted') )
                     if((profileName!='DNL Payments Team Member'  &&  profileName!='DNL Payments Manager' &&  profileName!='DNL Payment Processor' && profileName!='DNL System Administrator' && profileName!='DNL Payments Team Member'&&  profileName!='DNL System Admin' ) && (  payment.DNL_Status__c != 'Converted') )  //&&  profileName!='Pre-Sales'

                    {
                        
                    }
                     
                    // else if(( profileName =='DNL Payments Manager' || profileName =='DNL Payments Team Member' || profileName =='DNL Payment Processor' || profileName =='DNL System Admin' || profileName =='DNL System Administrator'|| profileName =='System Administrator' ) && payment.DNL_Status__c == 'Converted')
          //    else if(( profileName =='DNL Payments Manager' || profileName =='DNL Payments Team Member' || profileName =='DNL Payment Processor' || profileName =='System Administrator' ) && payment.DNL_Status__c == 'Converted')

                   //  {
                   //   system.debug('inside if');
                      // payment.addError('Payments of Versara client cannot be modified, please check with your manager');
                    // }
                    else{
                           payment.addError('Payments of Versara client cannot be modified, please check with your manager');

                     }
                         }

                }
                
            }
   
}