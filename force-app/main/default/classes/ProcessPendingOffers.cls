public class ProcessPendingOffers implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts{
    
    public database.QueryLocator start(Database.BatchableContext BC){
        Date consideredDate = Date.newInstance(2020,1,31);
        Date startDate = Date.newInstance(2018,8,1);
        String query='Select Id,nu_dse__First_Payment_Date__c,nu_dse__Status__c,Latest_Offer__c,IsAttorney__c,IsRelatedRecordEligibleForPick__c from nu_dse__Offer__c where nu_dse__Program__c != null AND nu_dse__First_Payment_Date__c>: startDate AND nu_dse__First_Payment_Date__c<: consideredDate AND nu_dse__Status__c == \'To Payment Processing\' AND nu_dse__Program__r.Test_Program__c == False'; 
        return database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Offer__c> OfferList){
        List<Id> OfferIds = new List<Id>();
        for(nu_dse__Offer__c Offer: OfferList){
            Offer.nu_dse__Status__c = 'Accepted';
            OfferIds.add(Offer.Id);
        }
        Date consideredDate = Date.newInstance(2020,1,31);
        Id SettlementRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        List<nu_dse__Payment__c> PaymentList = [Select Id,nu_dse__Transaction_Status__C, nu_dse__Offer__c from nu_dse__Payment__c where nu_dse__Offer__c =: OfferIds AND nu_dse__Schedule_Date__c <: consideredDate AND RecordTypeId=:SettlementRecordType AND (nu_dse__Transaction_Status__c = 'Pending' OR nu_dse__Transaction_Status__c = 'Scheduled')];
        
        for(nu_dse__Payment__c Payment: PaymentList){
            Payment.nu_dse__Transaction_Status__c ='Cleared';
        }
        
        Update PaymentList;
        Update OfferLIst;
    }
    
    public void finish(Database.BatchableContext BC){
    
    }
    
}