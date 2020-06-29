public without sharing class SystemUtils {
  
    // method to return RecordTypeID dynamically
    public static ID getRecordTypeID(String objName, String recTypeName){
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = sObjectMap.get(objName) ; // getting Sobject Type
        Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); //getting all Recordtype for the Sobject
        Id recTypeID = recordTypeInfo.get(recTypeName).getRecordTypeId();//particular RecordId by  Name
        return recTypeID;
    }  
}