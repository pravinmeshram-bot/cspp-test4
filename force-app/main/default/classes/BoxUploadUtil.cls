public class BoxUploadUtil{

    @future(callout=true)
    public static void  processUploadDDP(){
          list<nu_dse__prospect__c> lstprosepct = new list<nu_dse__prospect__c>();
          lstprosepct  = [select id,name from nu_dse__prospect__c limit 1];
          List<DailyReportUpload__c> DailyReportUpload = DailyReportUpload__c.getall().values();
          if(DailyReportUpload != null && !DailyReportUpload.isEmpty()){
            Loop.loopMessage lm = new Loop.loopMessage();
            lm.sessionId = DailyReportUpload[0].CurrentSessionId__c;
            system.debug('@@ lm.sessionId->'+lm.sessionId);
            lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                lstprosepct[0].id, 
                DailyReportUpload[0].DDPId__c,
                new Map<string, string>{
                    'deploy' => DailyReportUpload[0].DeliveryId__c
                }
            ));
            lm.sendAllRequests();
            }
        
    }
}