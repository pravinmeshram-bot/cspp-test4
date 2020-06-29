global class Schedule_Batch_Dnlsettlement implements schedulable {

    global void execute(SchedulableContext SC) {
      Batch_DNLSettlement_Sync b=new Batch_DNLSettlement_Sync();
      database.executeBatch(b,3);
   }
}

/*
   // String cron = '0 00 13,01 * * ?';   //1AM & 1PM EST
String cron = '0 00 15,03 * * ?';   //3AM & 3PM EST
Schedule_Batch_Dnlsettlement sch=new Schedule_Batch_Dnlsettlement();
system.schedule('Schedule DNL Settelment rate(3EST)', cron, sch);*/