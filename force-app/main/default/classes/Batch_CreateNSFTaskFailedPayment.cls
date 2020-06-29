public class Batch_CreateNSFTaskFailedPayment implements Database.Batchable<sObject>, database.stateful {
        
    public Set<Id> programIds = new Set<Id>();
    public Set<Id> NSFProgramIds = new Set<Id>();
    public Date draftSchedulingDate;
    public Boolean returnProgramCount = False;
    
    public Batch_Data__c NSFTaskPaymentBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    public Batch_CreateNSFTaskFailedPayment() {
    }

    public Batch_CreateNSFTaskFailedPayment(Set<Id> paramIds) {
        
        programIds = paramIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
         
        NSFTaskPaymentBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Batch_CreateNSFTaskFailedPayment'];
        System.OrgLimit async;
        
        if(Test.isRunningTest()){
            
            asyncLimitUsed = 0;  
              
        } else {
          
            async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            
            if(async.getValue() != null) {
                
                asyncLimitUsed = async.getValue();
            }
        }
        
        if(NSFTaskPaymentBatchData.Last_Execution_Time__c == null || NSFTaskPaymentBatchData.Last_Execution_Time__c.day() != System.now().day()){
            
            NSFTaskPaymentBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        Boolean entered = False;
        Set<String> programStatusInSet = new Set<String>{'Active Client'};
        
        if (draftSchedulingDate == null) {

            String scheduledDateString = Label.Draft_payment_starting_scheduled_date;
            System.debug('scheduledDateString-->'+scheduledDateString);
            draftSchedulingDate = Date.parse(scheduledDateString);
        }
        String query = 'SELECT Id FROM nu_dse__Program__c ';
        
        if (programIds != null && programIds.isEmpty() == false) {
            
            query += ' WHERE Id IN :programIds AND nu_dse__Program_Status__c IN :programStatusInSet AND nu_dse__Consecutive_NSF_Payments__c > 0';
        
        } else {
            
            query += ' WHERE nu_dse__Program_Status__c IN :programStatusInSet AND nu_dse__Consecutive_NSF_Payments__c > 0';
        }
         
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programScopeList) {
        
        Date today = System.today();
        Map<Id, nu_dse__Program__c> programLastFailedPaymentMap = new Map<Id, nu_dse__Program__c> ();
        List<nu_dse__Payment__c> paymentUpdateList = new List<nu_dse__Payment__c> ();
        List<Task> taskList = new List<Task>();
        Map<String, Id> taskCommTempIds = new Map<String, Id> ();
        Map<String, Id> taskOwnerIdMap = new Map<String, Id> ();
        Map<Id, Date> programIdScheduleDate = new Map<Id, Date> ();
        
        System.debug('programScopeList--->' + programScopeList);
        
        for (Task_Communication_Template__mdt CommTempCMDT : [SELECT Id, Label, DeveloperName, Communication_Template_Id__c FROM Task_Communication_Template__mdt]) {
              
            taskCommTempIds.put(CommTempCMDT.Label, CommTempCMDT.Communication_Template_Id__c);
            System.debug('taskCommTempIds----> '+ taskCommTempIds);
        }
        
        for (Task_Owner_Id_Mapping__mdt taskOwnerIdInst : [SELECT Id, Label, Owner_Id__c FROM Task_Owner_Id_Mapping__mdt]) {
            
            taskOwnerIdMap.put(taskOwnerIdInst.Label, taskOwnerIdInst.Owner_Id__c);
        }
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Payment__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Id recordTypeId = recordTypeMap.get('Draft').getRecordTypeId();
        
        System.debug('**recordTypeId'+recordTypeId);
        
        List<AggregateResult> programAndItsScheduleAggList = [SELECT nu_dse__Program__c, Max(nu_dse__Schedule_Date__c) scheduleDate
                                                                FROM nu_dse__Payment__c 
                                                                WHERE nu_dse__Program__c IN :programScopeList AND RecordTypeId = :recordTypeId 
                                                                AND nu_dse__Transaction_Status__c IN ('Completed', 'Cleared', 'Failed')
                                                                AND nu_dse__Schedule_Date__c >= :draftSchedulingDate
                                                                AND nu_dse__Schedule_Date__c <= :today
                                                                Group By nu_dse__Program__c];
        Set<String> programAndItsScheduleDateSet = new Set<String>();
        
        for (AggregateResult aggResult :programAndItsScheduleAggList) {
            
            Date scheduledDate = (Date)aggResult.get('scheduleDate');
            
            String scheduledYear = String.valueOf(scheduledDate.Year());
            String scheduledMonth = (scheduledDate.Month() > 9) ? String.valueOf(scheduledDate.Month()) : '0' + String.valueOf(scheduledDate.Month());
            String scheduledDay = (scheduledDate.Day() > 9) ? String.valueOf(scheduledDate.Day()) : '0' + String.valueOf(scheduledDate.Day());
            
            String programId_ScheduleDateString = (Id)(aggResult.get('nu_dse__Program__c')) + '-' + scheduledYear + '-'  + scheduledMonth + '-' + scheduledDay;
            programAndItsScheduleDateSet.add(programId_ScheduleDateString);
        }
        
        System.debug('programAndItsScheduleAggList-->'+programAndItsScheduleAggList);
        System.debug('programAndItsScheduleDateSet-->'+programAndItsScheduleDateSet);
        
        if (programAndItsScheduleDateSet.isEmpty() == False) {
            
            for (nu_dse__Payment__c paymentInstance : [SELECT Id, nu_dse__Is_Makeup_Payment_Created__c, nu_dse__Transaction_Status__c, nu_dse__Program__c,
                                                        NSF_Date__c, nu_dse__Schedule_Date__c, Active_NSF_Tasks_Available__c, Processed_In_NSF_Batch__c 
                                                        FROM nu_dse__Payment__c 
                                                        WHERE nu_dse__Program__c IN :programScopeList AND RecordTypeId = :recordTypeId AND nu_dse__Schedule_Date__c <= :today AND
                                                        ProgramId_And_Schedule_Date__c IN :programAndItsScheduleDateSet AND
                                                        (nu_dse__Transaction_Status__c = 'Failed' OR nu_dse__Transaction_Status__c = 'Cleared' OR nu_dse__Transaction_Status__c = 'Completed') 
                                                        ORDER By nu_dse__Schedule_Date__c DESC]) {
                
                System.debug('paymentInstance-->'+paymentInstance);
                
                nu_dse__Payment__c paymentInst = new nu_dse__Payment__c();
                paymentInst.Id = paymentInstance.Id;
                
                if ((programIdScheduleDate.containsKey(paymentInstance.nu_dse__Program__c) == False 
                        || programIdScheduleDate.get(paymentInstance.nu_dse__Program__c) == paymentInstance.nu_dse__Schedule_Date__c)
                    && paymentInstance.nu_dse__Is_Makeup_Payment_Created__c == False && paymentInstance.nu_dse__Transaction_Status__c == 'Failed'
                    && paymentInstance.Processed_In_NSF_Batch__c == False) {
                    
                    System.debug('paymentInstance*in-->'+paymentInstance);
                    
                    if (programLastFailedPaymentMap.containsKey(paymentInstance.nu_dse__Program__c) == False) { 
                       
                        NSFProgramIds.add(paymentInstance.nu_dse__Program__c);
                        
                        if (returnProgramCount == False) {
                            
                            nu_dse__Program__c programInstance = new nu_dse__Program__c();
                            programInstance.Id = paymentInstance.nu_dse__Program__c;
                            programInstance.Last_Failed_Payment_ID__c = paymentInstance.Id;
                            programInstance.nu_dse__Program_Status__c = 'NSF';
                            
                            programLastFailedPaymentMap.put(programInstance.Id, programInstance);
                        }
                    }
                    
                    if (returnProgramCount == False) {
                        
                        taskList.addAll(FlowLogicsForBatchClass.createTasks(paymentInstance, taskCommTempIds, taskOwnerIdMap ));
                        paymentInst.Active_NSF_Tasks_Available__c = true;
                        paymentInst.Processed_In_NSF_Batch__c = true;
                        paymentUpdateList.add(paymentInst);
                    }
                }
                
                if (programIdScheduleDate.containsKey(paymentInstance.nu_dse__Program__c) == False) {
                    
                    programIdScheduleDate.put(paymentInstance.nu_dse__Program__c, paymentInstance.nu_dse__Schedule_Date__c);
                }
            }
        }
        
        System.debug('taskList-->'+taskList);
        
        if (returnProgramCount == False) {
            
            //inserting new communication tasksunder payments...
            insert taskList;
            
            //updating program to NSF...
            update programLastFailedPaymentMap.values();
            
            //updating payment that it have active NSF tasks...
            update paymentUpdateList;
        }
        
    }
     
    public void finish(Database.BatchableContext BC) {
        
        System.debug('NSFProgramIds'+NSFProgramIds);
        
        if (NSFProgramIds != null && NSFProgramIds.isEmpty() == False && returnProgramCount == False) {
            
            List<Id> programIdList = new List<Id>();
            programIdList.addAll(NSFProgramIds);
            
            Attorney_cancelPaymentsBatch bat = new Attorney_cancelPaymentsBatch(programIdList);
            Database.executeBatch(bat,Integer.valueOf(Label.Cancel_Payments_Batch_Size));
        
        }
        
        if (returnProgramCount == True) {
            
            nu_dse__Processor_Sync_Info__c processorSyncInfo = new nu_dse__Processor_Sync_Info__c();
            processorSyncInfo.nu_dse__From_Date__c = draftSchedulingDate;
            processorSyncInfo.nu_dse__To_Date__c = System.today();
            processorSyncInfo.nu_dse__SObject_Name__c = 'Program';
            processorSyncInfo.nu_dse__Returned_Records_Count__c = NSFProgramIds.size();
            processorSyncInfo.nu_dse__Api_call_Name__c = 'Batch_CreateNSFTaskFailedPayment';
            processorSyncInfo.nu_dse__Processor_Name__c = 'Batch_CreateNSFTaskFailedPayment';
            processorSyncInfo.nu_dse__Comments__c = 'Contains Program count which have recent Failed draft payment betweent the specified date.'
                                                       + 'Its Program status will be updated to NSF once we run our batch class';
            
            insert processorSyncInfo;
            
            if (NSFProgramIds.size() < 8001 && NSFProgramIds.size() > 0) {
                
                List<nu_dse__Processor_Sync_Data__c> processorSyncDataList = new List<nu_dse__Processor_Sync_Data__c> ();
                
                for (Id ProgramId : NSFProgramIds) {

                    nu_dse__Processor_Sync_Data__c processorSyncData = new nu_dse__Processor_Sync_Data__c();
                    processorSyncData.nu_dse__Processor_Sync_Info__c = processorSyncInfo.Id;
                    processorSyncData.nu_dse__Program_Id__c = ProgramId;
                    
                    processorSyncDataList.add(processorSyncData);
                }
                
                insert processorSyncDataList;
            }
        }
        
        if(!Test.isRunningTest()){
            
            System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        
            if(async.getValue() != null) {
                
                NSFTaskPaymentBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(NSFTaskPaymentBatchData.Number_of_Callouts__c) + async.getValue() - asyncLimitUsed);
            
            } else {
                
                NSFTaskPaymentBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(NSFTaskPaymentBatchData.Number_of_Callouts__c)+asyncLimitUsed);
            }
        }
        
        NSFTaskPaymentBatchData.Last_Execution_Time__c = System.now();
        NSFTaskPaymentBatchData.Batch_Execution_Status__c = 'Success';
        Update NSFTaskPaymentBatchData;
       
    }
}