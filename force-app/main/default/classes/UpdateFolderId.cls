@RestResource(urlMapping='/LeadService/UpdateFolderId/*')
global class UpdateFolderId {

    
    @HTTPPOST
    global static nu_dse__Program__c doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String clientId = req.params.get('clientId');
        String folderId = req.params.get('folderId');
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>(); 
        List<Account> accounts = new List<Account>();
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        Account acct = new Account(); 
        
        if(clientId !=null && clientId !=''){
            
            programs = [select id, nu_dse__Program__c.nu_dse__Account__r.Box_Folder_Name__c,nu_dse__Program__c.nu_dse__Account__r.BoxFolderId__c from nu_dse__Program__c where  name=:clientId or nu_dse__Program__c.nu_dse__Account__r.Box_Folder_Name__c=:clientId  limit 1];
            accounts = [select id,BoxFolderId__c  from Account where Box_Folder_Name__c=:clientId  limit 1];
            system.debug(':::programs:::'+programs); 
            system.debug( ':::programs:::'+programs.size()); 
            
            if(programs.size()>0){
            program = programs[0];
            
            program.client_folder_Id__c = folderId; 

            }
            
            if(accounts.size()>0){
            
             acct = accounts[0];
             
             acct.BoxFolderId__c = folderId; 
             
            }
            
             
            
        }
        
         
           if(program.id !=null){
            update program;
           }else{
             
               Throw new customexception('No Records to update!');
           }
            if(acct.id!=null){
              
                    update acct; 
            
            }
      
       program = [select id,client_folder_Id__c, nu_dse__Program__c.nu_dse__Account__r.Box_Folder_Name__c,nu_dse__Program__c.nu_dse__Account__r.BoxFolderId__c from nu_dse__Program__c where  Id=:program .Id limit 1];

        
        return program; 
    }
    
  
}