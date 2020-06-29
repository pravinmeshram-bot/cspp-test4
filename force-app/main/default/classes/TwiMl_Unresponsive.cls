public class TwiMl_Unresponsive {
     public static final string UNRESPONSIVE_LIVE_VB = ' Hello, this is Timberline Financial calling. It is very important that we speak to you as soon as possible to avoid termination of your account with us. If you have a few minutes to speak with us , please press 1 to connect to a live Client Support Agent and begin your call now! If now is not convenient for you, please call Pioneer Law Firm Client Support as soon as possible. Our number is 855-250-8329 .Thank You .';
     public static final string UNRESPONSIVE_VOICE_VB ='Hello, this is Timberline Financial calling with an important message regarding your account. It is very important that we speak to you as soon as possible about your account. At your earliest convenience, please call Pioneer Law Firm. Our toll free number is 855-250-8329 or we\'ll try you again at a later date. We look forward to speaking with you soon.';
    
    
     public  string getResponse(){
      
       string digits = ApexPages.currentPage().getParameters().get('Digits');
       String answeredBy  = ApexPages.currentPage().getParameters().get('AnsweredBy') ;
       string    response ='';
       Map<String,Document> recordings = TwilioUtil.getVBRecordings();
         
       TwilioTwiML.Response r = new TwilioTwiML.Response();
           
         if(answeredBy=='human' && Digits == null){
                     
                    //r.append(new TwilioTwiML.Say(NSF_LIVE_VB));
                     
             
                     TwilioTwiML.Gather gather = new TwilioTwiMl.Gather(); 
                     
                     gather.setAction('/TwiML_Unresponsive');
                     gather.setNumDigits(1);
             if(recordings.containsKey('UNRESPONSIVE_LIVE_VB')){ 
                  
                 gather.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('UNRESPONSIVE_LIVE_VB').Id));
             }   
                 r.append(gather);
                     
             
          }else if(answeredBy=='machine_start'){
                
              if(recordings.containsKey('UNRESPONSIVE_LIVE_VB')){
                 r.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('UNRESPONSIVE_VOICE_VB').Id));
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