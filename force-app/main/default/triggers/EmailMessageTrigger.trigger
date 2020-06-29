trigger EmailMessageTrigger on EmailMessage (after insert) {
    try
    {
        EmailMessage eMsg = Trigger.New[0];
        
        if(eMsg.Incoming == true)
        {
            Case cs =  [Select Id,AccountId,ContactId,Status,Case_Created_Origin__c,Origin from Case where Id=: eMsg.ParentId]; 
            
            if(cs.Status == 'New' && string.isBlank(cs.Case_Created_Origin__c) && cs.Origin == 'Email')
                cs.Case_Created_Origin__c = eMsg.ToAddress;
            
            System.debug('++++++++++++ cs' + cs);
            System.debug('++++++++++++ eMsg.FromAddress' + eMsg.FromAddress);
            
        List<Account> c = [Select Id  from Account where PersonEmail=: eMsg.FromAddress order by createdDate desc]; 
                               

            if(string.isNotBlank(cs.AccountId) && c.size() > 0)
            {
                if(c.size() > 0)
                {
                    cs.AccountId = c[0].Id;
                    //cs.ContactId = c[0].Id;
                }
            }

            
            update cs;
        }
    }
    Catch(Exception e)
    {
        System.debug('++++++++++++' + e.getMessage());
    }
}