public without sharing class Attorney_StaticVariableUtility {
    
    //commom
    public static final Datetime DEFAULTDATETIME = DateTime.newInstanceGmt(1753, 1, 1,0,0,0);
    public static final string INTEGRATION_INITIATED = 'Initiated';
    public static final string INTEGRATION_SUCCESS = 'Success';
    public static final string INTEGRATION_FAILED = 'Failed';
    public static final string INTEGRATION_OVERFLOW = 'Overflow';
    
    public static final string INTERNAL_ERROR_PREFIX = 'Message: ';
    public static final string INTERNAL_STACK_TRACE = 'Stack Trace: ';
    public static LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('NDSPushCredentials');
    public static Boolean apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()].attorney_admin__c;
    public static Boolean VelocifyAdmin = [select id, velocify_admin__c from user where id =: userinfo.getuserid()].velocify_admin__c;
    
    public static List<Batch_Data__c> BatchDataList = [Select Id,Name, Number_of_Callouts__c, Last_Execution_Time__c,Number_of_records_processed__c from Batch_Data__c where isAsyncMethod__c = true]; 
    
    public static Batch_Data__c getAsyncMethodData(String methodName){
        Map<String,Batch_Data__c> BatchDataMap = new Map<String, Batch_Data__c>();
        for(Batch_Data__c bd: BatchDataList){
            BatchDataMap.put(bd.Name,bd);
        }
        return BatchDataMap.get(methodName); 
    } 
    
    public static user currentUser = [select Id, velocify_admin__c, attorney_ignore_validation__c, attorney_admin__c, overwrite_latest_offer__c from user where id=:userInfo.getUserId()];
    
//    public static Id PaymentsQueueId = [];
    
    public static string ModifyGTOwner = 'mayur.techup@gmail.com';
 
    public static NextBatchJobTimings__c nextJobTimings = NextBatchJobTimings__c.getValues(UserInfo.getProfileId());
    
    //Payment object
    public static final Id draftRecordId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeID();
    public static final Id settlementRecordId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeID();
    public static Boolean isPaymentTriggerExecuted = false;  //Recursive Flag
    public static Integer paymentBatchSize = 99;//Note: Must not be more than 100
    //public static Boolean isNotesPushed = false;
    public Static Boolean groupTasksCreatedforPrizm = false;
    
    //Offer Object
     public static Boolean isOfferTriggerExecuted = false; //Recursive Flag
    
    //GroupTask Object
     public static Boolean isGrpTaskTriggerExecuted = false;//Recursive Flag
    
     //Task Object
     public static Boolean isTaskTriggerExecuted = false;//Recursive Flag
    
     //Workflow Object
     public static Boolean isWorkflowTriggerExecuted = false;//Recursive Flag
    
    public static Boolean isClientTriggerExecuted = false;
    
    public static Boolean isProgramTriggerExecuted = false;
    
    
    public Static boolean isFieldUpdated = false;
    public Static boolean isRelatedOffersUpdated = false;
    
    public Static boolean isTaskBeforeExecuted = false;
        
    //Used in Task and Group Task
    public static Datetime dateToUTC(Date dt)
    {
       Datetime GMTDate = Datetime.newInstanceGmt(
                            dt.year(),
                            dt.month(),
                            dt.day());

        return GMTDate;                                        
    }
    
    //Fee Item object
    public static final Id SettlementFeeRecordId = Schema.SObjectType.nu_dse__Fee_Item__c.getRecordTypeInfosByName().get('Settlement Fee').getRecordTypeID();
    public static final Id ThirdpartyFeeRecordId = Schema.SObjectType.nu_dse__Fee_Item__c.getRecordTypeInfosByName().get('Thirdparty Fee').getRecordTypeID();
    
    //Trade Line
    public static final string DEFAULTCREDITORID = '00000000-0000-0000-0000-000000000000';
    public static Boolean isTradeLineTriggerExecuted = false;  //Recursive Flag

    
     //Common Method
    public static set<string> reProcessConfigs(string ObjName,Boolean isBatch)
    {
        Set<String> reProcessErrorMessage = new Set<String>();
        for(LeadTracReprocessConfig__mdt config:[Select Object_Name__c,Error_Message_To_Reprocess__c from 
                                                 LeadTracReprocessConfig__mdt where Object_Name__r.DeveloperName =: ObjName])
        {
            if(isBatch == true)
                reProcessErrorMessage.add('%' + config.Error_Message_To_Reprocess__c + '%');
            else 
                reProcessErrorMessage.add(config.Error_Message_To_Reprocess__c);
        }
        
        return reProcessErrorMessage;
    }
    
    //Common Method
    public static Boolean reProcessRecordCheck(set<string> reProcessErrorMessage,string IntegrationReason)
    {
        Boolean reProcess = false;
        for(string error:reProcessErrorMessage)
        {
            if(IntegrationReason!= null && IntegrationReason.contains(error))
            {
                reProcess=true;
                break;
            }
        }
        return reProcess;
        
    }
    
    //CommonMethod
    public static Decimal convertToDecimal(string inputValue)
    {
        Decimal decimalValue;
        
        if(string.isBlank(inputValue))
            inputValue = '0';
        
        try{
            if(!string.isBlank(inputValue) && inputvalue.contains('%'))
            {
            string interim = inputValue.replace('%','');
            decimalValue = Decimal.valueOf(interim);
            }
            else
            {      
            decimalValue = Decimal.valueOf(inputValue);
            }
        }
        catch(TypeException e){
            decimalValue = 0; 
        }
        
        return decimalValue;
    }
    

   
     
}