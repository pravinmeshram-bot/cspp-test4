public class ConnectionHelper_DNL_Settlment {
    
  public static Id getConnectionId(String connectionName) {   
   List<PartnerNetworkConnection> ConnectionList = [Select id from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName = :connectionName];
   if ( ConnectionList.size() != 0 ) {
           return ConnectionList.get(0).Id;
    }
    return null;
  }
 public static Id getConnectionOwnerId(String connectionName) {
   List<PartnerNetworkConnection> ConnectionList = [Select createdById from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName = :connectionName];
   if ( ConnectionList.size() != 0 ) {
       return ConnectionList.get(0).createdById;
    }
    return null;
  }
}