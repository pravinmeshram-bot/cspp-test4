@RestResource(urlmapping='/AssetService/AddAsset/*')
global class AddAsset {

    @HTTPPOST
    global static Response doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>(); 
        List<nu_dse__TradeLine__c> debts = new list<nu_dse__TradeLine__c>() ; 
        Response response = new Response();
        
        System.debug('Request body::: '+ req.params.get('fileName'));
        
        
        String clientId = req.params.get('clientId');
        String debtId = req.params.get('debtId');
        String assetType =  req.params.get('assetType'); 
        string assetFileName = req.params.get('assetFileName');
        String assetDescription = req.params.get('assetDescription');
        blob assetBytes = req.requestBody; 
        
        System.debug('AssetType::::'+ assetType);
        
        if(!isAssetTypeExists(assetType)){
            
            assetType = 'Miscellaneous';
        }
        
        if(clientId ==null && debtId ==null){
            
            response.status='ERROR'; 
            response.error ='Record Id Not Found';
            throw new customException('Either Set clientId or ProgramId');
        }
        
        if(clientId !=null && clientId !=''){
            
            programs = [select id, nu_dse__Program__c.nu_dse__Account__r.clientnumber__c from nu_dse__Program__c where id=:clientId or name=:clientId or nu_dse__Program__c.nu_dse__Account__r.clientnumber__c=:clientId  limit 1];
            system.debug(':::programs:::'+programs); 
            system.debug(':::programs:::'+programs.size()); 
        }
       
        if(debtId !=null && debtId !=''){
            
            debts = [select id,name,nu_dse__Program__r.nu_dse__Account__r.clientnumber__c from nu_dse__TradeLine__c where Id=:debtId or name =:debtId];
            system.debug('::debts::'+debts);
            system.debug('::debts::'+debts.size());
        }
        
        if((clientId !=null && programs.Size() ==0) || (debtId !=null && debts.size()==0)){
            
             response.status='ERROR'; 
             response.error ='Record Id Not Found';
            
            throw new customException('Record Id Not Found');
            
        }else if(clientId ==null && debtId ==null){
            
            response.status='ERROR'; 
            response.error ='Record Id Not Found';
            throw new customException('Either Set clientId or ProgramId');
        }
         
        If((clientId != null && clientId !='' && programs.size() > 0) ||(debtId !=null && debtId != '' &&  debts.size() > 0)){
          
            
            sObject parent; 
            
            Box b = new Box(); 
            
            
            if(programs !=null && programs.size() >0 ){
                
                 parent = programs[0]; 
            }
           
            if(debts !=null &&  debts.size() > 0  ){
                
                
                 parent = debts[0]; 
            }
            
            Try{
              system.debug('::parent::'+parent);
              system.debug('::assetType::'+assetType);
              system.debug('::assetFileName::'+assetFileName);
              system.debug('::assetDescription::'+assetDescription);
              System.debug('::assetBytes::'+assetBytes);  
             if(!Test.isRunningTest()){
                  b.uploadFilesToBox(parent, assetType, assetFileName,assetDescription ,assetBytes);
             }
              response.status='OK';
                
            }catch(DMLException de){
                
                response.status='ERROR'; 
                response.error =de.getMessage(); 
                
                throw new customException('Failed to add assert !');
            }
            
        }
       
        return response ;
    }
    
    global class Response{
        
         string status{get;set;}
         string error{get;set;}
        
    }
    
    public static boolean isAssetTypeExists(String assetType){
        
        if(assetType == null){ return false;}
        for(DocType__c fileTypes : DocType__c.getAll().values()){
            
            if(assetType.equalsIgnoreCase(fileTypes.Name)){
                
                return true; 
            }
        } 
        
      
        
        return false; 
    }
    
}