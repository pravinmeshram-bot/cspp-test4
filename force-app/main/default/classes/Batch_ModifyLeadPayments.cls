/* Date : 21-12-2017
 * Description : Batch class to send payments to Service360
 */

public class Batch_ModifyLeadPayments implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext BC) {
    
        String queryString = 'SELECT Id, Record_Id__c FROM Records_To_Process__c WHERE Record_Id__c != null '
                           + 'AND Integration_Type__c IN (\'Velocify\') AND Status__c IN (\'Pending\',\'Error\') order by createdDate asc';
    
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Records_To_Process__c> recordToProcessList) {
        
        try {
            
            Id paymentId = Id.valueOf(recordToProcessList[0].Record_Id__c);
            
            String response = PaymentHandler.modifyLeadsPayments2(new List<Id>{paymentId});
            System.debug('*** response ' + response);
            ServiceLeads360.ResponseWrapper responseWrapperInstance = (ServiceLeads360.ResponseWrapper)JSON.deserialize(response, ServiceLeads360.ResponseWrapper.class);
            
            Records_To_Process__c recordToDML = new Records_To_Process__c(Id = recordToProcessList[0].Id);
            
            if(responseWrapperInstance.statusCode == '200') {
                
                delete recordToDML;
            } else {
                
                recordToDML.Error_Message__c = responseWrapperInstance.statusMessage;
                recordToDML.Status__c = 'Error';
                
                update recordToDML;
            }
        } catch(Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_ModifyLeadPayments', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = UserInfo.getName());
            insert errorLog;
            
        }
    }
    
    public void finish(Database.BatchableContext BC) {    
    
    }
}