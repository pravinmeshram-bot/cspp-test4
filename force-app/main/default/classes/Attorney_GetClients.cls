public class Attorney_GetClients{
    
    
    //Added by Rajesh
    Static List<User> userList = [Select Id,name from User];
    Static List<Group> queueList = [Select Id,name from Group where type='Queue'];
    
    public static Map<String,LeadTracProgramType__mdt> getLeadtrackProgramLst(){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst = [Select Id,RAMS__c,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type'];    
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt programType : leadtrckProgramTypeLst ){
            LeadTracProgramTypeMap.put(programType.Label,programType);
        }
        return LeadTracProgramTypeMap;
    }
    
    public Static List<Payment_Status_Mapping__mdt> PaymentStatusMappingList = [Select Id, MasterLabel, DeveloperName, Transaction_Status__c from Payment_Status_Mapping__mdt];
 /*   public static String PaymentStatusMapping(String PaymentStatus){
        //Map<String,Payment_Status_Mapping__mdt> PaymentStatusMapping = new Map<String,Payment_Status_Mapping__mdt>();
        if(PaymentStatus == null || PaymentStatus == '' || PaymentStatus == 'None')
        {
            return null;
        }
        
        for(Payment_Status_Mapping__mdt psm : Attorney_GetClients.PaymentStatusMappingList){
            //PaymentStatusMapping.put(psm.MasterLabel, psm);
            if(PaymentStatus.equalsIgnoreCase(psm.MasterLabel)){
                return psm.Transaction_Status__c;
            }
        }
        return PaymentStatus;
    }*/
    
    
    Public static String getUserIdByName(String UserName){
        /*List<User> usrLst = [Select Id,name FROM User where Name =: UserName];
String UserId; 
if(!usrLst.isEmpty())
UserId = usrLst[0].Id;
else
UserId = '';
//0051F000000kzDs
return UserId;*/
        
        //Added by Rajesh
        For(user u:userList){
            if(u.name == userName)
                return u.id;
        }
        return '';
    }
    public static String getQueueByName(String queueName){
        /*system.debug('###queueName::'+queueName);
String str = queueName.trim();
List<Group> queueLst = [Select Id,Name from Group where Name LIKE :('%' + str + '%') and Type = 'Queue'];
//List<QueueSobject> queueLst = [select id,QueueId from QueueSobject where Queue.Name =: str];
//system.debug('###query::'+[Select Id,Name from Group where Name LIKE :('%' + queueName + '%') and Type = 'Queue']);
system.debug('###queueLst::'+queueLst);
String queueId;
if(!queueLst.isEmpty())
queueId = queueLst[0].Id;
else
queueId = '';
system.debug('###queueId::'+queueId);
return queueId;*/ 
        
        //Added by Rajesh
        for(Group g : queueList){
            if(g.name.containsIgnoreCase(queueName.trim()))
                return g.id;
        }
        return '';
    }
    
    public static Date ConvertSalesforceValidDateFormat(String inputDate){
        system.debug('###inputDate::'+inputDate);
        String[] cd1;
        if(inputDate.contains('/')){
            cd1 = inputDate.split('/');
        //else if(inputDate.contains('-'))
           // cd1 = inputDate.split('-'); 
           Date dt;
           if(cd1[2].length() == 2){
                dt = Date.newInstance(Integer.ValueOf(cd1[2])+1900,Integer.ValueOf(cd1[0]),Integer.ValueOf(cd1[1]));        
           }  
           else if(cd1[2].length() == 4)
                dt = Date.newInstance(Integer.ValueOf(cd1[2]),Integer.ValueOf(cd1[0]),Integer.ValueOf(cd1[1])); 
        return dt;   
        }
        
        return Date.newInstance(1900,1,1); 
    }
    
    public static String checkEmail(String inputEmail){
        if(inputEmail == null || inputEmail == '')
            return null;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(inputEmail);
        if(MyMatcher.matches()){
            return inputEmail;
        }
        return 'invalid@email.com';
    }    

    public static leadtracNetClient.ArrayOfString resp;
    public static leadtracNetClient.GetTaskResult taskRes;
    public static leadtracNetClient.ArrayOfClient cilent;
    public static leadtracNetServicing.ModifiedDraftPlanResult draftPlanRes;
    public static leadtracNetServicing.ArrayOfGetActiveDraftPlanResult planResltArray;
    
    public static void fetchDraftPayments(DateTime StartTime, DateTime EndTime, String sysLogId, List<String> draftFileNumbersLst){
        /***************Getting LeadTrac credentials and Endpoint URL from custom settings************************/
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        leadtracNetServicing.ServicingSoap soap= new leadtracNetServicing.ServicingSoap();
        leadtracNetServicing.ArrayOfString fileArr1 = new leadtracNetServicing.ArrayOfString();
        
        NextBatchJobTimings__c nextBatchTimings = NextBatchJobTimings__c.getInstance();
        
        fileArr1.string_x = draftFileNumbersLst;
        if (!Test.isRunningTest())
            planResltArray = soap.GetActiveDraftPlans(credentials.UserName__c,credentials.Password__c,fileArr1);
        /*******************************************Draft Payment Creation Process *****************************************/
        leadtracNetServicing.DraftPlan draftPlan;
        List<nu_dse__Payment__c> paymentUpsrtLst = new List<nu_dse__Payment__c>();
        nu_dse__Payment__c payment;
        leadtracNetServicing.ArrayOfSplit splitArray;
        Set<String> paymentSet = new Set<String>();
        
        //Bypass Payment status
        List<String> AttorneyPaymentIds = new List<String>();
        
        List<nu_dse__Program__c> progLst = [select id,import_id__c from nu_dse__Program__c where import_id__c IN: draftFileNumbersLst];
        Map<String,nu_dse__Program__c> fileProgMap = new Map<String,nu_dse__Program__c>();
        for(nu_dse__Program__c prog: progLst)
            fileProgMap.put(prog.import_Id__c,prog);  
        system.debug('###fileMap::'+fileProgMap);
        
        nu_dse__Program__c programToUpd = new nu_dse__Program__c  ();
        List<nu_dse__Program__c> programToUpdLst = new List<nu_dse__Program__c>();
        leadtracNetServicing.ArrayOfPayment paymentsArray;
        system.debug('###planResltArray::'+planResltArray);
        Id paymentRecordTypeId = SystemUtils.getRecordTypeID('nu_dse__Payment__c','Draft');
        leadtracNetServicing.ArrayOfResultMessage messageArray;
        List<leadtracNetServicing.ResultMessage> resMesLst;
        List<String> messages;
        if(planResltArray.GetActiveDraftPlanResult != NULL)
        
            //Bypass Payment status
            for(leadtracNetServicing.GetActiveDraftPlanResult activeDraftPalnRes: planResltArray.GetActiveDraftPlanResult){
                draftPlan = new leadtracNetServicing.DraftPlan();
                draftPlan = activeDraftPalnRes.DraftPlan;
                paymentsArray = draftPlan.Payments;
                for(leadtracNetServicing.Payment pay: paymentsArray.Payment){
                    AttorneyPaymentIds.add(String.ValueOf(pay.PaymentId));
                }
            }
            
            List<nu_dse__Payment__c> PaymentList = [Select Id,Attorney_Payment_Id__c,Payment_Status__c from nu_dse__Payment__c where Attorney_Payment_Id__c=:AttorneyPaymentIds];
            Map<String,nu_dse__Payment__c> AttorneyPaymentMap = new Map<String,nu_dse__Payment__c>();
            for(nu_dse__Payment__c P: PaymentList){
                AttorneyPaymentMap.put(p.Attorney_Payment_Id__c,p);
            }
            //End Bypass Payment status
            
            for(leadtracNetServicing.GetActiveDraftPlanResult activeDraftPalnRes: planResltArray.GetActiveDraftPlanResult){
                
                draftPlan = new leadtracNetServicing.DraftPlan();
                draftPlan = activeDraftPalnRes.DraftPlan;
                messageArray = activeDraftPalnRes.Messages;
                resMesLst = new List<leadtracNetServicing.ResultMessage>();
                if(messageArray.ResultMessage != NULL)
                resMesLst.addAll(messageArray.ResultMessage);
                messages = new List<String>();
                for(leadtracNetServicing.ResultMessage resMess: resMesLst){
                    if(String.isNotBlank(resMess.MessageType) && String.isNotBlank(resMess.Message))
                        messages.add(resMess.Message);
                }
                if (!Test.isRunningTest ()){
                    if(messages.isEmpty())
                    if(fileProgMap.containsKey(draftPlan.FileNumber) ){
                        programToUpd = fileProgMap.get(draftPlan.FileNumber);
                        programToUpd.Draft_Plan_ID__c = String.ValueOf(draftPlan.PlanId);
                        programToUpd.Draft_Plan_Status__c = draftPlan.Status;
                        programToUpd.Draft_Plan_Suspended_On__c = draftPlan.SuspendedOn;
                        programToUpd.Draft_Plan_Completed_On__c = draftPlan.CompletedOn;
                        programToUpd.Draft_Plan_Activated_On__c = draftPlan.ActivatedOn;
                        programToUpdLst.add(programToUpd);
                    }
                    
                }
                paymentsArray = new  leadtracNetServicing.ArrayOfPayment();
                
                if(messages.isEmpty()){
                paymentsArray = draftPlan.Payments;
                for(leadtracNetServicing.Payment pay: paymentsArray.Payment){
                    payment = new nu_dse__Payment__c();
                    //payment.nu_dse__Program__c = programToUpd.Id;
                    payment.Attorney_Payment_Id__c = String.ValueOf(pay.PaymentId);
                    
                 //   payment.External_Id__c = String.ValueOf(pay.PaymentId);
                 //   payment.nu_dse__External_GCS_ID__c= String.ValueOf(pay.PaymentId);
                    payment.FileNumber__c = draftPlan.FileNumber;
                    payment.Draft_Plan_Id__c = String.ValueOf(draftPlan.PlanId);
                //    payment.nu_dse__Payment_Sequence_Number__c = pay.Number_x;
                    payment.nds_Payment_Type__c = pay.PaymentType;
                    payment.Payment_Type_Data__c = pay.PaymentTypeData;
                    //paymentRec.nu_dse__Payment_Type__c = pay.PaymentType;
                    payment.Status_Reason__c = pay.StatusReason;
                    payment.Statused_On__c = pay.StatusedOn;
                    payment.nu_dse__Schedule_Date__c = Date.ValueOf(pay.DueOn);
               //     payment.nu_dse__Amount__c = pay.Amount;
                    payment.recordtypeid = paymentRecordTypeId;
                    //String PaymentStatus= Attorney_GetClients.PaymentStatusMapping(pay.Status);
                    //payment.nu_dse__Transaction_Status__c = Attorney_GetClients.PaymentStatusMapping(pay.Status);
         /*           payment.Payment_Status__c = pay.Status.trim();
                    System.debug('****Uchit Payment Status'+ payment.Payment_Status__c);
                    if(payment.Payment_Status__c == '')
                        payment.Payment_Status__c = null;*/
                    if(!AttorneyPaymentMap.containsKey(payment.Attorney_Payment_Id__c) || AttorneyPaymentMap.get(payment.Attorney_Payment_Id__c).Payment_Status__c == null)
                        payment.Payment_Status__c = pay.Status;
//Royal Development Jira 349
                    payment.Last_Modified_By_NDS__c = system.now();
                    payment.Attorney__c = True;
                    //Split Amount Loading into Payments
                    splitArray = new leadtracNetServicing.ArrayOfSplit(); 
                    splitArray = pay.Splits;
                    paymentSet.add(String.ValueOf(pay.PaymentId));
                    Map<String,Decimal> amountMap = new Map<String,Decimal>();
                    
                    //Admin fee Development Jira 113
                    
                    
                    if(splitArray.Split != NULL)
                        for(leadtracNetServicing.Split split: splitArray.Split){
                            if(Split.Amount > 0 || Split.Amount < 0 )
                            amountMap.put(split.Name,Split.Amount);
                        }
                        system.debug('###amountMap::'+amountMap);
                        if(amountMap.size() == 1 && amountMap.containsKey('Draft')){
                            payment.nu_dse__Amount__c = amountMap.get('Draft');  
                            payment.nu_dse__Processor_Fee__c = null;
                            payment.nu_dse__Service_Fee__c = null;
                            payment.nu_dse__Retainer_Fee__c = null;
                            //Changes for Admin Fee Jira 113
                            
                              payment.nu_dse__Admin_Fee__c = null;
                       //     payment.nu_dse__Monthly_Maintenance_Fee__c = null;
                       
                       //End of Admin Fee Changes
                            payment.nu_dse__Type__c =  'ADHOC';
                        }else{
                            system.debug('###enterelse::');
                            payment.Draft_Split__c = null;
                            payment.nu_dse__Processor_Fee__c = null;
                            payment.nu_dse__Service_Fee__c = null;
                            payment.nu_dse__Retainer_Fee__c = null;
                            
                                  //Changes for Admin Fee Jira 113
                            
                              payment.nu_dse__Admin_Fee__c = null;
                       //     payment.nu_dse__Monthly_Maintenance_Fee__c = null;
                       
                       //End of Admin Fee Changes

                            //for(leadtracNetServicing.Split split: splitArray.Split){
                            //if(split.Name == 'Draft')
                          //      payment.Draft_Split__c = split.Amount;    
                            if(amountMap.containskey('Trust') && amountMap.get('Trust') != null)
                                payment.nu_dse__Processor_Fee__c = amountMap.get('Trust').setScale(2);
                            if(amountMap.containskey('Reserve') && amountMap.get('Reserve') != null)
                                payment.nu_dse__Amount__c = amountMap.get('Reserve').setScale(2);
                            if(amountMap.containskey('Service') && amountMap.get('Service') != null)
                                payment.nu_dse__Service_Fee__c = amountMap.get('Service').setScale(2);
                            if(amountMap.containskey('Retainer') && amountMap.get('Retainer') != null)
                                payment.nu_dse__Retainer_Fee__c = amountMap.get('Retainer').setScale(2);
                                
                                //Commented for Admin fee Development Jira 113
                            if(amountMap.containskey('Legal'))
                                if(amountMap.get('Legal') != null)
                                    payment.nu_dse__Admin_Fee__c = amountMap.get('Legal').setScale(2);
                                
                                
                                if(amountMap.containskey('Monthly') && amountMap.get('Monthly')!= null)
                                payment.nu_dse__Processor_Fee__c = amountMap.get('Monthly').setScale(2);
                                if(amountMap.containskey('Savings') && amountMap.get('Savings')!= null)
                                payment.nu_dse__Amount__c = amountMap.get('Savings').setScale(2);
                                
                                //Admin fee Development Jira 113
                                
                              if(amountMap.containskey('Legal1') && amountMap.get('Legal1') != null && amountMap.get('Legal1') != 0){
                                  payment.nu_dse__Admin_Fee__c = amountMap.get('Legal1').setScale(2);
                                  payment.nu_dse__Fee_Item_Category__c = 'Type I';
                              } else if(amountMap.containskey('Legal2') && amountMap.get('Legal2') != null && amountMap.get('Legal2') != 0){
                                  payment.nu_dse__Admin_Fee__c = amountMap.get('Legal2').setScale(2);
                                  payment.nu_dse__Fee_Item_Category__c = 'Type II';
                              }  else if(amountMap.containskey('Legal3') && amountMap.get('Legal3') != null && amountMap.get('Legal3') != 0){
                                  payment.nu_dse__Admin_Fee__c = amountMap.get('Legal3').setScale(2);
                                  payment.nu_dse__Fee_Item_Category__c = 'Type III';
                              }   
                              
                              //End of Admin fee Development Jira 113
                              
                           // }  
                        }
                     system.debug('###Payment::'+payment);
                    paymentUpsrtLst.add(payment);           
                    
                }   
                } 
            }
        
        /***********************Program Update*********************************/
        system.debug('###programToUpdLst::'+programToUpdLst);
        if(!programToUpdLst.isEmpty() && !Test.isRunningTest () && nextBatchTimings.Load_Draft_Payments__c == True){
            Update programToUpdLst;
        }
        system.debug('###programToUpdLst::'+programToUpdLst);
        /******************************added to get Program Id***********************************/
        for(nu_dse__Payment__c pay: paymentUpsrtLst){
            system.debug('###externalId::'+pay.FileNumber__c);
            if(fileProgMap.containsKey(pay.FileNumber__c))
                pay.nu_dse__Program__c = fileProgMap.get(pay.FileNumber__c).Id;
        }
        if(!paymentUpsrtLst.isEmpty() && nextBatchTimings.Load_Draft_Payments__c == True){
            Schema.SObjectField f = nu_dse__Payment__c.Attorney_Payment_Id__c;
            Database.UpsertResult[] cr = Database.upsert(paymentUpsrtLst, f, false);
            system.debug('###cr::'+cr);
            String errorString = '';
            for(Database.UpsertResult saveRec: Cr){
                if(!saveRec.isSuccess()){
                    for(Database.Error err : saveRec.getErrors())
                        errorString += err;
                }
            }
            if(errorString != ''){
                CalloutException e = new CalloutException();
                e.setMessage(errorString);
                throw e;
            }
        }
    }
    public static void fetchClinets(DateTime StartTime, DateTime EndTime, String sysLogId, List<String> clientFileNumbersLst, Id batchJobId){
        //try{
            //Getting client date which are recently modified in NDS through callout
            
            /***************************************Initalization******************************************************/
            leadtracNetClient lead1 = new leadtracNetClient();
        
            leadtracNetClient.ClientServiceSoap soap1 = new leadtracNetClient.ClientServiceSoap();
            if (!Test.isRunningTest ()) {
                taskRes = new leadtracNetClient.GetTaskResult(); 
                resp = new leadtracNetClient.ArrayOfString();
                cilent = new leadtracNetClient.ArrayOfClient ();
                draftPlanRes = new leadtracNetServicing.ModifiedDraftPlanResult();
                planResltArray = new leadtracNetServicing.ArrayOfGetActiveDraftPlanResult();
            }
            
            
            /***************Getting LeadTrac credentials and Endpoint URL from custom settings************************/
            LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
            
            NextBatchJobTimings__c nextBatchTimings = NextBatchJobTimings__c.getInstance();
            
            leadtracNetClient.ArrayOfString resp = new leadtracNetClient.ArrayOfString();
            resp.string_x = clientFileNumbersLst;
            
            /****************************Task and GroupTask Creation Process***********************************/
            List<Group> defaultGrpLst = [Select Id,Name from Group where Name LIKE :('%' +  'SystemAdmin' + '%') and Type = 'Queue'];
            List<User> defaultUsrLst = [Select Id,Name FROM USER where UserName = 'integration_user@attorney.com' or username = 'bmalleichervu@stratfs.com.uat' or username = 'bmalleichervu@stratfs.com'];
            
            leadtracNetClient.ArrayOfTask taskArray = new leadtracNetClient.ArrayOfTask();
            List<Task> taskLst = new List<Task>();
            Task tasIns = new Task();
            List<nu_dse__Group_Task__c> groupTaskLst = new List<nu_dse__Group_Task__c>();
            nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c();
            
            //commented by Rajesh for NMI-557
        /*    if(!Test.isRunningTest())
                taskRes = soap1.GetTasks(credentials.UserName__c,credentials.Password__c,resp,StartTime.adddays(-6),EndTime.addhours(10));*/
                         //  taskRes = soap1.GetTasks(credentials.UserName__c,credentials.Password__c,resp);

            system.debug('###taskinclient::'+taskRes);
            if (taskRes.Tasks != NULL) {
                taskArray = taskRes.Tasks;
                if(taskArray.Task != NULL)
                    for(leadtracNetClient.Task tas: taskArray.Task){
                        System.Debug(tas);
                        leadtracNetClient.TaskType taskType = new leadtracNetClient.TaskType();
                        
                        taskType = tas.TaskType;
                        system.debug('###taskinclient::'+taskType);
                        
                        if(tas.AssignedAs == 'User'){
                            tasIns = new Task();
                            //     tasIns.Unique_Identifier__c = String.ValueOf(tas.TaskId);
                            tasIns.Task_id__c = String.ValueOf(tas.TaskId);
                            tasIns.ActivityDate = Date.ValueOf(tas.ScheduledOnUTC);
                            tasIns.Subject = tas.Subject;
                            tasIns.Description = tas.Description;
                            tasIns.Completed_Date__c = tas.CompletedOn;
                            tasIns.Priority = taskType.Priority;
                            tasIns.Category__c = taskType.Category;
                            tasIns.Subject__c = taskType.Name;
                            tasIns.Last_Modified_By_NDS__c = System.now();
                            if (!Test.isRunningTest ())
                                tasIns.FileNumber__c = tas.FileNumber;
                            String OnerId = getUserIdByName(tas.AssignedTo);
                            tasIns.UserName__c = tas.AssignedTo;
                     /*       if(OnerId != '')
                                tasIns.OwnerId = OnerId;
                            else {*/
                                if (defaultUsrLst.size () > 0) 
                                    tasIns.OwnerId = defaultUsrLst[0].Id;      
                        //    }
                            //tasIns.OwnerId = getUserIdByName(tas.AssignedTo);
                            //tasIns.subject_picklist__c = tas.TaskName;
                            tasIns.TaskTypeId__c = String.ValueOf(taskType.TaskTypeId);
                            taskLst.add(tasIns);
                        }
                        if(tas.AssignedAs == 'Group'){
                            groupTask = new nu_dse__Group_Task__c();
                            
                            groupTask.TaskTypeId__c = String.ValueOf(taskType.TaskTypeId);
                            groupTask.Priority__c = taskType.Priority;
                            groupTask.nu_dse__ActivityDate__c = Date.ValueOf(tas.ScheduledOnUTC);
                            //    groupTask.nu_dse__Unique_Identifier__c = String.ValueOf(tas.TaskId);
                            groupTask.Task_id__c = String.ValueOf(tas.TaskId);
                            groupTask.nu_dse__Subject__c = tas.Subject;
                            groupTask.nu_dse__Description__c = tas.Description;
                            groupTask.Completed_On__c = tas.CompletedOn;
                            groupTask.Subject_Picklist__c = taskType.Name;
                            groupTask.NDS_Assigned__c = tas.AssignedTo;
                                                        groupTask.UserName__c = tas.AssignedTo;

                            groupTask.Last_Modified_By_NDS__c = System.now();
                            //groupTask.Subject_Picklist__c = tas.TaskName;
                            if (!Test.isRunningTest ())
                                groupTask.FileNumber__c = tas.FileNumber;
                            String queueId = getQueueByName(tas.AssignedTo);
                            
                            if(queueId == '')
                           queueId = defaultGrpLst[0].id;
                       //     groupTask.OwnerId = queueId;
                            groupTaskLst.add(groupTask);
                        }
                    }
            }
            
            system.debug('###taskinclient::'+groupTaskLst);
            system.debug('###taskinclient::'+taskLst);
            
            /*****************************callout for geeting client and program updated data from NDS system***********************/
            leadtracNetClient.ArrayOfString fileArr = new leadtracNetClient.ArrayOfString();
            fileArr.string_x = clientFileNumbersLst;
            
            //leadtracNetClient.ClientServiceSoap soap = new leadtracNetClient.ClientServiceSoap();
            leadtracNetClient.ArrayOfString property = new leadtracNetClient.ArrayOfString();
            List<String> propertySet = new List<String>();
            
            /*****************************Property For Client************************************/
            propertySet.add('FirstName');
            propertySet.add('LastName');
            propertySet.add('Address1');
            propertySet.add('Address2');
            propertySet.add('CellNumber');
            propertySet.add('City');
            propertySet.add('EmailAddress');
            propertySet.add('HomeNumber');
            propertySet.add('Name1BestNumber');
            propertySet.add('Name2BestNumber');
            propertySet.add('State');
            propertySet.add('WorkNumber');
            propertySet.add('ZipCode');
            propertySet.add('Name1AKA');
            propertySet.add('Name2AKA');
            propertySet.add('AccountId');

            propertySet.add('Name2DOB');
            /*****************************Property For Personal Information************************************/
            propertySet.add('AddressLine1');
            propertySet.add('UserDefined');
            propertySet.add('Appartment#');
            propertySet.add('AuthEmail');
            propertySet.add('AuthName');
            propertySet.add('AuthPhone');
            propertySet.add('BestDay');
            propertySet.add('BestTime');
            propertySet.add('CorrespondencePreference');
            propertySet.add('DebtConsultant');
            propertySet.add('DoNotCall');
            propertySet.add('DoNotEmail');
            propertySet.add('DoNotSMS');
            propertySet.add('FaxNumber');
            propertySet.add('Name1DLNumber');
            propertySet.add('Name1DLState');
            propertySet.add('Name1DOB');
            propertySet.add('Name1Email');
            propertySet.add('Name1Employer');
            propertySet.add('Name1Occupation');
            propertySet.add('Name1SSN');
            propertySet.add('Name2AddressLine1');
            propertySet.add('Name2BestTime');
            propertySet.add('Name2CellNumber');
            propertySet.add('Name2DLNumber');
            propertySet.add('Name2DLState');
            propertySet.add('Name2Email');
            propertySet.add('Name2Employer');
            propertySet.add('Name2FaxNumber');
            propertySet.add('Name2First');
            propertySet.add('Name2Last');
            propertySet.add('Name2HomeNumber');
            propertySet.add('Name2Occupation');
            propertySet.add('Name2SSN');
            propertySet.add('Name2WorkNumber');
            propertySet.add('Name2ZipCode');
            propertySet.add('Name2City');
            propertySet.add('Name2State');
            propertySet.add('Prefix');
            propertySet.add('SalesEmail');
            propertySet.add('Name2SSN');
            propertySet.add('TimeZone');
            propertySet.add('LeadID');
            
            /*****************************Property For Program Quote************************************/
            propertySet.add('ESTSettlementAmt');
                        propertySet.add('PolicyGroup');

            propertySet.add('ProgramFeeAmt');
            propertySet.add('ProgramSavings');
            propertySet.add('RetainerFee');
            propertySet.add('RetainerFeeTotal');
                        propertySet.add('RetainerTerm');

            propertySet.add('TotalProgramCost');
            propertySet.add('TrustFeeMonthly');
            propertySet.add('TrustFeeMonthlyTotal');
            propertyset.add('AccountReviewEvent');
            
            /*****************************Property For Program Option************************************/
            
            propertySet.add('CancellationDate');
            propertySet.add('CancellationReason');
                        propertySet.add('EstSettlementPercent');
                        propertySet.add('LegalFeeMonthly');
                        propertySet.add('ProgramFeePercent');

            propertySet.add('CurrentDebtPayment');
            propertySet.add('EstimatedTotalDebt');
            propertySet.add('FirstDraftDate');
            propertySet.add('MaxProgramLength');
            propertySet.add('NSFDraftAmount');
            propertySet.add('NSFDraftDate');
            propertySet.add('NSFReason');
            propertySet.add('ProgramLength');
            propertySet.add('ProgramType');
            propertySet.add('RecurringDate');
            propertySet.add('RecurringDate2');
                        propertySet.add('Dependants');

            /*********************************Bank Account(Parent - Program) - Import_Id__c is external Id which stores file number***********************************/
            
            propertySet.add('AccountOwnerName');
            propertySet.add('AccountType');
            propertySet.add('BankAccountNumber');
            propertySet.add('BankCity');
            propertySet.add('BankName');
            propertySet.add('BankPhone');
            propertySet.add('BankRoutingNumber');
            propertySet.add('BankState');
            propertySet.add('BankZipCode');
            propertySet.add('BankStreetAddress');
            /**********************************Financial Profile(Parent - Program) - Import_Id__c is external Id which stores file number**********************************/
            
            propertySet.add('AutoInsuranceCost');
            propertySet.add('MortgageRentCost'); 
            propertySet.add('OtherIncomeAmount2'); 
            propertySet.add('DiscretionaryIncome'); //mayur
            propertySet.add('DiscretionaryPercentage'); //mayur
            propertySet.add('AutoLoanCost');
            propertySet.add('AutoOther');
            propertySet.add('BackTaxes');
            propertySet.add('CableSatelliteCost');
            propertySet.add('CharityCost');
            propertySet.add('ChildCareCost');
            propertySet.add('ClothingCost');
            propertySet.add('EducationCost');
            propertySet.add('EntertainmentCost');
            propertySet.add('FoodCost');
            propertySet.add('GymFees');
            propertySet.add('HomeRentInsuranceCost');
            propertySet.add('Homeowner');
            propertySet.add('HouseholdItemsCost');
            propertySet.add('LaundryCost');
            propertySet.add('LifeInsuranceCost');
            propertySet.add('MedicalCareCost');
            propertySet.add('Name1AnnualIncome');
            propertySet.add('Name1MonthlyIncome');
            propertySet.add('Name2AnnualIncome');
            propertySet.add('Name1SelfEmployed'); //mayur
            propertySet.add('Name2MonthlyIncome'); //mayur
            propertySet.add('Name2SelfEmployed'); //mayur
            propertySet.add('Other1Cost');
            propertySet.add('Other1Name');
            propertySet.add('OtherIncomeAmount'); //mayur
            propertySet.add('PersonalCare');
            propertySet.add('StudentLoans');
            propertySet.add('TelephoneCost');
            propertySet.add('UtilitiesCost');
            propertySet.add('Hardship');
            propertySet.add('HardshipReason');
            propertySet.add('AlternateNumber');
            propertyset.add('OtherIncomeReason2');
            propertyset.add('OtherIncomeReason');
            propertySet.add('TotalCostOfLiving'); //mayur
            propertySet.add('FiledBankruptcy'); //mayur
            propertyset.add('TotalIncome');
            propertyset.add('BankruptcyChapter');
            propertyset.add('BankruptcyYear');
            propertyset.add('CreditScore1');
            propertyset.add('EstimatedHomeValue');
            propertyset.add('MortgageBalance');
            
            property.string_x = propertySet;
            
            if (!Test.isRunningTest ())
                cilent = soap1.GetClients(credentials.UserName__c,credentials.Password__c,fileArr,property);
                            system.debug('###cilent::'+cilent);
            List<leadtracNetClient.client> clientLst = cilent.Client;
            Map<String,propertyClass> filemap = new Map<String,propertyClass>();
            List<Workflow__c> workFlowLst = new List<Workflow__c>();
            Workflow__c workFlow;
            leadtracNetClient.ArrayOfClientStatus currentArray = new leadtracNetClient.ArrayOfClientStatus();
            
            List<String> RAMSIds = new List<String>();
            if(cilent.Client != NULL) {
                for(leadtracNetClient.client cl: cilent.Client){
                    
                    //Program status changes
                    //String programStatus = '';
                    //String StatusDatetime = '';
                    
                    leadtracNetClient.ArrayOfClientProperty properties = new leadtracNetClient.ArrayOfClientProperty();
                    propertyClass propCls = new propertyClass();
                    
                    properties = cl.Properties;
                    currentArray = cl.CurrentStatus;
                    propCls.CampaignId = cl.CampaignId;
                    
                    for(leadtracNetClient.ClientStatus clientStat: currentArray.ClientStatus){
                        //system.debug('###clientStatus::'+clientStat);
                        workFlow = new Workflow__c();
                        workFlow.Name = clientStat.WorkflowName;
                        workFlow.Workflow_Status__c = clientStat.Name;
                        workFlow.NDS_External_ID__c = cl.FileNumber+'_'+clientStat.WorkflowName;
                        workFlow.Workflow_Status_Date__c = clientStat.UpdatedOn;
                        workFlow.FileNumber__c = cl.FileNumber;  
                        workFlow.Status_Id__c = String.ValueOf(clientStat.StatusId); 
                        workflow.Last_Modified_By_NDS__c = System.Now();
                        
                        if(workflow.Name.equalsIgnoreCase('Primary')){
                            propCls.StatusDateTime = workFlow.Workflow_Status_Date__c;
                            propCls.ProgramStatus = workFlow.Workflow_Status__c;
                        }
                        
                        workFlowLst.add(workFlow);
                    }
                    for(leadtracNetClient.ClientProperty prop: properties.ClientProperty){
                        //system.debug('###prop::'+prop);
                        
                        if(prop.Name == 'BankStreetAddress')
                            propCls.BankStreetAddress = prop.Value;
                        if(prop.Name == 'UserDefined')
                            propCls.UserDefined = prop.Value;
                        if(prop.Name == 'Name1AKA')
                            propCls.Name1AKA = prop.value;
                             if(prop.Name == 'Name2AKA')
                            propCls.Name2AKA = prop.value;
                            
                            if(prop.Name == 'AccountId')
                            propCls.AccountId = prop.value;
                            
                            
                             if(prop.Name == 'AuthEmail')
                            propCls.AuthEmail = prop.value;
                             if(prop.Name == 'AuthName')
                            propCls.AuthName = prop.value;
                             if(prop.Name == 'AuthPhone')
                            propCls.AuthPhone = prop.value;
                        if(prop.Name == 'AlternateNumber')
                            propcls.AlternateNumber = prop.Value;
                        if(prop.Name == 'Name2DOB')
                            propcls.Name2DOB = prop.value;
                        if(prop.Name == 'AccountReviewEvent')
                            propCls.AccountReviewEvent = prop.value;
                        if(prop.Name == 'LeadID')
                            propCls.LeadID = prop.value;
                        if(prop.Name == 'OtherIncomeReason2')
                            propCls.OtherIncomeReason2 = prop.value;
                        if(prop.Name == 'OtherIncomeReason')
                            propCls.OtherIncomeReason = prop.value;
                        if(prop.Name == 'TotalIncome')
                            propCls.TotalIncome = prop.value;
                        if(prop.Name == 'BankruptcyYear')
                            propcls.BankruptcyYear = prop.value;
                        if(prop.Name == 'BankruptcyChapter')
                            propCls.BankruptcyChapter = prop.value;
                        if(prop.Name == 'CreditScore1')
                            propCls.CreditScore1 = prop.value;
                        if(prop.Name == 'EstimatedHomeValue')
                            propCls.EstimatedHomeValue = prop.value;
                        if(prop.Name == 'FiledBankruptcy')
                            propcls.FiledBankruptcy = prop.value;
                            
                            if(prop.Name == 'MortgageRentCost')
                            propcls.MortgageRentCost = prop.value;
                        if(prop.Name == 'MortgageBalance')
                            propcls.MortgageBalance = prop.value;
                        if(prop.Name == 'FirstName')
                            propCls.firstName = prop.Value;
                        if(prop.Name == 'LastName')
                            propCls.lastName = prop.value;
                        if(prop.Name == 'Address1')
                            propCls.Address1 = prop.Value;
                        if(prop.Name == 'Address2')
                            propCls.Address2 = prop.value;
                        if(prop.Name == 'CellNumber')
                            propCls.CellNumber = prop.Value;
                        if(prop.Name == 'City')
                            propCls.City = prop.value;
                        if(prop.Name == 'Name2City')
                            propCls.Name2City = prop.value;
                        if(prop.Name == 'Name2State')
                            propCls.Name2State = prop.value;         
                        if(prop.Name == 'EmailAddress')
                            propCls.EmailAddress = prop.Value;
                        if(prop.Name == 'State')
                            propCls.State = prop.value;
                        if(prop.Name == 'WorkNumber')
                            propCls.WorkNumber = prop.Value;
                        if(prop.Name == 'ZipCode')
                            propCls.ZipCode = prop.value;
                        if(prop.Name == 'AddressLine1')
                            propCls.AddressLine1 = prop.Value;
                        if(prop.Name == 'Appartment')
                            propCls.Appartment = prop.value;
                        if(prop.Name == 'BestDay')
                            propCls.BestDay = prop.Value;
                        if(prop.Name == 'BestTime')
                            propCls.BestTime = prop.value;
                        if(prop.Name == 'CorrespondencePreference')
                            propCls.CorrespondencePreference = prop.Value;
                        if(prop.Name == 'DebtConsultant')
                            propCls.DebtConsultant = prop.value;
                        if(prop.Name == 'DoNotCall')
                            propCls.DoNotCall = prop.Value;
                        if(prop.Name == 'DoNotEmail')
                            propCls.DoNotEmail = prop.value;
                        if(prop.Name == 'DoNotSMS')
                            propCls.DoNotSMS = prop.Value;
                        if(prop.Name == 'FaxNumber')
                            propCls.FaxNumber = prop.value;
                        if(prop.Name == 'Name1DLNumber')
                            propCls.Name1DLNumber = prop.Value;
                        if(prop.Name == 'Name1DLState')
                            propCls.Name1DLState = prop.value;
                        if(prop.Name == 'Name1DOB')
                            propCls.Name1DOB = prop.Value;
                        if(prop.Name == 'Name1Email')
                            propCls.Name1Email = prop.value;
                        if(prop.Name == 'Name1Employer')
                            propCls.Name1Employer = prop.Value;
                        if(prop.Name == 'Name1Occupation')
                            propCls.Name1Occupation = prop.value;
                        if(prop.Name == 'Name1SSN')
                            propCls.Name1SSN = prop.Value;
                        if(prop.Name == 'Name2AddressLine1')
                            propCls.Name2AddressLine1 = prop.value;
                            
                              if(prop.Name == 'Dependants')
                            propCls.Dependants = prop.value;
                            
                            
                        if(prop.Name == 'Name2BestTime')
                            propCls.Name2BestTime = prop.Value;
                        if(prop.Name == 'Name2CellNumber')
                            propCls.Name2CellNumber = prop.value;
                        if(prop.Name == 'Name2DLNumber')
                            propCls.Name2DLNumber= prop.Value;
                        if(prop.Name == 'Name2DLState')
                            propCls.Name2DLState = prop.value;
                        if(prop.Name == 'Name2Email')
                            propCls.Name2Email = prop.Value;
                            if(prop.Name == 'RetainerTerm')
                            propCls.RetainerTerm = prop.Value;
                        if(prop.Name == 'Name2Employer')
                            propCls.Name2Employer = prop.value;
                        if(prop.Name == 'Name2FaxNumber')
                            propCls.Name2FaxNumber = prop.Value;
                        if(prop.Name == 'Name2First')
                            propCls.Name2First = prop.value;
                        if(prop.Name == 'Name2Last')
                            propCls.Name2Last = prop.Value;
                        if(prop.Name == 'Name2HomeNumber')
                            propCls.Name2HomeNumber = prop.value;
                             if(prop.Name == 'HomeNumber')
                            propCls.HomeNumber = prop.value;
                            
                            if(prop.Name == 'Name1BestNumber')
                            propCls.Name1BestNumber = prop.value;
                            
                            if(prop.Name == 'Name2BestNumber')
                            propCls.Name2BestNumber = prop.value;
                            
                        if(prop.Name == 'Name2Occupation')
                            propCls.Name2Occupation = prop.Value;
                        if(prop.Name == 'Name2SSN')
                            propCls.Name2SSN = prop.value;
                        if(prop.Name == 'Name2WorkNumber')
                            propCls.Name2WorkNumber = prop.Value;
                        if(prop.Name == 'Name2ZipCode')
                            propCls.Name2ZipCode = prop.value;
                        if(prop.Name == 'Prefix')
                            propCls.Prefix = prop.Value;
                        if(prop.Name == 'SalesEmail')
                            propCls.SalesEmail = prop.value;
                        if(prop.Name == 'Name2SSN')
                            propCls.Name2SSN = prop.Value;
                        if(prop.Name == 'TimeZone')
                            propCls.TimeZone = prop.value;
                        if(prop.Name == 'ESTSettlementAmt')
                            propCls.ESTSettlementAmt = prop.Value;
                            if(prop.Name == 'PolicyGroup')
                            propCls.PolicyGroup = prop.Value;
                        if(prop.Name == 'ProgramFeeAmt')
                            propCls.ProgramFeeAmt = prop.value;
                        if(prop.Name == 'ProgramSavings')
                            propCls.ProgramSavings = prop.Value;
                        if(prop.Name == 'RetainerFee')
                            propCls.RetainerFee = prop.value;
                        if(prop.Name == 'RetainerFeeTotal')
                            propCls.RetainerFeeTotal = prop.Value;
                        if(prop.Name == 'TotalProgramCost')
                            propCls.TotalProgramCost = prop.value;
                        if(prop.Name == 'TrustFeeMonthly')
                            propCls.TrustFeeMonthly = prop.Value;
                        if(prop.Name == 'TrustFeeMonthlyTotal')
                            propCls.TrustFeeMonthlyTotal = prop.value;
                        if(prop.Name == 'CancellationDate')
                            propCls.CancellationDate = prop.Value;
                        if(prop.Name == 'CancellationReason')
                            propCls.CancellationReason = prop.value;
                        if(prop.Name == 'CurrentDebtPayment')
                            propCls.CurrentDebtPayment = prop.Value;
                        if(prop.Name == 'EstimatedTotalDebt')
                            propCls.EstimatedTotalDebt = prop.value;
                        if(prop.Name == 'FirstDraftDate')
                            propCls.FirstDraftDate = prop.Value;
                        if(prop.Name == 'MaxProgramLength')
                            propCls.MaxProgramLength = prop.value;
                        if(prop.Name == 'NSFDraftAmount')
                            propCls.NSFDraftAmount = prop.Value;
                        if(prop.Name == 'NSFDraftDate')
                            propCls.NSFDraftDate = prop.value;
                        if(prop.Name == 'NSFReason')
                            propCls.NSFReason = prop.Value;
                        if(prop.Name == 'ProgramLength')
                            propCls.ProgramLength = prop.value;
                        if(prop.Name == 'ProgramType')
                            propCls.ProgramType = prop.value;
                        if(prop.Name == 'RecurringDate')
                            propCls.RecurringDate = prop.Value;
                        if(prop.Name == 'RecurringDate2')
                            propCls.RecurringDate2 = prop.value;
                        
                        /*******Bank Account*********************/
                        if(prop.Name == 'TelephoneCost')
                            propCls.TelephoneCost = prop.value;
                        if(prop.Name == 'AccountOwnerName')
                            propCls.AccountOwnerName = prop.value;
                        if(prop.Name == 'AccountType')
                            propCls.AccountType = prop.value;
                        if(prop.Name == 'BankAccountNumber')
                            propCls.BankAccountNumber = prop.value;
                        if(prop.Name == 'BankCity')
                            propCls.BankCity = prop.value;
                        if(prop.Name == 'BankName')
                            propCls.BankName = prop.value;
                        if(prop.Name == 'BankPhone')
                            propCls.BankPhone = prop.value;
                        if(prop.Name == 'BankRoutingNumber')
                            propCls.BankRoutingNumber = prop.value;
                        if(prop.Name == 'BankState')
                            propCls.BankState = prop.value; 
                        if(prop.Name == 'BankZipCode')
                            propCls.BankZipCode = prop.value;       
                             
                        
                        /*********Financial Profile**************/
                        if(prop.Name == 'Hardship')
                            propCls.HardShip = prop.Value;
                        if(prop.Name == 'HardshipReason')
                            propCls.HardshipReason = prop.value;
                        if(prop.Name == 'AutoInsuranceCost')
                            propCls.AutoInsuranceCost = prop.value;
                        if(prop.Name == 'AutoLoanCost')
                            propCls.AutoLoanCost = prop.value;
                        if(prop.Name == 'AutoOther')
                            propCls.AutoOther = prop.value;
                        if(prop.Name == 'BackTaxes')
                            propCls.BackTaxes = prop.value;
                        if(prop.Name == 'CableSatelliteCost')
                            propCls.CableSatelliteCost = prop.value;
                        if(prop.Name == 'CharityCost')
                            propCls.CharityCost = prop.value;
                        if(prop.Name == 'ChildCareCost')
                            propCls.ChildCareCost = prop.value;
                        if(prop.Name == 'ClothingCost')
                            propCls.ClothingCost = prop.value;  
                        if(prop.Name == 'EducationCost')
                            propCls.EducationCost = prop.value;                 
                        if(prop.Name == 'EntertainmentCost')
                            propCls.EntertainmentCost = prop.value;
                            
                            if(prop.Name == 'OtherIncomeAmount2')
                            propCls.OtherIncomeAmount2= prop.value;
                            
                        if(prop.Name == 'FoodCost')
                            propCls.FoodCost = prop.value;
                        if(prop.Name == 'GymFees')
                            propCls.GymFees = prop.value;
                        if(prop.Name == 'HomeRentInsuranceCost')
                            propCls.HomeRentInsuranceCost = prop.value;
                        if(prop.Name == 'Homeowner')
                            propCls.Homeowner = prop.value;
                        if(prop.Name == 'HouseholdItemsCost')
                            propCls.HouseholdItemsCost = prop.value;
                        if(prop.Name == 'LaundryCost')
                            propCls.LaundryCost = prop.value;
                        if(prop.Name == 'LifeInsuranceCost')
                            propCls.LifeInsuranceCost = prop.value; 
                        if(prop.Name == 'MedicalCareCost')
                            propCls.MedicalCareCost = prop.value;   
                        if(prop.Name == 'Name1AnnualIncome')
                            propCls.Name1AnnualIncome = prop.value;
                        if(prop.Name == 'Name1AnnualIncome')
                            propCls.Name1AnnualIncome = prop.value;
                        if(prop.Name == 'Name1MonthlyIncome')
                            propCls.Name1MonthlyIncome = prop.value;
                        if(prop.Name == 'Name2AnnualIncome')
                            propCls.Name2AnnualIncome = prop.value;
                        if(prop.Name == 'Other1Cost')
                            propCls.Other1Cost = prop.value;
                        if(prop.Name == 'Other1Name')
                            propCls.Other1Name = prop.value;
                        if(prop.Name == 'PersonalCare')
                            propCls.PersonalCare = prop.value;
                        if(prop.Name == 'StudentLoans')
                            propCls.StudentLoans = prop.value;  
                        if(prop.Name == 'TelephoneCost')
                            propCls.TelephoneCost = prop.value;     
                        if(prop.Name == 'UtilitiesCost')
                            propCls.UtilitiesCost = prop.value;   
                        if(prop.Name == 'EstSettlementPercent')
                            propCls.EstSettlementPercent = prop.value;
                        if(prop.Name == 'LegalFeeMonthly')
                            propCls.LegalFeeMonthly = prop.value;
                        if(prop.Name == 'ProgramFeePercent')
                            propCls.ProgramFeePercent = prop.value;                             
                        if(prop.Name == 'DiscretionaryIncome')
                            propCls.DiscretionaryIncome = prop.value;
                        if(prop.Name == 'DiscretionaryPercentage')
                            propCls.DiscretionaryPercentage = prop.value;
                        if(prop.Name == 'Name1SelfEmployed')
                            propCls.Name1SelfEmployed = prop.value;
                        if(prop.Name == 'Name2MonthlyIncome')
                            propCls.Name2MonthlyIncome = prop.value;
                        if(prop.Name == 'Name2SelfEmployed')
                            propCls.Name2SelfEmployed = prop.value;                            
                        if(prop.Name == 'OtherIncomeAmount')
                            propCls.OtherIncomeAmount = prop.value;
                        if(prop.Name == 'TotalCostOfLiving')
                            propCls.TotalCostOfLiving = prop.value;
                        
                    }
                    if(propcls.LastName != NULL && propcls.LastName != '')
                        filemap.put(cl.FileNumber,propCls);
                }
            }
            List<Account> accLst = new List<Account>();
            accLst = [select id,NDS_file_Number__c, PersonEmail from account where NDS_File_Number__c IN: filemap.keySet()];
            
            
            Map<String,Account> fileAccountMap = new Map<String,Account>();
            List<nu_dse__Program__c> programLst = new List<nu_dse__Program__c>();
            set<Id> accountIdSet = new Set<Id>();
            Map<Id,nu_dse__Program__c> accountProgramMap = new Map<Id,nu_dse__Program__c>();
            for(Account acc: accLst){
                fileAccountMap.put(acc.NDS_File_Number__c,acc);
                accountIdSet.add(acc.Id);
            }
            System.debug('***fileAccountMap'+fileAccountMap);
            System.debug('***AccountIdSet'+AccountIdset);
            
            Map<String,nu_dse__Program__c> programFileNumMap = new Map<String,nu_dse__Program__c>();
            programLst = [select id,Name,nu_dse__Account__c,Import_ID__c,Cancellation_Date__c,GCS_Policy_Group__c,nu_dse__Program_Status__c from nu_dse__Program__c where Import_ID__c IN: filemap.keySet() /*AND nu_dse__Account__c IN: accountIdSet*/];
            System.debug('programLst'+programLst);
            for(nu_dse__Program__c program: programLst){
                accountProgramMap.put(program.nu_dse__Account__c, program);
                programFileNumMap.put(program.Import_ID__c,program);
            }
            Account acc;
            nu_dse__Program__c program;
            //Added By Shyam
            nu_dse__Bank_Account__c objBankAccount;
            nu_dse__Financial_Profile__c objFinancialProfile;
            List<Account> accountUpsertLst = new List<Account>();
            List<nu_dse__Program__c> programUpsertLst = new List<nu_dse__Program__c>();
            List<nu_dse__Program__c> ramsProgramList = new List<nu_dse__Program__c>();
            List<nu_dse__Program__c> attorneyProgramList = new List<nu_dse__Program__c>();
            
            List<nu_dse__Bank_Account__c> bankAccountUpsertLst = new List<nu_dse__Bank_Account__c>(); //Added By Shyam
            List<nu_dse__Financial_Profile__c> financialProfileUpsertLst = new List<nu_dse__Financial_Profile__c>(); //Added By Shyam
            //Id accountRecType = SystemUtils.getRecordTypeID('Account','Attorney Client');
            
            Id programRecType = null;
            if (!Test.isRunningTest ())
                programRecType = SystemUtils.getRecordTypeID('nu_dse__Program__c','Attorney');
            for(String str: filemap.keySet()){
                program = new nu_dse__Program__c();
                acc = new Account();
                
                objBankAccount = new nu_dse__Bank_Account__c(); //Added By Shyam
                objFinancialProfile  = new nu_dse__Financial_Profile__c(); //Added By Shyam
                acc.NDS_File_Number__c= str;
                propertyClass prop= filemap.get(acc.NDS_File_Number__c);
            //    acc.BillingStreet = prop.BankStreetAddress;
                acc.firstName = prop.firstName;
                system.debug('LastName:::' +prop.lastname);
                system.debug('filenumber:::' +str);
                acc.lastname = prop.lastName;
                acc.Attorney__c = True;
                acc.Last_Modified_By_NDS__c = System.Now();
                acc.PersonMailingStreet = prop.AddressLine1; //+prop.appartment;
                acc.PersonMobilePhone = prop.CellNumber;
                acc.Authorized_User_Email__c = checkEmail(prop.AuthEmail);
                acc.Authorized_User_Phone__c = Prop.AuthPhone;
                
                if(prop.AuthName != NULL && prop.AuthName != '' && prop.AuthName.Length() < 5001)
                {
                    acc.Authorized_User_Name__c = prop.AuthName;
                }
                else if(prop.AuthName != NULL && prop.AuthName != ''){
                    acc.Authorized_User_Name__c = prop.AuthName.subString(0,4999);
                }    
                
if(prop.Name2State != NULL && prop.Name2State != '' && prop.Name2State.Length() < 3)
                {
                acc.nu_dse__co_State__c = prop.Name2State;
                }
                else
                                acc.nu_dse__co_State__c = '';

                acc.PersonMailingCity = prop.City;
           //     acc.nu_dse__co_State__c = prop.Name2State;
                acc.nu_dse__co_City__c  = prop.Name2City;
                
                if(!fileAccountMap.containsKey(str) || fileAccountMap.get(str).PersonEmail == null)
                    acc.PersonEmail = checkEmail(prop.EmailAddress);
                acc.PersonHomePhone = prop.HomeNumber;
                
                
                //Changes added by Rajesh for NMI-493
                if(prop.CellNumber != null){
                    acc.Phone = prop.CellNumber;
                } else if(prop.HomeNumber != null) {
                    acc.Phone = prop.HomeNumber;
                }
                
         //       acc.nu_dse__Best_Phone__c = prop.Name1BestNumber;
                
         //       acc.nu_dse__CO_Best_Phone__c = prop.Name2BestNumber;
                
                acc.PersonMailingState = prop.State; 
                acc.nu_dse__Work_Phone__c = prop.WorkNumber;
                acc.PersonMailingPostalCode = prop.Zipcode;
                acc.Best_Day__c = prop.BestDay;
                acc.Best_Time__c = prop.BestTime;
                acc.Contact_Preference__c = prop.CorrespondencePreference;
    /*             if(prop.DebtConsultant != NULL && prop.DebtConsultant != '' && prop.DebtConsultant.Length() < 51)
                {
                acc.Sales_Rep__c = prop.DebtConsultant;
                }
                else
                                acc.Sales_Rep__c = null;  */

             //   acc.Sales_Rep__c = prop.DebtConsultant;
                acc.nu_dse__Other_Phone__c = prop.AlternateNumber;
                if(Boolean.ValueOf(prop.DoNotCall = 'True'))
                  //  acc.nds_Do_Not_Call__c = True;
                      acc.PersonDoNotCall = True;
                else
                  //    acc.nds_Do_Not_Call__c = False;
                      acc.PersonDoNotCall = False;
                
                if(Boolean.ValueOf(prop.DoNotEmail = 'True'))
                  //  acc.nds_Do_Not_Email__c = True;
                    acc.PersonHasOptedOutOfEmail = True;
                else
                 //   acc.nds_Do_Not_Email__c = False;
                    acc.PersonHasOptedOutOfEmail = False;
                
                if(Boolean.ValueOf(prop.DoNotSMS = 'True'))
                //    acc.nds_Do_Not_SMS__c = True;
                      acc.SMS_Opted_Out__c = True;
                else
                //    acc.nds_Do_Not_SMS__c = False;
                    acc.SMS_Opted_Out__c = False;
                /*    acc.nds_Do_Not_Call__c = Boolean.ValueOf(prop.DoNotCall);
acc.nds_Do_Not_Email__c = Boolean.valueOf(prop.DoNotEmail);
acc.nds_Do_Not_SMS__c = Boolean.ValueOf(prop.DoNotSMS);*/
                acc.Fax = prop.FaxNumber;
                acc.Drivers_License__c = prop.Name1DLNumber;
                acc.Drivers_License_State__c = prop.Name1DLState;
                acc.Nick_Name__c = prop.Name1AKA;
                acc.co_Nick_Name__c = prop.Name2AKA;
                if(NextBatchTimings.Populate_GCS_Id__c && getLeadtrackProgramLst().get(prop.ProgramType) != null && getLeadtrackProgramLst().get(prop.ProgramType).RAMS__c){
                   //Changes made by Rajesh for NMI-551
                    if(prop.AccountId != null && prop.AccountId.Contains(':')){
                        acc.nu_dse__External_RAMS_ID__c = prop.AccountId.substringAfterLast(':');
                    } else{
                        acc.nu_dse__External_RAMS_ID__c = prop.AccountId;    
                    }
                    RAMSIds.add(acc.nu_dse__External_RAMS_ID__c);
                } else {
                acc.nu_dse__External_GCS_ID__c = prop.AccountId;
                }
                acc.Employer_Name__c = prop.Name1Employer;
                acc.Occupation__c = prop.Name1Occupation;
                acc.nu_dse__SSN__c = prop.Name1SSN;
          //    acc.nu_dse__Social_Security_Number__c = prop.Name1SSN;
                acc.nu_dse__Co_Address_Line__c = prop.Name2AddressLine1;
                acc.Co_Best_Time__c = prop.Name2BestTime;
                acc.nu_dse__CO_Cell_Phone__c = prop.Name2CellNumber;
                acc.Co_Drivers_License__c = prop.Name2DLNumber;
                acc.Co_Drivers_License_State__c = prop.Name2DLState;
                //   acc.nu_dse__CO_Email_Address__c = prop.Name2Email;
                                acc.nu_dse__CO_Email_Address__c = checkEmail(prop.Name2Email);

                acc.Co_Applicant_Employer_Name__c = prop.Name2Employer ;
                acc.Co_Applicant_FAX_number__c = prop.Name2FaxNumber;
                
                 //Added by VS
                if(Attorney_StaticVariableUtility.nextJobTimings.Account_Record_Type__c == null) 
                    acc.RecordtypeId = '123';
                else
                     acc.RecordtypeId = SystemUtils.getRecordTypeID('Account',Attorney_StaticVariableUtility.nextJobTimings.Account_Record_Type__c);
                   

                acc.CampaignId__c = prop.CampaignId;
             
  
                if(prop.Name2DOB != '' && prop.Name2DOB != NULL)
                    acc.nu_dse__Co_Date_of_Birth__c = ConvertSalesforceValidDateFormat(prop.Name2DOB);
                else
                    acc.nu_dse__Co_Date_of_Birth__c = NULL;    
                     if(prop.Name1DOB != '' && prop.Name1DOB != NULL)
                    acc.PersonBirthdate = ConvertSalesforceValidDateFormat(prop.Name1DOB);
                else
                    acc.PersonBirthdate = NULL;   
                acc.nu_dse__Co_First_Name__c = prop.Name2First;
                acc.nu_dse__CO_Home_Phone__c = prop.Name2HomeNumber;
                acc.nu_dse__Co_Last_Name__c = prop.Name2Last;
                acc.Co_Occupation__c = prop.Name2Occupation;
                acc.nu_dse__Co_SSN__c = prop.Name2SSN;
               // Changed by Mayur for ND-86
               // acc.nu_dse__CO_SSN_ENC__c = prop.Name2SSN;
                acc.nu_dse__CO_Work_Phone__c = prop.Name2WorkNumber;
                acc.nu_dse__Co_Postal_Code__c = prop.Name2ZipCode;
                acc.Salutation = prop.Prefix;
                
                acc.Time_Zone__c = prop.TimeZone;
                
                //Program mapping
                system.debug('###prop.ESTSettlementAmt::'+prop.ESTSettlementAmt);
                 program.Attorney__c = TRUE;
                 program.Lead_Id__c = prop.LeadID;
                 program.External_Id__c = prop.LeadID;
                
                //Added by VS
                if(Attorney_StaticVariableUtility.nextJobTimings.Program_Record_Type__c == null) 
                    program.RecordtypeId = '123';
                else
                    program.RecordtypeId = SystemUtils.getRecordTypeID('nu_dse__Program__c',Attorney_StaticVariableUtility.nextJobTimings.Program_Record_Type__c);
                
                
                  if(prop.DebtConsultant != NULL && prop.DebtConsultant != '' && prop.DebtConsultant.Length() < 51)
                {
                program.Sales_Rep__c = prop.DebtConsultant;
                }
                else
                                program.Sales_Rep__c = null; 
                
                //Made changes by Mayur on 1/27 for ND-31               
                if(!programFileNumMap.containsKey(Str) || (programFileNumMap.get(Str).nu_dse__Program_Status__c != 'Graduated Program' && programFileNumMap.get(Str).nu_dse__Program_Status__c != 'Client Cancelled'))
                    program.nu_dse__Program_Status__c = prop.ProgramStatus;
                if(prop.StatusDateTime != null){
                    program.Status_Date_Time__c = prop.StatusDateTime;
                }
             /*   if(prop.ESTSettlementAmt == '' || prop.ESTSettlementAmt == NULL)
                    program.nds_EstimatedSettlement_Amount__c = 0;
                else    
                    program.nds_EstimatedSettlement_Amount__c = Decimal.ValueOf(prop.ESTSettlementAmt);
                    
                    
                    
                if(prop.ProgramFeeAmt == '' || prop.ProgramFeeAmt == NULL)
                    program.nds_EstimatedProgram_Fee__c = 0;
                else
                    program.nds_EstimatedProgram_Fee__c = Decimal.ValueOf(prop.ProgramFeeAmt);
                if(prop.ProgramSavings == '' || prop.ProgramSavings == NULL)
                    program.nds_Program_Savings__c = 0;
                else    
                    program.nds_Program_Savings__c = Decimal.ValueOf(prop.ProgramSavings);
                if(prop.RetainerFee == '' || prop.RetainerFee == NULL)
                    program.nds_Retainer_Fee__c = 0;
                else
                    program.nds_Retainer_Fee__c = Decimal.ValueOf(prop.RetainerFee);
                if(prop.RetainerFeeTotal == '' || prop.RetainerFeeTotal == NULL)
                    program.nds_Retainer_Fee_Total__c = 0;
                else
                    program.nds_Retainer_Fee_Total__c = Decimal.ValueOf(prop.RetainerFeeTotal);
                    
                    if(prop.RetainerTerm== '' || prop.RetainerTerm== NULL)
                    program.RetainerTerm__c = 0;
                else
                                    program.RetainerTerm__c = Decimal.ValueOf(prop.RetainerTerm);

                if(prop.TotalProgramCost == '' || prop.TotalProgramCost == NULL)
                {
                }
                //    program.nu_dse__Total_Program_Cost__c = 0;
                else    
                {
                }
                 //   program.nu_dse__Total_Program_Cost__c = Decimal.ValueOf(prop.TotalProgramCost);
                    
                if(prop.TrustFeeMonthly == '' || prop.TrustFeeMonthly == NULL)
                    program.nds_Trust_Fee_Monthly__c = 0;
                else    
                    program.nds_Trust_Fee_Monthly__c = Decimal.ValueOf(prop.TrustFeeMonthly);
                if(prop.TrustFeeMonthlyTotal == '' || prop.TrustFeeMonthlyTotal == NULL)
                    program.nds_Trust_Fee_monthly_total__c= 0;
                else    
                    program.nds_Trust_Fee_monthly_total__c = Decimal.ValueOf(prop.TrustFeeMonthlyTotal);*/
                    
                    program.nds_Total_Program_Cost__c  = Attorney_StaticVariableUtility.convertToDecimal(prop.TotalProgramCost); 
                    program.nds_EstimatedSettlement_Amount__c  = Attorney_StaticVariableUtility.convertToDecimal(prop.ESTSettlementAmt);
                    program.nds_EstimatedProgram_Fee__c  = Attorney_StaticVariableUtility.convertToDecimal(prop.ProgramFeeAmt);
                    program.nds_Program_Savings__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.ProgramSavings);
                    program.nds_Retainer_Fee__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.RetainerFee);
                    program.nds_Retainer_Fee_Total__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.RetainerFeeTotal);
                    program.RetainerTerm__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.RetainerTerm);
                    program.nds_Trust_Fee_Monthly__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.TrustFeeMonthly);
                    program.nds_Trust_Fee_monthly_total__c  = Attorney_StaticVariableUtility.convertToDecimal(prop.TrustFeeMonthlyTotal);
                    Program.Sales_Rep_Email__c = checkEmail(prop.SalesEmail);
             
          /*      if(programFileNumMap.containsKey(Str) && programFileNumMap.get(Str).Cancellation_Date__c == null && prop.CancellationDate != '' && prop.CancellationDate != NULL){
                    program.Cancellation_Date__c = ConvertSalesforceValidDateFormat(prop.CancellationDate);
                } else if
                (!programFileNumMap.containsKey(Str) && prop.CancellationDate != '' && prop.CancellationDate != NULL)
                
                {
                    program.Cancellation_Date__c = ConvertSalesforceValidDateFormat(prop.CancellationDate);
                
                }*/
                
                
                if(prop.FirstDraftDate != '' && prop.FirstDraftDate != NULL)
                    program.nu_dse__Initial_Debit_Date__c = ConvertSalesforceValidDateFormat(prop.FirstDraftDate);
                else
                    program.nu_dse__Initial_Debit_Date__c = NULL;
                
           
                program.nds_Cancellation_Reason__c = prop.CancellationReason;
                                program.Last_Modified_By_NDS__c = System.Now();
                                
                                
                                
                                 
                                
                                
               if(String.ValueOf(prop.PolicyGroup) != NULL && String.ValueOf(prop.PolicyGroup) != '')
               {
                   if(getLeadtrackProgramLst().get(prop.ProgramType) != null && getLeadtrackProgramLst().get(prop.ProgramType).RAMS__c){
                       // acc.nu_dse__External_RAMS_ID__c = prop.AccountId;    
                   } else {
                         if(!programFileNumMap.containsKey(str) || programFileNumMap.get(str).GCS_Policy_Group__c == null)
                               program.GCS_Policy_Group__c = prop.PolicyGroup;
                   }
               }               
                

                program.Current_Account_Review__c = prop.AccountReviewEvent;
                program.Estimated_Settlement__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.EstSettlementPercent);
                program.Monthly_Legal_Fee__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.LegalFeeMonthly);
                
                if(String.ValueOf(prop.UserDefined) != NULL && String.ValueOf(prop.UserDefined) != '' && prop.UserDefined.Length() < 5001 && !String.ValueOf(prop.UserDefined).contains('Data Clean Up'))
                {
                    program.Client_Sticky_Note__c = prop.UserDefined;
                }
                else if(String.ValueOf(prop.UserDefined) != NULL && String.ValueOf(prop.UserDefined) != '' && !String.ValueOf(prop.UserDefined).contains('Data Clean Up')){
                    program.Client_Sticky_Note__c  = prop.UserDefined.subString(0,4999);
                }

  /*              if(prop.EstSettlementPercent != '' && prop.EstSettlementPercent != NULL)  {
                    system.debug('###program:EstSettlementPercent::'+prop.EstSettlementPercent);
                    String Setper = prop.EstSettlementPercent.replace('%','');
                    system.debug('###program:EstSettlementPercentAfter::'+Setper);
                    program.Estimated_Settlement__c = decimal.ValueOf(Setper);
                }else
                    program.Estimated_Settlement__c = 0;
                    system.debug('LegalFeeMonthlyTotal' +prop.LegalFeeMonthlyTotal);
                if(prop.LegalFeeMonthlyTotal != '' && prop.LegalFeeMonthlyTotal != NULL)    
                    program.Monthly_Legal_Fee__c = Decimal.ValueOf(prop.LegalFeeMonthlyTotal);
                else
                    program.Monthly_Legal_Fee__c = 0; */

   /*             if(prop.ProgramFeePercent != '' && prop.ProgramFeePercent != NULL) 
                {
                                    system.debug('###ProgramFeePercent ::'+prop.ProgramFeePercent);

                                                        String Setfee = prop.ProgramFeePercent.replace('%','');
                                                                            system.debug('###ProgramFeePercent::'+Setfee);


                    program.Settlement_Fee__c = Decimal.ValueOf(Setfee);
                    }
                else
                {
                    program.Settlement_Fee__c = 0; 
                    }   */
                    
          //          Estimated_Settlement__c Settlement_Fee__c
                     
                       program.Settlement_Fee__c = Attorney_StaticVariableUtility.convertToDecimal(prop.ProgramFeePercent);
                       program.nds_Current_Debt_Payments__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.CurrentDebtPayment);
                       program.nds_Estimated_Total_Debt__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.EstimatedTotalDebt);
                       program.nds_NSF_Draft_Amount__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.NSFDraftAmount);
                       program.nu_dse__Program_Length__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.ProgramLength);
                         

                    
     /*           if(prop.CurrentDebtPayment == '' || prop.CurrentDebtPayment == NULL)
                    program.nds_Current_Debt_Payments__c = 0;
                else
                    program.nds_Current_Debt_Payments__c = Decimal.ValueOf(prop.CurrentDebtPayment);
                if(prop.EstimatedTotalDebt == '' || prop.EstimatedTotalDebt == NULL)
                    program.nds_Estimated_Total_Debt__c = 0;
                else
                    program.nds_Estimated_Total_Debt__c = Decimal.ValueOf(prop.EstimatedTotalDebt); */
                if(prop.NSFDraftDate != '' && prop.NSFDraftDate != NULL)  
                    program.NSF_Draft_Date__c = ConvertSalesforceValidDateFormat(prop.NSFDraftDate);
                else
                    program.NSF_Draft_Date__c = NULL;
                program.nds_Maxprogram_length__c = prop.MaxProgramLength;
     /*           if(prop.NSFDraftAmount == '' || prop.NSFDraftAmount == NULL)
                    program.nds_NSF_Draft_Amount__c = 0;
                else    
                    program.nds_NSF_Draft_Amount__c = Decimal.ValueOf(prop.NSFDraftAmount);*/
                   program.nds_NSF_Reason__c = prop.NSFReason;
 /*               if(prop.ProgramLength == '' || prop.ProgramLength  == NULL)
                    program.nu_dse__Program_Length__c = 0;
                else
                    program.nu_dse__Program_Length__c = Decimal.ValueOf(prop.ProgramLength);*/
                program.Program_Type__c = prop.ProgramType;
                program.nu_dse__Reoccurring_Debit_Day__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.RecurringDate);
                program.nu_dse__Twice_Monthly_Reoccuring_Day__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.RecurringDate2);
  /*           
                
                /**********Start by Shyam**********************/
                //Bank Account Mapping
                objBankAccount.nu_dse__Telephone__c = prop.TelephoneCost;
                objBankAccount.nu_dse__Holder_s_Name__c  = prop.AccountOwnerName;
                objBankAccount.nu_dse__Bank_Account_Number__c   = prop.BankAccountNumber;
                if(prop.AccountType!= null && prop.AccountType!= '' && prop.AccountType == 'Checking')
                {
                 objBankAccount.nu_dse__Account_Type__c   = 'CHECKING';
                }
                else if(prop.AccountType!= null && prop.AccountType!= '' && prop.AccountType == 'Savings') 
                {
                 objBankAccount.nu_dse__Account_Type__c   = 'SAVING';
                } 
                
                else
                {
                                 objBankAccount.nu_dse__Account_Type__c   = null;

                }


                
                objBankAccount.nu_dse__City__c   = prop.BankCity;
                objBankAccount.nu_dse__Bank_Name__c   = prop.BankName;
                objBankAccount.nu_dse__Telephone__c   = prop.BankPhone;
                                objBankAccount.bank_street_address__c   = prop.BankStreetAddress;

                objBankAccount.nu_dse__Routing_Number__c   = prop.BankRoutingNumber;
                objBankAccount.nu_dse__State__c   = prop.BankState;
                objBankAccount.nu_dse__Zip__c   = prop.BankZipCode;
                                objBankAccount.Last_Modified_By_NDS__c = System.Now();

                
                // Financial Profile Mapping
                objFinancialProfile.nu_dse__Hardship_Description__c = prop.HardshipReason;
                objFinancialProfile.nu_dse__Hardship_Reason__c = prop.Hardship; 
                                                objFinancialProfile.Last_Modified_By_NDS__c = System.Now();

                
