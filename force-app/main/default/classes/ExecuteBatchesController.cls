public class ExecuteBatchesController {
    
    public Boolean isChecked { get; set; }
    public List<batchClassListWrapper> batchClassList { get; set; }
    public List<String> batchClassNameList = new List<String>{'BatchSyncTaskbasedOnGroupTask', 'BatchSyncGroupTaskbasedOnTask', 
                                                              'BatchCreateChildTaskForGroupTask', 'BatchDeleteAttorneyTasksAndRetrigger',
                                                              'Attorney_GetTaskTypesBatch','Attorney_CalculateFuturePaymentBatch',
                                                              'Attorney_GetUserListBatch','Attorney_CreateOrUpdateNDSTradeBatch',
                                                              'Attorney_ProgramFeeTemplateUpdateBatch','Attorney_getFileNumberBatch',
                                                              'Batch_ExecutePaymentFlows', 'Batch_CreateNSFTaskFailedPayment'};
    public List<String> batchClassNameWithParamList = new List<String>{'BatchDeleteAttorneyTasksAndRetrigger'};
    
    public ExecuteBatchesController(){
        
        this.batchClassList = new List<batchClassListWrapper>();
        if (batchClassNameList.isEmpty() == False) {
            System.debug(batchCLassNameList);
            for (ApexClass apexClassInstance : [SELECT Name,CreatedDate FROM ApexClass WHERE Name IN :batchClassNameList]) {
                System.debug(apexClassInstance);
                batchClassListWrapper batchClass = new batchClassListWrapper();
                batchClass.className = apexClassInstance.Name;
                if (batchClassNameWithParamList.Contains(apexClassInstance.Name)) {
                    batchClass.isTriggerFlow = false;
                }
                batchClassList.add(batchClass);
            }
        }
    }
    
    public void gobalSelect(){
        
        for (batchClassListWrapper batchClass : batchClassList) {
            
            batchClass.isChecked = isChecked;
        }            
    }
    
    public void batchExection(){
        
        String actionToExecute = ApexPages.currentPage().getParameters().get('actionToExecute');
        
        if (String.isNotBlank(actionToExecute)) {
            
            List<batchClassListWrapper> batchToExecuteList = new List<batchClassListWrapper>();
            Set<String> batchNameSet = new Set<String>();
            
            for (batchClassListWrapper batchClass : batchClassList) {
                
                if (batchClass.isChecked == True) {
                    
                    batchToExecuteList.add(batchClass);
                    batchNameSet.add(batchClass.className);
                    batchClass.isChecked = false;
                    //batchClass.isTriggerFlow = false;
                    //batchClass.batchExecutionSize = 200;
                }
            }
            this.isChecked = false;

            if (batchNameSet.isEmpty() == False) {
                
                Map<String, AsyncApexJob> AsyncApexJobMap = new Map<String, AsyncApexJob>();
                for (AsyncApexJob AsyncApex : [SELECT Id, Status, ApexClass.Name 
                                               FROM AsyncApexJob 
                                               WHERE  ApexClass.Name IN :batchNameSet AND status IN ('Queued','Preparing','Processing') LIMIT 1 ]) {
                                                   
                    AsyncApexJobMap.put(AsyncApex.ApexClass.Name, AsyncApex);
                }
                if (batchToExecuteList.isEmpty() == False) {
                    
                    Map<String, String> pageMessageMap  = new Map<String, String>{'SUCCESS'=>'', 'ERROR'=>''};
                        for (batchClassListWrapper batchClass : batchToExecuteList) {
                            
                            if (AsyncApexJobMap.isEmpty() || ( AsyncApexJobMap.isEmpty() == False && AsyncApexJobMap.ContainsKey(batchClass.className) == False )) {
                                
                                if (actionToExecute == 'startExecution') {
                                    
                                    Database.executeBatch((batchClass.className == 'BatchDeleteAttorneyTasksAndRetrigger'? new BatchDeleteAttorneyTasksAndRetrigger(batchClass.isTriggerFlow) : (Database.Batchable<sObject>)createInstance(batchClass.className)), batchClass.batchExecutionSize);
                                    pageMessageMap.put('SUCCESS', pageMessageMap.get('SUCCESS')+', '+batchClass.className );
                                } else {
                                    
                                    pageMessageMap.put('ERROR', pageMessageMap.get('ERROR')+', '+batchClass.className);
                                }
                            } else {
                            
                                if (actionToExecute == 'startExecution') {
                                    
                                    pageMessageMap.put('ERROR', pageMessageMap.get('ERROR')+''+batchClass.className+' is Currently '+AsyncApexJobMap.get(batchClass.className).status+'.');
                                } else {
                                
                                    System.abortJob(AsyncApexJobMap.get(batchClass.className).Id);
                                    pageMessageMap.put('SUCCESS', pageMessageMap.get('SUCCESS')+', '+batchClass.className );
                                }
                            }
                        }
                    if (pageMessageMap.isEmpty() == False) {
                        
                        if (String.isNotBlank(pageMessageMap.get('SUCCESS'))) {
                            
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, pageMessageMap.get('SUCCESS').removeStart(', ')
                                                                            +(actionToExecute == 'startExecution' ? ' is Running Successfully' : ' is Aborted Successfully'));
                            ApexPages.addMessage(myMsg);
                        }
                        if (String.isNotBlank(pageMessageMap.get('ERROR'))) {
                            
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, (actionToExecute != 'startExecution' ? pageMessageMap.get('ERROR').removeStart(', ')
                                                                            +' is Currently not running .' : pageMessageMap.get('ERROR')));
                            ApexPages.addMessage(myMsg);
                        }
                    }
                } 
            } else {
                    
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Batch is selected.');
                ApexPages.addMessage(myMsg);
            }            
            
            for (batchClassListWrapper batchClass : batchClassList) {
                
                if (batchClass.isChecked == True) {
                    
                    batchClass.isTriggerFlow = false;
                }
            }
        }
    }
    
    public Object createInstance(String className) {
        
        Type typ = Type.forName(className);
        Object instance = null;
        if (typ != null) {
            if('Attorney_getFileNumberBatch'.equalsIgnoreCase(ClassName)){
                NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
                if(!Test.isRunningTest()){
                DateTime startTime = timings.LastSuccessfulRun__c.addHours(-7);
                DateTime endTime = system.now().addHours(-7);
                if(timings.APIDuration__c != NULL)
                    endTime = startTime.addMinutes(Integer.ValueOf(timings.APIDuration__c));
                instance = new Attorney_GetFileNumberBatch(startTime,endTime);
                } else {
                    instance = new Attorney_GetFileNumberBatch(System.now(),System.now());
                    
                }
            }
            else{
                instance = typ.newInstance();
            }
        }
        if (instance == null) {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                                            'Couldn\'t successfully instantiate an object for class ' + className 
                                                            + '. Please check if Class name is correct, is compilable and current user has access.');
            ApexPages.addMessage(myMsg);
        }
        return instance;
    }
    
    public class batchClassListWrapper {
        
        public Boolean isChecked { get; set; }
        public String className { get; set; }
        public Integer batchExecutionSize { get; set; }
        public Boolean isTriggerFlow { get; set; }
        
        public batchClassListWrapper () {
            
            this.isChecked = False;
            this.batchExecutionSize = 200;
        }
    }
}