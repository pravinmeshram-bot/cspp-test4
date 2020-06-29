public class IVRScoreRollupCalculationBatchHandler {
    
    private Map<Id,IVR_Configuration__c> IVRConfigMap = new Map<Id,IVR_Configuration__c>();
    private Map<Id,IVR_Scoring__c> IVREntriesMap = new Map<Id,IVR_Scoring__c>();
    private Map<Id,nu_dse__Program__c> programMap = new Map<Id,nu_dse__Program__c>();
    private Set<Id> incomingProgramSet = new set<Id>();
    private Map<string,Schema.DescribeFieldResult> labelToAPIMap = new Map<string,Schema.DescribeFieldResult>();
    
    private set<Id> processedSet = new set<Id>();
    
    public IVRScoreRollupCalculationBatchHandler(Set<Id> incomingProgramSet){
        IVRConfigMap = new Map<Id,IVR_Configuration__c>([Select Id,Point_Value__c,Technical_Definition__c,Name,IVR_Scoring_Table_Field__c from IVR_Configuration__c where is_Active__c=true]);
        this.incomingProgramSet = incomingProgramSet;
        programMap = new Map<Id,nu_dse__Program__c>([Select Id,Name from nu_dse__Program__c where id=:incomingProgramSet]);
        System.debug('++++++++++ incomingProgramSet' + incomingProgramSet);
    }
    
    public void setupIVREntries()
    {
        for(IVR_Scoring__c ivrRecord: [Select Id,Program_Name__c,Program_Name__r.Name,Name from IVR_Scoring__c where Program_Name__c in: incomingProgramSet])
            IVREntriesMap.put(ivrRecord.Program_Name__c,ivrRecord);
        
        System.debug('++++++++++ IVREntriesMap 1' + IVREntriesMap);
        
        getSobjectDescribe('IVR_Scoring__c');
        
        for(string incomingProgram:incomingProgramSet)
        {
            if(!IVREntriesMap.containsKey(incomingProgram))
            { 
                IVR_Scoring__c IVRScoring = new IVR_Scoring__c();
                IVRScoring.Program_Name__c = incomingProgram;
                IVRScoring.Name = programMap.get(incomingProgram).Name +'__score';        
                resetFieldsForRollupCalculation(IVRScoring);
                IVREntriesMap.put(incomingProgram,IVRScoring);
            }
            else
            {
                IVR_Scoring__c IVRScoring = IVREntriesMap.get(incomingProgram);
                resetFieldsForRollupCalculation(IVRScoring);
                IVREntriesMap.put(incomingProgram,IVRScoring);
            }
        } 
    }
    
    public static ReformedQueryWithColumnName reformQueryWithBatchFiler(string technicalQuery)
    {
        ReformedQueryWithColumnName response = new ReformedQueryWithColumnName();
        
        Pattern regexPattern = Pattern.compile('(?is)SELECT (.*?)(?<!\\w"") FROM (?!\\w*?"")(.*?)( WHERE |$)(.*?)( GROUP BY |$)');
        Matcher regexMatcher = regexPattern.matcher(technicalQuery);
        
        if(regexMatcher.find()) {
            string[] groupMatched = regexMatcher.group(0).split(';');
            string fieldName = regexMatcher.group(1);
            string sobjectName = regexMatcher.group(2);
            string whereCondition =  regexMatcher.group(3);
            string groupByCondtion = regexMatcher.group(4);
            
            if(string.isBlank(whereCondition))
                response.reformedQuery = technicalQuery + ' where ' +fieldName + '=:incomingProgramSet ';
            else if(string.isNotBlank(whereCondition))
                response.reformedQuery = technicalQuery.replace(' where ',' where ' +fieldName + '=:incomingProgramSet and ');  
            
            response.uniqueFieldName = fieldName;
        }
        
        return response;
    }
    
    public void rollupCalculation()
    {
        setupIVREntries();

        for(IVR_Configuration__c ivrConfig:IVRConfigMap.values())
        {
            ReformedQueryWithColumnName response = reformQueryWithBatchFiler(ivrConfig.Technical_Definition__c);
            
            System.debug('++++++++++ querySF' + string.valueOf(response.reformedQuery));
            
            for(Sobject s:Database.query(response.reformedQuery))
            {
                string currentProgramID = string.valueOf(s.get(response.uniqueFieldName));
                
                System.debug('++++++++++ currentProgramID' + string.valueOf(response.reformedQuery));
                
                IVR_Scoring__c IVRScoring = IVREntriesMap.get(currentProgramID);
                
                if(!processedSet.contains(currentProgramID))
                {
                    if(string.isBlank(IVRScoring.Program_Name__c))
                        IVRScoring.Program_Name__c = string.valueOf(s.get(response.uniqueFieldName));
                    
                     if(string.isBlank(IVRScoring.Name))
                        IVRScoring.Name = programMap.get(currentProgramID).Name +'__score';        
                }
                                              
                IVRScoring.put(ivrConfig.IVR_Scoring_Table_Field__c,ivrConfig.Point_Value__c);
                IVREntriesMap.put(currentProgramID,IVRScoring);
                processedSet.add(currentProgramID);
                
                 System.debug('++++++++++ IVRScoring Final' + string.valueOf(IVRScoring));
                     
            }
        }
        
        upsert IVREntriesMap.values();
    }
    
    public void resetFieldsForRollupCalculation(IVR_Scoring__c IVRScoring)
    {
        System.debug('++++++++++ IVRScoring Entry' + string.valueOf(IVRScoring));
        
        for(string key:labelToAPIMap.Keyset())
        {
            Schema.DescribeFieldResult desribeResult = labelToAPIMap.get(key);
            
            if(desribeResult.isUpdateable() && desribeResult.isCustom() && desribeResult.getType() ==  Schema.DisplayType.DOUBLE)
                IVRScoring.put(desribeResult.name,0);
        }
        
        System.debug('++++++++++ IVRScoring Exit' + string.valueOf(IVRScoring));
    }
    
    public void getSobjectDescribe(String sObjectType)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult desribeResult = fieldMap.get(fieldName).getDescribe();
            labelToAPIMap.put(fieldMap.get(fieldName).getDescribe().getLabel().ToUpperCase(),desribeResult);   
        }
        
        System.debug('++++++++++ labelToAPIMap' + string.valueOf(labelToAPIMap));
    }
    
    public class ReformedQueryWithColumnName{
        public string reformedQuery;
        public string uniqueFieldName;
    }
    
}