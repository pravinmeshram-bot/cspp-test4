@RestResource(urlMapping='/ClientService/*')
global class ClientService {

    @HTTPPOST
    global static List<Client> getClients(List<String> clientIdList){
     
        List<Client> clients = new List<Client>(); 
        
        for(nu_dse__program__c cl: [SELECT id,createdDate,owner.name,ownerId,LastModifiedDate,LastModifiedBy.Name,Array_Status__c, nu_dse__Account__c,nu_dse__Account__r.clientnumber__c 
                                    FROM nu_dse__program__c where nu_dse__Account__r.clientnumber__c in : clientIdList]){
            
            client c = new Client(); 
            
            c.ClientNumber = String.valueOf(cl.nu_dse__Account__r.clientnumber__c); 
            c.CreatedOn = cl.createdDate ;
            c.UpdatedOn = cl.LastModifiedDate ; 
            c.updatedBy = cl.LastModifiedBy.Name; 
            c.CurrentStatus = cl.Array_Status__c;
            c.Assignee = cl.owner.name; 
            clients.add(c);
        }
        
        system.debug('::clients::'+clients);
        return clients; 
    }

    @HTTPGET
    global static List<Client> getAllClients(){
        
        List<Client> clients = new List<Client>(); 
        
        for(nu_dse__program__c cl: [select id,createdDate,LastModifiedDate,LastModifiedById,Array_Status__c, nu_dse__Account__r.clientnumber__c from nu_dse__program__c ]){
            
            client c = new Client(); 
            
            c.ClientNumber = String.valueOf(cl.nu_dse__Account__r.clientnumber__c); 
            c.CreatedOn = cl.createdDate ;
            c.UpdatedOn = cl.LastModifiedDate ; 
            c.updatedBy = cl.LastModifiedById; 
            c.CurrentStatus = cl.Array_Status__c;
            
            clients.add(c);
        }
        system.debug('::clients:: '+clients);
        return clients; 
       
    }
    
   
     
        global class Client
            {
             global string ClientNumber;
             //global string CampaignId; 
             global DateTime CreatedOn;
             global DateTime UpdatedOn;
             global string UpdatedBy;
             global String CurrentStatus; 
             global String Assignee; 
             global String Properties;
            // global String Assets;
      }
      
}