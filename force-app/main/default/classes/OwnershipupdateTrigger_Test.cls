@isTest
public class OwnershipupdateTrigger_Test  {
  public static string ClientRecordtypeid = [select id,name from recordtype where sobjecttype= 'Account' and developername='Client'].id;
  public static Id InHouseLitQueueId = [select Id from Group where Type = 'Queue' and name = 'In-House Litigation' LIMIT 1].Id;
  public static Id ALLGQueueId = [select Id from Group where Type = 'Queue' and name = 'ALLG' LIMIT 1].Id;
  static testmethod void ALLUpdate() {
        Account acc = new Account();
        acc.nu_dse__Co_First_Name__c = 'TestFirstCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'TestFirst';
        acc.LastName = 'TestLast';
        acc.RecordTypeId = ClientRecordtypeid;
        insert acc;
        
        nu_dse__Fee_Template__c ALLGfeeTemp = new nu_dse__Fee_Template__c();
        ALLGfeeTemp.Name = 'ALLG Import';
        insert ALLGfeeTemp;

        nu_dse__Program__c ALLGprogram = new nu_dse__Program__c(); 
        ALLGprogram.nu_dse__Account__c = acc.Id;
        ALLGprogram.Array_Status__c = '37722';
        ALLGprogram.nu_dse__Total_Debt_Included__c = 0.00;
        ALLGprogram.External_Id__c = 'testid';
        ALLGprogram.nu_dse__Fee_Template__c = ALLGfeeTemp.Id;
        insert ALLGprogram; 
        
        nu_dse__TradeLine__c ALLGtradeLine = new nu_dse__TradeLine__c();
        ALLGtradeLine.nu_dse__Program__c = ALLGprogram.Id;
        ALLGtradeLine.nu_dse__Account__c = acc.Id;
        ALLGtradeLine.nu_dse__Original_Debt__c = 200;
        insert ALLGtradeLine;
      
        ALLGtradeLine.Litigation_Stage__c = 'Garnishment';
        update ALLGtradeLine;
      
        ALLGprogram = [SELECT Id, OwnerId FROM nu_dse__Program__c WHERE Id =:ALLGprogram.Id LIMIT 1];
        System.assertEquals(ALLGQueueId,ALLGprogram.OwnerId);
        
        ALLGtradeLine = [SELECT Id, Litigation_Stage__c, OwnerId FROM nu_dse__TradeLine__c WHERE Id =:ALLGtradeLine.Id LIMIT 1];
        System.assertEquals(ALLGQueueId,ALLGtradeLine.OwnerId);
      
  
  }
  static testmethod void  inhouseUpdate(){
        Account acc1 = new Account();
        acc1.nu_dse__Co_First_Name__c = 'TestFirstCo';
        acc1.nu_dse__Client_Status__c = 'New Client';
        acc1.FirstName = 'TestFirst';
        acc1.LastName = 'TestLast';
        acc1.RecordTypeId = ClientRecordtypeid;
        insert acc1;
  
        nu_dse__Fee_Template__c feeTemp1 = new nu_dse__Fee_Template__c();
        feeTemp1.Name = 'Import';
        insert feeTemp1;

        nu_dse__Program__c program1 = new nu_dse__Program__c(); 
        program1.nu_dse__Account__c = acc1.Id;
        program1.Array_Status__c = '37722';
        Program1.External_Id__c = 'testid1';
        Program1.nu_dse__Total_Debt_Included__c = 0.00;
        program1.nu_dse__Fee_Template__c = feeTemp1.Id;
        insert program1; 
        
        nu_dse__TradeLine__c tradeLine1 = new nu_dse__TradeLine__c();
        tradeLine1.nu_dse__Program__c = program1.Id;
        tradeLine1.nu_dse__Account__c = acc1.Id;
        tradeLine1.nu_dse__Original_Debt__c = 200;
        insert tradeLine1;
      
        tradeLine1.Litigation_Stage__c = '--none--';
        update tradeLine1;
       
        program1 = [SELECT Id, OwnerId FROM nu_dse__Program__c WHERE Id =:program1.Id LIMIT 1];
        System.assertEquals(InHouseLitQueueId,program1.OwnerId);     
        
        tradeLine1 = [SELECT Id, Litigation_Stage__c, OwnerId FROM nu_dse__TradeLine__c WHERE Id =:tradeLine1.Id LIMIT 1];
        System.assertEquals(InHouseLitQueueId,tradeLine1.OwnerId); 
   
   }
}