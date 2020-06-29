global class Batch_DNLSettlement_Sync implements database.Batchable<sObject>{
    string query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query='Select id,name,ConnectionReceivedId,Average_of_Adjusted_Settlement__c,Current_Creditor__c,Original_Creditor__c,Start_Date__c,End_Date__c,Type__c from DNL_Settlement_Rate__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DNL_Settlement_Rate__c> DNLSettlementList) {
      Id networkId = ConnectionHelper_DNL_Settlment.getConnectionId('Peerform'); 
    system.debug('networkId'+networkId);
    Set<Id> DnlrtSet = new Set<Id>(); 
    for (DNL_Settlement_Rate__c Dsr : DNLSettlementList) {
       if (Dsr.ConnectionReceivedId == null )  
           DnlrtSet.add(Dsr.id); 
        }
    if (DnlrtSet.size() > 0) { 
       List<PartnerNetworkRecordConnection> DNLConnections =  new  List<PartnerNetworkRecordConnection>();   
       for (DNL_Settlement_Rate__c dnlRec : DNLSettlementList) {   
         if (DnlrtSet.contains(dnlRec.id)) {                    
           PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection(ConnectionId = networkId, 
                                                        LocalRecordId = dnlRec.Id,SendClosedTasks = false,SendOpenTasks = false,
                                                        SendEmails = false);
           DNLConnections.add(newConnection);                 
        }
      }
    if (DNLConnections.size() > 0 ) { 
        database.insert(DNLConnections); 
       }
   }  
  }
    
    global void finish(Database.BatchableContext BC) {
         
    }
}