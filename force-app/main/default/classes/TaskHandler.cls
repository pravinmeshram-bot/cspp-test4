public class TaskHandler {

    public static void handle(Map<id,task> newTasks, Map<id,task> oldTasks){

         List<id> taskIds = new LIst<id>();
         List<id> smsTaskIds = new List<id>();
         List<id> vbTaskIds = new List<id>();
         List<id> eaTaskIds = new List<id>();

        for(id tId : newTasks.keySet()){

            String prefix = nu_dse__Program__c.sobjecttype.getDescribe().getKeyPrefix();

            if( ((String)newTasks.get(tid).whatId).startsWith(prefix) && newTasks.get(tid).nu_dse__Communication_Template__c !=null &&  (newTasks.get(tId).Status=='Completed' && OldTasks.get(tId).status!='Completed')){

                taskIds.add(newTasks.get(tId).id);
            }
        }

        for(task t: [ select id,nu_dse__Communication_Template__c,nu_dse__Communication_Template__r.nu_dse__Action_Type__c from Task where Id in : taskIds  ]){

          if(t.nu_dse__Communication_Template__r.nu_dse__Action_Type__c == 'Voice Broadcast'){
              vbTaskIds.add(t.Id);
            }

          if(t.nu_dse__Communication_Template__r.nu_dse__Action_Type__c == 'SMS'){

           smstaskIds.add(t.Id);

           }


           if(t.nu_dse__Communication_Template__r.nu_dse__Action_Type__c == 'Email Alert'){


               eaTaskIds.add(t.Id);

            }
        }

        if(vbTaskIds.size()>0){

          sendVB(vbTaskIds);
        }

        if(smsTaskIds.size()>0){

          sendSMS(smsTaskIds);

        }

        if(eaTaskIds.size()>0){
            sendEmailAlerts(eaTaskIds);
        }
    }

    public static void sendSMS(String toPhone,String fromPhone, String sms) {

         TwilioConfig__c config = TwilioConfig__c.getOrgDefaults();

        TwilioRestClient client = TwilioAPI.getDefaultClient();

        /*
         * Only Supports US numbers.
         */

        if(!toPhone.startsWith('+1')){

            toPhone = '+1'+toPHone;
        }

        Map<String,String> properties = new Map<String,String>();
        properties.put('To',toPhone);
        properties.put('From',fromPhone);
        properties.put('Body',sms);


          TwilioMessage message = client.getAccount().getMessages().create(properties);
          system.debug('message-->'+message);

    }

     @Future(Callout=true)
    public static void sendSMS(List<Id> taskIds){

        Map<String,String> sms = new Map<String,String>();
        Map<id,String> programPhone = new Map<id,String>();
        List<Id> programIds = new List<id>();
        for(Task t: [select id,what.id from Task where Id in:taskIds]){

            programIds.add(t.what.id);

        }

        for(nu_dse__Program__c p: [select id, nu_dse__Account__r.phone, nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone from nu_dse__Program__c where id in: programIds]){

            if(p.nu_dse__Account__r.PersonHomePhone !=null){
               programPhone.put(p.id,p.nu_dse__Account__r.PersonHomePhone);
            }else if(p.nu_dse__Account__r.PersonMobilePhone !=null){

                programPhone.put(p.id,p.nu_dse__Account__r.PersonMobilePhone);

            }else{

                 programPhone.put(p.id,p.nu_dse__Account__r.phone);
            }
        }


        for(Task t: [select id,what.Id,nu_dse__Communication_Template__r.nu_dse__TwiML__c, nu_dse__Communication_Template__r.nu_dse__From__c, nu_dse__Communication_Template__r.nu_dse__SMS_Body__c from Task where id in: TaskIds ]){

            sendSMS(programPhone.get(t.what.id),t.nu_dse__Communication_Template__r.nu_dse__From__c, t.nu_dse__Communication_Template__r.nu_dse__SMS_Body__c);
        }
    }

@Future(Callout=true)
    public static void sendVB(List<id> taskIds){

       Map<String,String> VB = new Map<String,String>();
        Map<id,String> programPhone = new Map<id,String>();
        List<Id> programIds = new List<id>();
        for(Task t: [select id,what.id from Task where Id in:taskIds]){

            programIds.add(t.what.id);

        }

        for(nu_dse__Program__c p: [select id, nu_dse__Account__r.phone, nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone from nu_dse__Program__c where id in: programIds]){

            if(p.nu_dse__Account__r.PersonHomePhone !=null){
               programPhone.put(p.id,p.nu_dse__Account__r.PersonHomePhone);
            }else if(p.nu_dse__Account__r.PersonMobilePhone !=null){

                programPhone.put(p.id,p.nu_dse__Account__r.PersonMobilePhone);

            }else{

                 programPhone.put(p.id,p.nu_dse__Account__r.phone);
            }
        }

        for(Task t: [select id,what.Id,nu_dse__Communication_Template__r.nu_dse__TwiML__c,nu_dse__Communication_Template__r.nu_dse__From__c from Task where id in: TaskIds ]){

            sendVoiceBroadCast(programPhone.get(t.what.id),t.nu_dse__Communication_Template__r.nu_dse__From__c, t.nu_dse__Communication_Template__r.nu_dse__TwiML__c);
        }

    }


     public static void sendVoiceBroadCast(String toPhone,String fromPhone, String url){

        TwilioConfig__c config = TwilioConfig__c.getOrgDefaults();

        TwilioRestClient client = TwilioAPI.getDefaultClient();

        if(!toPhone.startsWith('+1')){

            toPhone = '+1'+toPHone;
        }

         Map<String,String> params = new Map<String,String>();
           params.put('To',toPhone);
           params.put('From',fromPhone);
           params.put('MachineDetection','DetectMessageEnd');
           params.put('Url',url);


           TwilioCall call = client.getAccount().getCalls().create(params);
           system.debug('voice-->'+call);

    }
    @Future
    public static void sendEmailAlerts(List<id> eaTaskIds){


        Map<Id,Id> emailAlertsProgram = new Map<Id,Id>();
        Map<Id,Id> programAccount = new Map<Id,Id>();
        List<Id> programIds = new List<id>();
        for(Task t: [select id,what.id from Task where Id in:eaTaskIds]){
            programIds.add(t.what.id);
            emailAlertsProgram.put(t.what.id,t.id);

        }

        for(nu_dse__Program__c p: [SELECT id, nu_dse__Account__c FROM nu_dse__Program__c WHERE id in: programIds]){
            programAccount.put(p.Id,p.nu_dse__Account__c);
         }

         for(Task t: [select id,what.Id,nu_dse__Communication_Template__r.nu_dse__TwiML__c,nu_dse__Communication_Template__r.nu_dse__From__c from Task where id in: eaTaskIds ]){
             sendEmail(t.what.id,programAccount.get(t.what.Id), t.nu_dse__Communication_Template__c);
         }

    }

    public static void sendEmail(ID targetObjectForTemplate, ID candidate, Id templateId) {


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //will generally be the accountId
        mail.setTargetObjectId(targetObjectForTemplate);
        mail.setTemplateId(templateId);
        mail.setWhatId(candidate);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        //currently only support timberlinefinancial
        mail.setReplyTo('cs@timberlinefinancial.com');
        mail.setSaveAsActivity(false);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }



}