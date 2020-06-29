/**
 * Name			:	SFSPortal_AFSettlementCtrl
 * Author		:	Amit Goyal
 * Date			:	10/Sept/2019
 * Description	:	To Create Advance Fund Settlement from the Program Detail Page
 * Usage		:	related component is placed on HealthPageTab
 * */

public class SFSPortal_AFSettlementCtrl{
    public nu_dse__Program__c programInstance {get; set;}
    public User userInstance {get; set;}
    
    public Boolean isFeeAdvancement {get; set;}
    public nu_dse__Group_Task__c tsk {get; set;}
    
    public list<SelectOption> tradelines {get; set;}
    public list<String> selectedTradelines {get; set;}
    
    public String programId {get;
        set {
            if(programId == null) {
                programId = value;
                init();
            }
        }
    }
    
    public SFSPortal_AFSettlementCtrl(){
        programInstance=new nu_dse__Program__c();
        isFeeAdvancement=false;
        tsk= new nu_dse__Group_Task__c();
        tradelines = new list<SelectOption>();
        selectedTradelines = new list<String>();
    }
    
    public void resetRequest(){
        programInstance=new nu_dse__Program__c();
        isFeeAdvancement=false;
        tsk= new nu_dse__Group_Task__c();
        tradelines = new list<SelectOption>();
        selectedTradelines = new list<String>();
        init();
    }
    
    public void submitAdvFundSettlement(){
        // Create a Group Task with the given data
        System.debug('**** this.recordId-->' + this.programId);
        if((this.programId != null && this.programId.trim().length()>0) && isFeeAdvancement == true)
        {
            Boolean isValidRequest = true;
            
            if(tsk.Total_fund_required__c == null || tsk.Total_fund_required__c<=0)
            {
                isValidRequest=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '\'Total fund required\', Please enter a valid fund value.'));
            }
            
