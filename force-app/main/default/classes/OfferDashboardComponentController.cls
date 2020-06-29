/* Date : 28-12-2017
 * Description : Dashboard component controller 
 */
global class OfferDashboardComponentController {

    @RemoteAction
    global static OfferDashboardWrapper getOfferDashboardReport(String programId) {
    
        if(programId != null) {
            
            Map<String, Map<String, Integer>> tradelineAndOfferMap = new Map<String, Map<String, Integer>>();
            
            List<String> stausValueList = new List<String>();
            
            Map<Id, nu_dse__TradeLine__c> tradelineMap = new Map<Id, nu_dse__TradeLine__c>
                                                                ([SELECT Id, Name FROM nu_dse__TradeLine__c
                                                                    WHERE nu_dse__Program__c = :programId]);
            
            for(AggregateResult ar : [SELECT nu_dse__TradeLine__c tradelineId, nu_dse__Status__c status, count(Id) recCount 
                                        FROM nu_dse__Offer__c 
                                        WHERE nu_dse__Program__c =: programId 
                                        Group By nu_dse__TradeLine__c, nu_dse__Status__c]) {
                
                Id tradelineId = (Id)ar.get('tradelineId');
                
                if(tradelineMap.containsKey(tradelineId)) {
                    
                    String tradelineName = tradelineMap.get(tradelineId).Name;
                    
                    if(tradelineAndOfferMap.containsKey(tradelineName)) {
                    
                        tradelineAndOfferMap.get(tradelineName).put(String.valueOf(ar.get('status')), Integer.valueOf(ar.get('recCount')));
                    } else {
                    
                        tradelineAndOfferMap.put(tradelineName, new Map<String, Integer>{String.valueOf(ar.get('status')) => Integer.valueOf(ar.get('recCount'))});
                    }
                }   
            }
            
            for(Schema.PicklistEntry status : nu_dse__Offer__c.nu_dse__Status__c.getDescribe().getPicklistValues()) {
            
                stausValueList.add(status.getValue());
            }
            
            OfferDashboardWrapper wrapper = new OfferDashboardWrapper();
            wrapper.tradelineOfferMap = tradelineAndOfferMap;
            wrapper.offerStatusList = stausValueList;
            
            return wrapper;
            
        }
        return null;
    }
    
    global class OfferDashboardWrapper {
    
        public Map<String, Map<String, Integer>> tradelineOfferMap {get; set;}
        public List<String> offerStatusList {get; set;}
    }
}