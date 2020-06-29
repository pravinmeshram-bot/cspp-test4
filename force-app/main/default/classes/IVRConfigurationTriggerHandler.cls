public class IVRConfigurationTriggerHandler {
    
    
    public static void validate(List<IVR_Configuration__c> ivrConfigList)
    {
        string status = null;
        
        for(IVR_Configuration__c config:ivrConfigList)
        {
            status = validateSourceColumnName(config.Technical_Definition__c);
            
            if(status == 'Success')
            {
                status = validateTargetColumnName('IVR_Scoring__c',config.IVR_Scoring_Table_Field__c);
                
                if(status == 'Success')
                {
                    try
                    {
                        Database.query(config.Technical_Definition__c + ' Limit 0');
                    }
                    catch(Exception ex)
                    {
                        if(!ex.getMessage().contains('Non-selective query against large object type (more than 200000 rows)'))
                        {
                            config.addError('Technical Definition Query Invalid: ' + ex.getMessage());
                        }
                    }
                }
                else
                {
                    config.addError(status);
                }
            }
            else
            {
                config.addError(status);
            }  
        }
    }
    
    public static string validateSourceColumnName(string technicalQuery)
    {
        Pattern regexPattern = Pattern.compile('(?is)SELECT (.*?)(?<!\\w"") FROM (?!\\w*?"")(.*?)( WHERE |$)(.*?)( GROUP BY |$)');
        Matcher regexMatcher = regexPattern.matcher(technicalQuery);
        
        if(regexMatcher.find()) {
            string fieldName = regexMatcher.group(1);
            
            if(fieldName.contains(',') || fieldName.contains('(') || fieldName.contains(' '))
                return 'Technical Definition Query: Only one column permitted in the select statement (Ex: Select \'target_program_api\' from sobject) ';
        }
        return 'Success';
    }
    
    public static string validateTargetColumnName(String sObjectType,string fieldName)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        if(fieldMap.containsKey(fieldName.ToLowerCase()))
        {
            Schema.DescribeFieldResult desribeResult = fieldMap.get(fieldName.ToLowerCase()).getDescribe();
            if(desribeResult.isUpdateable() && desribeResult.isCustom() && desribeResult.getType() ==  Schema.DisplayType.DOUBLE)
                return 'Success';
            else
                return 'IVR Scoring Table Field: Field exist in the IVR_Scoring__c object but data type is not number';
        }
        else
        {
            return 'IVR Scoring Table Field: ' + fieldName + ' not found in the IVR_Scoring__c object';
        }
    }
    
}