/*
Description  : This is a generic class used to wrapping all the responses related to Box Document functionality
Created Date : 03/04/2020
Version      : 1.0
Reference    : Box_DocumentCenter.cmp
*/
public class SFSPortal_DocumentCenterWrapper {
	 public SFSPortal_DocumentCenterWrapper() {}
    //apex class structure to deserialize Folder/file response JSON
    public class boxDocumentRespose{
        @AuraEnabled public List<FoldersInfo> FoldersInfoLst;
    }
    public class FoldersInfo{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public String sequence_id;
        @AuraEnabled public String etag;
        @AuraEnabled public String name;
        @AuraEnabled public String created_at;
        @AuraEnabled public String modified_at;
        @AuraEnabled public String item_status;
        @AuraEnabled public String description;
        @AuraEnabled public itemCollections item_collection;
        public FoldersInfo(){}
        public FoldersInfo(String type,String id,String sequence_id,String etag,String name,String created_at,String modified_at,String description,String item_status ){
            this.type=type;
            this.id=id;
            this.sequence_id=sequence_id;
            this.etag=etag;
            this.created_at=created_at;
            this.modified_at=modified_at;
            this.description=description;
            this.item_status=item_status;
            this.item_collection=new itemCollections();
            
        }
    }
    public class itemCollections{
        @AuraEnabled public String total_count;
        @AuraEnabled public List<entry> entries;
        public itemCollections(){}
        public itemCollections(String count){
            this.total_count = count;
            this.entries=new list<entry>();  
        }
    }
    //subfolder wrapper
    public class subfolderDetailsWrapper{
        @AuraEnabled public Integer total_count;	//2
        @AuraEnabled public entry[] entries;
        @AuraEnabled public Integer offset;	//0
        @AuraEnabled public Integer res_limit;	//100
        
    }
   
    public class entry{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public String etag;
        @AuraEnabled public String name;
        @AuraEnabled public string created_at;
        @AuraEnabled public string modified_at;
        @AuraEnabled public String extension;
        @AuraEnabled public String size;
        @AuraEnabled public String category; 
        //@AuraEnabled public expiring_embed_link expiring_embed_link; 
        public entry(){}
    }
    /*public class expiring_embed_link{
        @AuraEnabled public string url;
    }*/
}