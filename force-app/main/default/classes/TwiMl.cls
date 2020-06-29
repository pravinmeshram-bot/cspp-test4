global class TwiMl {

    global  string getResponse(){
      
        String digits = ApexPages.currentPage().getParameters().get('Digits');
        String answeredBy  = ApexPages.currentPage().getParameters().get('AnsweredBy') ;
        String taskId = ApexPages.currentPage().getParameters().get('taskId') ;
        String    response = '';
        Id portFolioId;
        Map<String,Document> recordings = TwilioUtil.getVBRecordings();
        Voice_Recordings__c recordingname = null;
        TwilioTwiML.Response r = new TwilioTwiML.Response();
         
        System.debug('Executed TwiML getRESPONSE()');
         
        if(taskId != null && taskId !='') {
            
            Task t = [select id, nu_dse__Communication_Template__c,whatId from Task where Id =:taskId];
             
            String sObjName = t.whatId.getSObjectType().getDescribe().getName();

            if(sObjName=='nu_dse__Program__c'){
               
                nu_dse__Program__c p = [select id,Portfolio__c from nu_dse__Program__c where Id =: t.whatId];
                portFolioId = p.Portfolio__c;
            }
             
            if(sObjName=='nu_dse__Payment__c'){
                 
                nu_dse__Payment__c payment=[select id,nu_dse__program__r.portfolio__c from nu_dse__Payment__c where Id=:t.whatId];
                 
                portFolioId = payment.nu_dse__program__r.portfolio__c;
            }
            
            if(sObjName=='nu_dse__Offer__c'){
                 
                nu_dse__Offer__c offerInst =[select Id, nu_dse__program__r.portfolio__c from nu_dse__Offer__c where Id=:t.whatId];
                 
                portFolioId = offerInst.nu_dse__program__r.portfolio__c;
            }
            
            System.debug('taskId-->'+taskId);
             
            if(t.nu_dse__Communication_Template__c!=null &&portfolioId != null) {
                 
                recordingname = getVoiceRecording(t.nu_dse__Communication_Template__c,portfolioId, 'human'); 
                 
            }else{
           
                System.debug('throw Exception Portfolio:'+PortfolioId);
                throw new customException('Communication Template or Portfolio missing: Communication Template Id :'+ t.nu_dse__Communication_Template__c+' Portfolio: '+PortfolioId);
            }
              
            if(answeredBy=='human' && Digits == null && recordingname !=null && recordings.get(recordingname.Recording_Name__c) != null ){
                         
                system.debug('If condition human entered:::'+recordings.get(recordingname.Recording_Name__c));                  
     
                TwilioTwiML.Gather gather = new TwilioTwiMl.Gather(); 
             
                gather.setAction('/TwiMLPage?taskId='+t.id);
                gather.setNumDigits(1);
                gather.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get(recordingname.Recording_Name__c).Id)) ;
                            
                r.append(gather);
                      
            }else if(answeredBy=='machine_start'||answeredBy=='machine_end_beep' || answeredBy=='machine_end_silence' || answeredBy=='machine_end_other'){
                  
                recordingname=  getVoiceRecording(t.nu_dse__Communication_Template__c,portfolioId, 'machine');
                  
                r.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get(recordingname.Recording_Name__c).Id));
                  
            }
            
            if(answeredBy=='human' && Digits=='1'){
                 
                recordingname = getVoiceRecording(t.nu_dse__Communication_Template__c,portfolioId, 'human'); 
    
                TwilioTwiML.Dial dial = new TwilioTwiML.Dial(recordingname.Customer_Service__c ); 
                     
                r.append(dial);
            }
             
        }
                
            response +=r.toXML() ;
            
            System.debug('return response -->'+response);
            return response;
    }
    
    public Voice_Recordings__c getVoiceRecording(String communicationTemplateId, String portfolioId,String twilioAnswering ){
    
        Map<id,map<id,map<id,string>>> recordings = new Map<id,map<id,map<id,string>>>();
        List<Voice_Recordings__c> voiceRecording = [select id,Recording_Name__c,twilio_answer_type__c,Customer_Service__c from Voice_Recordings__c where Communication_Template__c=: communicationTemplateId and Portfolio__c=: portfolioId and twilio_answer_type__c=:twilioAnswering limit 1];
        if(voiceRecording.size() != 0 && voiceRecording[0].Recording_Name__c !=null){
            
            return voiceRecording[0];
        }else{
            
            throw new CustomException('Voice Recorings Not found for communication tempateId:'+communicationTemplateId +'Portfolio id:'+portfolioId +'Answering type:'+twilioAnswering);
        }
     
    }
    
}