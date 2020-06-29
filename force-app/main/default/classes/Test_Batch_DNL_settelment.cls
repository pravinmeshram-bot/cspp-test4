@isTest
public class Test_Batch_DNL_settelment {
    
  public static testMethod void ConnectionHelper()
  {
      String connname='Perrform test';
      ConnectionHelper_DNL_Settlment.getConnectionId(connname);
      ConnectionHelper_DNL_Settlment.getConnectionOwnerId(connname);
  }
  public static testmethod void BatchDNLSettelment()
  {
    list<DNL_Settlement_Rate__c> lstDNL=new list<DNL_Settlement_Rate__c>();
    DNL_Settlement_Rate__c DSR=new DNL_Settlement_Rate__c();
    DSR.Average_of_Adjusted_Settlement__c=7;
    DSR.Current_Creditor__c='ABC PVT.';
    DSR.Original_Creditor__c='XYZ';
    DSR.End_Date__c=system.now()+3;
    DSR.Start_Date__c=system.now();
      DSR.Type__c='Legal';
      lstDNL.add(DSR);
      Database.insert(lstDNL);
    //DSR.ConnectionReceivedId=
    test.startTest();
      Batch_DNLSettlement_Sync b=new Batch_DNLSettlement_Sync();
     // Database.executeBatch(b,3);
      
      Database.QueryLocator ql = b.start(null);
     b.execute(null,lstDNL);
     b.Finish(null);
    test.stopTest();
  }
   public static testmethod void ScheduleDNLSettelment()
  {
    test.startTest();
      Schedule_Batch_Dnlsettlement sh1 = new Schedule_Batch_Dnlsettlement();

      String sch = '0 0 23 * * ?'; 
      system.schedule('Test DNL Check', sch, sh1); 
      test.stopTest();
   }

}