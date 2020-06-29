public class JSONParseBOXResponse {
	public String type;	//folder
	public String id;	//100907764256
	public String sequence_id;	//0
	public String etag;	//0
	public String name;	//Test Copy
	public String created_at;	//2020-01-21T08:46:43-08:00
	public String modified_at;	//2020-01-23T11:13:33-08:00
	public String description;	//
	public Integer size;	//0
	public cls_path_collection path_collection;
	public cls_created_by created_by;
	public cls_modified_by modified_by;
	public cls_trashed_at trashed_at;
	public cls_purged_at purged_at;
	public String content_created_at;	//2020-01-21T08:46:43-08:00
	public String content_modified_at;	//2020-01-23T11:13:33-08:00
	public cls_owned_by owned_by;
	public cls_shared_link shared_link;
	public cls_folder_upload_email folder_upload_email;
	public cls_parent parent;
	public String item_status;	//active
	public cls_item_collection item_collection;
	public class cls_path_collection {
		public Integer total_count;	//2
		public cls_entries[] entries;
	}
	public class cls_entries {
		public String type;	//folder
		public String id;	//101009976665
		public String sequence_id;	//2
		public String etag;	//2
		public String name;	//1099c
	}
	class cls_sequence_id {
	}
	class cls_etag {
	}
	class cls_created_by {
		public String type;	//user
		public String id;	//11238624736
		public String name;	//Neeraj MZ Dev
		public String login;	//neeraj@mindzcloud.com
	}
	class cls_modified_by {
		public String type;	//user
		public String id;	//11238624736
		public String name;	//Neeraj MZ Dev
		public String login;	//neeraj@mindzcloud.com
	}
	class cls_trashed_at {
	}
	class cls_purged_at {
	}
	class cls_owned_by {
		public String type;	//user
		public String id;	//11238624736
		public String name;	//Neeraj MZ Dev
		public String login;	//neeraj@mindzcloud.com
	}
	class cls_shared_link {
	}
	class cls_folder_upload_email {
	}
	class cls_parent {
		public String type;	//folder
		public String id;	//99254086859
		public String sequence_id;	//0
		public String etag;	//0
		public String name;	//Test Integration
	}
	public class cls_item_collection {
		public Integer total_count;	//29
		public cls_entries[] entries;
		public Integer offset;	//0
		public Integer limits;	//100
		public cls_order[] order;
	}
	class cls_order {
		public String bys;	//type
		public String direction;	//ASC
	}
	public static JSONParseBOXResponse parse(String json){
		return (JSONParseBOXResponse) System.JSON.deserialize(json, JSONParseBOXResponse.class);
	}

}