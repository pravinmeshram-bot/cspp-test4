public class Batch_ExecutePaymentFlows implements Database.Batchable<sObject> {
    
     public Database.QueryLocator start(Database.BatchableContext BC) {
         
         Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
         
         Boolean closeTaskIfMakeUpPaymentCreated = processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c;
         Boolean programStatusReactivateFees = processBuilderInst.Program_Status_Reactivate_Fees__c;
         Boolean entered = False;
         String query = '';
         System.debug('1-->'+closeTaskIfMakeUpPaymentCreated);
         System.debug('2-->'+programStatusReactivateFees);
         Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
         try {
         
             query = 'SELECT Id FROM nu_dse__Payment__c WHERE ';
             
             if (closeTaskIfMakeUpPaymentCreated  == True) {
                 
                 query += ' (Active_NSF_Tasks_Available__c = True AND nu_dse__Is_Makeup_Payment_Created__c = True AND nu_dse__Dont_Consider__c = True ) OR ';
                 entered = True;
                 System.debug('1-->'+query);
             }
             
             if (programStatusReactivateFees == True) {
                 
                 Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
                 
                 query += ' (RecordTypeId = :feeRecordTypeId AND nu_dse__Transaction_Status__c = \'Cancelled\' AND ' 
                         + 'nu_dse__Advance_Payment__r.nu_dse__Transaction_Status__c= \'Scheduled\' AND ' 
                         + 'nu_dse__Advance_Payment__r.RecordType.DeveloperName = \'Draft\')';
                 entered = True;
                 System.debug('2-->'+query);
             }
             
             if (entered) {
                 
                 query = query.removeEnd('OR ');
                 System.debug('3-->'+query);
                 return Database.getQueryLocator(query);
             
             } else {
                 
                 query = 'SELECT Id FROM nu_dse__Payment__c LIMIT 0';
                 return Database.getQueryLocator(query);
             }
         }catch(Exception e) {
         
             nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchToExecutePaymentFlows.start', nu_dse__User_Context__c = UserInfo.getUserId(),nu_dse__Message__c = e.getMessage());
             insert errorLog;
             query = 'SELECT Id FROM nu_dse__Payment__c LIMIT 0';
             return Database.getQueryLocator(query);

         }
     }
     
     public void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> paymentScopeList) {
         
         List<nu_dse__Payment__c> paymentList = [SELECT Id, Active_NSF_Tasks_Available__c, nu_dse__Transaction_Status__c, nu_dse__Is_Makeup_Payment_Created__c , 
                                                   RecordType.DeveloperName, NSF_Date__c, nu_dse__Dont_Consider__c, nu_dse__Program__c, 
                                                   RecordTypeId, LastModifiedBy.Attorney_Admin__c, nu_dse__Advance_Payment__r.RecordType.DeveloperName, 
                                                   nu_dse__Advance_Payment__r.nu_dse__Transaction_Status__c, LastModifiedDate
                                                   FROM nu_dse__Payment__c WHERE Id IN :paymentScopeList];
         
         Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
         Boolean CloseTaskIfMakeUpPaymentCreated = processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c;
         Boolean ProgramStatusReactivateFees = processBuilderInst.Program_Status_Reactivate_Fees__c;
         
         Set<Id> paymentIdWithNSFTaskClosedSet = new Set<Id>();
         
         Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
         List<nu_dse__Payment__c> paymentUpdateList = new List<nu_dse__Payment__c> ();
         
         try {
             
             for (nu_dse__Payment__c paymentInst : paymentList ) {
                 
                 Boolean entered = False;
                 nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c();
                 paymentInstance.Id = paymentInst.Id;
                 
                 if (CloseTaskIfMakeUpPaymentCreated && paymentInst.nu_dse__Is_Makeup_Payment_Created__c == True && 
                     paymentInst.nu_dse__Dont_Consider__c == True && paymentInst.Active_NSF_Tasks_Available__c == True) {
                     
                     entered = True;
                     paymentInstance.Active_NSF_Tasks_Available__c = False;
                     paymentIdWithNSFTaskClosedSet.add(paymentInst.Id);
                 }
                 
                 if (ProgramStatusReactivateFees && paymentInst.RecordTypeId == feeRecordTypeId && 
                     paymentInst.nu_dse__Transaction_Status__c  == 'Cancelled' && 
                     paymentInst.nu_dse__Advance_Payment__r.nu_dse__Transaction_Status__c  == 'Scheduled' && 
                     paymentInst.nu_dse__Advance_Payment__r.RecordType.DeveloperName == 'Draft') {
                     
                     entered = True;
                     paymentInstance.nu_dse__Transaction_Status__c = 'Scheduled';
                 }
                 
                 if (entered) {
                     
                     paymentUpdateList.add(paymentInstance);
                 }
             }
             
             if (paymentIdWithNSFTaskClosedSet.isEmpty() == False) {
        
                List<Task> taskList = [SELECT Id, Status FROM TASK WHERE WHATId IN :paymentIdWithNSFTaskClosedSet AND Status != 'Completed'];
                
                if (taskList.isEmpty() == False) {
                    
                    for (Task taskInst : taskList) {
                        
                        taskInst.Status = 'Completed';
                    }
                    update taskList;
                }
            }
            
            //For transaction status update and task completed field update.
            update paymentUpdateList;
            
        } catch(Exception e) {
         
            nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchToExecutePaymentFlows.execute', nu_dse__User_Context__c = UserInfo.getUserId(),nu_dse__Message__c = e.getMessage());
            insert errorLog;
        }
    }
     
    public void finish(Database.BatchableContext BC) {
         
    }
}