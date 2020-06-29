/**
 * @File Name          : Attorney_CreateOrUpdateNDSPaymentHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/11/2019, 1:26:14 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/10/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 1.1    13/03/2020   Praveen                      ND-303 - Deactivate “Update Parent Payment ” process Builder  and move the logic to Code to reduce the CPU timeout.
**/
public without sharing class Attorney_CreateOrUpdateNDSPaymentHandler{
       
       //below method added by Mayur for ND-322.
    public static void UpdateFeeStatus(){
        List<nu_dse__Payment__C> PaymentList = Trigger.new;
        Map<Id, nu_dse__Payment__c> PaymentOldMap = (Map<Id, nu_dse__Payment__c>)Trigger.oldMap;
        
        Id FeeRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        List<Id> PaymentIds = new List<Id>();
        for(nu_dse__Payment__c Payment: PaymentList){
            if(Payment.RecordTypeId == FeeRecordType && Payment.nu_dse__Transaction_Status__c == 'Cancelled' && (PaymentOldMap.get(Payment.Id).nu_dsE__Transaction_Status__C== 'Completed' || PaymentOldMap.get(Payment.Id).nu_dsE__Transaction_Status__C== 'Cleared' || PaymentOldMap.get(Payment.Id).nu_dsE__Transaction_Status__C == 'Failed')){
                //Payment.nu_dse__Transaction_Status__c = PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c;
                PaymentIds.add(Payment.Id);
            }
        }
        if(!PaymentIds.isEmpty()){
            Map<Id,nu_dse__Payment__c> PaymentsTobeUpdated = new Map<Id,nu_dsE__Payment__c>([Select Id, nu_dse__Transaction_Status__c, nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c from nu_dse__Payment__c where Id=: PaymentIds AND nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c = 'CFT' And nu_dse__Advance_Payment__r.recordtype.name='Draft']);
            for(nu_dse__Payment__c Payment: PaymentList){
                if(PaymentsTobeUpdated.containsKey(Payment.Id)){
                    Payment.nu_dse__Transaction_Status__c = PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c;
                    Payment.Payment_Status__c = PaymentOldMap.get(Payment.Id).Payment_Status__c;
                }
            }
        }
    }
    
    public static void UpdateFundsSource(){
        List<nu_dse__Payment__c> PaymentList = (List<nu_dse__Payment__c>)Trigger.new;
        Map<Id, nu_dse__Payment__c> PaymentOldMap = (Map<Id, nu_dse__Payment__c>)Trigger.oldMap;
        
        List<Id> OfferIds = new List<Id>();
        Id SettlementRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        for(nu_dse__Payment__c Payment: PaymentList){
            if(Payment.RecordTypeId == SettlementRecordType && Payment.nu_dse__Offer__c != null){
                OfferIds.add(Payment.nu_dse__Offer__c);
            }
        }
        
        if(!OfferIds.isEmpty()){
        
            Map<Id,nu_dse__Offer__c> OfferMap = new Map<Id,nu_dse__Offer__c>([Select Id, SOurce_Of_Payment__c from nu_dse__Offer__c where Id=:OfferIds]);
            for(nu_dse__Payment__c Payment: PaymentList){
                if(Payment.RecordTypeId == SettlementRecordType && Payment.nu_dse__Offer__c != null){
                    if((Trigger.isInsert || Trigger.isUpdate) && Payment.Funds_Source__c == null && Payment.RecordTypeId == SettlementRecordType && Payment.nu_dse__Offer__c != null && OfferMap.containsKey(Payment.nu_dse__Offer__c)){
                        if(OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'PSA' || OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Extra Funds Required'){
                            Payment.Funds_Source__c = 'PSA';
                        } else if(OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Client Direct'){
                            Payment.Funds_Source__c = 'Direct Pay';
                        }
                    }
                    else if(((Trigger.isUpdate && Payment.Funds_Source__c != PaymentOldMap.get(Payment.Id).Funds_Source__c) || (Trigger.isInsert && Payment.Funds_Source__c != null)) && Payment.RecordTypeId == SettlementRecordType  && Payment.nu_dse__Offer__c != null && OfferMap.containsKey(Payment.nu_dse__Offer__c)){
                        if((Payment.Funds_Source__c != 'PSA' && (OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'PSA' || OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Extra Funds Required'))|| (Payment.Funds_Source__c != 'Direct Pay' && OfferMap.get(Payment.nu_dse__Offer__c).Source_Of_Payment__c == 'Client Direct')){
                            Payment.addError('Funds Source can not be changed for this offer');
                        }
                    }
                }
            }    
        }
    }
       
       public static boolean ProgramUpdated = false;
       

    //Makeup Payments for failed transactions.
  /*  public static void createMakeupPayments(Map<Id,nu_dse__Payment__c> mapOldPayments, Map<Id,nu_dse__Payment__c> mapNewPayments){
        system.debug('--In create payment method!');
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        List<nu_dse__Payment__c> lstPaymentsToProcess = new List<nu_dse__Payment__c>();
        //Check if trigger is in update mode or insert mode
        if(Trigger.isUpdate){
            system.debug('--Is Update!');
            system.debug('--new map! ' + mapNewPayments);
            //If trigger is in update mode, check if transaction status is changed to failed
            for(Id paymentId : mapNewPayments.keySet()){
                nu_dse__Payment__c newPayment = mapNewPayments.get(paymentId);
                nu_dse__Payment__c oldPayment = mapOldPayments.get(paymentId);

                system.debug('--newPayment.nu_dse__Transaction_Status__c! ' + newPayment.nu_dse__Transaction_Status__c);
                system.debug('--newPayment.recordTypeId! ' + newPayment.recordTypeId);
                system.debug('--DraftRecordTypeId! ' + DraftRecordTypeId);
                system.debug('--oldPayment.nu_dse__Transaction_Status__c! ' + oldPayment.nu_dse__Transaction_Status__c);
            

                //Check if there is any change in the transaction status AND transaction status = failed.
                if(newPayment.nu_dse__Transaction_Status__c == 'Failed' && 
                newPayment.recordTypeId == DraftRecordTypeId){
                    //Add record for processing
                system.debug('-- Inside final if' );
                    lstPaymentsToProcess.add(newPayment);
                }
            }
        }else if(Trigger.isInsert){
             for(Id paymentId : mapNewPayments.keySet()){
                nu_dse__Payment__c newPayment = mapNewPayments.get(paymentId);

                //Check if transaction status = failed.
                if(newPayment.nu_dse__Transaction_Status__c == 'Failed' && newPayment.recordTypeId == DraftRecordTypeId){
                    //Add record for processing
                    lstPaymentsToProcess.add(newPayment);
                }
             }
        }
        system.debug('--lstPaymentsToProcess : ' + lstPaymentsToProcess);
        //Check if there are the payments to process and start creating makeup payments
        if(lstPaymentsToProcess != null && lstPaymentsToProcess.size() > 0){
            List<nu_dse__Payment__c> lstPaymentsToInsert = new List<nu_dse__Payment__c>();
            List<Id> lstProcessedPaymentsId = new List<Id>();

            for(nu_dse__Payment__c paymentToPorcess : lstPaymentsToProcess){
                lstProcessedPaymentsId.add(paymentToPorcess.Id);
                nu_dse__Payment__c makeupPayment = new nu_dse__Payment__c();
                
                makeupPayment.nu_dse__Advance_Payment__c = paymentToPorcess.Id;
                makeupPayment.nu_dse__Transaction_Status__c = 'Pending';
                makeupPayment.nu_dse__Amount__c = paymentToPorcess.nu_dse__Amount__c;
                makeupPayment.nu_dse__Admin_Fee__c = paymentToPorcess.nu_dse__Admin_Fee__c;
                makeupPayment.nu_dse__Ancillary_Fee__c = paymentToPorcess.nu_dse__Ancillary_Fee__c;
                makeupPayment.nu_dse__Monthly_Maintenance_Fee__c = paymentToPorcess.nu_dse__Monthly_Maintenance_Fee__c;
                makeupPayment.nu_dse__Monthly_Other_Fee__c = paymentToPorcess.nu_dse__Monthly_Other_Fee__c;
                makeupPayment.nu_dse__Monthly_Third_Party_Fees__c = paymentToPorcess.nu_dse__Monthly_Third_Party_Fees__c;
                makeupPayment.nu_dse__Payment_Type__c = paymentToPorcess.nu_dse__Payment_Type__c;
                makeupPayment.nu_dse__Processor_Fee__c = paymentToPorcess.nu_dse__Processor_Fee__c;
                makeupPayment.nu_dse__Retainer_Fee__c = paymentToPorcess.nu_dse__Retainer_Fee__c;
                //For monthly payment, schedule date should be 5 days
                if(paymentToPorcess.nu_dse__Type__c == 'MONTHLY'){
                    makeupPayment.nu_dse__Schedule_Date__c = paymentToPorcess.nu_dse__Schedule_Date__c + 5;
                }else{
                    makeupPayment.nu_dse__Schedule_Date__c = paymentToPorcess.nu_dse__Schedule_Date__c + 3;
                }
                makeupPayment.nu_dse__Service_Fee__c = paymentToPorcess.nu_dse__Service_Fee__c;
                makeupPayment.nu_dse__Transaction_Method__c = paymentToPorcess.nu_dse__Transaction_Method__c;
                makeupPayment.nu_dse__Type__c = paymentToPorcess.nu_dse__Type__c;

                lstPaymentsToInsert.add(makeupPayment);
            }

            //insert all makeup Payments
            insert lstPaymentsToInsert;

            system.debug('--lstPaymentsToInsert : ' + lstPaymentsToInsert);

            //TO-DO set status of original payments in future methods
            updateFailedPayments(JSON.serialize(lstProcessedPaymentsId));
        }
    }

    @future
    public static void updateFailedPayments(String lstOfPaymentsToUpdate){
        if(lstOfPaymentsToUpdate != null){
            //Convert json string to list of string
            List<String> lstPaymentIds =  (List<String>) JSON.deserialize(lstOfPaymentsToUpdate, List<String>.class);
            if(lstPaymentIds != null && lstPaymentIds.size() > 0){
                List<nu_dse__Payment__c> lstPayToUpdate = new List<nu_dse__Payment__c>();
                for(Id payId : lstPaymentIds){
                    nu_dse__Payment__c pay = new nu_dse__Payment__c();
                    pay.Id = payId;
                    pay.nu_dse__Is_Makeup_Payment_Created__c = true;
                    pay.nu_dse__Dont_Consider__c = true;

                    lstPayToUpdate.add(pay);
                }

                update lstPayToUpdate;
            }
        }
    }

    //Private function to creat group task for the makeup payments that returns group task
    private nu_dse__Group_Task__c createGroupTask(nu_dse__Payment__c payment){
        Group paymentGroup = [Select Id, name from Group where name = 'Payment Processing' limit 1];

        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c();
        groupTask.NFS_payment__c = payment.Id;
        groupTask.nu_dse__Subject__c = 'Take Back Fee';
        groupTask.Subject_Picklist__c = 'Take Back Fees';
        groupTask.nu_dse__ActivityDate__c = System.today() + 2;
        if(paymentGroup != null){
            groupTask.OwnerId = paymentGroup.Id ;
        }
        groupTask.nu_dse__Description__c = '$25 \n' + 
        'The client NSF’d on ' + System.today().format() +' draft. Collect NSF fee.';

        return groupTask;
    }*/

       //changes for NMI-523
      
    public static void UpdateProgramRollUps(){
        System.debug('*****Program Roll-UP');
        if(!ProgramUpdated){
        
            System.debug('*****Program Roll-UP');
            List<nu_dse__Payment__c> PaymentNewList;
            if(Trigger.isDelete)
                PaymentNewList = (List<nu_dse__Payment__c>)Trigger.old;
            else
                PaymentNewList = (List<nu_dse__Payment__c>)Trigger.new;
            
            Map<Id,nu_dse__Payment__c> PaymentOldMap = (Map<Id,nu_dse__Payment__c>)Trigger.OldMap;
            
            List<Id> ProgramIds = new List<Id>();
            //Map<Id,List<nu_dse__Payment__c>> ProgramPaymentMap = new Map<Id,List<nu_dse__Payment__c>>();
            
            Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            
            for(nu_dse__Payment__c payment : PaymentNewList){
                if(Payment.RecordTypeId == DraftRecordTypeId && ((((Payment.nu_dse__Transaction_Status__c == 'Failed' || Payment.nu_dse__Transaction_Status__c == 'Cancelled') || (!Trigger.isInsert && (PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c == 'Failed' || PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c == 'Cancelled'))) && (Trigger.isInsert || Trigger.isDelete || Payment.nu_dse__Transaction_Status__c != PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c)) || (Payment.Should_Count_NSF__c && !Trigger.isInsert && PaymentOldMap.get(Payment.Id).Should_Count_NSF__c != Payment.Should_Count_NSF__c))){
                    ProgramIds.add(Payment.nu_dse__Program__c);
                }
            }
            //System.debug(ProgramIds);
            if(!ProgramIds.isEmpty()){
                System.debug('*****'+ProgramIds);
                
                List<nu_dse__Program__c> ProgramList = new List<nu_dse__Program__c>();
                Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>();
                for(nu_dse__Payment__c Payment : [Select Id,nu_dse__Program__c, nu_dse__Transaction_Status__c, RecordTypeId from nu_dse__Payment__c where nu_dse__Program__c =: ProgramIds AND RecordTypeId=:DraftRecordTypeId AND (nu_dse__Transaction_Status__c = 'Cancelled' OR nu_dse__Transaction_Status__c = 'Failed')]){
                   nu_dse__Program__c Program = new nu_dse__Program__c();
                   if(ProgramMap.containsKey(Payment.nu_dse__Program__c)){
                       Program = ProgramMap.get(Payment.nu_dse__Program__c);
                   } else {
                       Program.Id = Payment.nu_dse__Program__c;
                       Program.Count_Of_NSFs__c = 0;
                       Program.Count_Of_Skips__c = 0;
                   }
                   
                   if(Payment.nu_dse__Transaction_Status__c == 'Cancelled'){
                        Program.Count_Of_Skips__c++;
                    } else if(Payment.nu_dse__Transaction_Status__c == 'Failed'){
                        Program.Count_Of_NSFs__c++;
                    }
                   ProgramMap.put(Program.Id,Program);
                }
                    
                ProgramUpdated = true;
                System.debug('*****Update Program'+ProgramMap.values());
                Update ProgramMap.values();
            }
        }
    }
      
    //added for refund change
    public static void BeforeUpdateHandler(List<nu_dse__Payment__c> paymentList, Map<Id,nu_dse__Payment__c> paymentNewMap, Boolean isInsert){
        System.debug('****beforeUpdateTrigger');
        Map<Id,nu_dse__Payment__c> ParentChildPaymentMap = new Map<Id,nu_dse__Payment__c>();
        List<nu_dse__Payment__c> paymentChildList;
        Id refundRecordTypeId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        Id feeRecordTypeId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();

        if(!isInsert){
            paymentChildList = new List<nu_dse__Payment__c>([Select Id,nu_dse__Advance_Payment__c from nu_dse__Payment__c where nu_dse__Advance_Payment__c =:paymentNewMap.keySet() AND recordTypeId=:refundRecordTypeId]);
            for(nu_dse__Payment__c payment: paymentChildList){
                ParentChildPaymentMap.put(payment.nu_dse__Advance_Payment__c, payment);
                System.debug('***Here');
            }
           // BeforeUpdateExecuted = true;
        }
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        for(nu_dse__Payment__c Payment : PaymentList){
            if(Payment.recordTypeId == DraftRecordTypeId && 
                ((Payment.payment_Status__c == 'Refunded') || (Payment.Refund_Payment__c == true) || ParentChildPaymentMap.containsKey(payment.id)) ){
                
                //&& (isInsert || !ParentChildPaymentMap.containsKey(payment.id))
                payment.Payment_Status__c = 'Cleared';
                Payment.Refund_Payment__c = true;
            }
        }
        
        
        /*List<Payment_Status_Mapping__mdt> PaymentStatusMappingList = [Select Id, MasterLabel, DeveloperName, Transaction_Status__c from Payment_Status_Mapping__mdt];
        
        Map<String,Payment_Status_Mapping__mdt> PaymentStatusMapping = new Map<String,Payment_Status_Mapping__mdt>();
        for(Payment_Status_Mapping__mdt psm : PaymentStatusMappingList){
            PaymentStatusMapping.put(psm.MasterLabel, psm);
            //if(PaymentStatus.equalsIgnoreCase(psm.MasterLabel)){
            //    return psm.Transaction_Status__c;
            //}
        }
        
        for(nu_dse__Payment__c payment : PaymentList){
            if(payment.isAttorney__c == true && PaymentStatusMapping.containsKey(payment.Payment_Status__c)){
        //        payment.nu_dse__Transaction_Status__c = PaymentStatusMapping.get(payment.Payment_Status__c).Transaction_Status__c; //commented till we finalize requirement
            }
            else if(payment.isAttorney__c == true && !PaymentStatusMapping.containsKey(payment.Payment_Status__c)){
        //        payment.nu_dse__Transaction_Status__c = null; //commented till we finalize requirement
            }
        }*/
    
    }
    
    //Added for recursion check as part of S20-503
    public static boolean RefundRecordCreated = false;
    public static void CreateRefundRecord(List<nu_dse__Payment__c> paymentList,Map<Id,nu_dse__Payment__c> paymentOldMap,Map<Id,nu_dse__Payment__c> paymentNewMap){
        if(!Attorney_CreateOrUpdateNDSPaymentHandler.RefundRecordCreated){
            List<nu_dse__Payment__c> listParentPayment = new List<nu_dse__Payment__c>();  // ND-303
            nu_dse__Payment__c updateParentPymnt = new nu_dse__Payment__c(); // ND-303
            Map<Id,nu_dse__Payment__c> ParentChildPaymentMap = new Map<Id,nu_dse__Payment__c>();
            Id refundRecordTypeId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
            List<nu_dse__Payment__c> paymentChildList = new List<nu_dse__Payment__c>([Select Id,nu_dse__Advance_Payment__c from nu_dse__Payment__c where nu_dse__Advance_Payment__c =:paymentNewMap.keySet() AND recordTypeId=:refundRecordTypeId]);
            System.debug('****paymentChildList'+paymentChildlist);
            for(nu_dse__Payment__c payment: paymentChildList){
                System.debug('***ChildRecordMap');
                ParentChildPaymentMap.put(payment.nu_dse__Advance_Payment__c, payment);
            }
            
            Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            List<nu_dse__Payment__c> NewRefundPayments = new List<nu_dse__Payment__c>();
            for(nu_dse__Payment__c payment : paymentList){
                if(Payment.recordTypeId == DraftRecordTypeId && Payment.Refund_Payment__c == true 
                && !ParentChildPaymentMap.containsKey(payment.id)){
                    nu_dse__Payment__c refundPayment = new nu_dse__Payment__c();
                    refundPayment.RecordTypeId = refundRecordTypeId;
                    refundPayment.nu_dse__Amount__c =  payment.nu_dse__Amount__c;
                    refundPayment.nu_dse__Schedule_Date__c=  payment.nu_dse__Schedule_Date__c;
                    refundPayment.nu_dse__program__c=  payment.nu_dse__program__c;
                    refundPayment.Payment_Status__c =  'Cleared';
                    refundPayment.nu_dse__Payment_Type__c=  'Refund';
                    refundPayment.nu_dse__Advance_Payment__c = payment.Id;
                    NewRefundPayments.add(refundPayment);
                    // ND-303 Start
                    updateParentPymnt.id = payment.Id;
                    updateParentPymnt.isRefundRecordCreated__c = true;
                    listParentPayment.add(updateParentPymnt); 
                    // ND - ND-303 End
                }
            }
            system.debug('====='+NewRefundPayments);
            Boolean isNewRecordsInserted = false; // ND-303
            if(!NewRefundPayments.isEmpty()){
                insert NewRefundPayments;
                Attorney_CreateOrUpdateNDSPaymentHandler.RefundRecordCreated = true;
                isNewRecordsInserted = true; // ND-303
            }
            // ND-303 Start
            system.debug('===='+listParentPayment);
            if(isNewRecordsInserted && !listParentPayment.isEmpty()){
               update listParentPayment;
            }
            // ND-303 End
        }
    }
    //added for refund change
    public static void CreateOrUpdateNDSPayment(List<nu_dse__Payment__c> paymentLst, Map<Id,nu_dse__Payment__c> paymentOldMap,Map<Id,nu_dse__Payment__c> paymentNewMap){ //added one parameter for refund change
        
        System.debug('*******Payment Push Method');
        
        Boolean IsInsert = false;
        List<nu_dse__Payment__c> updateObjPaymentList = new List<nu_dse__Payment__c>();
        Set<Id> draftpaymentIds = new Set<Id>();
        Set<Id> settlementpaymentIds = new Set<Id>();
        Set<Id> processingpaymentIds = new Set<Id>();
        
        Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('Payment',false);
        
        //added for refun change
        Id RefundRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        
        //Commented by Rajesh
        /*Map<Id,nu_dse__Payment__c> ParentChildPaymentMap = new Map<Id,nu_dse__Payment__c>();
        List<nu_dse__Payment__c> paymentChildList = new List<nu_dse__Payment__c>([Select Id,nu_dse__Advance_Payment__c from nu_dse__Payment__c where nu_dse__Advance_Payment__c =:paymentNewMap.keySet() AND recordTypeId =: RefundRecordTypeId]);
        for(nu_dse__Payment__c payment: paymentChildList){
            ParentChildPaymentMap.put(payment.nu_dse__Advance_Payment__c, payment);
        }*/
        //refund change
        
        for(nu_dse__Payment__c objPayment: paymentLst){
            
            if(objPayment.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false)
            {
                System.debug('****Attorney');
                System.debug('****PaymentId'+objPayment.Id);
                System.debug('****PaymentRecordType'+objPayment.RecordTypeId);
                System.debug('****PaymentRecordType'+Attorney_StaticVariableUtility.draftRecordId);
                System.debug('****PaymentRecordType'+Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeID());
                //added refund recordType Condition for push
                if (objPayment.RecordTypeId == Attorney_StaticVariableUtility.draftRecordId || (objPayment.RecordTypeId == RefundRecordTypeId && objPayment.nu_dse__Advance_Payment__c == null))
                {    
                 System.debug('****RecordTypeMatched');
                    
                    if(objPayment.Attorney_Payment_Id__c == null || objPayment.Attorney_Payment_Id__c == '')
                        IsInsert = true;
                    else
                        IsInsert = false;
                    System.debug('****DraftRecord');
                    System.debug('++++++++++++++ IsInsert ' + IsInsert);
                    
                    if((IsInsert==false && objPayment.IsRelatedRecordEligibleForPick__c==true &&
                        (//objPayment.nu_dse__Payment_Sequence_Number__c != paymentOldMap.get(objPayment.Id).nu_dse__Payment_Sequence_Number__c ||                          
                         objPayment.nu_dse__Schedule_Date__c != paymentOldMap.get(objPayment.Id).nu_dse__Schedule_Date__c
                       || objPayment.payment_Status__c != paymentOldMap.get(objPayment.Id).payment_Status__c 
                         || objPayment.nu_dse__Transaction_Status__c!= paymentOldMap.get(objPayment.Id).nu_dse__Transaction_Status__c
                         || objPayment.Integration_Status__c == 'Overflow'
                         || objPayment.Category_changed__c == True

                         || objPayment.nu_dse__Transaction_Method__c!= paymentOldMap.get(objPayment.Id).nu_dse__Transaction_Method__c

                         || objPayment.Statused_On__c != paymentOldMap.get(objPayment.Id).Statused_On__c
                         || objPayment.Status_Reason__c != paymentOldMap.get(objPayment.Id).Status_Reason__c
                      || objPayment.nds_Payment_Type__c != paymentOldMap.get(objPayment.Id).nds_Payment_Type__c
                         || objPayment.Payment_Type_Data__c != paymentOldMap.get(objPayment.Id).Payment_Type_Data__c
                         || objPayment.nu_dse__Total_Amount__c != paymentOldMap.get(objPayment.Id).nu_dse__Total_Amount__c
                         || objPayment.nu_dse__Admin_Fee__c!= paymentOldMap.get(objPayment.Id).nu_dse__Admin_Fee__c
                                         || objPayment.nu_dse__Fee_Item_Category__c!= paymentOldMap.get(objPayment.Id).nu_dse__Fee_Item_Category__c

                         
                   
                  //       || objPayment.nu_dse__Monthly_Maintenance_Fee__c!= paymentOldMap.get(objPayment.Id).nu_dse__Monthly_Maintenance_Fee__c

                                                  || objPayment.refund_payment__C!= paymentOldMap.get(objPayment.Id).refund_payment__C

                         || objPayment.nu_dse__Amount__c != paymentOldMap.get(objPayment.Id).nu_dse__Amount__c 
                         || objPayment.nu_dse__Retainer_Fee__c!= paymentOldMap.get(objPayment.Id).nu_dse__Retainer_Fee__c
                         || objPayment.nu_dse__Service_Fee__c!= paymentOldMap.get(objPayment.Id).nu_dse__Service_Fee__c
                         || objPayment.nu_dse__Processor_Fee__c != paymentOldMap.get(objPayment.Id).nu_dse__Processor_Fee__c))//condition 1
                       || (IsInsert==true && objPayment.IsRelatedRecordEligibleForPick__c==true && /*Mayur U*/ ((objPayment.nu_dse__Admin_Fee__c != NULL && objPayment.nu_dse__fee_item_category__c != NULL) || objPayment.nu_dse__Admin_Fee__c == NULL)) //condition 2
                       || (objPayment.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(objPayment.Integration_Reason__c) 
                           && reProcessErrorMessage.size() > 0 && objPayment.IsRelatedRecordEligibleForPick__c==true 
                           && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objPayment.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objPayment.Integration_Reason_2__c)))//condition 3
                       || (IsInsert==true && string.isBlank(objPayment.Integration_Status__c) && objPayment.IsRelatedRecordEligibleForPick__c==true /*Mayur U*/ && ((objPayment.nu_dse__Admin_Fee__c != NULL && objPayment.nu_dse__fee_item_category__c != NULL) || objPayment.nu_dse__Admin_Fee__c == NULL)))//condition 4
                    {
                    //Mayur U
                        if(objPayment.Integration_Status__c != 'Initiated'  || (!IsInsert && objPayment.nu_dse__Fee_Item_Category__c!= paymentOldMap.get(objPayment.Id).nu_dse__Fee_Item_Category__c))
                        {
                            draftpaymentIds.add(objPayment.Id);
                            processingpaymentIds.add(objPayment.Id);
                        }
                    }
                }
                
                else if (objPayment.RecordTypeId == Attorney_StaticVariableUtility.settlementRecordId)
                { 
                    if(objPayment.Attorney_Payment_Id__c == null || objPayment.Attorney_Payment_Id__c == '')
                        IsInsert = true;
                    else
                        IsInsert = false;
                    
                    System.debug('++++++++++++++ IsInsert1 ' + IsInsert);
                    System.debug('++++++++++++++ reProcessErrorMessage ' + reProcessErrorMessage);
                    System.debug('++++++++++++++ IsRelatedRecordEligibleForPick__c ' + objPayment.IsRelatedRecordEligibleForPick__c);
                    System.debug('++++++++++++++ objPayment.Integration_Reason__c ' + objPayment.Integration_Reason__c);
                    
                    if((IsInsert==false && objPayment.IsRelatedRecordEligibleForPick__c==true &&
                        (objPayment.nu_dse__Schedule_Date__c != paymentOldMap.get(objPayment.Id).nu_dse__Schedule_Date__c
                      //   || objPayment.nu_dse__Payment_Sequence_Number__c != paymentOldMap.get(objPayment.Id).nu_dse__Payment_Sequence_Number__c
                         || objPayment.nu_dse__Amount__c != paymentOldMap.get(objPayment.Id).nu_dse__Amount__c
                         || objPayment.payment_Status__c != paymentOldMap.get(objPayment.Id).payment_Status__c 
                         || objPayment.nu_dse__Transaction_Status__c!= paymentOldMap.get(objPayment.Id).nu_dse__Transaction_Status__c
                         || objPayment.Integration_Status__c == 'Overflow'
                      

                         || objPayment.nu_dse__Transaction_Method__c!= paymentOldMap.get(objPayment.Id).nu_dse__Transaction_Method__c
                         || objPayment.Statused_On__c != paymentOldMap.get(objPayment.Id).Statused_On__c
                         || objPayment.Status_Reason__c != paymentOldMap.get(objPayment.Id).Status_Reason__c
                         || objPayment.nds_Payment_Type__c != paymentOldMap.get(objPayment.Id).nds_Payment_Type__c
                         || objPayment.Payment_Type_Data__c != paymentOldMap.get(objPayment.Id).Payment_Type_Data__c))//condition 1
                       || (IsInsert==true && objPayment.IsRelatedRecordEligibleForPick__c==true) //condition 2
                       || (objPayment.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(objPayment.Integration_Reason__c) 
                           && reProcessErrorMessage.size() > 0 && objPayment.IsRelatedRecordEligibleForPick__c==true 
                           && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objPayment.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objPayment.Integration_Reason_2__c)))//condition 3
                       || (IsInsert==true && string.isBlank(objPayment.Integration_Status__c) && objPayment.IsRelatedRecordEligibleForPick__c==true))//condition 4
                    {
                    if(objPayment.Integration_Status__c != 'Initiated')
                        {
                        settlementpaymentIds.add(objPayment.Id);
                        processingpaymentIds.add(objPayment.Id);
                        
                        }
                    }
                }    
            }
        }
        
        System.debug('+++++++++++++++++++++ getCallouts ' + Limits.getCallouts());
        System.debug('+++++++++++++++++++++ getLimitCallouts() ' + Limits.getLimitCallouts());
        system.debug('====='+processingpaymentIds.size() + '====='+processingpaymentIds);
        
        Boolean IsOverFlow; 
        if(processingpaymentIds.size() < Limits.getLimitCallouts() - Limits.getCallouts())
            IsOverFlow = false; //Less than 100 Records
        else
            IsOverFlow = true; //More than 100 Records
        
        for(Id objPaymentId: processingpaymentIds){
            nu_dse__Payment__c objPaymentUpd = new nu_dse__Payment__c(Id=objPaymentId);
            if(IsOverFlow == false)
                setIntegrationFields(objPaymentUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null); 
            if(IsOverFlow == true)
                setIntegrationFields(objPaymentUpd,Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW,null);
            updateObjPaymentList.add(objPaymentUpd);
        }
        
        if(draftpaymentIds.size() > 0 && IsOverFlow == false)
        {
            System.debug('********Draft');
           System.enqueueJob(new AsynCallToNDDraftPaymentWithSplits(draftpaymentIds, PaymentOldMap));
        }
        
        if(settlementpaymentIds.size() > 0 && IsOverFlow == false)
        {
            System.debug('+++++++++++++++ Settlement');
            System.enqueueJob(new AsynCallToNDSettlementPaymentWithSplits(settlementpaymentIds));
        }
        
        /*if(IsOverFlow == true)
            Database.executeBatch(new Attorney_CreateOrUpdateNDSPaymentBatch(), Attorney_StaticVariableUtility.paymentBatchSize);*/
     //Mayur U 
   //  
     
     If(!updateObjPaymentList.IsEmpty())
     {
     Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;  
         /*if(Test.isRunningTest()){
             PaymentTriggerHandler.hasAlreadyRanAfterUpdate=true;
         }*/
     update updateObjPaymentList;
     }
        
    }
    
    
    public static void setIntegrationFields(nu_dse__Payment__c objPaymentUpd,string IntegrationStatus,string IntegrationReason)
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
        
        
        objPaymentUpd.Integration_Status__c = IntegrationStatus;
        objPaymentUpd.Integration_Reason__c = Reason1;
        objPaymentUpd.Integration_Reason_2__c = Reason2;
    }
    
    
    public class AsynCallToNDSettlementPaymentWithSplits implements Queueable,Database.AllowsCallouts {
        
        Set<Id> PaymentIds;
        public AsynCallToNDSettlementPaymentWithSplits(set<Id> cPaymentIds)
        {
            this.PaymentIds = cPaymentIds; 
        }
        
        public void execute(QueueableContext context) {
            //Changes made by uchit for ND-13   
            Batch_Data__c AsyncDraftMethod = Attorney_StaticVariableUtility.getAsyncMethodData('AsynCallToNDSettlementPaymentWithSplits');
            if(AsyncDraftMethod == null && Test.isRunningTest()){
                AsyncDraftMethod = new Batch_Data__c();
            }
            DateTime now = System.now();
            if(AsyncDraftMethod.Last_Execution_Time__c == null || AsyncDraftMethod.Last_Execution_Time__c.Day() != now.Day() || AsyncDraftMethod.Number_Of_Callouts__c == null){
                AsyncDraftMethod.Number_Of_Callouts__c = String.valueOf(0);
                AsyncDraftMethod.Number_of_records_processed__c = 0;
            }
            AsyncDraftMethod.Number_Of_Callouts__c = String.valueOf(Integer.valueOf(AsyncDraftMethod.Number_Of_Callouts__c) + 1);
            AsyncDraftMethod.Number_of_records_processed__c = AsyncDraftMethod.Number_of_records_processed__c + PaymentIds.size();
            AsyncDraftMethod.Last_Execution_Time__c = System.now();
            CallToNDSettlementPaymentWithSplits(PaymentIds); 
            if(!Test.isRunningTest()){
                Update AsyncDraftMethod;
            }
        }
    }
    
    //Method used in Both Trigger and BatchProcess
    public static void CallToNDSettlementPaymentWithSplits(Set<Id> PaymentIds)
    {
        List<nu_dse__Payment__c> updateObjPaymentList = new List<nu_dse__Payment__c>();
        
        for(nu_dse__Payment__c objPayment : [Select nu_dse__Program__r.Import_id__c,Integration_Status__c,Integration_Reason__c,Attorney_Payment_Id__c , nu_dse__External_GCS_ID__c, CreatedDate,LastModifiedDate,nu_dse__Schedule_Date__c,
                                            // nu_dse__Payment_Sequence_Number__c,
                                            nu_dse__Amount__c,payment_Status__c ,Statused_On__c,
                                             Status_Reason__c,nds_Payment_Type__c,Payment_Type_Data__c,nu_dse__Offer__r.NDS_Offer_Id__c,
                                             nu_dse__Offer__r.nu_dse__TradeLine__r.Import_id__c
                                             from nu_dse__Payment__c where id IN : PaymentIds])
        {
            try
            {
                leadtracNetDebt.DebtServiceSoap soap = new leadtracNetDebt.DebtServiceSoap();
                leadtracNetDebt.Payment sPayment= doSettlementMapping(objPayment);
                leadtracNetDebt.ArrayOfString paymentSplitArray = new leadtracNetDebt.ArrayOfString();
                List<string> paymentSplitArrayList = new List<string>();
                
                paymentSplitArrayList.add('payee_amount:' + string.valueof((objPayment.nu_dse__Amount__c == null) ? 0 : objPayment.nu_dse__Amount__c));
                paymentSplitArray.string_x = paymentSplitArrayList;
                
                System.debug('+++++++++++++++++++ FileNumber ' + objPayment.nu_dse__Program__r.Import_id__c);
                System.debug('+++++++++++++++++++ DebtId ' + Long.ValueOf(objPayment.nu_dse__Offer__r.nu_dse__TradeLine__r.Import_id__c));
                System.debug('+++++++++++++++++++ sPayment ' + sPayment);
                System.debug('+++++++++++++++++++ paymentSplitArray ' + paymentSplitArray);
                
                leadtracNetDebt.UpdateDraftPaymentResult  settlementPaymentPlanResult = new leadtracNetDebt.UpdateDraftPaymentResult ();
                settlementPaymentPlanResult = soap.CreateOrUpdateSettlementPaymentWithSplitList(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                                                                Attorney_StaticVariableUtility.credentials.Password__c,
                                                                                                objPayment.nu_dse__Program__r.Import_id__c,
                                                                                                Long.ValueOf(objPayment.nu_dse__Offer__r.nu_dse__TradeLine__r.Import_id__c),
                                                                                                sPayment,
                                                                                                paymentSplitArray);
                
                System.debug('+++++++++++++++++++ settlementPaymentPlanResult ' + settlementPaymentPlanResult);
                
                if(settlementPaymentPlanResult.IsSuccessful == true)
                {
                    if(objPayment.Attorney_Payment_Id__c == null)
                    {
                        leadtracNetDebt.Payment pay = settlementPaymentPlanResult.DraftPayment;
                        objPayment.Attorney_Payment_Id__c = string.valueof(pay.PaymentId);
                        
                        
                        
                      //  objPayment.External_Id__c = string.valueof(pay.PaymentId);
                        //objPayment.nu_dse__External_GCS_ID__c  = string.valueof(pay.PaymentId);
                    }
                    
                    
                    setIntegrationFields(objPayment,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                    
                }
                else
                {
                    leadtracNetDebt.ArrayOfResultMessage arrayResultMessage = settlementPaymentPlanResult.Messages;
                    List<leadtracNetDebt.ResultMessage> resultMessage = arrayResultMessage.ResultMessage;
                    setIntegrationFields(objPayment,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessage[0].Message);
                }
                
            }
            catch(Exception e)
            {
                setIntegrationFields(objPayment,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
            }
            
            updateObjPaymentList.add(objPayment);  
        }
        System.debug('*****PaymentTriggerExecuted');
        system.debug('===='+updateObjPaymentList.size() + '====='+ updateObjPaymentList);
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        update updateObjPaymentList;
    }
    
    public static leadtracNetDebt.Payment doSettlementMapping(nu_dse__Payment__c objPayment){
        //debtPayment
        leadtracNetDebt.Payment debtPayment = new leadtracNetDebt.Payment();
        debtPayment.PaymentId = (objPayment.Attorney_Payment_Id__c == null) ? 0 : Long.ValueOf(objPayment.Attorney_Payment_Id__c );
        if(!Test.isRunningTest())
        debtPayment.PlanId = Long.ValueOf(objPayment.nu_dse__Offer__r.NDS_Offer_Id__c);
        debtPayment.CreatedOn = objPayment.CreatedDate;
        debtPayment.ModifiedOn = objPayment.LastModifiedDate;
        debtPayment.DueOn = (objPayment.nu_dse__Schedule_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objPayment.nu_dse__Schedule_Date__c;
  //      debtPayment.Number_x =  (objPayment.nu_dse__Payment_Sequence_Number__c == null) ? 0 : Integer.ValueOf(objPayment.nu_dse__Payment_Sequence_Number__c);
        debtPayment.Amount = (objPayment.nu_dse__Amount__c == null) ? 0 : objPayment.nu_dse__Amount__c;
        debtPayment.Status = objPayment.payment_Status__c;
  //      debtPayment.Status = 'None';
        debtPayment.StatusedOn = (objPayment.Statused_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objPayment.Statused_On__c;
        debtPayment.StatusReason = objPayment.Status_Reason__c;
  //      debtPayment.StatusReason = 'Test';
       
        
        if(string.isNotBlank(objPayment.nds_Payment_Type__c))    
            debtPayment.PaymentType = objPayment.nds_Payment_Type__c;
        else
            debtPayment.PaymentType = 'Other';
        
  //      debtPayment.PaymentType = 'Other';
        // debtPayment.PaymentTypeData ='Test';
        debtPayment.PaymentTypeData = objPayment.Payment_Type_Data__c;
        
        System.debug('+++++++++++++++++++++++ debtPayment' + debtPayment);
        
        return debtPayment;
    }
    
    
    public class AsynCallToNDDraftPaymentWithSplits implements Queueable,Database.AllowsCallouts {
        
        Set<Id> PaymentIds;
        Map<Id,nu_dse__Payment__c> PaymentOldMap;
        public AsynCallToNDDraftPaymentWithSplits(set<Id> cPaymentIds, Map<Id,nu_dse__Payment__c> PaymentOldMap)
        {
            this.PaymentIds = cPaymentIds; 
            this.PaymentOldMap = PaymentOldMap;
        }
       
        public void execute(QueueableContext context) { 
            //Changes made by uchit for ND-13
            Batch_Data__c AsyncDraftMethod = Attorney_StaticVariableUtility.getAsyncMethodData('AsynCallToNDDraftPaymentWithSplits');
            DateTime now = System.now();
             if(Test.isRunningTest() && AsyncDraftMethod == null){
                AsyncDraftMethod = new Batch_Data__c();
            } 
           if(AsyncDraftMethod.Last_Execution_Time__c == null || (AsyncDraftMethod.Last_Execution_Time__c.Day()!= null && AsyncDraftMethod.Last_Execution_Time__c.Day() != now.Day() ) || AsyncDraftMethod.Number_Of_Callouts__c == null){
                AsyncDraftMethod.Number_Of_Callouts__c = String.valueOf(0);
                AsyncDraftMethod.Number_of_records_processed__c = 0;
            }
            AsyncDraftMethod.Number_Of_Callouts__c = String.valueOf(Integer.valueOf(AsyncDraftMethod.Number_Of_Callouts__c) + 1);
            AsyncDraftMethod.Number_of_records_processed__c = AsyncDraftMethod.Number_of_records_processed__c + PaymentIds.size();
            AsyncDraftMethod.Last_Execution_Time__c = System.now();
             
                //Update AsyncDraftMethod;
            
            CallToNDDraftPaymentWithSplits(PaymentIds,PaymentOldMap);
            if(!Test.isRunningTest()){
                Update AsyncDraftMethod; 
            }
        }
    
    }
    
    //Method used in Both Trigger and BatchProcess
    public static void CallToNDDraftPaymentWithSplits(Set<Id> PaymentIds,Map<Id,nu_dse__Payment__c> PaymentOldMap)
    {
        List<nu_dse__Payment__c> updateObjPaymentList = new List<nu_dse__Payment__c>();
        
        
        
        
        //added for refun change
        Id RefundRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
        Map<Id,nu_dse__Payment__c> ParentChildPaymentMap = new Map<Id,nu_dse__Payment__c>();
        List<nu_dse__Payment__c> paymentChildList = new List<nu_dse__Payment__c>([Select Id,nu_dse__Advance_Payment__c from nu_dse__Payment__c where nu_dse__Advance_Payment__c =:paymentIds AND RecordTypeId =:RefundRecordTypeId ]);
        for(nu_dse__Payment__c payment: paymentChildList){
            ParentChildPaymentMap.put(payment.nu_dse__Advance_Payment__c, payment);
        }
        //refund change
        
        for(nu_dse__Payment__c objPayment : [Select id,nu_dse__Program__r.Draft_Plan_ID__c,nu_dse__Program__r.Program_Type__c,Integration_Status__c,Integration_Reason__c,nu_dse__Program__r.Import_id__c,Attorney_Payment_Id__c ,nu_dse__External_GCS_ID__c, CreatedDate,LastModifiedDate,
                                             nu_dse__Schedule_Date__c,//nu_dse__Payment_Sequence_Number__c,
                                             payment_Status__c ,Statused_On__c,
                                             Status_Reason__c,nds_Payment_Type__c,Payment_Type_Data__c,nu_dse__Offer__r.NDS_Offer_Id__c,
                                             nu_dse__Offer__r.nu_dse__TradeLine__r.Import_id__c,nu_dse__Retainer_Fee__c,nu_dse__Service_Fee__c,
                                             nu_dse__Amount__c, nu_dse__Monthly_Maintenance_Fee__c,nu_dse__Admin_Fee__c, nu_dse__Fee_Item_Category__c,
                                             nu_dse__Processor_Fee__c,nu_dse__Total_Amount__c
                                             from nu_dse__Payment__c where id In: PaymentIds])
        {
            //Added by rajesh
            nu_dse__Payment__c PaymentToUpdate = new nu_dse__Payment__c(Id=objPayment.Id);
            
            try
            {
                leadtracNetServicing.ServicingSoap soap = new leadtracNetServicing.ServicingSoap();
                
                //added for refund change
                leadtracNetServicing.Payment sPayment= doDraftMapping(objPayment,ParentChildPaymentMap.containsKey(objPayment.Id),PaymentOldMap );
                
                leadtracNetServicing.ArrayOfString paymentSplitArray = new leadtracNetServicing.ArrayOfString();
                List<string> paymentSplitArrayList = new List<string>();
                
     //Development for Royal Model Jira - 349           
     if(objPayment.nu_dse__program__r.Program_Type__c != 'Royal')
                {
                
                 //Admin fee Development Jira 113
                paymentSplitArrayList.add('Draft:' + string.valueof((objPayment.nu_dse__Total_Amount__c== null) ? 0 : objPayment.nu_dse__Total_Amount__c));
                paymentSplitArrayList.add('Legal:' + string.valueof((objPayment.nu_dse__Admin_Fee__c== null) ? 0 : objPayment.nu_dse__Admin_Fee__c));
                if(objPayment.nu_dse__Fee_Item_Category__c == 'Type I')
                {
                paymentSplitArrayList.add('Legal1:' + string.valueof((objPayment.nu_dse__Admin_Fee__c== null) ? 0 : objPayment.nu_dse__Admin_Fee__c));
                paymentSplitArrayList.add('Legal2:' + '0');
                paymentSplitArrayList.add('Legal3:' + '0');
                }
                else if(objPayment.nu_dse__Fee_Item_Category__c == 'Type II')
                {
                paymentSplitArrayList.add('Legal2:' + string.valueof((objPayment.nu_dse__Admin_Fee__c== null) ? 0 : objPayment.nu_dse__Admin_Fee__c));
                paymentSplitArrayList.add('Legal1:' + '0');
                paymentSplitArrayList.add('Legal3:' + '0');
                }
                else if(objPayment.nu_dse__Fee_Item_Category__c == 'Type III')
                {
                paymentSplitArrayList.add('Legal2:' + '0');
                paymentSplitArrayList.add('Legal1:' + '0');
                paymentSplitArrayList.add('Legal3:' + string.valueof((objPayment.nu_dse__Admin_Fee__c== null) ? 0 : objPayment.nu_dse__Admin_Fee__c)); 
                }
                else
                {
                paymentSplitArrayList.add('Legal2:' + '0');
                paymentSplitArrayList.add('Legal1:' + '0');
                paymentSplitArrayList.add('Legal3:' + '0');
                
                }
                               
                paymentSplitArrayList.add('Reserve:' + string.valueof((objPayment.nu_dse__Amount__c == null) ? 0 : objPayment.nu_dse__Amount__c));
                paymentSplitArrayList.add('Retainer:' + string.valueof((objPayment.nu_dse__Retainer_Fee__c== null) ? 0 : objPayment.nu_dse__Retainer_Fee__c));
                paymentSplitArrayList.add('Service:' + string.valueof((objPayment.nu_dse__Service_Fee__c== null) ? 0 : objPayment.nu_dse__Service_Fee__c));
                paymentSplitArrayList.add('Trust:' + string.valueof((objPayment.nu_dse__Processor_Fee__c== null) ? 0 : objPayment.nu_dse__Processor_Fee__c));
                
                }
                else
                {
                paymentSplitArrayList.add('Savings:' + string.valueof((objPayment.nu_dse__Amount__c == null) ? 0 : objPayment.nu_dse__Amount__c));
                paymentSplitArrayList.add('Monthly:' + string.valueof((objPayment.nu_dse__Processor_Fee__c== null) ? 0 : objPayment.nu_dse__Processor_Fee__c));
                paymentSplitArrayList.add('Draft:' + string.valueof((objPayment.nu_dse__Total_Amount__c== null) ? 0 : objPayment.nu_dse__Total_Amount__c));
                }
                
                
                paymentSplitArray.string_x = paymentSplitArrayList;
                
                System.debug('+++++++++++++++++++ FileNumber ' + objPayment.nu_dse__Program__r.Import_id__c);
                System.debug('+++++++++++++++++++ sPayment ' + sPayment);
                System.debug('+++++++++++++++++++ paymentSplitArray ' + paymentSplitArray);
                
                leadtracNetServicing.UpdateDraftPaymentResult  settlementPaymentPlanResult = new leadtracNetServicing.UpdateDraftPaymentResult();
                settlementPaymentPlanResult = soap.CreateOrUpdateDraftPaymentWithSplitList(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                                                           Attorney_StaticVariableUtility.credentials.Password__c,
                                                                                           objPayment.nu_dse__Program__r.Import_id__c,
                                                                                           sPayment,
                                                                                           paymentSplitArray);
                                                                                           
                //end Admin fee Development Jira 113
                
                System.debug('+++++++++++++++++++ settlementPaymentPlanResult ' + settlementPaymentPlanResult);
                
                if(settlementPaymentPlanResult.IsSuccessful == true)
                {
                

                    if(objPayment.Attorney_Payment_Id__c == null)
                    {
                        leadtracNetServicing.Payment pay = settlementPaymentPlanResult.DraftPayment;
                        //Changed by Rajesh
                        PaymentToUpdate.Attorney_Payment_Id__c = string.valueof(pay.PaymentId);
                 

                              
                    //    objPayment.External_Id__c = string.valueof(pay.PaymentId);
                        //objPayment.nu_dse__External_GCS_ID__c  = string.valueof(pay.PaymentId);

                    }                    
                   //Changed by Rajesh
                    setIntegrationFields(PaymentToUpdate,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                    
                    
                }
                else
                {
                    leadtracNetServicing.ArrayOfResultMessage arrayResultMessage = settlementPaymentPlanResult.Messages;
                    List<leadtracNetServicing.ResultMessage> resultMessage = arrayResultMessage.ResultMessage;
                   //Changed by Rajesh
                    setIntegrationFields(PaymentToUpdate,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessage[0].Message);
                }
            }
            catch(Exception e)
            {
            //Changed by Rajesh
                setIntegrationFields(PaymentToUpdate,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
            }
            //Changed by Rajesh
            updateObjPaymentList.add(PaymentToUpdate);
        }
        System.debug('****PaymentTriggerExecuted');
        system.debug('====='+updateObjPaymentList.size() + '====='+ updateObjPaymentList);
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        update updateObjPaymentList;
    }
    
    public static leadtracNetServicing.Payment doDraftMapping(nu_dse__Payment__c objPayment,Boolean childExists,Map<Id,nu_dse__Payment__c> PaymentOldMap){
        //debtPayment
        leadtracNetServicing.Payment debtPayment = new leadtracNetServicing.Payment();
        debtPayment.PaymentId = (objPayment.Attorney_Payment_Id__c == null) ? 0 : Long.ValueOf(objPayment.Attorney_Payment_Id__c );
        debtPayment.PlanId = Long.ValueOf(objPayment.nu_dse__Program__r.Draft_Plan_ID__c);
        debtPayment.CreatedOn = objPayment.CreatedDate;
        debtPayment.ModifiedOn = objPayment.LastModifiedDate;
        debtPayment.DueOn = (objPayment.nu_dse__Schedule_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objPayment.nu_dse__Schedule_Date__c;
   //     debtPayment.Number_x =  (objPayment.nu_dse__Payment_Sequence_Number__c == null) ? 0 : Integer.ValueOf(objPayment.nu_dse__Payment_Sequence_Number__c);
        debtPayment.Amount = (objPayment.nu_dse__Total_Amount__c == null) ? 0 : objPayment.nu_dse__Total_Amount__c;
        
        //Changes made by Mayur as immediate fix to stop sending pending status to NDS if we are drafting in NDS - 
        // Jira - https://stratfs.atlassian.net/browse/NMI-472
        //if((objPayment.payment_Status__c != 'Pending' || PaymentOldMap == null || (PaymentOldMap.containsKey(objPayment.Id) && (PaymentOldMap.get(objPayment.Id).nu_dse__Transaction_Status__c == 'Cancelled' || PaymentOldMap.get(objPayment.Id).Payment_Status__c == 'Canceled')))|| (getLeadtrackProgramLst().containsKey(objPayment.nu_dse__Program__r.Program_Type__c) && getLeadtrackProgramLst().get(objPayment.nu_dse__Program__r.Program_Type__c).Drafting_in_Salesforce__c)){
        if((objPayment.payment_Status__c != 'Pending') || (getLeadtrackProgramLst().containsKey(objPayment.nu_dse__Program__r.Program_Type__c) && getLeadtrackProgramLst().get(objPayment.nu_dse__Program__r.Program_Type__c).Drafting_in_Salesforce__c)){
        if(childExists && objPayment.payment_Status__c == 'Cleared'){
            debtPayment.Status = 'Refunded';
            //Below lines added by Praveen for ND-150 to convert Scheduled to Pending while sending it to NDS
        }else if(objPayment.payment_Status__c == 'Scheduled')
        {
        debtPayment.Status = 'Pending';
        }
        else{
        debtPayment.Status = objPayment.payment_Status__c;
        }
        }
        else
        {
        debtPayment.Status = 'Null';
        }
        
     //   debtPayment.Status = 'None';
        debtPayment.StatusedOn = (objPayment.Statused_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objPayment.Statused_On__c;
        debtPayment.StatusReason = objPayment.Status_Reason__c;
  //      debtPayment.StatusReason = 'Test';
  
        if(string.isNotBlank(objPayment.nds_Payment_Type__c))    
           debtPayment.PaymentType = objPayment.nds_Payment_Type__c;
         else
           debtPayment.PaymentType = 'Other';
           
     //   debtPayment.PaymentType = 'Other';
        // debtPayment.PaymentTypeData ='Test';
        debtPayment.PaymentTypeData = objPayment.Payment_Type_Data__c;
        
        System.debug('+++++++++++++++++++++++ debtPayment' + debtPayment);
        
        return debtPayment;
    }
    
    public Static Boolean rollupToOfferUpdated = false;
    
    public static void rollupCalculationToOffer(List<nu_dse__Payment__c> paymentsList)
    {
        Set<Id> offerIds = new Set<Id>();
        Map<Id,nu_dse__Offer__c> offerUpdateMap = new  Map<Id,nu_dse__Offer__c>();
        Map<Id,nu_dse__Payment__c> OldPaymentMap = (Map<Id,nu_dse__Payment__c>)Trigger.OldMap;
        Map<Id,nu_dse__Payment__c> NewPaymentMap = (Map<Id,nu_dse__Payment__c>)Trigger.newMap;
        
        for(nu_dse__Payment__c objPayment : paymentsList){
            if((Trigger.isInsert || Trigger.isDelete || objPayment.nu_dse__Amount__c != OldPaymentMap.get(ObjPayment.Id).nu_dse__Amount__c) && objPayment.RecordTypeId == Attorney_StaticVariableUtility.settlementRecordId && string.isNotBlank(objPayment.nu_dse__Offer__c) && objPayment.isAttorney__c == true)
            {
                    offerIds.add(objPayment.nu_dse__Offer__c);
            }
        }
        
        //Changes made by Vaibhav for NMI - 487
        
        for(Id offerId:offerIds)
        {
            nu_dse__Offer__c offer = new nu_dse__Offer__c(Id=offerId, nu_dse__Number_of_Payments__c=0,nu_dse__First_Payment_Date__c=null,nu_dse__Offer_Amount__c=0);
            offerUpdateMap.put(offerId,offer);
        }

        Boolean amountTaken = false;
        Map<Id,boolean> OfferAmountTaken = new Map<Id,boolean>();
        //Added for S20-503 by Uchit
        if(!OfferIds.isEmpty()){
        for(nu_dse__Payment__c objPayment : [Select Id,nu_dse__Total_Amount__c,nu_dse__Amount__c,nu_dse__Schedule_Date__c,nu_dse__Offer__c, nu_dse__Offer__r.Offer_Original_Amount__c,nu_dse__Transaction_Status__c from nu_dse__Payment__c where nu_dse__Offer__c IN: offerIds
                                            and RecordTypeId=:Attorney_StaticVariableUtility.settlementRecordId and isAttorney__c = true])
        {   
        
            //System.debug()
            if(offerUpdateMap.containsKey(objPayment.nu_dse__Offer__c))
            {
                
                nu_dse__Offer__c offer = offerUpdateMap.get(objPayment.nu_dse__Offer__c);
                offer.nu_dse__Number_of_Payments__c  = offer.nu_dse__Number_of_Payments__c + 1;
                
                if(Trigger.isInsert && ObjPayment.nu_dse__Amount__c != null && NewPaymentMap.containsKey(objPayment.Id)){
                    if(!OfferAmountTaken.containsKey(ObjPayment.nu_dse__Offer__c) && objPayment.nu_dse__Offer__r.Offer_Original_Amount__c == null){
                        //offer.Offer_Original_Amount__c = ObjPayment.nu_dse__Amount__c;
                        amountTaken = true;
                        OfferAmountTaken.put(ObjPayment.nu_dse__Offer__c,True);
                    } else if(!OfferAmountTaken.containsKey(ObjPayment.nu_dse__Offer__c) && objPayment.nu_dse__Offer__r.Offer_Original_Amount__c != null){
                        //offer.Offer_Original_Amount__c = ObjPayment.nu_dse__Amount__c + objPayment.nu_dse__Offer__r.Offer_Original_Amount__c;
                        amountTaken = true;
                        OfferAmountTaken.put(ObjPayment.nu_dse__Offer__c,True);
                    } else if(OfferAmountTaken.containsKey(ObjPayment.nu_dse__Offer__c)){
                        //offer.Offer_Original_Amount__c = ObjPayment.nu_dse__Amount__c + Offer.Offer_Original_Amount__c;
                    }
                }
                
                if(objPayment.nu_dse__Schedule_Date__c != null)
                {
                    if(offer.nu_dse__First_Payment_Date__c == null)
                         offer.nu_dse__First_Payment_Date__c = objPayment.nu_dse__Schedule_Date__c;
                    else if(objPayment.nu_dse__Schedule_Date__c  < offer.nu_dse__First_Payment_Date__c)
                         offer.nu_dse__First_Payment_Date__c = objPayment.nu_dse__Schedule_Date__c;
                }
                   
                if(objPayment.nu_dse__Amount__c != null && objPayment.nu_dse__Transaction_Status__c != 'Failed' && objPayment.nu_dse__Transaction_Status__c != 'Cancelled')
                    offer.nu_dse__Offer_Amount__c = offer.nu_dse__Offer_Amount__c + ObjPayment.nu_dse__Amount__c;
                
                offerUpdateMap.put(objPayment.nu_dse__Offer__c,offer);
            
            }
            rollupToOfferUpdated = true;
            
            //NMI - 487 Changes ended
        }
        }
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;  
        Database.update(offerUpdateMap.values(),false);
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = false;
        
    }
    
    public static Map<String,LeadTracProgramType__mdt> getLeadtrackProgramLst(){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst = [Select Id,RAMS__c,Drafting_in_Salesforce__c,Label,Parameter__c FROM LeadTracProgramType__mdt];    
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt programType : leadtrckProgramTypeLst ){
            LeadTracProgramTypeMap.put(programType.Label,programType);
        }
        return LeadTracProgramTypeMap;
    }
    
    //Populate Fee Template
    public static void populateFeeTemplate(Set<Id> ids){
     /*   List<nu_dse__Program__c > Intlist = [SELECT Id, (SELECT nu_dse__Payment_Sequence_Number__c FROM nu_dse__Payments__r) FROM nu_dse__Program__c ];
        
        List<List<nu_dse__Payment__c>> pay  = new List<List<nu_dse__Payment__c>>();
        
        for(Integer j=0; j<Intlist.size();j++ ){
            pay.add(Intlist[j].nu_dse__Payments__r);
        }
        System.debug('Size  '+ pay.size());
        
        
        for(Integer i= 0 ; i<pay.size();i++){
            Decimal temp = pay[i][0].nu_dse__Payment_Sequence_Number__c;
            for(Integer k = 1; k<pay[i].size();k++){
                if(pay[i][k].nu_dse__Payment_Sequence_Number__c > temp){
                    temp = pay[i][k].nu_dse__Payment_Sequence_Number__c;
                } 
            }
            System.debug('After MaX Value '+temp);
            //  Other Logic to populate  ;
            
        }
        
        */
        
    }
    
    
    public static void deletePaymentFromNDS(){
    
        List<nu_dse__Payment__c> PaymentList = Trigger.old;
        List<String> PaymentIds = new List<String>();
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        for(nu_dse__Payment__c Payment: PaymentList){
            if(Payment.Attorney_Payment_Id__c != null && Payment.RecordTypeId == DraftRecordTypeId){
                PaymentIds.add(Payment.Attorney_Payment_Id__c);
            }
        }
        
        if(!PaymentIds.isEmpty()){
            System.enqueueJob(new DeleteDraftPaymentFromNDS(PaymentIds));
        }
    
    }
    
    public class DeleteDraftPaymentFromNDS implements Queueable,Database.AllowsCallouts {
        
        List<String> PaymentIds;
        
        public DeleteDraftPaymentFromNDS(List<String> cPaymentIds)
        {
            this.PaymentIds = cPaymentIds; 
        }
        
        public void execute(QueueableContext context) { 
            leadtracNetServicing.ServicingSoap soap = new leadtracNetServicing.ServicingSoap();
            
            for(String PaymentId: PaymentIds){
                if(!Test.isRunningTest()){
                leadtracNetServicing.Result DeletePaymentResult = soap.DeletePayment(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                                                           Attorney_StaticVariableUtility.credentials.Password__c,
                                                                                           Long.valueOf(PaymentId));
                }
            }
        }
    }
}