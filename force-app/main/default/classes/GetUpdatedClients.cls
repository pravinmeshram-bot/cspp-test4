@RestResource(urlMapping='/ClientService/GetUpdatedClients/*')
global class GetUpdatedClients {

    
    @HTTPGET
    global static List<Client> doGet(){
        
        List<Client> clients = new List<Client>(); 
        
        Date startDate ;
        
        Date endDate ; 
        
        RestRequest req = RestContext.request;

        String startD = req.params.get('startDate');
        String endD = req.params.get('endDate');
        
        System.debug('Start and End Dates: '+ startD + ' '+ endD);
        
        try{
            
            startDate = Date.valueOf(startD); 
            endDate= Date.valueOf(endD);
            
        } catch(System.TypeException typeE){
            
            System.debug('date conversion exception');
            
            throw new CustomException('Start Date and End date conversion failed');
            
        } catch(System.Exception e){
            
            throw new CustomException('Date conversion failed'); 
        }
        
        System.debug('Dates converted:: '+ startDate +' '+ endDate); 
        
        for(nu_dse__program__c cl: [select id,nu_dse__Account__r.Auto_client_number__c,createdDate,LastModifiedDate,LastModifiedById,Array_Status__c, nu_dse__Account__c from nu_dse__program__c where lastmodifiedDate >= :startDate and LastModifiedDate <= :enddate ]){
            
            client c = new Client(); 
            
            c.ClientNumber = cl.nu_dse__Account__r.Auto_client_number__c; 
            c.CreatedOn = cl.createdDate ;
            c.UpdatedOn = cl.LastModifiedDate ; 
            c.updatedBy = cl.LastModifiedById; 
            c.CurrentStatus = cl.Array_Status__c;
           
            
            clients.add(c);
        }
        
        system.debug('::clients::'+clients);
        return clients; 
       
    }
    
    
    @HTTPPOST
     global static List<Client> doPOST(Date startDate, Date endDate){
        
        List<Client> clients = new List<Client>(); 
        
     
        // Added name in below query in oct10-2017
        for(nu_dse__program__c cl: [select id,name,createdDate,LastModifiedDate,LastModifiedById,Array_Status__c, nu_dse__Account__c from nu_dse__program__c where lastmodifiedDate >= :startDate and LastModifiedDate <= :enddate ]){
            
            client c = new Client(); 
            
            c.ClientNumber = cl.name; 
            c.CreatedOn = cl.createdDate ;
            c.UpdatedOn = cl.LastModifiedDate ; 
            c.updatedBy = cl.LastModifiedById; 
            c.CurrentStatus = cl.Array_Status__c;
            
            clients.add(c);
        }
        
        System.debug(':::Clients:::'+clients);
        return clients; 
       
    }
    
    global class Client {
         global string ClientNumber;
         global string CampaignId; 
         global DateTime CreatedOn;
         global DateTime UpdatedOn;
         global string UpdatedBy;
         global String CurrentStatus; 
         global String Assignee; 
         global String Properties;
         global String Assets;
    }
   
}