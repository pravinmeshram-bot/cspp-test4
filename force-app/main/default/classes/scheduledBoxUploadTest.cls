@isTest
private class scheduledBoxUploadTest{
  static testmethod void  testschedule(){
     nu_dse__Prospect__c t=new nu_dse__Prospect__c();
     t.nu_dse__First_Name__c    ='testfirst';
     t.nu_dse__last_Name__c    ='testlast';
     insert t;
     
     Loop__DDP__c ddp1 = new Loop__DDP__c();
     ddp1.name = 'pftp';
     insert ddp1;
    
     Loop__DDP_Integration_Option__c delivery = new Loop__DDP_Integration_Option__c();
     delivery.name = 'FTP';
     delivery.Loop__DDP__c= ddp1.id;
     insert delivery;
     
     DailyReportUpload__c settings = new DailyReportUpload__c();
     settings.name = 'FTPUploadSettings';
     settings.DDPId__c = ddp1.id;
     settings.DeliveryId__c = delivery.id;
     settings.CurrentSessionId__c = userinfo.getsessionid();
     insert settings;

        Datetime dt = Datetime.now().addMinutes(1); String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
        system.schedule('Test ScheduledBatchClass', CRON_EXP, new scheduledBoxUpload());
    }
}