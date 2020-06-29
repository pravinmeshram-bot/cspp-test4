public class TradeLinesWithOffersPaymentsController {
    //public String programId {get; set;}
    public Map<Id, nu_dse__Offer__c> offersByTradelineId {get; set;}
    public Map<Id, List<nu_dse__Payment__c>> paymentsByOfferId {get; set;}
    public List<nu_dse__TradeLine__c> tradeLines {get; set;}
    public boolean isOfferAvalable {get; set;}
    //public boolean isPaymentAvalable {get; set;}
    
    public String programId {get; set {
            if(programId == null) {
                programId = value;
                init();
            }
        }
    }
    
    public void init(){
        system.debug('+++++programId+++'+programId);
        if (!String.isBlank(programId)) {
           // List<nu_dse__TradeLine__c> tradeLines = [SELECT Id, Name, (Select Id, Name from nu_dse__Offer__r)  FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =: programId];
            tradeLines = [SELECT Id, Name  FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c =: programId];
            List<nu_dse__Offer__c> offers = [Select Id, Name, Latest_Offer__c, Account_Name__c, NDS_Creditor_Info__c,nu_dse__Offer_Amount__c,Current_Balance__c, Current_Balance_Percentage__c, nu_dse__TradeLine__c, nu_dse__TradeLine__r.Name from nu_dse__Offer__c where nu_dse__TradeLine__c IN: tradeLines and Latest_Offer__c = true];
            offersByTradelineId = new Map<Id, nu_dse__Offer__c>();
            paymentsByOfferId = new Map<Id, List<nu_dse__Payment__c>>();
            isOfferAvalable = false;
            for (nu_dse__Offer__c offer: offers) {
                offersByTradelineId.put(offer.nu_dse__TradeLine__c, offer);
            }
            
            if (!offersByTradelineId.isEmpty()) {
                isOfferAvalable = true;
            }
            
            for (nu_dse__Payment__c payment: [Select Id, Name, nu_dse__Schedule_Date__c,nu_dse__Amount__c,nu_dse__Transaction_Status__c, nu_dse__Offer__c from nu_dse__Payment__c where nu_dse__Offer__c IN: offers and RecordType.DeveloperName = 'Settlement']) {
                if (paymentsByOfferId.isEmpty() || !paymentsByOfferId.containsKey(payment.nu_dse__Offer__c)) {
                    paymentsByOfferId.put(payment.nu_dse__Offer__c, new List<nu_dse__Payment__c>{payment});
                } else {
                    paymentsByOfferId.get(payment.nu_dse__Offer__c).add(payment);
                }
            }
            
            
        }
        system.debug('+++++isOfferAvalable+++'+isOfferAvalable);
        system.debug('+++++tradeLines+++'+tradeLines);
        system.debug('+++++offersByTradelineId+++'+offersByTradelineId);
        system.debug('+++++paymentsByOfferId+++'+paymentsByOfferId);
    }
}