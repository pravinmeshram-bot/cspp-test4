public class Offer_ApprovalScreenCtrl {
    public String ofrId;
    public ProcessInstance objProcessInstance;
    public nu_dse__Offer__c ofr {get; set;}
    public PageReference redirectPage;
    public Boolean isError {get; set;}
    public ProcessInstance pi;
    public Boolean showActions {get; set;}
    public list<String> statusOptions;
    public string commentStr {get; set;}
    public Offer_ApprovalScreenCtrl(ApexPages.StandardController stdCtrl){
        ofrId=stdCtrl.getId();
        statusOptions=new list<String>{'Pending', 'Management Approved', 'Pending Creditor Approval', 'Pending Client Approval', 'Offer Made' ,'Canceled'};
        isError=false;
        showActions=false;
        commentStr='';
        dataSetup();
    }
    // testing the process
    public Offer_ApprovalScreenCtrl(){
        ofrId = ApexPages.currentPage().getParameters().get('recId');
        statusOptions=new list<String>{'Pending', 'Management Approved', 'Pending Creditor Approval', 'Pending Client Approval', 'Offer Made','Canceled'};
        isError=false;
        showActions=false;
        commentStr='';
        dataSetup();
    }
    
    public void dataSetup(){
        if(ofrId != null && ofrId.trim().length()>0){
            list<nu_dse__Offer__c> offers = [select Id, Name, nu_dse__TradeLine__c, nu_dse__Program__c, NDS_Creditor_Info__c,
                                             Creditor_Name__c, nu_dse__Collection_Agency__c, Notes__c, nu_dse__Status__c,
                                             nu_dse__Offer_Type__c, Original_Balance__c, nu_dse__Offer_Amount__c,
                                             nu_dse__Total_Settlement_with_Fee__c, Settlement__c, nu_dse__Number_of_Payments__c,
                                             nu_dse__Counter_Proposal__c, nu_dse__Fee_Re_Occurring_Day__c, nu_dse__Number_of_Fee_payments__c,
                                             nu_dse__First_Payment_Date__c, nu_dse__Payment_Re_Occuring_Day__c, nu_dse__Program_Fee__c,
                                             nu_dse__Program_Fee_Start_Date__c, nu_dse__Settlement_Contact_Number__c,
                                             nu_dse__Settlement_Contact_Person_Name__c, nu_dse__Settlement_Id__c, nu_dse__Settlement_Received__c,
                                             nu_dse__Upfront_Amount__c, nu_dse__Valid_Until__c,Admin_Approved__c, CreatedById, 
                                             CreatedBy.Name, CreatedBy.Email, LastModifiedBy.Name, Attorney_Settlement_Approval_Status__c,
                                             Timberline_Settlement_Approval_Status__c,Manager_Approved__c,DNL_Negotiations_Approval_Status__c,
                                             Letter_Uploaded__c,Authorization_Received__c,Is_Negotiation_Manager_Approved__c,
                                             Import_Id__c, nu_dse__Processor_Error__c,Rejection_Reason__c, Portfolio_Name__c, DNL_Status__c
                                             From nu_dse__Offer__c 
                                             Where id =:ofrId];
            ofr = offers != null && offers.size()>0 ? offers[0] : new nu_dse__Offer__c();
            set<String> firstStageProfiles = new set<String>{'System Administrator', 'Negotiations Manager', 'Negotiations Team Member', 'Performance Manager', 'NAR Associates', 'NAR Manager', 'DNL Payments Team Member', 'DNL Negotiations Director', 'DNL Payments Manager', 'Litigation Manager', 'Lit Support', 'Litigation Negotiator', 'NAR Director', 'Director Litigation', 'Director Negotiations', 'DNL Negotiations Team Member', 'Payments Processor','Client Experience Rep'};
            set<String> secondStageProfiles = new set<String>{'System Administrator', 'Lit Support Manager','Performance Manager','Litigation Manager', 'Negotiations Manager', 'NAR Associates', 'NAR Manager', 'NAR Director', 'Director Litigation', 'Director Negotiations', 'DNL Negotiations Director', 'DNL Payments Team Member', 'Lit Support', 'Litigation Negotiator', 'Negotiations Team Member', 'DNL Negotiations Team Member', 'DNL Payments Manager', 'Payments Processor','Client Experience Rep'};
            set<String> thirdStageProfiles = new set<String>{'System Administrator', 'NAR Associates', 'NAR Manager', 'NAR Director'};
            set<String> fourthStageProfiles = new set<String>{'System Administrator', 'Lit Support Manager', 'Litigation Manager', 'Negotiations Manager', 'Performance Manager', 'NAR Associates', 'NAR Manager', 'NAR Director', 'Director Litigation', 'Director Negotiations', 'DNL Negotiations Director', 'DNL Payments Team Member', 'Payments Manager'};
            
            //set<String> PreTILAProfiles = new Set<String>{'System Administrator','DNL Payments Manager', 'DNL Negotiations Manager'};

            list<User> users = [Select Id, Name, ProfileId, Profile.Name From User Where ProfileId =: UserInfo.getProfileId() limit 1];
            ProcessInstance[] piList = [Select ID, Status, TargetObject.Name, 
                                (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                Where TargetObjectID =: ofrId AND Status IN: statusOptions];
            pi=piList!=null && piList.size()>0 ? piList[0] : new ProcessInstance();
            if(pi != null && (pi.Workitems != null && pi.Workitems.size()>0)){
                if(statusOptions.contains(pi.Status)){
                    system.debug('### ActorId: '+pi.Workitems[0].ActorId);
                    system.debug('++++ofr++'+ofr);
                    
                    /*if(String.valueOf(pi.Workitems[0].ActorId).startsWith('005') || Test.isRunningTest()){
                        if(ofr.DNL_Status__c == 'Pre-TILA Signed'){
                            System.debug('Pre-TILA');
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || PreTILAProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        else{
                        System.debug('Non Pre-TILA');
                        */if(ofr.nu_dse__Status__c == 'In-House Attorney Review' && (ofr.Portfolio_Name__c != 'Harbor' || ofr.Portfolio_Name__c != 'Pioneer' || ofr.Portfolio_Name__c != 'Bedrock' || ofr.Portfolio_Name__c != 'Boulder' || ofr.Portfolio_Name__c != 'Stonepoint' || ofr.Portfolio_Name__c != 'CALF'  || ofr.Portfolio_Name__c != 'Option1Legal'  || ofr.Portfolio_Name__c != 'Canyon' || ofr.Portfolio_Name__c != 'GREATLAKES' || ofr.Portfolio_Name__c != 'Rockwell' || ofr.Portfolio_Name__c != 'Wyolawfirm' || ofr.Portfolio_Name__c != 'CarolinaLegalServices' || ofr.Portfolio_Name__c != 'Anchor' || ofr.Portfolio_Name__c != 'Northstar Legal Group' || ofr.Portfolio_Name__c != 'Whitestone' || ofr.Portfolio_Name__c != 'Heartland' || ofr.Portfolio_Name__c != 'MonarchLegalGroup') && (ofr.Attorney_Settlement_Approval_Status__c == 'None' || ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Rejected'))
                        {
                            //Step-1-Attorney
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || firstStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.nu_dse__Status__c == 'Management Review' && (ofr.Timberline_Settlement_Approval_Status__c == 'None' || ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Rejected'))
                        {
                            //Step-1- Timberline
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || firstStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.Manager_Approved__c == False && ofr.nu_dse__Status__c  == 'DNL Manager Review' && (ofr.DNL_Negotiations_Approval_Status__c == 'None' || ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Rejected'))
                        {
                            //Step-1-DNL
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || firstStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'In-House Attorney Approved') && (ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.Attorney_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' || ofr.Attorney_Settlement_Approval_Status__c == 'None'))
                        {
                            //Step-2 - Attorney
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || secondStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'Management Approved') && (ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' ))
                        {
                            //Step-2 - Timberline
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || secondStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.Authorization_Received__c == True && ofr.Letter_Uploaded__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Rejected'))
                        {
                            //Step-2-DNL
                            // as second step in DNL is NAR approval
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || thirdStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Attorney_Settlement_Approval_Status__c== 'Obtain Authorization Approved' || ofr.Attorney_Settlement_Approval_Status__c== 'Negotiations Associate Review Rejected')){
                            //Step-3 - Attorney
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || thirdStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Negotiations Associate Review Rejected')){
                            //Step-3- Timberline
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || thirdStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.Is_Negotiation_Manager_Approved__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Payment Processing Rejected'))
                        {
                            //Step-3-DNL
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || fourthStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Attorney_Settlement_Approval_Status__c=='Negotiations Associate Review Approved' || ofr.Attorney_Settlement_Approval_Status__c=='Payment Processing Rejected')){
                            //Step-4 - Attorney
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || fourthStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        
                        if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Timberline_Settlement_Approval_Status__c =='Negotiations Associate Review Approved' || ofr.Timberline_Settlement_Approval_Status__c =='Payment Processing Rejected')){
                            //Step-4- Timberline
                            if(pi.Workitems[0].ActorId==UserInfo.getUserId() || fourthStageProfiles.contains(users[0].Profile.Name)){
                                showActions=true;
                            }
                        }
                        //}
                    }
                    
                    if(!String.valueOf(pi.Workitems[0].ActorId).startsWith('005')){
                        set<String> queueMembers = new set<String>();
                        list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type 
                                              FROM Group Where Id =: pi.Workitems[0].ActorId limit 1];
                        
                    /*if(ofr.DNL_Status__c == 'Pre-TILA Signed'){
                        System.debug('Pre-TILA');
                        if(queueMembers.contains(UserInfo.getUserId()) || PreTILAProfiles.contains(users[0].Profile.Name)){
                            showActions=true;
                        }
                    }
                    else{
                    System.debug('Non Pre-TILA');*/
                        if((groups != null && groups.size()>0) && groups[0].Type=='Queue'){
                            for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId =: groups[0].Id]){
                                if(String.valueOf(sgm.UserOrGroupId).startsWith('005')){
                                    queueMembers.add(sgm.UserOrGroupId);
                                }
                            }
                            
                            
                            
                            if(ofr.nu_dse__Status__c == 'In-House Attorney Review' && (ofr.Portfolio_Name__c != 'Harbor' || ofr.Portfolio_Name__c != 'Pioneer' || ofr.Portfolio_Name__c != 'Bedrock' || ofr.Portfolio_Name__c != 'Boulder' || ofr.Portfolio_Name__c != 'Stonepoint' || ofr.Portfolio_Name__c != 'CALF'  || ofr.Portfolio_Name__c != 'Option1Legal'  || ofr.Portfolio_Name__c != 'Canyon' || ofr.Portfolio_Name__c != 'GREATLAKES' || ofr.Portfolio_Name__c != 'Rockwell' || ofr.Portfolio_Name__c != 'Wyolawfirm' || ofr.Portfolio_Name__c != 'CarolinaLegalServices' || ofr.Portfolio_Name__c != 'Anchor' || ofr.Portfolio_Name__c != 'Northstar Legal Group' || ofr.Portfolio_Name__c != 'Whitestone' || ofr.Portfolio_Name__c != 'Heartland' || ofr.Portfolio_Name__c != 'MonarchLegalGroup') && (ofr.Attorney_Settlement_Approval_Status__c == 'None' || ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Rejected'))
                            {
                                //Step-1-Attorney
                                if(queueMembers.contains(UserInfo.getUserId()) || firstStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.nu_dse__Status__c == 'Management Review' && (ofr.Timberline_Settlement_Approval_Status__c == 'None' || ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Rejected'))
                            {
                                //Step-1- Timberline
                                if(queueMembers.contains(UserInfo.getUserId()) || firstStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.Manager_Approved__c == False && ofr.nu_dse__Status__c  == 'DNL Manager Review' && (ofr.DNL_Negotiations_Approval_Status__c == 'None' || ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Rejected'))
                            {
                                //Step-1-DNL
                                if(queueMembers.contains(UserInfo.getUserId()) || firstStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'In-House Attorney Approved') && (ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.Attorney_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' || ofr.Attorney_Settlement_Approval_Status__c == 'None'))
                            {
                                //Step-2 - Attorney
                                if(queueMembers.contains(UserInfo.getUserId()) || secondStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'Management Approved') && (ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' ))
                            {
                                //Step-2 - Timberline
                                if(queueMembers.contains(UserInfo.getUserId()) || secondStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.Authorization_Received__c == True && ofr.Letter_Uploaded__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Rejected'))
                            {
                                //Step-2-DNL
                                // as second step in DNL is NAR approval
                                if(queueMembers.contains(UserInfo.getUserId()) || thirdStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Attorney_Settlement_Approval_Status__c== 'Obtain Authorization Approved' || ofr.Attorney_Settlement_Approval_Status__c== 'Negotiations Associate Review Rejected')){
                                //Step-3 - Attorney
                                if(queueMembers.contains(UserInfo.getUserId()) || thirdStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Negotiations Associate Review Rejected')){
                                //Step-3- Timberline
                                if(queueMembers.contains(UserInfo.getUserId()) || thirdStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.Is_Negotiation_Manager_Approved__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Payment Processing Rejected'))
                            {
                                //Step-3-DNL
                                if(queueMembers.contains(UserInfo.getUserId()) || fourthStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Attorney_Settlement_Approval_Status__c=='Negotiations Associate Review Approved' || ofr.Attorney_Settlement_Approval_Status__c=='Payment Processing Rejected')){
                                //Step-4 - Attorney
                                if(queueMembers.contains(UserInfo.getUserId()) || fourthStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Timberline_Settlement_Approval_Status__c =='Negotiations Associate Review Approved' || ofr.Timberline_Settlement_Approval_Status__c =='Payment Processing Rejected')){
                                //Step-4- Timberline
                                if(queueMembers.contains(UserInfo.getUserId()) || fourthStageProfiles.contains(users[0].Profile.Name)){
                                    showActions=true;
                                }
                            }
                            
                            //}
                       // }
                    }
                }
            }
            redirectPage = new PageReference('/'+ofrId);
        }else{
            isError=true;
        }
    }
    
    public PageReference Approve(){
        system.debug('### showActions: '+showActions);
        try{
            if(showActions){
                system.debug('### Rejection_Reason__c: '+ofr.Rejection_Reason__c);
                // if((ofr.Rejection_Reason__c == null || ofr.Rejection_Reason__c == '') && (commentStr == null || commentStr == ''))
                if(ofr.Rejection_Reason__c == null || ofr.Rejection_Reason__c == '') 
                {
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkItemRequest();
                    req.setComments(commentStr );
                    req.setWorkitemId(pi.Workitems[0].Id);
                    req.setAction('Approve');
                    Approval.ProcessResult result =  Approval.process(req);
                    //update ofr;
                    
                    // Send email to submitter/negotiator
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] { ofr.CreatedBy.Email };
                    message.optOutPolicy = 'FILTER';
                    message.subject = 'Advance Settelement Approved';
                    String emailBodyStr = 'Hi '+ofr.CreatedBy.Name+'</br></br>';
                    emailBodyStr+='Your Advance Settlement has been approved. for more details: </br>';
                    emailBodyStr+='<a href="'+URL.getSalesforceBaseUrl().getHost()+'/'+ofr.Id+'" target="_Blank">Click here</a> </br></br>';
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
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please remove the \'Rejection Reason\' and \'Comment\' while approving the advancement.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please remove the "Rejection Reason" while approving the offer'));
                    system.debug('### error: remove rejection reason');
                }
            }
        } 
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
        }
        return null;
    }
    
    public PageReference Reject(){
        try{
            if(showActions){
                system.debug('####Rejection Reason -->'+ ofr.Rejection_Reason__c);
                if(ofr.Rejection_Reason__c != null && ofr.Rejection_Reason__c != ''){
                    if(ofr.nu_dse__Status__c == 'In-House Attorney Review' && (ofr.Portfolio_Name__c != 'Harbor' || ofr.Portfolio_Name__c != 'Pioneer' || ofr.Portfolio_Name__c != 'Bedrock' || ofr.Portfolio_Name__c != 'Boulder' || ofr.Portfolio_Name__c != 'Stonepoint' || ofr.Portfolio_Name__c != 'CALF'  || ofr.Portfolio_Name__c != 'Option1Legal'  || ofr.Portfolio_Name__c != 'Canyon' || ofr.Portfolio_Name__c != 'GREATLAKES' || ofr.Portfolio_Name__c != 'Rockwell' || ofr.Portfolio_Name__c != 'Wyolawfirm' || ofr.Portfolio_Name__c != 'CarolinaLegalServices' || ofr.Portfolio_Name__c != 'Anchor' || ofr.Portfolio_Name__c != 'Northstar Legal Group' || ofr.Portfolio_Name__c != 'Whitestone' || ofr.Portfolio_Name__c != 'Heartland' || ofr.Portfolio_Name__c != 'MonarchLegalGroup') && (ofr.Attorney_Settlement_Approval_Status__c == 'None' || ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Rejected'))
                    {
                        //Step-1-Attorney
                        ofr.nu_dse__Status__c = 'In-House Attorney Denied';
                        ofr.Attorney_Settlement_Approval_Status__c = 'In-House Attorney Review Rejected';
                    }
                    
                    if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'In-House Attorney Approved') && (ofr.Attorney_Settlement_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.Attorney_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' || ofr.Attorney_Settlement_Approval_Status__c == 'None'))
                    {
                        //Step-2-Attorney
                        ofr.nu_dse__Status__c = 'Management Denied';
                        ofr.Attorney_Settlement_Approval_Status__c = 'Obtain Authorization Rejected';
                    }
                    
                    if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Attorney_Settlement_Approval_Status__c== 'Obtain Authorization Approved' || ofr.Attorney_Settlement_Approval_Status__c== 'Negotiations Associate Review Rejected')){
                        //Step-3-Attorney
                        ofr.nu_dse__Status__c = 'Negotiations Associate Denied';
                        ofr.Attorney_Settlement_Approval_Status__c = 'Negotiations Associate Review Rejected';
                    }
                    
                    if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Attorney_Settlement_Approval_Status__c=='Negotiations Associate Review Approved' || ofr.Attorney_Settlement_Approval_Status__c=='Payment Processing Rejected')){
                        //Step-4-Attorney
                        ofr.nu_dse__Status__c = 'Payments Department Denied';
                        ofr.Attorney_Settlement_Approval_Status__c = 'Payment Processing Rejected';
                    }
                    
                    if(ofr.nu_dse__Status__c == 'Management Review' && (ofr.Timberline_Settlement_Approval_Status__c == 'None' || ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Rejected'))
                    {
                        //Step-1- Timberline
                        ofr.nu_dse__Status__c = 'Management Denied';
                        ofr.Timberline_Settlement_Approval_Status__c = 'Management Review Rejected';
                    }
                    
                    if((ofr.nu_dse__Status__c == 'Pending Client Approval' ||  ofr.nu_dse__Status__c == 'Pending Creditor Approval' || ofr.nu_dse__Status__c == 'Management Approved') && (ofr.Timberline_Settlement_Approval_Status__c == 'Management Review Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Rejected' ))
                    {
                        //Step-2- Timberline
                        ofr.nu_dse__Status__c = 'Settlement Auth Denied';
                        ofr.Timberline_Settlement_Approval_Status__c = 'Obtain Authorization Rejected';
                    }
                    
                    if(ofr.nu_dse__Status__c=='Authorization and Letter Received' && (ofr.Timberline_Settlement_Approval_Status__c == 'Obtain Authorization Approved' || ofr.Timberline_Settlement_Approval_Status__c == 'Negotiations Associate Review Rejected')){
                        //Step-3- Timberline
                        ofr.nu_dse__Status__c = 'Negotiations Associate Denied';
                        ofr.Timberline_Settlement_Approval_Status__c = 'Negotiations Associate Review Rejected';
                    }
                    
                    if(ofr.nu_dse__Status__c == 'To Payment Processing' && (ofr.Timberline_Settlement_Approval_Status__c =='Negotiations Associate Review Approved' || ofr.Timberline_Settlement_Approval_Status__c =='Payment Processing Rejected')){
                        //Step-4- Timberline
                        ofr.nu_dse__Status__c = 'Payments Department Denied';
                        ofr.Timberline_Settlement_Approval_Status__c = 'Payment Processing Rejected';
                    }
                    
                    if(ofr.Manager_Approved__c == False && ofr.nu_dse__Status__c  == 'DNL Manager Review' && (ofr.DNL_Negotiations_Approval_Status__c == 'None' || ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Rejected'))
                    {
                        //Step-1-DNL
                        ofr.nu_dse__Status__c = 'Canceled';
                        //ofr.DNL_Negotiations_Approval_Status__c = 'In-House Attorney Review Rejected';
                    }
                    
                    system.debug('####Authorization Received --> ' + ofr.Authorization_Received__c);
                    system.debug('####Letter Uploaded --> ' + ofr.Letter_Uploaded__c);
                    system.debug('####DNL Negotiations Approval Status --> ' + ofr.DNL_Negotiations_Approval_Status__c);
                    if(ofr.Authorization_Received__c == True && ofr.Letter_Uploaded__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'In-House Attorney Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Rejected'))
                    {
                        //Step-2
                        ofr.nu_dse__Status__c = 'Canceled';
                        //  ofr.DNL_Negotiations_Approval_Status__c = 'Negotiations Associate Review Rejected';
                        
                    }
                    
                    if(ofr.Is_Negotiation_Manager_Approved__c == True && (ofr.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Approved' || ofr.DNL_Negotiations_Approval_Status__c == 'Payment Processing Rejected'))
                    {
                        //Step-3
                        ofr.nu_dse__Status__c = 'Canceled';
                        // ofr.DNL_Negotiations_Approval_Status__c = 'Payment Processing Rejected';
                    }
                    
                    ProcessInstance[] pi = [Select ID, Status, TargetObject.Name, 
                                            (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                                            (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance 
                                            Where TargetObjectID =: ofrId AND Status IN: statusOptions];
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkItemRequest();
                    
                    req.setComments(commentStr);
                    
                    system.debug('####Approval process work item request-->' + req);
                    
                    req.setWorkitemId(pi[0].Workitems[0].Id);
                    system.debug('777788777'+pi[0].Workitems[0].Id);
                    req.setAction('Reject');
                    system.debug('###Result-->'+ req);
                    
                    Approval.ProcessResult result =  Approval.process(req);
                    system.debug('###AppResult-->'+ result);
                    
                    update ofr;
                    return redirectPage ;  
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Rejection reason is mandatory.'));
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));  
        }
        return null;
    }
    
    public PageReference Cancel(){
        return redirectPage;
    }
}