public without sharing class Attorney_CreateOrUpdateNDSOfferHandler {

    public static void updateFundsSource(){
        List<nu_dse__Offer__c> OfferList = (List<nu_dse__Offer__c>)Trigger.new;
        Map<Id,nu_dse__Offer__c> OfferNewMap = (Map<Id,nu_dse__Offer__c>)Trigger.newMap;
        Map<Id,nu_dse__Offer__c> OfferOldMap = (Map<Id,nu_dse__Offer__c>)Trigger.oldMap;
        List<Id> OfferIds = new List<Id>();
        for(nu_dse__Offer__c Offer: OfferList){
            if(Offer.Source_Of_Payment__c != OfferOldMap.get(Offer.Id).Source_Of_Payment__c){
                OfferIds.add(Offer.Id);
            }
        }
        
        if(!OfferIds.isEmpty()){
            Id settlementRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
            List<nu_dse__Payment__c> PaymentList = [Select Id, Funds_Source__c,nu_dse__Offer__c from nu_dse__Payment__c where nu_dse__Offer__c =: OfferIds and recordTypeId =: settlementRecordType];
            
            for(nu_dse__Payment__c Payment: PaymentList){
                if(OfferNewMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'PSA' || OfferNewMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Extra Funds Required'){
                    Payment.Funds_Source__c = 'PSA';
                } else if(OfferNewMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Client Direct'){
                    Payment.Funds_Source__c = 'Direct Pay';
                }
            }
            
            Update PaymentList;
        }
    }

    //S20-490: Developed by Uchit: Delete Canceled Tasks when Offer is Accepted
    public Static Boolean isTaskDeleted = false;
    public static void deleteCanceledTasks(){
        if(!isTaskDeleted){
            List<nu_dse__Offer__c> OfferList = Trigger.new;
            Map<Id,nu_dse__Offer__c> OfferOldMap = (Map<Id,nu_dse__Offer__c>)Trigger.oldMap;
            
            List<Id> OfferIds = new List<Id>();
            for(nu_dse__Offer__c Offer: OfferList){
                if(Offer.Authorization_Received__c && offer.nu_dse__Status__c == 'Accepted' && offer.nu_dse__Status__c != OfferOldMap.get(Offer.Id).nu_dse__Status__c){
                    OfferIds.add(Offer.Id);
                }
            }
            
            if(!OfferIds.isEmpty()){
                List<Task> TaskList = [Select Id, Status from Task where WhatId=:OfferIds AND Status='Canceled'];
                if(!TaskList.isEmpty())
                    Delete TaskList;
                isTaskDeleted= true; 
                   
            }
        }
    }
    
    //Changes for S20-307 made by Uchit Gandhi
    public static void validateOfferAccepted(){
        Map<Id, nu_dse__Offer__c> OfferOldMap = (Map<Id, nu_dse__Offer__c>)Trigger.oldMap;
        List<nu_dse__Offer__c> OfferList = Trigger.new;
        List<id> OfferIds = new List<Id>();
        for(nu_dse__Offer__c offer: OfferList){
            if(offer.nu_dse__Status__c == 'Accepted' && offer.nu_dse__Status__c != OfferOldMap.get(Offer.Id).nu_dse__Status__c && Offer.isAttorney__c){
                OfferIds.add(Offer.Id);
            }
        }
         
        if(!OfferIds.isEmpty()){
            Map<Id,nu_dse__Offer__c> OfferMap = new Map<Id,nu_dse__Offer__c>([Select Id, nu_dse__Program__r.DNL_Status__c from nu_dse__Offer__c where Id=:OfferIds]);
            List<nu_dse__Payment__c> PaymentList = [Select Id, Integration_Status__c, Attorney_Payment_Id__c,nu_dse__Offer__c, nu_dse__Offer__r.nu_dse__Program__r.DNL_Status__c from nu_dse__Payment__c where nu_dse__Offer__c =: OfferIds AND Integration_Status__c = 'Success' AND Attorney_Payment_Id__c != null AND RecordTypeId =: Attorney_StaticVariableUtility.settlementRecordId];
            Map<Id, List<nu_dse__Payment__c>> OfferPaymentMap = new Map<Id, List<nu_dse__Payment__c>>();
            for(nu_dse__Payment__c Payment: PaymentList){
                if(!OfferPaymentMap.containsKey(Payment.nu_dse__Offer__c)){
                    OfferPaymentMap.put(Payment.nu_dse__Offer__c,new List<nu_dse__Payment__c>());
                }
                OfferPaymentMap.get(Payment.nu_dse__Offer__c).add(Payment);
            }
            
            for(nu_dse__Offer__c Offer: OfferList){
                if((!OfferPaymentMap.containsKey(Offer.Id) || OfferPaymentMap.get(Offer.Id) == null || OfferPaymentMap.get(Offer.Id).isEmpty()) && OfferMap.get(Offer.Id).nu_dse__Program__r.DNL_Status__c != 'Pre-TILA Signed' && OfferIds.contains(Offer.Id) && Offer.isAttorney__c){
                    Offer.addError('Offer can not be accepted until Settlement Plan is generated in NDS');
                }
            }
        }
        
    }
    
    public Static Boolean CreatedByUpdated = false;
 //Created this method for NMI-315. Updating Offer Created By from NDS.   
    public static void UpdateOfferCreatedBy(){
        System.debug('****isInsert'+Trigger.isInsert);
        if(!CreatedByUpdated){
            List<nu_dse__Offer__c> OfferList = (List<nu_dse__Offer__c>)Trigger.new;
            Map<Id,nu_dse__Offer__c> OfferOldMap = (Map<Id,nu_dse__Offer__c>)Trigger.oldMap;
            
            List<String> CreatedByList = new List<String>();
            
            for(nu_dse__Offer__c Offer : OfferList){
                if(Offer.NDS_Created_By__c != null && !Offer.NDS_Created_By__c.equalsIgnoreCase('dev_team') && Offer.Offer_Created_By__c == null){//(Trigger.isInsert || Offer.NDS_Created_By__c != OfferOldMap.get(Offer.Id).NDS_Created_By__c) && !Offer.NDS_Created_By__c.equalsIgnoreCase('dev_team')){
                    CreatedByList.add(Offer.NDS_Created_By__c);
                    System.debug('****NDS created by changed');
                }
                
                //Added by Uchit for S20-144
                if(Offer.isattorney__c == True && (Trigger.isInsert || Offer.nu_dse__Status__c != OfferOldMap.get(Offer.Id).nu_dse__Status__c) && Offer.nu_dse__Status__c == 'To Payment Processing')
                {
                Offer.PushtoNDS__c = True;
                }
            }
            
            List<NDS_User_List__c> NDSUserList = [Select Id,Email__c, User_Name__c from NDS_User_List__c where User_Name__c =: CreatedByList];
            Map<String,NDS_User_List__c> NDSUserMap = new Map<String,NDS_User_List__c>();
            
            List<String> EmailList = new List<String>();
            for(NDS_User_List__c NDSUser : NDSUserList){
                EmailList.add(NDSUser.Email__c);
                NDSUserMap.put(NDSUser.User_Name__c,NDSUser);
            }
            
            List<User> UserList = [Select Id,Email,Name from user where Email =: EmailList OR Name='Data Integration User'];
            Map<String,User> UserMap = new Map<String,User>();
            User DataIntegrationUser = new User();
            for(User u : UserList){
                if(u.Name=='Data Integration User'){
                    DataIntegrationUser = u;
                }
                UserMap.put(u.Email,u);
            }
            
            
            System.debug('****'+DataIntegrationUser.Id);
            for(nu_dse__Offer__c Offer : OfferList){
                System.debug('**** Update Offer Created By loop');
                if(Offer.Offer_Created_By__c == null && Offer.CreatedById != DataIntegrationUser.Id && Offer.isAttorney__c){
                    System.debug('****NOt Created by Data integration');
                   Offer.Offer_Created_By__c = Offer.CreatedById;
                }
                if(Offer.NDS_Created_By__c != null && Offer.Offer_Created_By__c == null && Offer.isAttorney__c){
                    if(NDSUserMap.containsKey(Offer.NDS_Created_By__c) && UserMap.containsKey(NDSUserMap.get(Offer.NDS_Created_By__c).Email__c)){
                        Offer.Offer_Created_By__c= UserMap.get(NDSUserMap.get(Offer.NDS_Created_By__c).Email__c).id;
                    }
                }
                System.debug('****'+Offer.Offer_Created_By__c);
            }
            
            CreatedByUpdated = true;
        }        
        
        
    }
    
    //end of method for NMI-315. Updating Offer Created By from NDS.
    
    public static void UpdateOfferField(List<nu_dse__Offer__c> OfferList){
    
        Map<Id, nu_dse__Offer__c> programIdAndOffer = new Map<Id, nu_dse__Offer__c>();
    
        for(nu_dse__Offer__c offer : OfferList){
            //if(!Attorney_StaticVariableUtility.isFieldUpdated){
                system.debug(Attorney_StaticVariableUtility.isFieldUpdated);
                System.debug('*****LatestOffer');
                offer.Latest_Offer__c = true;
                programIdAndOffer.put(offer.nu_dse__Program__c, offer);
                system.debug(Attorney_StaticVariableUtility.isFieldUpdated);
            //}
        }
        //Attorney_StaticVariableUtility.isFieldUpdated = true;
                
        for (nu_dse__Program__c pgm : [SELECT Id, DNL_Status__c FROM nu_dse__Program__c 
                                       WHERE Id IN :programIdAndOffer.keySet() AND DNL_Status__c = 'Pre-TILA Signed']) {
                                       
            programIdAndOffer.get(pgm.Id).Renegotiable__c = TRUE;
        }
    }
    
    public static void UpdateRelatedOfferField(List<nu_dse__Offer__c> OfferList){
        
        //if(!Attorney_StaticVariableUtility.isRelatedOffersUpdated){
            System.debug(Attorney_StaticVariableUtility.isRelatedOffersUpdated);
            List<Id> TradeIds = new List<Id>();
            List<Id> OfferIds = new List<Id>();
            for(nu_dse__Offer__c Offer : OfferList){
                TradeIds.add(Offer.nu_dse__Tradeline__c);
                OfferIds.add(Offer.Id);
            }
            
            List<nu_dse__Offer__c> relatedOfferList = [Select Id, nu_dse__Tradeline__c, Latest_Offer__c, Renegotiable__c  from nu_dse__Offer__c where nu_dse__Tradeline__c =: TradeIds AND Id NOT IN : OfferIds AND latest_offer__c = true];
            
            Map<Id,List<nu_dse__Offer__c>> TradeOfferMap = new Map<Id, List<nu_dse__offer__c>>();
            
            For(nu_dse__Offer__c Offer : relatedOfferList){
                if(!TradeOfferMap.containsKey(offer.nu_dse__Tradeline__c)){
                    TradeOfferMap.put(offer.nu_dse__Tradeline__c,new List<nu_dse__Offer__c>());
                }
                TradeOfferMap.get(offer.nu_dse__Tradeline__c).add(offer);
            }
            
            
            List<nu_dse__Offer__c> UpdatedOfferList = new List<nu_dse__Offer__c>();
            
            for(nu_dse__Offer__c Offer : OfferList){
            
                if(offer.nu_dse__Tradeline__c != null && TradeOfferMap.get(offer.nu_dse__Tradeline__c)!=null){
                
                    for(nu_dse__Offer__c RelatedOffer : TradeOfferMap.get(offer.nu_dse__Tradeline__c)){
                    
                        RelatedOffer.Latest_Offer__c = false;
                        
                        if (RelatedOffer.Renegotiable__c == False) {
                            
                            RelatedOffer.nu_dse__status__c = 'Canceled';
                        }
                                                
                        if(!UpdatedOfferList.contains(RelatedOffer)) {
                            system.debug('###relatedoffer'+ RelatedOffer);
                            UpdatedOfferList.add(RelatedOffer);
                        }
                    }
                }
            }
            //Attorney_StaticVariableUtility.isRelatedOffersUpdated = true;
            Update UpdatedOfferList;
            
            //System.debug(Attorney_StaticVariableUtility.isRelatedOffersUpdated);
        //}
    }
    
    public Static boolean PaymentPush = false;   //Uchit 
    public static void CreateOrUpdateNDSPaymentOffer(List<nu_dse__Offer__c> ObjOfferList, Map<Id,nu_dse__Offer__c> ObjOfferOldMap){
    //Uchit
        if(!PaymentPush){
        List<Id> OfferIds = new List<Id>();
        for(nu_dse__Offer__c ObjOffer: ObjOfferList){
        if(ObjOffer.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false && ObjOffer.Latest_offer__c && ObjOffer.nu_dse__status__c !=ObjOfferOldMap.get(ObjOffer.Id).nu_dse__status__c && getOfferStatusLst().containsKey(ObjOffer.nu_dse__status__c) && getOfferStatusLst().get(ObjOffer.nu_dse__status__c).Active__c)
            {
                
                 OfferIds.add(ObjOffer.Id);
                 
                 }
            }
            
                if(!OfferIds.isEmpty()){
                
                Id SettlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
                List<nu_dse__Payment__c> PaymentList = [Select Id, PushToNDS__c
                                                        from nu_dse__Payment__c where nu_dse__Offer__c =: OfferIds 
                                                        AND RecordTypeId =: SettlementRecordTypeId];
                if(PaymentList != null){
                    System.debug('****'+Date.today());
                    
                    System.debug('*****'+PaymentList);
                    for(nu_dse__Payment__c Payment : PaymentList){
                        Payment.PushToNDS__c = True;
                        Payment.Integration_Status__c = 'Overflow';
                        
                    }
                    System.debug('*****'+PaymentList);
                    
                    Update PaymentList;
                } 
                
                PaymentPush = true;
            }
            }
                
               
                //End Uchit
        Boolean IsInsert = false;
        List<nu_dse__Offer__c> updateOfferList = new List<nu_dse__Offer__c>();
        
        Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('Offer',false);       

        for(nu_dse__Offer__c ObjOffer: ObjOfferList){
            system.debug(objOffer.IsAttorney__c);
            system.debug(Attorney_StaticVariableUtility.apiuser);
            System.debug(ObjOffer.PushToNDS__c);
            if(ObjOffer.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false && ObjOffer.PushToNDS__c == True && ObjOffer.Latest_offer__c) // Commented by Uchit for S20-144  && ObjOffer.nu_dse__status__c !=ObjOfferOldMap.get(ObjOffer.Id).nu_dse__status__c && getOfferStatusLst().containsKey(ObjOffer.nu_dse__status__c) && getOfferStatusLst().get(ObjOffer.nu_dse__status__c).Active__c)
            {
                
                System.debug('+++++ INN');
                System.debug('+++++ ObjOfferList' + string.valueOf(ObjOfferList));
                System.debug('+++++ ObjOfferOldMap' + string.valueOf(ObjOfferOldMap));
                
                if(ObjOffer.NDS_Offer_Id__c == null)
                    IsInsert = true;
                else
                    IsInsert = false;
                
                System.debug('+++++ IsInsert' + IsInsert);
                System.debug('+++++ IsRelatedRecordEligibleForPick__c' + ObjOffer.IsRelatedRecordEligibleForPick__c);
                
                if((IsInsert==false && ObjOffer.IsRelatedRecordEligibleForPick__c==true &&
                    (ObjOffer.Settlement_Status__c !=ObjOfferOldMap.get(ObjOffer.Id).Settlement_Status__c 
                                         || ObjOffer.nu_dse__status__c !=ObjOfferOldMap.get(ObjOffer.Id).nu_dse__status__c 

                     || ObjOffer.Suspended_On__c !=ObjOfferOldMap.get(ObjOffer.Id).Suspended_On__c 
                     || ObjOffer.nu_dse__Valid_Until__c !=ObjOfferOldMap.get(ObjOffer.Id).nu_dse__Valid_Until__c
               //      || ObjOffer.nu_dse__First_Payment_Date__c !=ObjOfferOldMap.get(ObjOffer.Id).nu_dse__First_Payment_Date__c
                     || ObjOfferOldMap.get(ObjOffer.Id).nu_dse__First_Payment_Date__c == NULL
                     || ObjOfferOldMap.get(ObjOffer.Id).Integration_Status__c == 'Overflow'
                     || ObjOffer.Ended_On__c !=ObjOfferOldMap.get(ObjOffer.Id).Ended_On__c))//condition 1
                   || (IsInsert==true && ObjOffer.IsRelatedRecordEligibleForPick__c==true) //condition 2
                   || (ObjOffer.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(ObjOffer.Integration_Reason__c) 
                       && reProcessErrorMessage.size() > 0 && ObjOffer.IsRelatedRecordEligibleForPick__c==true 
                       && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjOffer.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjOffer.Integration_Reason_2__c)))//condition 3
                   || (IsInsert==true && string.isBlank(ObjOffer.Integration_Status__c) && ObjOffer.IsRelatedRecordEligibleForPick__c==true))//condition 4
                {
                    
                    System.debug('+++++ IsInsert' + IsInsert);
                    
                    System.enqueueJob(new AsynCallToNDSettlementPayment(ObjOffer.Id));//ApexCall
                    
                    //Sync Update - Integration Status to Initiated
                    nu_dse__Offer__c objOfferUpd = new nu_dse__Offer__c(Id=ObjOffer.Id);
                    setIntegrationFields(objOfferUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null);
                    updateOfferList.add(objOfferUpd);
                }
                
            } 
        }
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
        update updateOfferList;
        //Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
    }
    
    public static void setIntegrationFields(nu_dse__Offer__c ObjOffer,string IntegrationStatus,string IntegrationReason)
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
        
        
        ObjOffer.Integration_Status__c = IntegrationStatus;
        ObjOffer.Integration_Reason__c = Reason1;
        ObjOffer.Integration_Reason_2__c = Reason2;
    }
    
    public static LeadtracNetDebt.SettlementPlan doSettlementMapping(nu_dse__Offer__c objOffer)
    {
        //SettlementPlan
        LeadtracNetDebt.SettlementPlan debtSettlementPlan = new LeadtracNetDebt.SettlementPlan();
        debtSettlementPlan.PlanId =  (objOffer.NDS_Offer_Id__c == null) ? 0 : Long.ValueOf(objOffer.NDS_Offer_Id__c);
        
        
             if(objOffer.Settlement_Status__c != '' && objOffer.Settlement_Status__c != null && objOffer.Settlement_Status__c == 'Payment Plan - Active')
                            {
                            debtSettlementPlan.Status = 'Payment_Plan_Active';

                            }
                            
                            else if(objOffer.Settlement_Status__c != '' && objOffer.Settlement_Status__c != null && objOffer.Settlement_Status__c == 'Payment Plan - Suspended')
                            {
                            debtSettlementPlan.Status = 'Payment_Plan_Suspended';

                            }
                             else
                            {
                            debtSettlementPlan.Status = (string.isBlank(objOffer.Settlement_Status__c)) ? objOffer.Settlement_Status__c : objOffer.Settlement_Status__c.replace(' ','_');
                            }
        
        
     //   debtSettlementPlan.Status =  objOffer.Settlement_Status__c;
     //   debtSettlementPlan.Status =  'None';
        debtSettlementPlan.SuspendedOn = (objOffer.Suspended_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objOffer.Suspended_On__c;
        debtSettlementPlan.CompletedOn = (objOffer.nu_dse__Valid_Until__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objOffer.nu_dse__Valid_Until__c;
        debtSettlementPlan.ActivatedOn = (objOffer.nu_dse__First_Payment_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objOffer.nu_dse__First_Payment_Date__c;
        debtSettlementPlan.CreatedOn =  objOffer.createddate;
        debtSettlementPlan.ModifiedOn = objOffer.LastModifiedDate;
        debtSettlementPlan.EndedOn = (objOffer.Ended_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objOffer.Ended_On__c;
        System.debug('++++++++++++ debtSettlementPlan' + debtSettlementPlan);
        return debtSettlementPlan;
    }
    
    public class AsynCallToNDSettlementPayment implements Queueable,Database.AllowsCallouts {
        
        Id OfferId;
        public AsynCallToNDSettlementPayment(Id cOfferId)
        {
            this.OfferId = cOfferId;
        }
        
        public void execute(QueueableContext context) {
            //Changes made by uchit for ND-13
            /*Batch_Data__c AsyncOfferMethod = Attorney_StaticVariableUtility.getAsyncMethodData('AsynCallToNDSettlementPayment');
            if(Test.isRunningTest()){
                AsyncOfferMethod = new Batch_Data__c();
            }
            DateTime now = System.now();
            if(AsyncOfferMethod != null && (AsyncOfferMethod.Last_Execution_Time__c == null || AsyncOfferMethod.Last_Execution_Time__c.Day() != now.Day() || AsyncOfferMethod.Number_Of_Callouts__c == null)){
                AsyncOfferMethod.Number_Of_Callouts__c = String.valueOf(0);
                AsyncOfferMethod.Number_of_records_processed__c = 0;
            }
            AsyncOfferMethod.Number_Of_Callouts__c = String.valueOf(Integer.valueOf(AsyncOfferMethod.Number_Of_Callouts__c) + 1);
            AsyncOfferMethod.Number_of_records_processed__c ++;
            AsyncOfferMethod.Last_Execution_Time__c = System.now();
            */
            
            nu_dse__Offer__c ObjOffer = [Select NDS_Offer_Id__c,Integration_Status__c,Integration_Reason__c,nu_dse__TradeLine__r.nu_dse__Program__r.import_Id__c,nu_dse__TradeLine__r.import_Id__c,Settlement_Status__c,Suspended_On__c,nu_dse__Valid_Until__c,nu_dse__First_Payment_Date__c,
                                         createddate,LastModifiedDate,Ended_On__c from nu_dse__Offer__c where id=:OfferId];
            
            try
            {
                LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
                LeadtracNetDebt.SettlementPlan settlementPlan = doSettlementMapping(ObjOffer);
                LeadTracNetDebt.CreateOrUpdateSettlementPaymentPlanResult settlementPaymentPlanResult = new LeadTracNetDebt.CreateOrUpdateSettlementPaymentPlanResult();
                settlementPaymentPlanResult = soap.CreateOrUpdateSettlementPayments(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                                                    Attorney_StaticVariableUtility.credentials.Password__c,
                                                                                    ObjOffer.nu_dse__TradeLine__r.nu_dse__Program__r.import_Id__c,//File Number
                                                                                    Long.ValueOf(ObjOffer.nu_dse__TradeLine__r.import_Id__c),//Debt Id
                                                                                    settlementPlan);
                
                 System.debug('++++++++++++++++++++++settlementPaymentPlanResult ' + settlementPaymentPlanResult);
                
                if(settlementPaymentPlanResult.IsSuccessful == true)
                {
                    if(objOffer.NDS_Offer_Id__c == null)
                    {
                         LeadtracNetDebt.SettlementPlan SettlePlan = settlementPaymentPlanResult.SettlementPlan;
                         ObjOffer.NDS_Offer_Id__c = string.valueof(SettlePlan.PlanId);
                    }
                    
                    setIntegrationFields(ObjOffer,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                }
                else
                {
                    LeadtracNetDebt.ArrayOfResultMessage arrayResultMessage = settlementPaymentPlanResult.Messages;
                    List<LeadtracNetDebt.ResultMessage> resultMessage = arrayResultMessage.ResultMessage;
                    setIntegrationFields(ObjOffer,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessage[0].Message);
                }
            }
            catch(Exception e)
            {
                 setIntegrationFields(ObjOffer,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                System.debug('exception'+ e);
            }
            
          
            Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
            Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
            update ObjOffer;
            /*if(!Test.isRunningTest()){
                Update AsyncOfferMethod;
            }*/
            //Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;  
        }
    }
    
    public Static void UpdateTradeStatus(){
        List<nu_dse__Offer__c> OfferList = (List<nu_dse__Offer__c>)Trigger.new;
        Map<Id,nu_dse__Offer__c> OfferOldMap = (Map<Id,nu_dse__Offer__c>)Trigger.oldMap;
        
        List<nu_dse__Tradeline__c> TradeUpdateList = new List<nu_dse__Tradeline__c>();
        for(nu_dse__Offer__c Offer : OfferList){
        //    if(Offer.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false && Offer.nu_dse__Status__c == 'Negotiations Associate Approved' && Offer.nu_dse__Status__c != OfferOldMap.get(Offer.id).nu_dse__Status__c){
              if(Offer.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false && Offer.nu_dse__Status__c == 'Accepted' && Offer.nu_dse__Status__c != OfferOldMap.get(Offer.id).nu_dse__Status__c){
                nu_dse__Tradeline__c trade = new nu_dse__Tradeline__c();
                trade.id = Offer.nu_dse__Tradeline__c;
                
                if(Offer.nu_dse__Offer_Amount__c != null && Offer.Original_Balance__c != null){
                    Decimal settlementPercent = Offer.nu_dse__Offer_Amount__c/Offer.Original_Balance__c;
                    
                    if(settlementPercent >= 0 && settlementPercent <= 0.40){
                        trade.Negotiation_Status__c = 'Settlement 1-40%';
                    } else if(settlementPercent > 0.40 && settlementPercent <= 0.60){
                        trade.Negotiation_Status__c = 'Settlement 40-60%';
                    } else if(settlementPercent > 0.60){
                        trade.Negotiation_Status__c = 'Settlement 60%+ (Aggressive Litigation)';
                    }
                }
            
                trade.Account_Status__c = 'Attorney Review Pending';
                TradeUpdateList.add(trade);
            } 
        }
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
        Update TradeUpdateList;
    }
    
        public static Map<String,Offer_Status__mdt> getOfferStatusLst(){
        List<Offer_Status__mdt> leadtrckProgramTypeLst = [Select Id,Label,Active__c FROM Offer_Status__mdt];    
        Map<String,Offer_Status__mdt> OfferStatusMap = new Map<String,Offer_Status__mdt>();
        for(Offer_Status__mdt OfferStatus : leadtrckProgramTypeLst ){
            OfferStatusMap.put(OfferStatus.Label,OfferStatus);
        }
        return OfferStatusMap;
    }
    
}