public class TwiML_NSF {

    /*
     public static final String NSF_LIVE_VB = 'Hello, this is Timberline Financial calling with an important message regarding your account. It is very important that we speak to you as soon as possible. If you have a few minutes to speak with us , please press 1 to connect to a live Client Support Agent and begin your call now! If now is not convenient for you, please call Timberline Financial Client Support as soon as possible. Our number is 1-855-250-8329 .Thank you.';         
     public static final String NSF_VOICE_VB = 'Hello, this is Timberline Financial calling with an important message regarding your account. It is very important that we speak to you as soon as possible about your account. At your earliest convenience, please call Timberline Financial. Our toll free number is 1-855-250-8329 or we\'ll try you again at a later date. We look forward to speaking with you soon.'; 
     public static final String MONTHLY_ACCOUNT_REVIEW_LIVE_VB = ' Hello, this is Timberline Financial calling to welcome you to our program. Should you have some time to talk to us today, please press 1 to connect to a live Client Support Agent and begin your call now! Otherwise, please call us when you have some time so we can answer any questions you may have. Our toll free number is 855-250-8329. We look forward to speaking with you shortly. ';
     public static final string MONTHLY_ACCOUNT_REVIEW_VOICE_VB=' Hello, this is Timberline Financial Client Support calling. Sorry we’ve missed you! We’re calling to review your account. At your earliest convenience, please call Timberline Financial so that our Client Support Agent can discuss your account. Our toll free number is 855-250-8329 or we\'ll try you again at a later date. We look forward to speaking with you soon.';
    */
    
     public  string getResponse(){
      
       string digits = ApexPages.currentPage().getParameters().get('Digits');
       String answeredBy  = ApexPages.currentPage().getParameters().get('AnsweredBy') ;
       string    response ='';
       Map<String,Document> recordings = TwilioUtil.getVBRecordings();

       TwilioTwiML.Response r = new TwilioTwiML.Response();        
            
         if(answeredBy=='human' && Digits == null){
                                   
         
                 TwilioTwiML.Gather gather = new TwilioTwiMl.Gather(); 
                 
                 gather.setAction('/TwiML_NSF');
                 gather.setNumDigits(1);
             if(recordings.containsKey('NSF_LIVE_VB')){ 
                 gather.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('NSF_LIVE_VB').Id)) ;
             }  
               r.append(gather);
                  
          }else if(answeredBy=='machine_start'||answeredBy=='machine_end_beep' || answeredBy=='machine_end_silence' || answeredBy=='machine_end_other'){
                
              if(recordings.containsKey('NSF_LIVE_VB')){ 
                r.append(new TwilioTwiML.Play('/servlet/servlet.FileDownload?file='+recordings.get('NSF_VOICE_VB').Id));
              }
            }
             
       
         
         if(answeredBy=='human' && Digits=='1') {
                 
                 TwilioTwiML.Dial dial = new TwilioTwiML.Dial('+18552508329'); 
                
                 r.append(dial);
             
               
             }
                     
         response +=r.toXML() ;
        
         return response    ;
         
        }
    
   
}