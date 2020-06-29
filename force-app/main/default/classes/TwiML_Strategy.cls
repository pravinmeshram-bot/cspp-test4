public class TwiML_Strategy {


     public  string getResponse(){
      
       string digits = ApexPages.currentPage().getParameters().get('Digits');
       String answeredBy  = ApexPages.currentPage().getParameters().get('AnsweredBy') ;
       string    response ='';
       Map<String,Document> recordings = TwilioUtil.getVBRecordings();
         
       TwilioTwiML.Response r = new TwilioTwiML.Response();
       
         
            
         if(answeredBy=='human' && Digits == null){
                     
                      //r.append(new TwilioTwiML.Say('Hello'));
                     TwilioTwiML.Gather gather = new TwilioTwiMl.Gather(); 
                     
                     gather.setAction('/TwiML_Strategy');
                     gather.setNumDigits(1);
             if(recordings.containsKey('TL_STRATEGY_CALL')){ 
                     gather.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('TL_STRATEGY_CALL').Id)) ;
                         //gather.append(new TwilioTwiML.Say(NSF_LIVE_VB));
                 //
                 }
                   r.append(gather);
                  
          }else if(answeredBy=='machine_start'||answeredBy=='machine_end_beep' || answeredBy=='machine_end_silence' || answeredBy=='machine_end_other'){
                
              if(recordings.containsKey('TL_STRATEGY_CALL')){ 
                r.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('TL_STRATEGY_CALL').Id));
              }
            }
             
       
         
         if(answeredBy=='human' && Digits=='1'){
                 
                 TwilioTwiML.Dial dial = new TwilioTwiML.Dial('+18552508329'); 
                
                 r.append(dial);
             
               
             }
                     
         response +=r.toXML() ;
        
         return response    ;
         
        }
}