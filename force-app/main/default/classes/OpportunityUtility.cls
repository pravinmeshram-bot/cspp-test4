global without sharing class OpportunityUtility
{
    webservice static string sendEmail(ID oppID,string currentOWDAddress)
    {  
        string result = null;
        
        List<OrgWideEmailAddress> OWD = [select id, Address,DisplayName from OrgWideEmailAddress where Address=:currentOWDAddress];
        
        if(OWD !=null && OWD.size() > 0)
        {
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Opportunity_On_Time_Payment_Notification'];
            
            Opportunity o = [Select Account.FirstName,Account.LastName,Program_ID__r.Program_Type__c,Program_ID__r.Portfolio__r.Name,Account.PersonEmail from Opportunity where ID=:oppID];
            User u = [Select Name,Title,Phone from User where ID=:userinfo.getuserid()];
            
            if(string.isNotBlank(o.Account.PersonEmail))
            {
                
                try
                {
                    string emailBody = emailTemplate.HtmlValue;
                    emailBody = emailBody.replace('{!Account.FirstName}', string.isNotBlank(o.Account.FirstName) ? o.Account.FirstName : '');
                    emailBody = emailBody.replace('{!Account.LastName},', string.isNotBlank(o.Account.LastName) ?o.Account.LastName : '');
                    emailBody = emailBody.replace('{!Program_ID__r.Program_Type__c}', string.isNotBlank(o.Program_ID__r.Program_Type__c) ? o.Program_ID__r.Program_Type__c : '');
                    emailBody = emailBody.replace('{!User.Name}', string.isNotBlank(u.Name) ?  u.Name : '');
                    emailBody = emailBody.replace('{!User.Title}', string.isNotBlank(u.Title) ?  u.Title : '');
                    emailBody = emailBody.replace('{!User.Phone}', string.isNotBlank(u.Phone) ?  u.Phone : '');
                    
                    string subject = emailTemplate.Subject;
                    subject = subject.replace('{!Program_ID__r.Portfolio__r.Name}', string.isNotBlank(o.Program_ID__r.Portfolio__r.Name) ?  o.Program_ID__r.Portfolio__r.Name : '');
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    List<String> sendTo = new List<String>();
                    sendTo.add(o.Account.PersonEmail);
                    mail.setToAddresses(sendTo);
                    mail.setReplyTo(OWD[0].Address);
                    mail.setOrgWideEmailAddressId(OWD[0].Id);
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(subject);
                    mails.add(mail);
                    
                    Messaging.sendEmail(mails);  
                    
                    result = 'Email Sent Successfully!';
                }
                catch(Exception e)
                {
                    result = 'Email_Error: Please contact your system Administrator';
                    //result = e.getMessage() + e.getStackTraceString();
                }
            }
            else
            {
                result = 'Email_Error: Invalid Customer Email';
            }
        }
        else
        {
            result = 'Email_Error: You are not authorized to send email';
        }
        
        return result;
        
    }
}