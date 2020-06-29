global class EmailToCase implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('envelope received:'+envelope);
        system.debug('email:'+email);
        
        try {
        
            String summonKeyPrefix = Summon__c.SObjecttype.getDescribe().getKeyPrefix();
            String subject = email.subject;
            
            Summon__c summonRec = new Summon__c();
            
            if (String.isNotBlank(subject) && subject.contains('[SFS Case')) {
            
                String summonTempName = subject.subStringBetween('[', ']');
                system.debug('summonTempName-->'+summonTempName);
                
                if (String.isNotBlank(summonTempName) ) {
                    
                    List <Summon__c> summonTempList = [SELECT Id, Name From Summon__c WHERE Name = :summonTempName LIMIT 1];
                    
                    if (summonTempList != null && summonTempList.isEmpty() == False) {
                        
                        summonRec.Id = Id.valueOf(summonTempList[0].Id);
                    }
                }
            }
            
            if (summonRec.Id == null) {
            
                summonRec.Subject__c = email.subject;
                summonRec.Origin__c = 'Email';
                summonRec.From_Address__c = email.fromAddress;
                summonRec.From_Name__c = email.fromName;
                
                //dynamic assignment
                summonRec.Status__c = 'New';
                summonRec.Priority__c = 'Medium';
            }
            summonRec.Description__c = email.plainTextBody;
            
            upsert summonRec;
            
            EmailMessage emailMessageInstance = new EmailMessage();
            
            emailMessageInstance.Summon__c = summonRec.Id;
            emailMessageInstance.Incoming = True;
            //emailMessageInstance.Status = 'New';
            emailMessageInstance.FromAddress = summonRec.From_Address__c;
            emailMessageInstance.FromName = summonRec.From_Name__c;
            emailMessageInstance.TextBody = summonRec.Description__c;
            //emailMessageInstance.ToAddress = email.ToAddresses;
            emailMessageInstance.Subject = email.Subject;
            
            insert emailMessageInstance;
            
        } catch(Exception e) {
        
            system.debug('Exception::::'+e.getMessage());
        }
        
        return result;
        
    }
}