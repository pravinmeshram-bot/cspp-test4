global without sharing class LeadUtility
{
    webservice static string sendEmail(ID leadID,string currentOWDAddress)
    {  
        string result = null;
        
        List<OrgWideEmailAddress> OWD = [select id, Address,DisplayName from OrgWideEmailAddress where Address=:currentOWDAddress];
        
        if(OWD !=null && OWD.size() > 0)
        {
           
            Lead l = [Select Id,Last_Email_Sent_Time__c,Account__c,Program_Name__c,Program_Name__r.Portfolio__c,Account__r.PersonEmail from Lead where ID=:leadID];
            
            if(string.isNotBlank(l.Account__r.PersonEmail))
            {
                
                try
                {
                    
                    DynamicTemplateController d= new DynamicTemplateController();
                    d.LeadId = l.Id;
                    d.AccountId =l.Account__c;
                    d.UserId = UserInfo.getUserId();
                    d.ProgramId = l.Program_Name__c;
                    d.PortfolioId = l.Program_Name__r.Portfolio__c;
                    d.vfTemplateName = 'Lead_On_Time_Payment_Notification';
                    string emailBody = null;
                    string subject = null;
                    
                    if(d.getTemplateContent().contains('::Split::'))
                    {
                        List<string> emailcontent = d.getTemplateContent().split('::Split::');
                        subject = emailcontent[0];
                        emailBody = emailcontent[1];
                    }
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    List<String> sendTo = new List<String>();
                    sendTo.add(l.Account__r.PersonEmail);
                    mail.setToAddresses(sendTo);
                    mail.setReplyTo(OWD[0].Address);
                 //   mail.setReplyTo('mayur.techup@gmail.com');
                    mail.setOrgWideEmailAddressId(OWD[0].Id);
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(subject);
                    mails.add(mail);
                    
                    Messaging.sendEmail(mails);  
                    
                    l.Last_Email_Sent_Time__c = System.now();
                    update l;
                    
                    result = 'Email Sent Successfully!';
                }
                catch(Exception e)
                {
                    result = e.getMessage() + ' - ' + e.getStackTraceString();
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