@RestResource(urlMapping='/ClientService/ChangeClientStatus/*')
global class ChangeClientStatus {
    
    
    
    @HTTPPOST
    global static Response doPost(List<String> clientIdList, String newstatus, String excelaDocumentName){
        
        Response response = new Response();
        List<nu_dse__program__c> programs = [select id from nu_dse__program__c where nu_dse__Account__r.Box_Folder_Name__c in:clientIdList ];
        
        If(programs.size()==0){
            
            throw new customException('Record Id Not Found');
        }
        
        for(nu_dse__program__c p: programs){
            
            p.Array_Status__c = newstatus; 
            
            if (excelaDocumentName != null) {
                
                p.Excela_Document_Name__c = excelaDocumentName;
            }
        }
        
        try{
            
            update programs;
            
            response.status = 'OK' ;
        }catch(Exception e){
            
             response.status = 'ERROR' ;
            response.error = e.getMessage();
        }
         
        
        return response ; 
    }
    
    global class Response{
        
         string status{get;set;}
         string error{get;set;}
        
    }


}