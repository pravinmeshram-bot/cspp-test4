global class Attorney_GetUserListBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts{
    
    global Batch_Data__c UserBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        UserBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_GetUserListBatch'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
            async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
                asyncLimitUsed = async.getValue();
        }
        if(UserBatchData.Last_Execution_Time__c == null || UserBatchData.Last_Execution_Time__c.day() != System.now().day()){
            UserBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        return Database.getQueryLocator([Select Id from LeadTracCredentials__c Limit 1]);
    }
    
    global void execute(Database.BatchableContext BC, List<LeadTracCredentials__c> taskTypeList){
        
        List<NDS_User_List__c> userList = new List <NDS_User_List__c> ();
        if (!Test.isRunningTest())
            userList = Attorney_GetUserListBatchHandler.getUserList();
        else{
            NDS_User_List__c usr = new NDS_User_List__c();
            usr.Email__c = 'test@test.com';
            usr.First_Name__c = 'first test';
            usr.Last_Name__c = 'last test';
            usr.User_Id__c = 'test001';
            usr.User_Name__c = 'test@test.com';
            userList.add(usr);
        }
        
        Schema.SObjectField f = NDS_User_List__c.Fields.User_Id__c;
        system.debug('###userLst::'+userList.size());
        Database.UpsertResult [] cr = Database.upsert(userList, f, false);
        for(Database.UpsertResult saveRec: Cr){
            if(!saveRec.isSuccess()){
                for(Database.Error err : saveRec.getErrors())
                    
                    system.debug('###error::'+err);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions'); 
            if(async.getValue() != null)
                UserBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf( UserBatchData.Number_of_Callouts__c) + async.getValue() - asyncLimitUsed);
            else
                UserBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf( UserBatchData.Number_of_Callouts__c) + asyncLimitUsed);
        } else {
            Upsert UserBatchData;
        }
        UserBatchData.Last_Execution_Time__c = System.now();
        UserBatchData.Batch_Execution_Status__c = 'Success';
        
        Update UserBatchData;
    }
}