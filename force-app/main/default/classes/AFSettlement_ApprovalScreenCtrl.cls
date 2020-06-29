public class AFSettlement_ApprovalScreenCtrl {
    public String tskId;
    public ProcessInstance objProcessInstance;
    public nu_dse__Group_Task__c tsk {get; set;}
    public PageReference redirectPage;
    public Boolean isError {get; set;}
    public ProcessInstance pi;
    public Boolean showActions {get; set;}
    public AFSettlement_ApprovalScreenCtrl(ApexPages.StandardController stdCtrl){
        tskId=stdCtrl.getId();
        isError=false;
        showActions=false;
        dataSetup();
    }
    
    public AFSettlement_ApprovalScreenCtrl(){
        tskId = ApexPages.currentPage().getParameters().get('recId');
        isError=false;
        showActions=false;
        dataSetup();
    }
    
    public void dataSetup(){
        if(tskId != null && tskId.trim().length()>0){
            list<User> users = [Select Id, Name, ProfileId, Profile.Name From User Where ProfileId =: UserInfo.getProfileId() limit 1];
            ProcessInstance[] piList = [Select ID, Status, TargetObject.Name, 
                                (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                Where TargetObjectID =: tskId AND Status = 'Pending'];
            pi=piList!=null && piList.size()>0 ? piList[0] : new ProcessInstance();
            if(pi != null && (pi.Workitems != null && pi.Workitems.size()>0)){
                if(pi.Status=='Pending'){
                    if(String.valueOf(pi.Workitems[0].ActorId).startsWith('005')){
                        if(pi.Workitems[0].ActorId==UserInfo.getUserId() || users[0].Profile.Name=='System Administrator'){
                            showActions=true;
                        }
                    }else{
                        set<String> queueMembers = new set<String>();
                        list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type 
                                              FROM Group Where Id =: pi.Workitems[0].ActorId limit 1];
                        if((groups != null && groups.size()>0) && groups[0].Type=='Queue'){
                            for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId =: groups[0].Id]){
                                if(String.valueOf(sgm.UserOrGroupId).startsWith('005')){
                                    queueMembers.add(sgm.UserOrGroupId);
                                }
                            }
                            
                            if(queueMembers.contains(UserInfo.getUserId()) || users[0].Profile.Name=='System Administrator'){
                                showActions=true;
                            }
                        }
                    }
                }
            }
            
            list<nu_dse__Group_Task__c> tasks = [select Name, OwnerId, Owner.Name, Manager_decline_reason__c, 
                                                 CreatedById, CreatedBy.Name, CreatedBy.Email, Total_fund_required__c, 
                                                 Funds_need_to_be_available_by_date__c, Recoup_timeframe__c, Program__c,
                                                 Tradeline_s_to_be_advanced__c, Type_of_Request__c, 
                                                 Were_additional_funds_requested__c, Perfect_Draft_History__c,
                                                 Settlement_type__c, BBB_Attorney_General_complaint__c,
                                                 Client_s_total_months_in_program__c, Legal_file_number__c,
                                                 Advancement_Facilitates_Lit_Settlement__c
                                                 From nu_dse__Group_Task__c 
                                                 Where id =:tskId];
            tsk=tasks != null && tasks.size()>0 ? tasks[0] : new nu_dse__Group_Task__c();
            redirectPage = new PageReference('/'+tskId);
        }else{
            isError=true;
        }
    }
    
    public PageReference Approve(){
        if(showActions){
            if(tsk.Manager_decline_reason__c == null || tsk.Manager_decline_reason__c == ''){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkItemRequest();
                req.setComments(tsk.Manager_decline_reason__c);
                req.setWorkitemId(pi.Workitems[0].Id);
                req.setAction('Approve');
                Approval.ProcessResult result =  Approval.process(req);
                update tsk;
                
                list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Payment Processing' limit 1];
                system.debug('### groups: '+groups.size());
                if(groups != null && groups.size()>0){
                    nu_dse__Group_Task__c paymentTask = tsk.clone(false, false, false, false);
                    String tskDescription='Advancement Amount:'+tsk.Total_fund_required__c+'\n';
                    tskDescription+='Advancement Date:'+tsk.Funds_need_to_be_available_by_date__c+'\n';
                    tskDescription+='Recoup date(s):'+tsk.Recoup_timeframe__c+'\n';
                    //tskDescription+='Requested by:'+tsk.CreatedBy.Name+'\n';
                    //tskDescription+='Approved by:'+tsk.Owner.Name;
                    paymentTask.Parent_Task__c=tsk.Id;
                    paymentTask.Program__c=tsk.Program__c;
                    paymentTask.nu_dse__Related_To__c=tsk.Program__c;
                    paymentTask.Department__c='Payments';
                    paymentTask.nu_dse__Subject__c='Advancement for Settlements';
                    paymentTask.Subject_Picklist__c='Advancement for Settlements';
                    paymentTask.OwnerId=groups[0].Id;
                    paymentTask.Manager_decline_reason__c='';
                    paymentTask.nu_dse__Description__c=tskDescription;
                    paymentTask.nu_dse__ActivityDate__c=System.Today().addDays(1);
                    insert paymentTask;
                }
                
                // Send email to submitter/negotiator
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { tsk.CreatedBy.Email };
                message.optOutPolicy = 'FILTER';
                message.subject = 'Advance Settelement Approved';
                String emailBodyStr = 'Hi '+tsk.CreatedBy.Name+'</br></br>';
                emailBodyStr+='Your Advance Settlement has been approved. for more details: </br>';
                emailBodyStr+='<a href="'+URL.getSalesforceBaseUrl().getHost()+'/'+tsk.Id+'" target="_Blank">Click here</a> </br></br>';
                emailBodyStr+='Thanks.';
                message.htmlBody = emailBodyStr;
                
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
                
                return redirectPage ;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please remove the \'Rejection Reason\' while approving the advancement.'));
            }
        }
        return null;
    }
    
    public PageReference Reject(){
        if(showActions){
            if(tsk.Manager_decline_reason__c != null && tsk.Manager_decline_reason__c != ''){
                ProcessInstance[] pi = [Select ID, Status, TargetObject.Name, 
                                            (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                            (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                            Where TargetObjectID =: tskId AND Status = 'Pending'];
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkItemRequest();
                req.setComments(tsk.Manager_decline_reason__c);
                req.setWorkitemId(pi[0].Workitems[0].Id);
                req.setAction('Reject');
                Approval.ProcessResult result =  Approval.process(req);
                update tsk;
                return redirectPage ;  
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Rejection reason is mandatory.'));
            }
        }
        return null;
    }
    
    public PageReference Cancel(){
        return redirectPage ;
    }

}