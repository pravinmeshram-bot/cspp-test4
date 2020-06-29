public Class Prizm_OfferHandler{

    public Static Boolean PrizmOfferExecuted = false;
    
    public static void UpdateLastDebt(){
    
        if(!PrizmOfferExecuted){
            List<nu_dse__Offer__c> OfferList = (List<nu_dse__Offer__c>)Trigger.new;
            Map<Id,nu_dse__Offer__c> OfferOldMap = (Map<Id,nu_dse__Offer__c>)Trigger.oldMap;
            
            List<nu_dse__Offer__c> UpdatedOfferList = new List<nu_dse__Offer__c>();
            List<Id> ProgramIds = new List<Id>();
            for(nu_dse__Offer__c Offer : OfferList){
                if(offer.nu_dse__Status__c == 'Accepted' && (Trigger.isInsert || offer.nu_dse__Status__c != OfferOldMap.get(Offer.Id).nu_dse__Status__c)){
                    ProgramIds.add(Offer.nu_dse__Program__c);
                    UpdatedOfferList.add(Offer);
                }
            }
            
            if(!ProgramIds.isEmpty()){
                Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>([Select Id,DNL_Status__c,(Select Id from nu_dse__Tradelines__r where Settlement_Status__c != 'Settled') from nu_dse__Program__c where Id =: ProgramIds]);
                
                for(nu_dse__Offer__c Offer : UpdatedOfferList){
                    if(ProgramMap.containsKey(Offer.nu_dse__Program__c)){
                        nu_dse__Program__c Program = ProgramMap.get(Offer.nu_dse__Program__c);
                        if(Program.DNL_Status__c == 'Pre-TILA Signed' && (Program.nu_dse__Tradelines__r == null || Program.nu_dse__Tradelines__r.size() == 0)){
                            Offer.Is_Last_Debt__c = true;
                        }
                    }
                }
                PrizmOfferExecuted = true;
            }
        }
    }

}