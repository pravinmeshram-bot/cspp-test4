public class CustomMetadataGenerator {

    public static Map<String, String> queryStrResultMap = new Map<String, String>();
    
    public static String getCMDRecords(String queryString) {
    
        String queryResult = '';
    
        if (String.isNotBlank(queryString)) {
        
            if (queryStrResultMap.containsKey(queryString) && String.isNotBlank(queryStrResultMap.get(queryString))) {
            
                queryResult = queryStrResultMap.get(queryString);
            } else {
            
                queryResult = JSON.serialize(Database.query(queryString));
            }
        }
        return queryResult;
    }
}