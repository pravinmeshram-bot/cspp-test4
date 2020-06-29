public class BoxSearch extends BoxItem{

    /**
     * An array of all possible file fields.
     */
    public static final list<String> ALL_FIELDS = new list<String> {'type', 'id', 'sequence_id', 'etag', 'sha1', 'name', 'description',
        'size', 'path_collection', 'created_at', 'modified_at', 'trashed_at', 'purged_at', 'content_created_at',
        'content_modified_at', 'created_by', 'modified_by', 'owned_by', 'shared_link', 'parent', 'item_status',
        'version_number', 'comment_count', 'permissions', 'lock', 'extension', 'is_package', 'file_version'};

    private static String SEARCH_FILE_URL = 'search?query';
    
    public BoxSearch(BoxApiconnection api, String Id){
        
        Super(api,id);
         this.information = new BoxFile.Info();
    }
     public override String getObjectType() {
        return 'search';
    }
    
    public override void setInfo(BoxJsonObject jsonObject) {
        this.information = new BoxFile.Info(jsonObject);
    }
    
    public  List<BoxSearch.Info> search(String query,  String objecttype){
        
        String url = this.api.baseUrl + SEARCH_FILE_URL+'='+query+'&ancestor_folder_ids='+ this.getId()+'&type='+objecttype ;
        BoxApiRequest request = new BoxApiRequest(this.api, url, BoxApiRequest.METHOD_GET);
        request.setTimeout(this.api.getTimeout());
    	request.addJsonContentTypeHeader();
    	List<BoxSearch.Info> searchResults = new List<BoxSearch.Info>(); 
        
    	HttpResponse response = request.send();
    	String responseBody = BoxApiRequest.getBoxResourceResponseBody(response, 'BoxSearch.search');
    	BoxGenericJsonObject responseObject = new BoxGenericJsonObject(responseBody);
        if (responseObject.getValue('total_count') != null) {
    		list<String> fileEntries = BoxJsonObject.parseJsonObjectArray(responseObject.getValue('entries'));
    		if (fileEntries.size() > 0) {
                for(String jsonFile: fileEntries){
                    
                    searchResults.add(new BoxFile.Info(jsonFile));
                }
    			return searchResults; 
    		}
    	}
        return null; 
    }
    
    public override BoxItem.Info copy(BoxFolder destination) { return null; }
    public override BoxItem.Info copy(BoxFolder destination, String newName) { return null; } 
    public override BoxItem.Info move(BoxFolder destination, String newName) {return null; } 
    public override BoxItem.Info move(BoxFolder destination) { return null;}
}