objFinancialProfile.nu_dse__Co_Client_Gross_Income__c = Attorney_StaticVariableUtility.convertToDecimal(prop.Name2MonthlyIncome);
objFinancialProfile.nu_dse__Extra_Income_Amount_1__c = Attorney_StaticVariableUtility.convertToDecimal(prop.OtherIncomeAmount);
objFinancialProfile.nu_dse__Net_Monthly_Income__c = Attorney_StaticVariableUtility.convertToDecimal(prop.Name1MonthlyIncome);
objFinancialProfile.nds_DiscretionaryIncome__c = Attorney_StaticVariableUtility.convertToDecimal(prop.DiscretionaryIncome);
objFinancialProfile.nds_Discretionary_Percentage__c = Attorney_StaticVariableUtility.convertToDecimal(prop.DiscretionaryPercentage);
objFinancialProfile.nu_dse__Rent_Mortgage_payment__c = Attorney_StaticVariableUtility.convertToDecimal(prop.MortgageRentCost);
                
                
                
                
        
                                      
                    if(Boolean.ValueOf(prop.Name1SelfEmployed = 'True'))
                    objFinancialProfile.Is_Self_Employed__c = True;
                    else
                    objFinancialProfile.Is_Self_Employed__c = False;
                    
                    
                                       
                    if(Boolean.ValueOf(prop.Name2SelfEmployed= 'True'))
                    objFinancialProfile.Is_Co_Applicant_Self_Employed__c = True;
                    else
                    objFinancialProfile.Is_Co_Applicant_Self_Employed__c = False;
                                objFinancialProfile.nu_dse__Automobile_Insurance__c  = Attorney_StaticVariableUtility.convertToDecimal(prop.AutoInsuranceCost);
    
                      
       /*         if(prop.AutoInsuranceCost == '' || prop.AutoInsuranceCost == NULL)
                    objFinancialProfile.nu_dse__Automobile_Insurance__c = 0;
                else    
                    objFinancialProfile.nu_dse__Automobile_Insurance__c  = Decimal.valueOf(prop.AutoInsuranceCost);*/
                    
         //           Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        //         Matcher AutoLo = isnumbers.matcher(prop.AutoLoanCost);   
        
                 /*if(prop.AutoLoanCost != '' && prop.AutoLoanCost != NULL)// && AutoLo.Matches())
                    objFinancialProfile.nu_dse__Car_Payment__c = Decimal.ValueOf(prop.AutoLoanCost);
                else
                    objFinancialProfile.nu_dse__Car_Payment__c   = 0;*/
                
                //Added by Vs - Start 
                objFinancialProfile.nu_dse__Car_Payment__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.AutoLoanCost);
                //Added by Vs - End 
                 objFinancialProfile.nu_dse__Car_Maintenance__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.AutoOther);

                 objFinancialProfile.nu_dse__Back_Taxes__c = Attorney_StaticVariableUtility.convertToDecimal(prop.BackTaxes);


        /*        if(prop.CableSatelliteCost == '' || prop.CableSatelliteCost  == NULL)
                    objFinancialProfile.nu_dse__Television_Cable_Satellite__c = 0;
                else
                    objFinancialProfile.nu_dse__Television_Cable_Satellite__c   = Decimal.ValueOf( prop.CableSatelliteCost);*/
                    
                 objFinancialProfile.nu_dse__Television_Cable_Satellite__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.CableSatelliteCost);

                  objFinancialProfile.nu_dse__Charity_Donations__c = Attorney_StaticVariableUtility.convertToDecimal(prop.CharityCost);
                   objFinancialProfile.nu_dse__Child_Care_Day_Care__c = Attorney_StaticVariableUtility.convertToDecimal(prop.ChildCareCost);
                  objFinancialProfile.nu_dse__Clothing__c = Attorney_StaticVariableUtility.convertToDecimal(prop.ClothingCost);
                  objFinancialProfile.nu_dse__Education__c = Attorney_StaticVariableUtility.convertToDecimal(prop.EducationCost);
                  objFinancialProfile.nu_dse__Entertainment__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.EntertainmentCost);
                  objFinancialProfile.nu_dse__Food_Groceries_Eating_Out__c = Attorney_StaticVariableUtility.convertToDecimal(prop.FoodCost);
                  objFinancialProfile.nu_dse__Gym_Health__c = Attorney_StaticVariableUtility.convertToDecimal(prop.GymFees);
                  objFinancialProfile.nu_dse__Homeowner_s_Renter_s_Insurance__c = Attorney_StaticVariableUtility.convertToDecimal(prop.HomeRentInsuranceCost);
                  objFinancialProfile.nu_dse__Household_Items__c = Attorney_StaticVariableUtility.convertToDecimal(prop.HouseholdItemsCost);
                  objFinancialProfile.nu_dse__Amount_Owed_on_Home__c = prop.MortgageBalance;
                  objFinancialProfile.nu_dse__Number_of_Dependants__c= Attorney_StaticVariableUtility.convertToDecimal(prop.Dependants);
                  objFinancialProfile.nu_dse__Home_Value__c= prop.EstimatedHomeValue;


   
                if(prop.Homeowner!= null && prop.Homeowner!= '' && prop.Homeowner == 'Yes')
                {
                 objFinancialProfile.nu_dse__Home_Status__c   = 'Own';
                }
                else if(prop.Homeowner != null && prop.Homeowner != '' && prop.Homeowner == 'No') 
                {
                 objFinancialProfile.nu_dse__Home_Status__c  = 'Rent';
                } 
                
                else
                {
                 objFinancialProfile.nu_dse__Home_Status__c  = null;

                }
            
                  
                  objFinancialProfile.nu_dse__Life_Insurance__c   = Attorney_StaticVariableUtility.convertToDecimal(prop.LifeInsuranceCost);
                  objFinancialProfile.nu_dse__Other_1_Payments__c = Attorney_StaticVariableUtility.convertToDecimal(prop.Other1Cost);
                  objFinancialProfile.nu_dse__Extra_Income_Description_2__c = prop.OtherIncomeReason2;
                  objFinancialProfile.nu_dse__Extra_Income_Description_1__c = prop.OtherIncomeReason;
                  objFinancialProfile.nu_dse__Utilities__c = Attorney_StaticVariableUtility.convertToDecimal(prop.UtilitiesCost);

                  objFinancialProfile.nu_dse__Laundry_Dry_Cleaning__c = Attorney_StaticVariableUtility.convertToDecimal(prop.LaundryCost);
                  objFinancialProfile.nu_dse__Medical__c = Attorney_StaticVariableUtility.convertToDecimal(prop.MedicalCareCost);
              //    objFinancialProfile.nu_dse__Additional_Income__c = Attorney_StaticVariableUtility.convertToDecimal(prop.Name1AnnualIncome);
               //   objFinancialProfile.Co_Client_Annual_Base_Salary_Velocify__c = Attorney_StaticVariableUtility.convertToDecimal(prop.Name2AnnualIncome);
                  objFinancialProfile.nu_dse__Personal_Care__c = Attorney_StaticVariableUtility.convertToDecimal(prop.PersonalCare);
                  objFinancialProfile.nu_dse__Student_Loans__c = Attorney_StaticVariableUtility.convertToDecimal(prop.StudentLoans);
                  objFinancialProfile.nu_dse__Telephone__c = Attorney_StaticVariableUtility.convertToDecimal(prop.TelephoneCost);
          //         objFinancialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c = prop.BankruptcyYear;
                   
                   
                   
                           if(prop.BankruptcyYear!= NULL && prop.BankruptcyYear!= '' && prop.BankruptcyYear.Length() < 5)
                {
                objFinancialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c = prop.BankruptcyYear;
                }
                else
                                objFinancialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c = '0000';
                   
                   
                   objFinancialProfile.nu_dse__Credit_Score__c = Attorney_StaticVariableUtility.convertToDecimal(prop.CreditScore1);
                    objFinancialProfile.nu_dse__Extra_Income_Amount_2__c= Attorney_StaticVariableUtility.convertToDecimal(prop.OtherIncomeAmount2);


    

              //  objFinancialProfile.nu_dse__Other_1_Payments_Description__c   = prop.Other1Name;
            
                 if(prop.Other1Name!= NULL && prop.Other1Name!= '' && prop.Other1Name.Length() < 256 && prop.Other1Name != 'Data Clean Up Needed in NDS')
                {
                    objFinancialProfile.nu_dse__Other_1_Payments_Description__c   = prop.Other1Name;
                }
                else if(prop.Other1Name!= NULL && prop.Other1Name!= '' && prop.Other1Name != 'Data Clean Up Needed in NDS'){
                    objFinancialProfile.nu_dse__Other_1_Payments_Description__c   = prop.Other1Name.subString(0,254);
                    if(prop.Other1Name.Length() < 5001 && prop.Other1Name != 'Data Clean Up Needed in NDS')
                        objFinancialProfile.NDS_Other_1_Payments_Description__c   = prop.Other1Name;
                    else
                        objFinancialProfile.NDS_Other_1_Payments_Description__c   = prop.Other1Name.subString(0,4999);
                }
             
         
                objFinancialProfile.nu_dse__Bankruptcy_Type__c = prop.BankruptcyChapter;
                objFinancialProfile.nu_dse__Client_Has_Filed_Bankruptcy__c = prop.FiledBankruptcy;
                
                /***************END By SHYAM**********************************************************/
                
                if(fileAccountMap.containsKey(str)){
                    acc.Id = fileAccountMap.get(str).Id;
                    if(accountProgramMap.containskey(acc.Id)){
                        program.Id = accountProgramMap.get(acc.Id).Id;
                        //program.nu_dse__Account__c = acc.Id;    
                        System.debug('***program.nu_dse__Account__c'+program.nu_dse__Account__c);
                        objBankAccount.nu_dse__Program__c = program.Id;
                        objFinancialProfile.nu_dse__Program__c = program.Id;
                        // System.debug('$$objFinancialProfile->program.Id'+objFinancialProfile.nu_dse__Program__c);
                    }
                    //rajesh
                    program.nu_dse__Account__c = acc.Id;    
                    
                    
                }
                program.Import_ID__c = str; 
            //    program.External_Id__c = str; 
                accountUpsertLst.add(acc);   
                programUpsertLst.add(program);
                
                // Added By Shyam
                objBankAccount.Import_Id__c = str;
                objFinancialProfile.Import_Id__c = str;
                bankAccountUpsertLst.add(objBankAccount);
                financialProfileUpsertLst.add(objFinancialProfile);
            }
            
            if(!accountUpsertLst.isEmpty()){
                List<Account> RAMSAccounts = new List<Account>();
                Map<Id,nu_dse__Program__c> RAMSProgramMap = new Map<Id,nu_dse__Program__c>();
                Map<String,nu_dse__Program__c> RAMSFileProgramMap = new Map<String,nu_dse__Program__c>();
                if(!RAMSIds.isEmpty()){
                    RAMSAccounts = [Select Id, nu_dse__External_RAMS_ID__c,NDS_File_Number__c, PersonEmail,(Select Id,nu_dse__Account__c,Import_Id__c from nu_dse__Programs__r) from Account where nu_dse__External_RAMS_ID__c=:RAMSIds AND NDS_File_Number__c = null];
                    
                    Map<String, Account> RAMSAccountMap = new Map<String, Account>();
                    for(Account a: RAMSAccounts){
                        if(!RAMSAccountMap.containsKey(a.nu_dse__External_RAMS_ID__c)){
                            RAMSAccountMap.put(a.nu_dse__External_RAMS_ID__c,a);
                            for(nu_dse__Program__c p:a.nu_dse__Programs__r)
                                RAMSProgramMap.put(a.Id,p);
                        }
                    }
                    
                    for(Account a: accountUpsertLst){
                        if(a.nu_dse__External_RAMS_ID__c != null && a.Id == null && RAMSAccountMap.containsKey(a.nu_dse__External_RAMS_ID__c)){
                            a.Id = RAMSAccountMap.get(a.nu_dse__External_RAMS_ID__c).Id;
                            if(RAMSProgramMap.containsKey(a.Id)){
                                nu_dse__Program__c p = RAMSProgramMap.get(a.Id);
                                p.Import_Id__c = a.NDS_File_Number__c;
                                RAMSProgramMap.put(a.Id,p);
                                RAMSFileProgramMap.put(p.Import_Id__c,p);
                            }
                        }
                    }
                    
                    for(nu_dse__Program__c p:ProgramUpsertLst){
                        System.debug('******'+p);
                        if(RAMSFileProgramMap.containsKey(p.Import_Id__c)){
                            System.debug('******RAMS Account');
                            p.Id = RAMSFileProgramMap.get(p.Import_Id__c).Id;
                            RAMSProgramList.add(p);
                        } else {
                            System.debug('******NON RAMS Account');
                            attorneyProgramList.add(p);
                        }
                    }    
                }
            }
            System.debug('********ProgramUpsertLst'+ProgramUpsertLst);
            System.debug('********AttorneyProgramList'+attorneyProgramList);
            System.debug('********RAMSProgramList'+RAMSProgramList);
            /***************************Upsert Bank Account*****************************/
            
            if(!bankAccountUpsertLst.isEmpty()  && nextBatchTimings.Load_Clients__c == True){
                Schema.SObjectField importIdField = nu_dse__Bank_Account__c.Import_Id__c;
                Database.UpsertResult[] objResult = Database.upsert(bankAccountUpsertLst, importIdField, false);
                String errorString = '';
                for(Database.UpsertResult saveRec: objResult){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }
                }
                if(errorString != ''){
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }
            /****************************Upsert Financial Profile************************/
            if(!financialProfileUpsertLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                Schema.SObjectField importIdField = nu_dse__Financial_Profile__c.Import_Id__c;
                Database.UpsertResult[] objResult = Database.upsert(financialProfileUpsertLst, importIdField, false);
                String errorString = '';
                for(Database.UpsertResult saveRec: objResult){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }
                }
                if(errorString != ''){
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }
            
            if(!RAMSIds.isEmpty()){
                if(!attorneyProgramList.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Schema.SObjectField f = nu_dse__Program__c.Import_Id__c;
                    Database.UpsertResult[] cr = Database.upsert(attorneyProgramList, f, false);
                    system.debug('###programNew::'+cr);
                    String errorString = '';
                    for(Database.UpsertResult saveRec: Cr){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                
                if(!RAMSProgramList.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    //Schema.SObjectField f = nu_dse__Program__c.Import_Id__c;
                    Database.SaveResult[] cr = Database.update(programUpsertLst, false);
                    system.debug('###programNew::'+cr);
                    String errorString = '';
                    for(Database.SaveResult saveRec: Cr){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
            } else {
                if(!ProgramUpsertLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Schema.SObjectField f = nu_dse__Program__c.Import_Id__c;
                    Database.UpsertResult[] cr = Database.upsert(ProgramUpsertLst, f, false);
                    system.debug('###programNew::'+cr);
                    String errorString = '';
                    for(Database.UpsertResult saveRec: Cr){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
            }
            
            
            //Upsert programUpsertLst;
            system.debug('###accLst11::'+accountUpsertLst); 
            system.debug('###programLst::'+programUpsertLst);
            system.debug('###workFlowLst::'+workFlowLst);
            
            
            if(!workFlowLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                Schema.SObjectField f = WorkFlow__c.NDS_External_ID__c;
            //    Database.UpsertResult[] cr = Database.upsert(workFlowLst, f, false); //Commented by Uchit
            //    system.debug('###workFlowStatus::'+cr);
                String errorString = '';
          /*      for(Database.UpsertResult saveRec: Cr){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }
                }*/
                if(errorString != '' && !Test.isRunningTest ()){
                    
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }    
            if(!groupTaskLst.isEmpty() && nextBatchTimings.Load_Group_Tasks__c == True){
                system.debug('###groupTaskLst::'+groupTaskLst);
                Schema.SObjectField f = nu_dse__Group_Task__c.Task_id__c;
                Database.UpsertResult[] cr = Database.upsert(groupTaskLst, f, false);
               system.debug('###taskinclient::'+cr);
                String errorString = '';
                for(Database.UpsertResult saveRec: Cr){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }
                }
                if(errorString != ''  && !Test.isRunningTest ()){
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }
            if(!taskLst.isEmpty() && nextBatchTimings.Load_Tasks__c == True){
                Schema.SObjectField f = Task.Task_id__c;
                Database.UpsertResult[] cr = Database.upsert(taskLst, f, false);
                String errorString = '';
                for(Database.UpsertResult saveRec: Cr){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }
                }
                if(errorString != ''  && !Test.isRunningTest ()){
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }
            if(!accountUpsertLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                
                /*List<Account> RAMSAccounts = new List<Account>();
                if(!RAMSIds.isEmpty()){
                    RAMSAccounts = [Select Id, nu_dse__External_RAMS_ID__c,NDS_File_Number__c from Account where nu_dse__External_RAMS_ID__c=:RAMSIds AND NDS_File_Number__c = null];
                    
                    Map<String, Account> RAMSAccountMap = new Map<String, Account>();
                    for(Account a: RAMSAccounts){
                        if(!RAMSAccountMap.containsKey(a.nu_dse__External_RAMS_ID__c)){
                            RAMSAccountMap.put(a.nu_dse__External_RAMS_ID__c,a);
                        }
                    }
                    
                    for(Account a: accountUpsertLst){
                        if(a.nu_dse__External_RAMS_ID__c != null && a.Id == null && RAMSAccountMap.containsKey(a.nu_dse__External_RAMS_ID__c)){
                            a.Id = RAMSAccountMap.get(a.nu_dse__External_RAMS_ID__c).Id;
                        }
                    }
                }*/

                String errorString = '';
                    Database.UpsertResult[] objResult = Database.upsert(accountUpsertLst,false);
                    for(Database.UpsertResult saveRec: objResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        if (!Test.isRunningTest ())
                            throw e;
                    }
                
                Set<String> fileSet = new Set<String>();
                Map<String,Account> fileAccmap = new Map<String,Account>();
                Map<String,nu_dse__Program__c> programMap = new Map<String,nu_dse__Program__c>();
                for(Account accFile: accountUpsertLst){
                    fileSet.add(accFile.NDS_File_Number__c);
                    fileAccmap.put(accFile.NDS_File_Number__c, accFile);
                }
                system.debug('###fileAccmap::'+fileAccmap);
                system.debug('###fileSet::'+fileSet);
                List<nu_dse__Program__c> programUpdLst = new List<nu_dse__Program__c>();
                programUpdLst = [select id, name, Import_ID__c, nu_dse__Account__c from nu_dse__Program__c where Import_ID__c IN: fileSet];
                System.debug('***fileSet'+fileSet);
                for(nu_dse__Program__c prog: programUpdLst){
                    prog.nu_dse__Account__c = fileAccmap.get(prog.Import_ID__c).Id;
                    programMap.put(prog.Import_Id__c,prog);
                }
                /*******************Added By Shyam****************************/
                List<nu_dse__Bank_Account__c> lstBankAccount = new List<nu_dse__Bank_Account__c>();
                
                lstBankAccount = [select id, name, Import_ID__c, nu_dse__Account__c from nu_dse__Bank_Account__c where Import_ID__c IN: fileSet];
                for(nu_dse__Bank_Account__c objBankAccountUpd : lstBankAccount){
              //    objBankAccountUpd.nu_dse__Account__c = fileAccmap.get(objBankAccountUpd.Import_ID__c).Id;
                    objBankAccountUpd.nu_dse__Program__c = programMap.get(objBankAccountUpd.Import_ID__c).Id;
                }//VS uncommented this
                
                /**********Updating WorkFlows with account Id*********************/
                List<WorkFlow__c> workFlowUpdLst = [Select id,Name,FileNumber__c from workFlow__c where FileNumber__c IN: fileSet];
                system.debug('***workFlowLst::'+workFlowLst);
                for(workflow__c work: workflowUpdLst){
                    System.debug('***Work.FileNumber__c'+work.fileNumber__c );
                    System.debug('***programMap.get(work.FileNumber__c).Id'+programMap.get(work.FileNumber__c).Id);
                    work.Account__c = fileAccmap.get(work.FileNumber__c).Id;
                    work.Program__c = programMap.get(work.FileNumber__c).Id;
                }
                /************Updating GroupTask with Program Id*****************/
                List<nu_dse__Group_Task__c> GroupTaskUpdLst = [Select id,Name,FileNumber__c FROM nu_dse__Group_Task__c Where FileNumber__c IN: fileSet];
                for(nu_dse__Group_Task__c grpTask: GroupTaskUpdLst){
                    grpTask.Program__c = programMap.get(grpTask.FileNumber__c).Id;
                    grpTask.nu_dse__Related_To__c = String.ValueOf(programMap.get(grpTask.FileNumber__c).Id);
                }
                /***************Updating Realted to in Task******************************/
                List<Task> taskUpdLst = [select Id,WhatId,FileNumber__c From Task where FileNumber__c IN: fileSet];
                for(Task tas:taskLst) {
                    if (!Test.isRunningTest())
                        tas.WhatId = programMap.get(tas.FileNumber__c).Id;
                }
                List<nu_dse__Financial_Profile__c> lstFinancialProfile = new List<nu_dse__Financial_Profile__c>();
                lstFinancialProfile = [select id, name, Import_ID__c from nu_dse__Financial_Profile__c where Import_ID__c IN: fileSet];
                for(nu_dse__Financial_Profile__c profile: lstFinancialProfile){
                    profile.nu_dse__Program__c = programMap.get(profile.Import_Id__c).Id;
                }
                
                
                if(!programUpdLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Database.saveResult[] objProgResult = Database.update(programUpdLst);
                    for(Database.saveResult saveRec: objProgResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                if(!lstBankAccount.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Database.saveResult[] objBankResult = Database.update(lstBankAccount);
                    for(Database.saveResult saveRec: objBankResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                if(!lstFinancialProfile.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Database.saveResult[] objFinResult = Database.update(lstFinancialProfile);
                    for(Database.saveResult saveRec: objFinResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                if(!workflowUpdLst.isEmpty() && nextBatchTimings.Load_Clients__c == True){
                    Database.saveResult[] objWrkResult = Database.update(workflowUpdLst);
                    for(Database.saveResult saveRec: objWrkResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                if(!GroupTaskUpdLst.isEmpty() && nextBatchTimings.Load_Group_Tasks__c == True){
                    Database.saveResult[] objGrpResult = Database.update(GroupTaskUpdLst);
                    for(Database.saveResult saveRec: objGrpResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                if(!taskLst.isEmpty() && nextBatchTimings.Load_Tasks__c == True){
                    Database.saveResult[] objTasResult = Database.update(taskLst);
                    for(Database.saveResult saveRec: objTasResult){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
                
            }       
            
            
            
        /*}catch(Exception e){
            
            System_Log__c SL = new System_Log__c();
            SL.Id = sysLogId;
            SL.Exception_Description__c = e.getMessage() + '\n\n' + e.getStackTraceString();
            SL.Status__c = 'Failed';
            Update SL;
            System.abortJob(batchJobId);
        }*/
        
    }
    
    public class propertyClass{
        public string firstName;
        public string lastName;
        public string address1;
        public string address2;
        public string AuthEmail;
        public string AuthPhone;
        public string AuthName;
        public string CellNumber;
        public string City;
        public string Name2City;
        public string Name2State;
        public string EmailAddress;
        public string HomeNumber;
        
                public string Name1BestNumber;


        public string Name2BestNumber;


        public string State;
        public string WorkNumber;
        public string ZipCode;
        public string AddressLine1;
        public string Appartment;
        public string BestDay;
        public string BestTime;
        public string CorrespondencePreference;
        public string DebtConsultant;
        public string DoNotCall;
        public string DoNotEmail;
        public string DoNotSMS;
        public string FaxNumber;
        public string Name1DLNumber;
        public string Name1DLState;
        public string Name1DOB;
        public string Name1Email;
        public string Name1Employer;
        public string Name1Occupation;
        public string Name1SSN;
        public string Name2AddressLine1;
        public string Name2BestTime;
        public string Name2CellNumber;
        public string Name2DLNumber;
        public string Name2DLState;
        public string Name2Email;
        public string Name2Employer;
        public string Name2FaxNumber;
        public string Name2First;
        public string Name2Last;
        public string Name2HomeNumber;
        public string Name2Occupation;
        public string Name2SSN;
        public string RetainerTerm;
        public string Name2WorkNumber;
        public string Name2ZipCode;
        public string Prefix;
        public string SalesEmail;
        public string TimeZone;
        public string ESTSettlementAmt;
                public string PolicyGroup;

        public string ProgramFeeAmt;
        public string ProgramSavings;
        public string RetainerFee;
        public string RetainerFeeTotal;
        public string TotalProgramCost;
        public string TrustFeeMonthly;
        public string TrustFeeMonthlyTotal;
        public string CancellationDate;
                public string MortgageRentCost;

        public string CancellationReason;
        public string CurrentDebtPayment;
        public string EstimatedTotalDebt;
        public string FirstDraftDate;
        public string MaxProgramLength;
        public string NSFDraftAmount;
        public string NSFDraftDate;
        public string NSFReason;
        public string ProgramLength;
        public string ProgramType;
        public string RecurringDate;
        public string RecurringDate2;
        public string CampaignId;
        public string BankStreetAddress;
        
        /**added for program status update**/
        public DateTime StatusDateTime;
        public string ProgramStatus;
        
        /******Bank Account *********************/
        public string TelephoneCost;
        public string AccountOwnerName;
        public string AccountType;
        public string BankAccountNumber;
        public string BankCity;
        public string BankName;
        public string BankPhone;
        public string BankRoutingNumber;
        public string BankState;
        public string BankZipCode;
        
        /************Financial Profile **************/
        public string Hardship;
        public string HardshipReason;
        public string AutoInsuranceCost;
        public string AutoLoanCost;
        public string AutoOther;
        public string BackTaxes;
        public string CableSatelliteCost;
        public string CharityCost;
        public string ChildCareCost;
        public string ClothingCost;
        public string EducationCost;
        public string EntertainmentCost;
        public string FoodCost;
        public string GymFees;
        public string HomeRentInsuranceCost;
        public string Homeowner;
         public string Dependants;
        public string HouseholdItemsCost;
        public string LaundryCost;
        public string LifeInsuranceCost;
        public string MedicalCareCost;
        public string OtherIncomeAmount2;
        public string Name1AnnualIncome;
        public string Name1MonthlyIncome;
        public string Name2AnnualIncome;
        public string Other1Cost;
        public string Other1Name;
        public string PersonalCare;
        public string StudentLoans;
        Public String DiscretionaryIncome;
        Public String DiscretionaryPercentage;
        Public String Name1SelfEmployed;
        Public String Name2MonthlyIncome;
        Public String Name2SelfEmployed;
        Public String OtherIncomeAmount;
        Public String TotalCostOfLiving;
        Public String FiledBankruptcy;
        //public string TelephoneCost;
        public string UtilitiesCost;
        public string EstSettlementPercent;
        public string LegalFeeMonthly;
        public string ProgramFeePercent;
        public string AlternateNumber;
        public string Name1AKA;
                public string Name2AKA;
                public string AccountId;

        public string Name2DOB;
        public string AccountReviewEvent;
        Public string UserDefined;
        public string LeadID;
        public String OtherIncomeReason2;
        public String OtherIncomeReason;
        public string TotalIncome;
        public string BankruptcyChapter;
        public string BankruptcyYear;
        public string CreditScore1;
        public string EstimatedHomeValue;
        public string MortgageBalance;
        
        /********************************************/
        public propertyClass(){
            MortgageBalance = '';
            EstimatedHomeValue = '';
            CreditScore1 = '';
            BankruptcyYear = '';
            BankruptcyChapter = '';
            TotalIncome = '';
            DiscretionaryIncome = '';
            DiscretionaryPercentage = '';
            Name1SelfEmployed = '';
            Name2MonthlyIncome = '';
            Name2SelfEmployed = '';
            OtherIncomeAmount = '';
            TotalCostOfLiving = '';
            Name2City = '';
            Name2State = '';
            FiledBankruptcy = '';            
            OtherIncomeReason2 = '';
            OtherIncomeReason = '';
            RetainerTerm = '';
            LeadID = '';
            AccountReviewEvent = '';
            Name2DOB = '';
            Name1AKA = '';
            Name2AKA = '';
            AccountId = '';
            AlternateNumber = '';
            ProgramFeePercent = '';
            LegalFeeMonthly = '';
            EstSettlementPercent = '';
            Hardship = '';
            HardshipReason = '';
            BankStreetAddress = '';
            TelephoneCost = '';
            firstName = '';
            lastName = '';
            address1 = '';
            address2 = '';
            CellNumber = '';
            City = '';
            MortgageRentCost = '';
            EmailAddress = '';
            HomeNumber = '';
            
                        Name1BestNumber= '';


            Name2BestNumber= '';

            State = '';
            WorkNumber = '';
            ZipCode = '';
            AddressLine1 = '';
            Appartment = '';
            BestDay = '';
            BestTime = '';
            CorrespondencePreference = '';
            DebtConsultant = '';
            DoNotCall = '';
            DoNotEmail = '';
            DoNotSMS = ''; 
            FaxNumber = '';
            Name1DLNumber = '';
            Name1DLState = '';
            Name1DOB = '';
            Name1Email = '';
            Name1Employer = '';
            Name1Occupation = '';
            Name1SSN = '';
            Name2AddressLine1 = '';
            Name2BestTime = '';
            Name2CellNumber = '';
            Name2DLNumber = '';
            Name2DLState = '';
            OtherIncomeAmount2 = '';
            Name2Email = '';
            Name2Employer = '';
            Name2FaxNumber = '';
            Name2First = '';
            Name2Last = '';
            Name2HomeNumber = '';
            AuthEmail = '';
            AuthPhone = '';
            AuthName = '';
            Name2Occupation = '';
            Name2SSN = '';
            Name2WorkNumber = '';
            Name2ZipCode = '';
            Prefix = '';
            SalesEmail = '';
            Name2SSN = '';
            TimeZone = '';
            ESTSettlementAmt = '';
                        PolicyGroup = '';

            ProgramFeeAmt = '';
            ProgramSavings = '';
            RetainerFee = '';
            RetainerFeeTotal = '';
            TotalProgramCost = '';
            TrustFeeMonthly = '';
            TrustFeeMonthlyTotal = '';
            CancellationDate = '';
            CancellationReason = '';
            CurrentDebtPayment = '';
            EstimatedTotalDebt = '';
            FirstDraftDate = '';
            MaxProgramLength = '';
            NSFDraftAmount = '';
            NSFDraftDate = '';
            NSFReason = '';
            ProgramLength = '';
            ProgramType = '';
            RecurringDate = '';
            RecurringDate2 = '';
            CampaignId = '';
            
            /** added for program status update**/
            StatusDateTime = null;
            ProgramStatus = '';
            
            /*******Bank Account***********/
            
            AccountOwnerName= ' ';
            AccountType= ' ';
            BankAccountNumber= ' ';
            BankCity= ' ';
            BankName= ' ';
            BankPhone= ' ';
            BankRoutingNumber= ' ';
            BankState= ' ';
            BankZipCode= ' ';
            
            /*******Financial Profile******/
            AutoInsuranceCost = ' ';
            AutoLoanCost = ' ';
            AutoOther = ' ';
            BackTaxes = ' ';
            CableSatelliteCost = ' ';
            CharityCost = ' ';
            ChildCareCost = ' ';
            ClothingCost = ' ';
            EducationCost = ' ';
            EntertainmentCost = ' ';
            FoodCost = ' ';
            Dependants = '';
            GymFees = ' ';
            HomeRentInsuranceCost = ' ';
            Homeowner = ' ';
            HouseholdItemsCost = ' ';
            LaundryCost = ' ';
            LifeInsuranceCost = ' ';
            MedicalCareCost = ' ';
            Name1AnnualIncome = ' ';
            Name1MonthlyIncome = ' ';
            Name2AnnualIncome = ' ';
            Other1Cost = ' ';
            Other1Name = ' ';
            PersonalCare = ' ';
            StudentLoans = ' ';
            TelephoneCost = ' ';
            UtilitiesCost = ' ';
            UserDefined = '';
            
        }
    }
}