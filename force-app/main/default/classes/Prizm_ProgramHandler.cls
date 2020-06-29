public Class Prizm_ProgramHandler{
  
    public Static Boolean TotalFeesUpdated = false;

    public Static void TotalFeesUpdate(Map<Id,nu_dse__Program__c> ProgramOldMap,List<nu_dse__Program__c> ProgramList,Boolean isInsert){
    
        if(!TotalFeesUpdated){
        //List<nu_dse__Program__c> ProgramList = (List<nu_dse__Program__c>)Trigger.new;
        //System.debug('****After');
        //Map<Id,nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.OldMap;
        //List<nu_dse>
        List<Id> ProgramIds = new List<Id>();
        for(nu_dse__Program__c Program : ProgramList){
            System.debug(Program.DNL_Status__c);
            System.debug(Program.nu_dse__Program_Status__c);
            System.debug(Program.Total_Fees__c);
            if(Program.DNL_Status__c != null && (Program.nu_dse__Program_Status__c == 'Graduated Program' || Program.nu_dse__Program_Status__c == 'Graduated') && (isInsert || Program.nu_dse__Program_Status__c != ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c || Program.Total_Fees__c != ProgramOldMap.get(Program.Id).Total_Fees__c)){
                ProgramIds.add(Program.Id);
            }
        }
        System.debug(ProgramIds);
        if(!ProgramIds.isEMpty()){
        List<Opportunity> OppoList = [Select Program_Id__c,Id,CreatedDate from Opportunity where Program_Id__c =: ProgramIds];
        
        List<nu_dse__Offer__c> OfferList = [Select Id,nu_dse__Offer_Amount__c,nu_dse__TradeLine__c,nu_dse__TradeLine__r.nu_dse__Program__c from nu_dse__Offer__c where nu_dse__TradeLine__r.nu_dse__Program__c =: ProgramIds AND nu_dse__Status__c = 'Accepted'];
        
        Map<Id,Opportunity> ProgramOppoMap = new Map<Id,Opportunity>();
        for(Opportunity opp : OppoList){
            if(!ProgramOppoMap.containsKey(opp.Program_Id__c)){
                ProgramOppoMap.put(opp.Program_Id__c,opp);
            } else if(ProgramOppoMap.get(opp.Program_Id__c).CreatedDate < Opp.CreatedDate){
                ProgramOppoMap.put(opp.Program_Id__c,opp);
            }
        }
        System.debug(ProgramOppoMap);
        List<ProgramWrapper> ProgramWrapList = new List<ProgramWrapper>();
        
        Map<Id, List<nu_dse__Offer__c>> ProgramOfferMap = new Map<Id, List<nu_dse__Offer__c>>();
        for(nu_dse__Offer__c Offer : OfferList){
            if(!ProgramOfferMap.containsKey(Offer.nu_dse__TradeLine__r.nu_dse__Program__c)){
                ProgramOfferMap.put(Offer.nu_dse__TradeLine__r.nu_dse__Program__c,new List<nu_dse__Offer__c>());
            }
            ProgramOfferMap.get(Offer.nu_dse__TradeLine__r.nu_dse__Program__c).add(Offer);
        }
        
        For(nu_dse__Program__c Program : ProgramList){
            If(ProgramOppoMap.containsKey(Program.Id)){
                List<TradeOffer> TradeOfferList = new List<TradeOffer>();
                if(ProgramOfferMap.containsKey(Program.Id)){
                    for(nu_dse__Offer__c Offer : ProgramOfferMap.get(Program.Id)){
                        TradeOffer to = new TradeOffer();
                        to.OfferAmount = String.valueOf(Offer.nu_dse__Offer_Amount__c);
                        to.TradeId = Offer.nu_dse__Tradeline__c;
                        TradeOfferList.add(to);
                    }
                }
                ProgramWrapper pw = new ProgramWrapper(String.valueOf(ProgramOppoMap.get(Program.Id).Id),String.valueOf(Program.Total_Fees__c),TradeOfferList);
                ProgramWrapList.add(pw);
            }
        }
        System.debug(ProgramWrapList);
        if(!ProgramWrapList.isEmpty())
        {
            TotalFeesUpdated = true;
           // UpdateTotalFees(JSON.Serialize(ProgramWrapList));
            //System.enqueueJob(new AsyncCallToPrizm(JSON.Serialize(ProgramWrapList)));
            calloutToPrizm(JSON.Serialize(ProgramWrapList));
        }
        }
        }
    }
    
    //ND-57 related changes from line number 71 to 99
    public static void calloutToPrizm(String OpportunityList){
         String accessToken;
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,System_Endpoint__c,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        if(!Test.isRunningTest()){
        SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
        accessToken=acc1.ReturnAccessToken(acc1);
        } else{
            accessToken = 'test';
        }
        System.debug(accessToken+'###0012');
        System.debug(OpportunityList);
        if(accessToken!=null){
            String endPoint= restIntegration.System_Endpoint__c+'/UpdateTotalFees'; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(OpportunityList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            HttpResponse res2;
            if(!Test.isRunningTest())
            res2=h2.send(req2);
            System.debug(res2+'###1203createresp');
            
        }
    }
    
    /*public class AsyncCallToPrizm implements Queueable,Database.AllowsCallouts {
        
        String OpportunityList;
        
        public AsyncCallToPrizm(String OpprtunityList)
        {
            this.OpportunityList = OpprtunityList; 
        }
        
         public void execute(QueueableContext context) {
             String accessToken;
            RestIntegrationInformation__mdt restIntegration = [select MasterLabel,System_Endpoint__c,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
            if(!Test.isRunningTest()){
            SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
            accessToken=acc1.ReturnAccessToken(acc1);
            } else{
                accessToken = 'test';
            }
            System.debug(accessToken+'###0012');
            System.debug(OpportunityList);
            if(accessToken!=null){
                String endPoint= restIntegration.System_Endpoint__c+'/UpdateTotalFees'; 
                //String jsonstr= getOppDataJSON(oppLst);
                Http h2= new Http();
                HttpRequest req2= new HttpRequest();
                req2.setHeader('Authorization','Bearer ' + accessToken);
                req2.setHeader('Content-Type','application/json');
                req2.setHeader('accept','application/json');
                req2.setBody(OpportunityList);
                req2.setMethod('POST');
                req2.setEndpoint(endPoint);
                HttpResponse res2;
                if(!Test.isRunningTest())
                res2=h2.send(req2);
                System.debug(res2+'###1203createresp');
                
            }
         }
        
    }*/
    
    public class ProgramWrapper {
        
        String OpportunityId;
        String TotalFees;
        List<TradeOffer> TradeOfferList;
        
        public ProgramWrapper(String OpportunityId,String TotalFees,List<TradeOffer> TradeOfferList){
            this.OpportunityId = OpportunityId;
            this.TotalFees = TotalFees;
            this.TradeOfferlist = TradeOfferList;
        }
        
    }
    
    public Class TradeOffer{
            
        String TradeId;
        String OfferAmount;
        
        public TradeOffer(){
            tradeId = '';
            OfferAmount = '';
        }
        
    }
    
    /*@future(callout = true)
    public static void UpdateTotalFees(String OpportunityList){
    
        String accessToken;
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,System_Endpoint__c,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        if(!Test.isRunningTest()){
        SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
        accessToken=acc1.ReturnAccessToken(acc1);
        } else{
            accessToken = 'test';
        }
        System.debug(accessToken+'###0012');
        System.debug(OpportunityList);
        if(accessToken!=null){
            String endPoint= restIntegration.System_Endpoint__c+'/UpdateTotalFees'; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(OpportunityList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            HttpResponse res2;
            if(!Test.isRunningTest())
            res2=h2.send(req2);
            System.debug(res2+'###1203createresp');
            
        }
    }*/
    
    
    public static void createGroupTask(){
        System.debug('Group Task Creation');
        if(!Attorney_StaticVariableUtility.groupTasksCreatedforPrizm){
            List<nu_dse__Program__c> ProgramList = (List<nu_dse__Program__c>)Trigger.new;
            Map<Id, nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.oldMap;
            
            Id QueueId = [Select Id from Group where DeveloperName = 'DNL_Payments_Queue' AND Type = 'Queue'].Id;
            List<nu_dse__Group_Task__c> GroupTaskList = new List<nu_dse__Group_Task__c>();
            for(nu_dse__Program__c program: ProgramList){
                if(Program.DNL_Status__c == 'Pre-TILA Signed' && Program.DNL_Status__c != ProgramOldMap.get(Program.Id).DNL_status__c){
                    nu_dse__Group_Task__c gTask = new nu_dse__Group_Task__c();
                    gTask.OwnerId = QueueId;
                    gTask.nu_dse__ActivityDate__c = System.Today()+1;
                    gTask.nu_dse__Subject__c = 'Upload ATD/ACH form for DNL';
                    gTask.Program__c = Program.Id;
                    GroupTaskList.add(gTask);
                }
            }
            System.debug('******'+GroupTaskList);
            if(!GroupTaskList.isEmpty()){
                
                Insert GroupTaskList;
            }
                Attorney_StaticVariableUtility.groupTasksCreatedforPrizm = true;
        }
    }

}