global class scheduledBoxUpload implements Schedulable {
   global String session_Id = UserInfo.getSessionId();
   global void execute(SchedulableContext SC) {
      List<DailyReportUpload__c> DailyReportUpload = DailyReportUpload__c.getall().values();
      system.debug('@@ DailyReportUpload->'+DailyReportUpload);
      if(DailyReportUpload != null && !DailyReportUpload.isEmpty()){
          DailyReportUpload[0].CurrentSessionId__c = session_Id;
          update DailyReportUpload;
          BoxUploadUtil.processUploadDDP();
      }
   }
   //scheduledBoxUpload obj = new scheduledBoxUpload();
   // String sch = '0 48 11 29 10 ?';
   // String jobID = system.schedule('scheduledBoxUpload', sch, obj);
}