            if(tsk.Funds_need_to_be_available_by_date__c == null || tsk.Funds_need_to_be_available_by_date__c < System.Today())
            {
                isValidRequest=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '\'Funds need to be available by date\', should be today or a future date.'));
            }
            
            if(tsk.Recoup_timeframe__c == null || tsk.Recoup_timeframe__c < System.Today())
            {
                isValidRequest=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '\'Recoup timeframe\', should be today or a future date.'));
            }
            
            if(selectedTradelines.isEmpty())
            {
                isValidRequest=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '\'Tradeline(s) to be advanced\', select some tradelines.'));
            }
            
            if(isValidRequest==true && (tsk.Type_of_Request__c != null && tsk.Type_of_Request__c != '') && 
               (tsk.Were_additional_funds_requested__c != null && tsk.Were_additional_funds_requested__c != '') && 
               (tsk.Perfect_Draft_History__c != null && tsk.Perfect_Draft_History__c != '') &&
               (tsk.BBB_Attorney_General_complaint__c != null && tsk.BBB_Attorney_General_complaint__c != '') && 
               (tsk.Advancement_Facilitates_Lit_Settlement__c != null &&  tsk.Advancement_Facilitates_Lit_Settlement__c != '') && 
               (tsk.Settlement_type__c != null && tsk.Settlement_type__c != ''))
            {
                // criteria that does not require manager approval
                // - Non Lit Offer Advancement request of $250 and below 
                // - Litigation Offer Advancement request of $150 and below
                String taskType='PaymentGroupTask';
                if((tsk.Advancement_Facilitates_Lit_Settlement__c=='Yes' && tsk.Total_fund_required__c>150) || (tsk.Advancement_Facilitates_Lit_Settlement__c=='No' && tsk.Total_fund_required__c>250))
                {
                    taskType='IndividualGroupTask';
                }
                String tradelineStr='';
                for(String str: selectedTradelines){
                    tradelineStr+=str+',';
                }
                tradelineStr=tradelineStr.substring(0, tradelineStr.length()-1);
                tsk.Tradeline_s_to_be_advanced__c=tradelineStr;
                String tskDescription='';
                
                String userId='';
                userId=UserInfo.getUserId();
                tsk.Program__c=this.programId;
                tsk.nu_dse__Related_To__c=this.programId;
                if(taskType=='IndividualGroupTask'){
                    tskDescription+='Total funds required: '+tsk.Total_fund_required__c+'\n';
                    tskDescription+='Funds need to be available by date:'+tsk.Funds_need_to_be_available_by_date__c+'\n';
                    tskDescription+='Recoup timeframe:'+tsk.Recoup_timeframe__c+'\n';
                    tskDescription+='Tradeline(s) to be advanced:'+tsk.Tradeline_s_to_be_advanced__c+'\n';
                    tskDescription+='Type of Request:'+tsk.Type_of_Request__c+'\n';
                    tskDescription+='Funds requested previously:'+tsk.Were_additional_funds_requested__c+'\n';
                    tskDescription+='Draft History:'+tsk.Perfect_Draft_History__c+'\n';
                    
                    tskDescription+='How was the client serviced (Explanation of back service):';
                    if(tsk.How_was_the_client_serviced__c != null && tsk.How_was_the_client_serviced__c.trim().length()>0){
                        tskDescription+=tsk.How_was_the_client_serviced__c;
                    }
                    tskDescription+='\n';
                    
                    tskDescription+='BBB/Attorney General complaint:'+tsk.BBB_Attorney_General_complaint__c+'\n';
                    
                    tskDescription+='Total months client has been in program:';
                    if(tsk.Client_s_total_months_in_program__c != null && tsk.Client_s_total_months_in_program__c>0){
                        tskDescription+=tsk.Client_s_total_months_in_program__c;
                    }
                    tskDescription+='\n';
                    
                    tskDescription+='Legal file number:';
                    if(tsk.Legal_file_number__c != null && tsk.Legal_file_number__c.trim().length()>0){
                        tskDescription+=tsk.Legal_file_number__c;
                    }
                    tskDescription+='\n';
                    
                    tskDescription+='Advancement Facilitates Lit Settlement:'+tsk.Advancement_Facilitates_Lit_Settlement__c+'\n';
                    tskDescription+='Settlement type:'+tsk.Settlement_type__c;
                    
                    tsk.nu_dse__Subject__c='Request to Advance Funds';
                    tsk.Subject_Picklist__c='Request to Advance Funds';
                    tsk.OwnerId=userId;
                    tsk.nu_dse__Description__c=tskDescription;
                }else{
                    tskDescription+='Advancement Amount:'+tsk.Total_fund_required__c+'\n';
                    tskDescription+='Advancement Date:'+tsk.Funds_need_to_be_available_by_date__c+'\n';
                    tskDescription+='Recoup date(s):'+tsk.Recoup_timeframe__c+'\n';
                    //tskDescription+='Requested by:'+tsk.CreatedBy.Name+'\n';
                    //tskDescription+='Approved by:'+tsk.Owner.Name;
                    tsk.Department__c='Payments';
                    tsk.nu_dse__Subject__c='Advancement for Settlements';
                    tsk.Subject_Picklist__c='Advancement for Settlements';
                    list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Payment Processing' limit 1];
                    tsk.OwnerId=groups[0].Id;
                    tsk.nu_dse__Description__c=tskDescription;
                    tsk.Manager_decline_reason__c='';
                }
                // 1 business day out
                tsk.nu_dse__ActivityDate__c=System.Today().addDays(1);
                
                system.debug('### tsk: '+tsk);
                insert tsk;
                
                resetRequest();
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please fill in all required (*) fields.'));
            }
        }else{
            // Invalid request
        }
    }
    
    public void init() {
        System.debug('**** this.recordId-->' + this.programId);
        if(String.isNotBlank(this.programId) == TRUE) {
            List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Account__c, nu_dse__Account__r.PersonContactId, 
                                                    Client_Portal_User_Id__c, (Select Id, Name From nu_dse__TradeLines__r)
                                                    FROM nu_dse__Program__c WHERE Id =: this.programId];
            System.debug('*** programList--> ' + programList);
            tradelines = new list<SelectOption>();
            if(!programList.isEmpty()) {
                //this.programInstance = programList[0];
                if(programList[0].nu_dse__Account__r.PersonContactId != null)
                {
                    List<User> userList = [SELECT Id, Name, ManagerId, LastLoginDate, Email, Source_Type__c, CreatedDate, PortalUserEmail__c, PortalUserMobile__c, MobilePhone, LastPasswordChangeDate 
                                           FROM User WHERE ContactId =: programList[0].nu_dse__Account__r.PersonContactId];
                    if(userList.isEmpty() == FALSE)
                    {
                        this.userInstance = userList[0];
                    }
                }else{
                    List<User> userList = [SELECT Id, Name, ManagerId, LastLoginDate, Email, Source_Type__c, CreatedDate, PortalUserEmail__c, PortalUserMobile__c, MobilePhone, LastPasswordChangeDate 
                                           FROM User WHERE Id =: UserInfo.getUserId()];
                    if(userList.isEmpty() == FALSE)
                    {
                        this.userInstance = userList[0];
                    }
                }
                
                System.debug('**** this.userInstance-->' + this.userInstance);
                System.debug('**** account-->' + programList[0].nu_dse__Account__c);
                
                if(!programList[0].nu_dse__TradeLines__r.isEmpty()){
                    for(nu_dse__TradeLine__c tradeline: programList[0].nu_dse__TradeLines__r){
                        tradelines.add(new SelectOption(tradeline.Name, tradeline.Name));
                    }
                }
            }
        }
    }
}