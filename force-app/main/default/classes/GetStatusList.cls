@RestResource(urlMapping='/ClientService/GetStatusList/*')
global class GetStatusList {

    
    @HTTPGET
    global static List<String> doGet(){
        
        List<string> statusList = new List<String>(); 
            
        Schema.DescribeFieldResult fr = nu_dse__Program__c.Array_Status__c.getDescribe();
            
         List<Schema.PicklistEntry> ple = fr.getPicklistValues();
         system.debug('>>>All Picklist Values>>>'+ple);
        
         for ( Schema.PicklistEntry f : ple )
         {
            statusList.add(f.getLabel());
         }
            return statusList; 
    }
    
  
}