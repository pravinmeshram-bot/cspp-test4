public class TwiMLGather {

    
    public static string getResponse(){
        
       String digits = ApexPages.currentPage().getParameters().get('Digits');
       String answeredBy  = ApexPages.currentPage().getParameters().get('AnsweredBy') ;

       string    response ='';
       TwilioTwiML.Response r = new TwilioTwiML.Response();
        
        if(answeredBy=='machine_start'||answeredBy=='machine_end_beep' || answeredBy=='machine_end_silence' || answeredBy=='machine_end_other'){
              
            r.append(new TwilioTwiML.Say('Hello'));
        }
              
         response +=r.toXML() ;
        return response		;
    }
}