//Custom field merging functionality for sobject. Fields should be enclosed in open({) and close brace(}).
public class CustomMergeFields {

    public static String mergeFields(String textBodyWithMergeFields, Set<String> fieldsSet, SObject sobjInstance) {
        
        system.debug('textBodyWithMergeFields-->'+textBodyWithMergeFields);
        system.debug('sobjInstance-->'+sobjInstance);
        system.debug('fieldsSet-->'+fieldsSet);
        
        if (String.isNotBlank(textBodyWithMergeFields) && fieldsSet != null && fieldsSet.isEmpty() == False
                && sobjInstance != null) {
                            
            for (String fieldName : fieldsSet) {
            
                //Checking whether it is relationship field or not
                List<String> relationshipFieldNameSet = fieldname.split('\\.');
                
                if (relationshipFieldNameSet != null && relationshipFieldNameSet.isEmpty() == False) {
                
                    //If size is more than 1, it is relationship field
                    if (relationshipFieldNameSet.size() > 1) {
                    
                        Sobject sobj = sobjInstance;
                        integer i=1;
                        
                        for (String relationshipFieldName : relationshipFieldNameSet) {
                        
                            if (relationshipFieldNameSet.size() == i) {
                                
                                textBodyWithMergeFields = replaceMergeFields(sobj, relationshipFieldName, fieldName, textBodyWithMergeFields);
                            
                            } else {
                                
                                sobj = sobj.getSObject(relationshipFieldName);
                            }
                            i++;
                        }
                    } else { //If size is 1, it is same object field
                    
                        textBodyWithMergeFields = replaceMergeFields(sobjInstance, fieldName, fieldName, textBodyWithMergeFields);
                    }
                }
            }
        }
        system.debug('textBodyWithMergeFields--->'+textBodyWithMergeFields);
        return textBodyWithMergeFields; 
    }
    
    public static String replaceMergeFields(SObject sobjectInstance, String fieldName, String replaceableFieldString, String textBody) {
        
        system.debug('sobjectInstance--->'+sobjectInstance);
        system.debug('fieldName--->'+fieldName);
        system.debug('replaceableFieldString--->'+replaceableFieldString);
        system.debug('textBody--->'+textBody);
        if (sobjectInstance != null && String.isNotBlank(fieldName)) {
        
            String fieldValueString;
            
            //Getting the value of the field from sobjectInstance
            Object fieldValueObject = sobjectInstance.get(fieldName);
            
            if (fieldValueObject != null) {
            
                fieldValueString = String.valueOf(fieldValueObject);
            }
            
            //Replacing the merge fields with the field values in input text body
            textBody = textBody.replaceAll('\\{' + replaceableFieldString + '\\}', fieldValueString);
        }
        return textBody;
    }
    
    public static Set<String> getFieldsFromTheTextBody(String textBodyWithMergeFields) {
    
        Set<String> fieldCollectionSet = new Set<String>();
        
        if (String.isNotBlank(textBodyWithMergeFields)) {
        
            do {
            
                String fieldString = textBodyWithMergeFields.subStringBetween('{', '}');
                
                if (String.isNotBlank(fieldString)) {
                
                    fieldCollectionSet.add(fieldString);
                    textBodyWithMergeFields = textBodyWithMergeFields.remove('{' + fieldString + '}');
                    
                } else {
                
                    break;
                }
            } while(String.isNotBlank(textBodyWithMergeFields.subStringBetween('{', '}')));
            system.debug('fieldCollectionSet-->'+fieldCollectionSet); 
        }
        return fieldCollectionSet;
    }
}