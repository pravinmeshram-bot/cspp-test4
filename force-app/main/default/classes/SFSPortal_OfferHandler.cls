public class SFSPortal_OfferHandler {
    
    public static void sendNotificationToOffer(List<nu_dse__Offer__c > newOffer, Map<Id, nu_dse__Offer__c > oldOfferMap) {
        
        Map<Id, List<nu_dse__Offer__c >> programIdWithOfferListMap = new Map<Id, List<nu_dse__Offer__c >>();
        Map<Id, String> OfferIdWithOneSignalIdMap= new Map<Id, String>();
        set<Id> offerIdSet = new set<Id>();
        
        for (nu_dse__Offer__c offerInstance : newOffer) {
              
            if ((oldOfferMap == null || (oldOfferMap.isEmpty() == False && oldOfferMap.ContainsKey(offerInstance.Id) 
                && (offerInstance.Available_for_Client_Review__c != oldOfferMap.get(offerInstance.Id).Available_for_Client_Review__c 
                    || offerInstance.Source_of_Payment__c != oldOfferMap.get(offerInstance.Id).Source_of_Payment__c 
                    || offerInstance.Tradeline_Litigation_Status__c != oldOfferMap.get(offerInstance.Id).Tradeline_Litigation_Status__c
                    || offerInstance.Authorization_Received__c != oldOfferMap.get(offerInstance.Id).Authorization_Received__c )))
                        && offerInstance.nu_dse__Program__c != null && offerInstance.Available_for_Client_Review__c 
                        && offerInstance.Source_of_Payment__c == 'PSA' && offerInstance.Tradeline_Litigation_Status__c == 'Non Lit'
                        && offerInstance.Authorization_Received__c == FALSE ) {
                
                offerIdSet.add(offerInstance.Id);
            }      
        }
        if (offerIdSet.isEmpty() == False) {
            
            for (nu_dse__Offer__c offerInstance : [SELECT Id, nu_dse__Program__c, nu_dse__Program__r.nu_dse__Program_Status__c, 
                                                   nu_dse__Program__r.SFSPortal_OneSignal_App_Id__c, nu_dse__Status__c 
                                                   FROM nu_dse__Offer__c 
                                                   WHERE Id IN :offerIdSet AND nu_dse__Program__c != null AND nu_dse__Program__r.nu_dse__Account__c != null 
                                                   AND nu_dse__Program__r.Client_Portal_User_Id__c != null AND nu_dse__Program__r.SFSPortal_OneSignal_App_Id__c != null 
                                                   AND ((Portfolio_Display_Name__c = 'Timberline Financial' 
                                                   AND nu_dse__Status__c = 'Management Approved') OR (Portfolio_Display_Name__c = 'Royal Legal Group' 
                                                   AND nu_dse__Status__c = 'In-House Attorney Approved') OR (Portfolio_Display_Name__c != 'Royal Legal Group' 
                                                   AND Portfolio_Display_Name__c != 'Timberline Financial' AND nu_dse__Status__c = 'Pending Creditor Approval'))]) {
                                                        
                OfferIdWithOneSignalIdMap.put(offerInstance.Id, offerInstance.nu_dse__Program__r.SFSPortal_OneSignal_App_Id__c);
            }    
        }
        if (OfferIdWithOneSignalIdMap!= null &&  OfferIdWithOneSignalIdMap.isempty() == False) {
            
            SFSPortal_TaskHandler.createNotification(OfferIdWithOneSignalIdMap);
        }
    }
}