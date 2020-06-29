/**
 * @File Name          : Attorney_cancelPaymentsBatch.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/23/2019, 2:12:04 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/23/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class Attorney_cancelPaymentsBatch implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts{

    global List<Id> ProgramIds = new List<Id>();
    
    global Attorney_cancelPaymentsBatch(List<Id> inputProgramIds){
        system.debug('--ProgramIds : ' + ProgramIds);
        ProgramIds = inputProgramIds;
    }
    
    global List<nu_dse__Payment__c> start(Database.BatchableContext BC){
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id FeeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        System.debug('****'+Date.today());
        List<nu_dse__Payment__c> PaymentList = [Select Id,nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c,RecordTypeId,Is_Skip_Payment__c, nu_dse__Program__c, nu_dse__Program__r.nu_dse__Program_Status__c, nu_dse__Transaction_Status__c,nu_dse__Is_Makeup_Payment_Created__c ,nu_dse__Schedule_Date__c from nu_dse__Payment__c 
                                                where nu_dse__Program__c =: ProgramIds AND 
                                                nu_dse__Schedule_Date__c>:Date.today() 
                                                AND (nu_dse__Transaction_Status__c = 'Pending' OR nu_dse__Transaction_Status__c = 'Scheduled' OR nu_dse__Transaction_Status__c = 'Cancelled') 
                                                AND (RecordTypeId =: DraftRecordTypeId OR RecordTypeId =: FeeRecordTypeId) FOR UPDATE];
        System.debug('-- PaymentList '+PaymentList);
        return PaymentList;
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> PaymentList){
        //Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        for(nu_dse__Payment__c Payment : PaymentList){
            if(payment.Is_Skip_Payment__c){
                system.debug('--bATCH after change payment : ' + payment);
            }
            system.debug('--Payment.nu_dse__Program__r.nu_dse__Program_Status__c : ' + Payment.nu_dse__Program__r.nu_dse__Program_Status__c);
            system.debug('--Payment.nu_dse__Transaction_Status__c : ' + Payment.nu_dse__Transaction_Status__c);
            //Prgram changes  to client active from client cancelled
            if(Payment.nu_dse__Program__r.nu_dse__Program_Status__c == 'Active Client' && Payment.nu_dse__Transaction_Status__c == 'Cancelled' && Payment.nu_dse__Is_Makeup_Payment_Created__c == False){
                //Payment.nu_dse__Transaction_Status__c = 'Scheduled';

                //New Code Starts
                //if(payment.RecordTypeID == DraftRecordTypeId){
                    system.debug('--tRUE CONDITION FOR IF STATEMENT' );
                    system.debug('--payment.Is_Skip_Payment__c  : ' + payment.Is_Skip_Payment__c);
                    if(!payment.Is_Skip_Payment__c){
                        if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'  || Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c.equalsIgnoreCase('CFT_REST')){                       
                            Payment.nu_dse__Transaction_Status__c = 'Scheduled';
                            Payment.Integration_Status__c = 'Overflow';
                        }else if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'GCS'|| Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS' ){                          
                            Payment.nu_dse__Transaction_Status__c = 'Pending';   
                            Payment.Integration_Status__c = 'Overflow';
                        }
                    }
                /*}else{
                    system.debug('--ELSE PART' );
                    if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'CFT' || Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c.equalsIgnoreCase('CFT_REST')){                       
                        Payment.nu_dse__Transaction_Status__c = 'Scheduled';
                    }else if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'GCS'|| Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS' ){                          
                        Payment.nu_dse__Transaction_Status__c = 'Pending';   
                    }
                }*/

                //New Code ends
                ////Prgram changes  to client cancelled from client active
            } else if(Payment.nu_dse__Program__r.nu_dse__Program_Status__c != 'Active Client' && (Payment.nu_dse__Transaction_Status__c == 'Scheduled' || Payment.nu_dse__Transaction_Status__c == 'Pending')){
                Payment.nu_dse__Transaction_Status__c = 'Cancelled';
                Payment.Integration_Status__c = 'Overflow';
            }
        }
        System.debug('*****'+PaymentList);
        //PaymentCancelled = true;
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Update PaymentList;
    }
    global void finish(Database.BatchableContext BC){
        
    }

}