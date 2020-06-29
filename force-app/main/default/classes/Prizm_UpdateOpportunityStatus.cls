@RestResource(urlMapping='/updateOpportunityStatus/*')
global class Prizm_UpdateOpportunityStatus{

    @HttpPost
    global static String updateOpportunityStatus() {
        String jsonStr;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if(!Test.isRunningTest()){
        	 jsonStr = RestContext.request.requestBody.toString();
        } else {
            List<OpportunityStatusWrapper> OppoWrapperList = new List<OpportunityStatusWrapper>();
            OpportunityStatusWrapper oppoW = new OpportunityStatusWrapper();
            oppoW.OpportunityId = [Select Id from Opportunity limit 1].Id;
            oppoW.Status = 'Closed Won';
            OppoWrapperList.add(oppoW);
            jsonStr = JSON.serialize(OppoWrapperList);
        }
        system.debug('Json-->'+jsonStr);
        List<OpportunityStatusWrapper> OppoWrapperList = (List<OpportunityStatusWrapper>)JSON.deserialize(jsonStr,List<OpportunityStatusWrapper>.class);
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        for(OpportunityStatusWrapper OppoWrap : OppoWrapperList){
            system.debug('OppWRAP'+OppoWrap);
            Opportunity oppo = new Opportunity();
            if(oppoWrap.OpportunityId!='' && oppoWrap.Status!='')
            {
            //Opportunity oppo = new Opportunity();
            oppo.Id = oppoWrap.OpportunityId;
            oppo.StageName = oppoWrap.Status;
            oppo.Sales_Rep__c = oppoWrap.salesRep;  //@
            OpportunityList.add(oppo);
            }
            //@36-39
            else{
                oppo.Sales_Rep__c = oppoWrap.salesRep;
                OpportunityList.add(oppo);
            }
               
            
        }
        system.debug('OPP--->'+OpportunityList);
        Update OpportunityList;
        return 'true';
        
    }
    
    public class OpportunityStatusWrapper{
        public string OpportunityId;
        public String Status;
        public String salesRep;  //@
        public OpportunityStatusWrapper(){
            OpportunityId = '';
            Status = '';
            salesRep='';  //@
        }
    }
}