public class ProspectHandler {

    
    public static void handle(map<id,nu_dse__prospect__c> oldleads,Map<id,nu_dse__prospect__c> newLeads){
        
      
        if(trigger.isUpdate){
            
          set<Id> modifiedLeads = new set<Id>(); 
       
          Map<String,string> fieldMap = new Map<String,string>(); 

         for(nu_dse__Field_mapping__c datamapping : [select id,nu_dse__Data_Mapping__c,nu_dse__Source_Field__c,nu_dse__Target_Field__c from nu_dse__Field_mapping__c where nu_dse__Data_Mapping__r.Name='VelocifyLead']){
            
            fieldMap.put(datamapping.nu_dse__Source_Field__c.toUpperCase(), datamapping.nu_dse__Target_Field__c);
        }
        
         for(id pId: newLeads.keySet()){
                        
            for(String f: fieldMap.keySet()) {
                
               // check if any of field values changed and add to a set. 
               if(oldleads.containsKey(pId) && (newLeads.get(pId).get(f) != oldleads.get(pid).get(f)) && newLeads.get(pId).Upd_External_Id__c !=null){  // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                   
                   if(!modifiedLeads.contains(pId) ){
                       
                       modifiedLeads.add(pId);
                   }
                
              }
                
            }
            
        }
            
            if (modifiedLeads.isEmpty() == False) {
            
                ProspectHandler.modifyLeads_Async(modifiedLeads);
            }
            
        }
    }
    
    @future(callout=true)
    public static void modifyLeads_Async(set<id> updatedLeads){
        
        String query = 'Select ' + getQueryFields('nu_dse__Prospect__c') + ' From nu_dse__Prospect__c where id in : updatedLeads';
        
        List<nu_dse__prospect__c> leads = Database.query(query);
        
        ServiceLeads360 lead360 = new ServiceLeads360(); 
        
        lead360.modifyLeads(leads);
        
    }
    
     private static String getQueryFields(String objectName){
        
     String[] types = new String[]{objectName};

     Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);

     Schema.DescribeSobjectResult result = results[0]; 
     
     Set<String> tempfields =   result.fields.getMap().keySet();
     
     Map<String,Schema.SObjectField> fieldMap =  result.fields.getMap();
     String fields = '';
        
        for(String k: fieldMap.keySet()){
            
            String f =  fieldMap.get(k).getDescribe().getName();
            
            fields += f; 
            tempfields.remove(k);
            if(tempfields.size()>0){
                
                fields +=',';
            }
            
        }
        
        return fields;
    }
    
    public class UpdatePortfolio implements Queueable{
    
        List<nu_dse__Prospect__c> ProspectList;
        
        public UpdatePortfolio(List<nu_dse__Prospect__c> ProspectLst)
        {
            this.ProspectList = ProspectLst; 
        }
        
        public void execute(QueueableContext context) {   
 
            List<Portfolio__c> PortfolioList = [Select Id, Name from Portfolio__c where Name='Timberline'];
            
            for(nu_dse__Prospect__c Prospect: ProspectList){
                if(Prospect.Portfolio__c == null){
                    Prospect.Portfolio__c = PortfolioList[0].Id;
                }
            }
            Update ProspectList;
        }
    
    }
    
    public Static void populatePortfolio(){
        List<nu_dse__Prospect__c> ProspectList = (List<nu_dse__Prospect__c>)Trigger.new;
        
        System.debug('*****'+ProspectList);
        List<Portfolio__c> PortfolioList = [Select Id, Name from Portfolio__c where Name='Timberline'];
        System.debug('*****'+PortfolioList);    
        for(nu_dse__Prospect__c Prospect: ProspectList){
            if(Prospect.Portfolio__c == null && !PortfolioList.isEmpty()){
                Prospect.Portfolio__c = PortfolioList[0].Id;
            }
        }
    }
}