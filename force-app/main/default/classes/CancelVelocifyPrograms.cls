public class CancelVelocifyPrograms implements Queueable, Database.AllowsCallouts{

    List<nu_dse__Program__c> programs ; 
    
    
    public  CancelVelocifyPrograms (List<nu_dse__Program__c> cancelPrograms){
        
        programs = new List<nu_dse__Program__c>(); 
        
        programs = cancelPrograms; 
    }    
    
    public void execute(QueueableContext context) {
        
        ServiceLeads360 serviceLeads = new ServiceLeads360(); 
        
        serviceLeads.modifyPrograms(Programs);
        
        map<String,String> leadstatus = new map<String,string>(); 
        Set<id> programIds = new Set<id>(); 
        
        for(nu_dse__Program__c p: programs){
            
            programIds.add(p.id);
        }
        
        for(nu_dse__Program__c p: [select id,external_id__c from nu_dse__Program__c where id in:programIds]){
            
            leadStatus.put(p.External_Id__c,'21');
            
        }
        
        if(leadstatus.size()>0){
            
          
             serviceLeads.modifyLeadStatus(leadStatus);
        }
    }
}