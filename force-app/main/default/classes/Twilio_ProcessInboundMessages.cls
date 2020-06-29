@Restresource(urlMapping='/ProcessInboundMessages/*')
global class Twilio_ProcessInboundMessages {

    @HttpPost
    global static String getResponse(){
        RestRequest req = RestContext.request;

        String fromNumber ='';// req.params.get('From'); 
        String body ='';// req.params.get('Body');
      
         Task t = new Task(); 
        
        t.subject = body; 
        
        t.ActivityDate = System.Date.today();
        
        insert t; 
      
       
       
            String response = '<?xml version="1.0" encoding="UTF-8"?>'; 
            
            response += '<message> message received :'+  fromNumber +' ' + body +'</message>' ; 
            
            return response; 
        
    }
    
    
}