public class Attorney_CreateOrUpdateNDSWrkFlowHandler {
    
    public static void CreateOrUpdateNDSWrkFlow(List<Workflow__c> ObjWorkflowList, Map<Id,Workflow__c> ObjWorkflowOldMap){
        List<Workflow__c> updateWorkflowList = new List<Workflow__c>();
        Boolean IsInsert = false;
        
        if(ObjWorkflowOldMap == Null)
            IsInsert = true;
        else
            IsInsert = false; 
        
        
        for(Workflow__c ObjWorkflow: ObjWorkflowList){
            
            if(ObjWorkflow.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false)
            {      
                if((IsInsert == false && ObjWorkflow.IsRelatedRecordEligibleForPick__c==true &&
                   ObjWorkflow.Workflow_Status__c != ObjWorkflowOldMap.get(ObjWorkflow.Id).Workflow_Status__c) || 
                    (IsInsert == true && ObjWorkflow.IsRelatedRecordEligibleForPick__c==true))
                {
                    //if (System.isBatch() == False) {
                        
                        System.enqueueJob(new AsynCallToNDSWorkflow(ObjWorkflow.Id));
                    //}
                    
                    //Sync Update - Integration Status to Initiated
                    Workflow__c objWorkflowUpd = new Workflow__c(Id=ObjWorkflow.Id);
                    setIntegrationFields(objWorkflowUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null);
                    updateWorkflowList.add(objWorkflowUpd);
                }
            }
        }
        
        update updateWorkflowList;
    }
    
    public static void setIntegrationFields(Workflow__c ObjWorkflow,string IntegrationStatus,string IntegrationReason)
    {
        string Reason1 = null;
        string Reason2 = null;
        
        if(string.isNotBlank(IntegrationReason))
        {
            if(IntegrationReason.length() <= 250)
            {
                Reason1 = IntegrationReason.subString(0,IntegrationReason.length());
            }
            else if(IntegrationReason.length() > 250)
            {
                Reason1 = IntegrationReason.subString(0,250);
                
                if(IntegrationReason.length() > 500)
                    Reason2 = IntegrationReason.subString(250,500);
                else
                    Reason2 = IntegrationReason.subString(250,IntegrationReason.length());
            }     
        }
        
        
        ObjWorkflow.Integration_Status__c = IntegrationStatus;
        ObjWorkflow.Integration_Reason__c = Reason1;
        ObjWorkflow.Integration_Reason_2__c = Reason2;
    }
    
    public class AsynCallToNDSWorkflow implements Queueable,Database.AllowsCallouts {
        
        Id WorkflowId;
        public AsynCallToNDSWorkflow(Id cWorkflowId)
        {
            this.WorkflowId = cWorkflowId;
        }
        
        public void execute(QueueableContext context) {
            
            Workflow__c ObjWorkflow = [Select Id,Workflow_Status__c,Name,Program__r.Import_ID__c from Workflow__c where id=:WorkflowId];
            
            try
            {    
                LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
                LeadtracNetClient.ArrayOfStatusItem arrayOfStatusItem = new LeadtracNetClient.ArrayOfStatusItem();
                Long statusId = 0;
                
                if(Test.isRunningTest() == False) {
                    
                    arrayOfStatusItem = soap.GetStatusList(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c);
                    
                } else{       
                    
                    arrayOfStatusItem.StatusItem = new List<LeadtracNetClient.StatusItem>();        
                    LeadtracNetClient.StatusItem statusItem = new LeadtracNetClient.StatusItem();       
                    statusItem.Name = 'New File';       
                    statusItem.WorkflowName = 'Primary';        
                    statusItem.WorkflowId = '1234';     
                    statusItem.StatusId = long.valueOf('123');      
                    arrayOfStatusItem.StatusItem.add(StatusItem);       
                }
                
                if(arrayOfStatusItem != null && arrayOfStatusItem.StatusItem != null)
                {
                    for(LeadtracNetClient.StatusItem item:arrayOfStatusItem.StatusItem){
                        
                        if(ObjWorkflow.Workflow_Status__c == item.Name && ObjWorkflow.Name == item.WorkflowName)
                        {
                            statusId = item.StatusId;
                            break;
                        }
                    }
                    
                    if(statusId != 0)
                    {
                        leadtracNetClient.ArrayOfString fileArray = new leadtracNetClient.ArrayOfString();
                        List<string> fileArrayList = new List<string>();
                        
                        fileArrayList.add(string.valueof(ObjWorkflow.Program__r.Import_ID__c));
                        fileArray.string_x = fileArrayList;
                        
                        string result = soap.ChangeClientStatus(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                                Attorney_StaticVariableUtility.credentials.Password__c,fileArray,statusId);
                        
                        if(String.isNotBlank(result))
                        {
                            setIntegrationFields(ObjWorkflow,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                        }
                        else
                        {
                            setIntegrationFields(ObjWorkflow,Attorney_StaticVariableUtility.INTEGRATION_FAILED,'Error Updating the workflow status ' + ObjWorkflow.Workflow_Status__c);
                        }
                    }
                    else
                    {
                        setIntegrationFields(ObjWorkflow,Attorney_StaticVariableUtility.INTEGRATION_FAILED,'StatusId not found for the workflow status ' + ObjWorkflow.Workflow_Status__c);
                    }
                    
                } 
            }
            catch(Exception e)
            {
                setIntegrationFields(ObjWorkflow,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                system.debug('****'+e.getStackTraceString());
            }
            
            Attorney_StaticVariableUtility.isWorkflowTriggerExecuted = true;
            update ObjWorkflow;  
        }
        
    }
}