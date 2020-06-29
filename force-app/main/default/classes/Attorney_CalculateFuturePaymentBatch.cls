global class Attorney_CalculateFuturePaymentBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Id FeeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        //LIst<Id> TradeIds = new List<Id>{'a0Q4100000IgSLq','a0Q4100000I19eIEAR','a0Q4100000I1624EAB'};
//        String query = 'Select Id, RecordTypeId,is_Future_Payment__c,nu_dse__Offer__r.nu_dse__Tradeline__r.Future_Payment_Amount__c,nu_dse__Offer__r.nu_dse__Tradeline__r.Future_Payment_Count__c, nu_dse__Offer__r.nu_dse__Tradeline__c, nu_dse__Total_Amount__c, nu_dse__Offer__c,nu_dse__Program__c from nu_dse__Payment__c where (RecordTYpeId =: FeeRecordTypeId OR RecordTYpeId =: SettlementRecordTypeId) AND is_Future_Payment__c = true AND nu_dse__Offer__c != null AND nu_dse__Total_Amount__c != null ORDER by nu_dse__Offer__r.nu_dse__Tradeline__c';
        String query = 'Select Id, Future_Payment_Count__c,Future_Payment_Amount__c,Future_Payment_Total_Amount__c,(Select Id from nu_dse__Offers__r where (nu_dse__Status__c = \'Settled\' OR nu_dse__Status__c = \'Payment Plan - Active\')) from nu_dse__Tradeline__c where ((Settled_Offer_Count__c > 0 AND Is_Program_Valid_for_Future_Payment__c = true) OR (Future_Payment_Count__c > 0 OR Future_Payment_Amount__c > 0 OR Future_Payment_Total_Amount__c > 0))';// AND Id =: TradeIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Tradeline__c> scope){
        System.debug(scope);
        Map<Id,List<Id>> TradeOfferMap = new Map<Id,List<Id>>();
        List<Id> OfferIds = new List<Id>();
        Map<Id,nu_dse__Tradeline__c> TradelineMap = new Map<Id,nu_dse__Tradeline__c>();
        Map<Id,Id> OfferTradeMap = new Map<Id,Id>();
        Map<Id,List<nu_dse__Payment__c>> TradePaymentsMap = new Map<Id,List<nu_dse__Payment__c>>();
        
        for(nu_dse__Tradeline__c tradeline : scope){
            
            if(!TradeOfferMap.containsKey(Tradeline.Id)){
                TradeOfferMap.put(Tradeline.Id,new List<Id>());
            }
            for(nu_dse__Offer__c Offer : Tradeline.nu_dse__Offers__r){
                TradeOfferMap.get(tradeline.Id).add(Offer.Id);
                OfferTradeMap.put(Offer.Id,Tradeline.Id);
                OfferIds.add(Offer.Id);
            }
        }
        
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Id FeeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        
        List<nu_dse__Payment__c> PaymentList = [Select Id, nu_dse__Offer__c, nu_dse__Amount__c,recordTypeId, nu_dse__Total_Amount__c,nu_dse__Offer__r.nu_dse__Tradeline__r.Future_Payment_Amount__c,nu_dse__Offer__r.nu_dse__Tradeline__r.Future_Payment_Count__c,nu_dse__Offer__r.nu_dse__Tradeline__r.Future_Payment_Total_Amount__c, nu_dse__Offer__r.nu_dse__Tradeline__c from nu_dse__Payment__c where nu_dse__Offer__c =: OfferIds AND is_Future_Payment__c = true AND (RecordTypeId =: settlementRecordTypeId OR RecordTypeId =: FeeRecordTypeId)];
        
        for(nu_dse__Payment__c Payment : PaymentList){
            if(OfferTradeMap.containsKey(payment.nu_dse__Offer__c)){
                if(!tradePaymentsMap.ContainsKey(OfferTradeMap.get(payment.nu_dse__Offer__c))){
                    tradePaymentsMap.Put(OfferTradeMap.get(payment.nu_dse__Offer__c),new List<nu_dse__Payment__c>());
                }
                tradePaymentsMap.get(OfferTradeMap.get(payment.nu_dse__Offer__c)).add(Payment);
            }
            
        }
        
        for(nu_dse__Tradeline__c Tradeline : scope){
                Tradeline.Future_Payment_Count__c = 0;
                Tradeline.Future_Payment_Amount__c = 0;
                Tradeline.Future_Payment_Total_Amount__c = 0;
            if(TradePaymentsMap.containsKey(Tradeline.Id)){
                for(nu_dse__Payment__c Payment : TradePaymentsMap.get(Tradeline.Id)){
                    if(Payment.RecordTypeId != FeeRecordTypeId){
                        Tradeline.Future_Payment_Count__c ++;
                    }
                    if(Payment.nu_dse__Amount__c != null)
                        Tradeline.Future_Payment_Amount__c += Payment.nu_dse__Amount__c;
                    if(Payment.nu_dse__Total_Amount__c != null)
                        Tradeline.Future_Payment_Total_Amount__c += Payment.nu_dse__Total_Amount__c;
                }
            }

        }
        Update scope;
        
    }

    global void finish(Database.BatchableContext BC){
    
    }
}