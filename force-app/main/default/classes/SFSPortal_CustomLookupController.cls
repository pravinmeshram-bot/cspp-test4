/* Date : 16-11-2018
 * Description : Handler for multiselectLookup controller
 */
public with sharing class SFSPortal_CustomLookupController {
        
    /* Method to get the list of sobjects */
    @AuraEnabled
    public static List<LookupWrapper> getSearchResult(String searchKeyWord, String ObjectName, String fieldsToQuery, String filterCondition) {
        
        List<LookupWrapper> wrapperList = new List<LookupWrapper>();
        try {
        
            String searchKey = searchKeyWord + '%';
            
            /* Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 */
            String sQuery =  'SELECT Id, Name';
            System.debug('fieldsToQuery:::::'+fieldsToQuery);
            if(String.isNotBlank(fieldsToQuery) == TRUE) {
            
                 sQuery += ', ' + fieldsToQuery;
            }
            
            sQuery += ' FROM ' + ObjectName + ' WHERE Name LIKE: searchKey ';
            
            if(ObjectName == 'Contact'){
                
                sQuery += 'AND IsPersonAccount = false';
            }
            
            System.debug('**** filterCondition-->' + filterCondition); 
            
            if(String.isNotBlank(filterCondition) == TRUE) {
            
                sQuery += filterCondition;
            }
            
            sQuery += ' ORDER BY CreatedDate DESC LIMIT 5 ';
            
            System.debug('sQuery-->' + sQuery );
            
            for(Sobject instance : Database.query(sQuery)) {
                List<String> fieldsToDisplay = new List<String>();
                
                if(String.isNotBlank(fieldsToQuery) == TRUE) {
                
                    List<String> fieldList = fieldsToQuery.split(',');
                    
                    if(fieldList != null && fieldList.isEmpty() == FALSE) {
                    
                        for(String apiName : fieldList) {
                        
                            fieldsToDisplay.add(String.valueOf(instance.get(apiName)));
                        }
                    }
                }
                
                wrapperList.add(new LookupWrapper((String) instance.get('Id'), (String) instance.get('Name'), fieldsToDisplay));
            }
            
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }
    
    public class LookupWrapper {
    
        @AuraEnabled
        public String recordId;
        
        @AuraEnabled
        public String label;
        
        @AuraEnabled
        public List<String> fieldsToDisplayList;
        
        public LookupWrapper(String Id, String name, List<String> fieldList) {
        
            this.recordId = Id;
            this.label = name;
            this.fieldsToDisplayList = fieldList;
        }
    }
}