global class Batch_Tradeline_payments_retrieve implements Database.Batchable<sObject> {
   string query;
   global Database.QueryLocator start(Database.BatchableContext BC){
      Id sfid='0061K00000daJ81';
      //Id sfid='006220000036KkL';
      query='select id,Name,Program_ID__c from opportunity where id!=:sfid AND (createdDate> 2019-06-24T06:10:21.000+0000 and createdDate< 2019-06-25T06:10:21.000+0000)';  
          //createdDate> 2019-06-24T06:10:21.000+0000 and createdDate< 2019-06-25T06:10:21.000+0000'
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC,List<opportunity> oppList){
        Set<String> oppProgIdSet = new Set<String>();
        Map<String,Id> oppProgIdMap = new Map<String,Id>();
        List<nu_dse__TradeLine__c> tradeToInsertLst = new List<nu_dse__TradeLine__c>();
        List<nu_dse__Payment__c> paymentToInsertLst = new List<nu_dse__Payment__c>();
        for(Opportunity opp: oppList){
            if(opp.Program_ID__c!=null){
            oppProgIdSet.add(opp.Program_ID__c);
            oppProgIdMap.put(opp.Program_ID__c,opp.Id);
            
           } 
            
        }
       system.debug('oppProgIdMap'+oppProgIdMap);
       List<nu_dse__Program__c> PrgmLst = [select id,Name,Import_ID__c FROM nu_dse__Program__c WHERE id IN: oppProgIdSet];
       List<nu_dse__Payment__c> lstpayment=[select id,Name,nu_dse__Program__c from nu_dse__Payment__c where nu_dse__Program__c in:oppProgIdSet];
       List<nu_dse__TradeLine__c> lstTrade=[select id,Name,nu_dse__Program__c from nu_dse__TradeLine__c where nu_dse__Program__c in:oppProgIdSet];
       system.debug('efore lstTrade'+lstTrade);
       for(nu_dse__Program__c prg:PrgmLst){
          if(oppProgIdMap.containsKey(prg.Id)){
           for(nu_dse__TradeLine__c trade:lstTrade){
               
                trade.Opportunity__c = oppProgIdMap.get(prg.id);
                trade.FileNumber__c = prg.Import_ID__c;
                tradeToInsertLst.add(trade);
               
              }
            system.debug('tradeToInsertLst'+tradeToInsertLst);
           for(nu_dse__Payment__c pay: lstpayment){
                pay.Opportunity__c = oppProgIdMap.get(prg.id);
                pay.FileNumber__c = prg.Import_ID__c;
                paymentToInsertLst.add(pay);
            }
           }
       }
       if(!tradeToInsertLst.isEmpty())
            Update tradeToInsertLst;
        if(!paymentToInsertLst.isEmpty())
            Update paymentToInsertLst; 
   }

   global void finish(Database.BatchableContext BC){

   }
}