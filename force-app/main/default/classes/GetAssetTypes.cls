@RestResource(urlMapping='/AssetService/GetAssetTypes/*')
global class GetAssetTypes {

    
    // return all forlder name from box 
    @HTTPGET
    global static List<String> doget(){
        
        List<String> assetTypes = new list<string>(); 
        
        for(DocType__c dt: [select name from DocType__c ]){
            
            assetTypes.add(dt.name);
        }
           return assetTypes; 
    }
}