public Class Prizm_LeadTriggerHandler{

    public Static boolean isTriggerExecuted = false;

    public static void Prizm_LeadTriggerBefore(){
        List<String> FileNumbers = new List<String>();
        List<Id> LeadIds = new List<Id>();
        for(Lead l : (List<Lead>)Trigger.New){
            l.Lead_Id__c = l.Id;
            FileNumbers.add(l.NDS_File_Number__c);
            if(Trigger.isUpdate && l.NDS_File_Number__c != null && l.NDS_File_Number__c != ''){
                LeadIds.add(l.Id);
            }
        }
        
        List<nu_dse__Program__c> ProgramList = [Select Id,Import_ID__c,nu_dse__Total_Debt_Included__c,nu_dse__Account__c, nu_dse__Account__r.LastName, nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.nu_dse__SSN__c,
                                                Rollup_Draft_Amount__c,nu_dse__Account__r.nu_dse__Co_State__c, nu_dse__Account__r.nu_dse__CO_SSN_ENC__c, nu_dse__Account__r.MiddleName, nu_dse__Payment_Frequency__c
                                                from nu_dse__Program__c where Import_id__c =: FileNumbers];
        
        Map<String, nu_dse__Program__c> FileProgramMap = new Map<String, nu_dse__Program__c>();
        
        for(nu_dse__Program__c p : ProgramList){
            FileProgramMap.put(p.Import_id__c,p);
        }
        
        for(Lead l : (List<Lead>)Trigger.New){
            if(FileProgramMap.containsKey(l.NDS_File_Number__c) && l.NDS_File_Number__c != null && l.NDS_File_Number__c != '')
            {
                l.Program_Name__c = FileProgramMap.get(l.NDS_File_Number__c).id;
                //l.LastName = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.LastName;
                l.Applicant_State__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.PersonMailingState;
                l.Applicant_SSN__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.nu_dse__SSN__c;
                l.Co_Applicant_State__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.nu_dse__Co_State__c;
                l.Co_Applicant_SSN__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.nu_dse__CO_SSN_ENC__c;
                l.Account__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__c;
                l.MiddleName = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Account__r.MiddleName;
                l.Payment_Frequency__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Payment_Frequency__c;
                l.Last_Draft__c = FileProgramMap.get(l.NDS_File_Number__c).Rollup_Draft_Amount__c;
                
                l.Unsettled_Debt__c = FileProgramMap.get(l.NDS_File_Number__c).nu_dse__Total_Debt_Included__c; //DV-156
                if(Trigger.isInsert){
                    l.Latest_Lead__c = true;
                }
            }
            else
            {
                l.Program_Name__c = null;
                l.Applicant_State__c = null;
                l.Applicant_SSN__c = null;
                l.Co_Applicant_State__c = null;
                l.Co_Applicant_SSN__c = null;
                l.Account__c = null;
                l.MiddleName = null;
            }
        }
    }
    
    public static void Prizm_LeadTriggerAfter(){
        System.debug('***isAfter');
        List<Id> ProgramIds = new List<Id>();
        List<Id> RelatedProgramIds = new List<Id>();
        Map<Id,Id> ProgramLeadMap = new Map<Id,Id>();
        
        Map<Id,Lead> LeadOldMap = (Map<Id,Lead>)Trigger.oldMap;
        for(Lead l: (List<Lead>)Trigger.new){
            if(l.Program_Name__c != null && l.latest_lead__c == true){
                ProgramLeadMap.put(l.Program_Name__c,l.Id);
                if(Trigger.isInsert || l.Program_Name__c != LeadOldMap.get(l.Id).Program_Name__c){
                    RelatedProgramIds.add(l.Program_Name__c);
                }
                if(Trigger.isInsert || l.Status != LeadOldMap.get(l.Id).Status){
                    ProgramIds.add(l.Program_Name__c);
                }
            }
        }
        
        if(!ProgramIds.isEmpty()){
            isTriggerExecuted=true; 
            System.debug('****'+ProgramIds);
            
            Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
            Id SettlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByDeveloperName().get('Settlement').getRecordTypeId();
            
            List<nu_dse__Tradeline__c> TradeList = [Select Id, nu_dse__Program__c,Lead__c from nu_dse__Tradeline__c where nu_dse__Program__c=:RelatedProgramIds];
            List<nu_dse__Payment__c> PaymentList = [Select Id,nu_dse__Program__c,Lead__c from nu_dse__Payment__c where nu_dse__Program__c=:RelatedProgramIds AND (RecordTypeId =: DraftRecordTypeId OR RecordTypeId =: SettlementRecordTypeId)];
            System.debug('*****'+PaymentList);
            System.debug('*****'+TradeList);
            System.debug('*****'+TradeList.size());
            For(nu_dse__Tradeline__c Trade : TradeList){
                Trade.Lead__c = ProgramLeadMap.get(Trade.nu_dse__Program__c);
            }
            System.debug('*****Tradelist'+Tradelist);
            Update TradeList;
            
            For(nu_dse__Payment__c Payment : PaymentList){
                Payment.Lead__c = ProgramLeadMap.get(Payment.nu_dse__Program__c);
            }
            Update PaymentList;
            
        
        if(Trigger.isInsert){
            List<Lead> LeadList = [Select Id,Latest_Lead__c from Lead where Program_Name__c =: ProgramIds AND isConverted = false AND Id NOT In : Trigger.newMap.keySet()];
            For(Lead l : LeadList){
                l.Latest_Lead__c = false;
            }
            Update LeadList;
        }
        
        List<nu_dse__Program__c> ProgramList=[Select Id, DNL_Status__c, nu_dse__Program_Status__c from nu_dse__Program__c where id =: ProgramIds];
        Map<Id,Lead> LeadNewMap = (Map<Id,Lead>)Trigger.newMap;
        for(nu_dse__Program__c Program : ProgramList){
            if(Program.DNL_Status__c != 'Graduated DRP'){
                if(Trigger.isInsert){
                    Program.DNL_Status__c = 'Lead Active';
                } else if(ProgramLeadMap.get(Program.Id) != null && Trigger.newMap.get(ProgramLeadMap.get(Program.Id)) != null
                        &&  LeadNewMap.get(ProgramLeadMap.get(Program.Id)).Latest_Lead__c == true){
                    if(LeadNewMap.get(ProgramLeadMap.get(Program.Id)).Status == 'DNL Not Interested'){
                        Program.DNL_Status__c = 'Not Interested';
                    } else if(LeadNewMap.get(ProgramLeadMap.get(Program.Id)).Status == 'DNL Ineligible'){
                        Program.DNL_Status__c = 'Ineligible';
                    } else if(LeadNewMap.get(ProgramLeadMap.get(Program.Id)).Status == 'DNL Uncontacted'){
                        Program.DNL_Status__c = 'Uncontacted';
                    } 
                }
            }
        }
        Update ProgramList;
        }
    }

    public Static void roundRobinLeadAssignment(){
        List<Lead> LeadList = (List<Lead>)Trigger.new;
        
       /*
        //Get userid from group member object
        set<Id> setUserId = new set<Id>();
        List<User> lstUser = new List<User>();
       
        for(User u:[Select id,name from User Where Profile.Name='Pre-Sales']){
              setUserId.add(u.id); 
        }
        //Generate wrapper from users
        lstUser = [SELECT Id, Name, IsRoundRobinAllocationEnabled__c, 
                   LastRRAllocationStatusUpdatedDateTime__c FROM User 
                   WHERE Id In :setUserId AND IsRoundRobinAllocationEnabled__c = true];
        
        if(lstUser != null && lstUser.size() > 0){
            Integer totalMembers = lstUser.size();
            List<Lead> LeadUpdate = new List<Lead>();
            for(Lead l : LeadList){ 
                System.debug('****'+ l.lead_number__c);
                System.debug('****'+totalMembers);
                if(l.Lead_Number__c != null && totalMembers != 0 && Trigger.isInsert){
                    isTriggerExecuted=true; 
                    System.debug('**** Owner Assign');
                    Lead newLead = new Lead();
                    newLead.id = l.id;
                    Integer indexToAssign = Math.mod(Integer.valueOf(l.Lead_Number__c),totalMembers);
                    newLead.ownerId = lstUser[indexToAssign].Id;
                    
                    LeadUpdate.add(newLead);
                }
                System.debug('****'+l.ownerId);
            }
            
            Update LeadUpdate;
        }
    }  */
        List<GroupMember> GroupMemberList = [Select Id,UserOrGroupId from GroupMember where Group.Name = 'Lead Assignment' ORDER BY UserOrGroupId];
        Integer totalMembers = GroupMemberList.size();
        List<Lead> LeadUpdate = new List<Lead>();
        for(Lead l : LeadList){ 
            System.debug('****'+ l.lead_number__c);
            System.debug('****'+totalMembers);
            if(l.Lead_Number__c != null && totalMembers != 0 && Trigger.isInsert){
                isTriggerExecuted=true; 
                System.debug('**** Owner Assign');
                Lead newLead = new Lead();
                newLead.id = l.id;
                Integer indexToAssign = Math.mod(Integer.valueOf(l.Lead_Number__c),totalMembers);
                newLead.ownerId = GroupMemberList[indexToAssign].UserOrGroupId;
                
                LeadUpdate.add(newLead);
            }
            System.debug('****'+l.ownerId);
        }
        
        Update LeadUpdate;
    }
}