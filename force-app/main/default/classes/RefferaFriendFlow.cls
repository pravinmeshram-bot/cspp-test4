//S20-14
Public class RefferaFriendFlow{
    @InvocableMethod
        public static void sendMail(list<Id> ProgramId){
        system.debug('line 4');
        List<nu_dse__Program__c> GetPortfolioDetails= new list<  nu_dse__Program__c>();
        if(ProgramId !=null && ProgramId.size()>0){
        
        GetPortfolioDetails=[select id,nu_dse__Account__r.PersonEmail, Portfolio__c, ownerid,  Portfolio__r.Communication_Template_Email__c,   Portfolio__r.Linkedin_URL__c from nu_dse__Program__c where
                              id=:ProgramId[0] ];
        
        
        }
        Emailtemplate et=[select id from emailtemplate where  name='Refer a Friend Template'];
        OrgWideEmailAddress owe= [select id from OrgWideEmailAddress where DisplayName='Timberline Financial'];
        system.debug('line 4' +GetPortfolioDetails + 'emailtemplate'+ et );
         List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
          list<Approval_Steps_Mapping__mdt> ApprovalSteps = new  list<Approval_Steps_Mapping__mdt> ();
    
    // getting the custom metadata value for the mating  rejection status value we have used the approval status to be shown  from Mapped_approval_steps_to_be_shown__c values
    // we will be configuring the approval status which needs to be shown in Mapped_approval_steps_to_be_shown__c field in semicolon separated way.
     ApprovalSteps= [SELECT MasterLabel, Approval_Step_Name__c, Mapped_approval_steps_to_be_shown__c,Approval_Process_Name__c  
                                                 FROM Approval_Steps_Mapping__mdt  where label=:'Mail Functionality'
                                                  ];
      if(GetPortfolioDetails !=null && GetPortfolioDetails.size()>0 &&  et !=null){
       Messaging.SingleEmailMessage mail = 
          new Messaging.SingleEmailMessage();
        if( GetPortfolioDetails[0].nu_dse__Account__r.PersonEmail !=null){
          // Step 2: Set list of people who should get the email
          List<String> sendTo = new List<String>();
          sendTo.add(GetPortfolioDetails[0].nu_dse__Account__r.PersonEmail );
          mail.setToAddresses(sendTo);
        
          // Step 3: Set who the email is sent from
        
         // mail.setSenderDisplayName('RefFeral Email');
          mail.setOrgWideEmailAddressId(owe.id);
          mail.setTemplateId(et.id);
          if(!Test.isRunningTest()){
          mail.setTargetObjectId(ApprovalSteps[0].Approval_Step_Name__c);
          }
          mail.setWhatId(GetPortfolioDetails[0].Id);
          // Step 4. Set email contents - you can use variables!
          mail.setSaveAsActivity(false);
          system.debug('line 34'+ mail);
          mail.setTreatTargetObjectAsRecipient(false);
          // Step 5. Add your email to the master list
          mails.add(mail);
       }
     
      // Step 6: Send all emails in the master list
          if(mails !=null && mails.size()>0){
          Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);
           if(!Test.isRunningTest()){
             
             System.debug('Email result ' + r[0].IsSuccess()); 
            } 
             if( r[0].IsSuccess()==true){
             
             Task tskObj= new Task();
             tskObj.Subject='Sent Referral Mail';
             tskObj.status='Completed';
             tskObj.whatid=GetPortfolioDetails[0].Id;
             insert tskObj;
             
             system.debug('line 53'+ tskObj.Id);
             
             
             }       
              }
      
        }
      }

}