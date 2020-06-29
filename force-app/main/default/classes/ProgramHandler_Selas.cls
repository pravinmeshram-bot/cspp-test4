public class ProgramHandler_Selas {
    
    public static void updateOfferRenegotiable(Map<Id, nu_dse__Program__c> oldProgramMap, List<nu_dse__Program__c> newProgramList) {
        
        if (newProgramList != NULL && newProgramList.isEmpty() == FALSE) {
        
            Set<Id> programIdSet = new Set<Id>();
            List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
            
            for (nu_dse__Program__c pgm : newProgramList) {
            
                if (pgm.DNL_Status__c != NULL && pgm.DNL_Status__c == 'Pre-TILA Signed'
                     && (oldProgramMap.get(pgm.Id).DNL_Status__c != pgm.DNL_Status__c)) {
                     
                     programIdSet.add(pgm.Id);
                }                
            }
            
            if(!programIdSet.isEmpty()){
                for (nu_dse__Offer__c off : [SELECT Id, Renegotiable__c, nu_dse__Program__c, Latest_Offer__c FROM nu_dse__Offer__c
                                             WHERE nu_dse__Program__c IN :programIdSet AND Latest_Offer__c = TRUE AND Renegotiable__c = FALSE]) {
                                             
                    off.Renegotiable__c = TRUE;
                    offerList.add(off);                     
                }
                
                if (offerList != NULL && offerList.isEmpty() == FALSE) {
                    
                    Update offerList;
                }
            }
        }
    }
}