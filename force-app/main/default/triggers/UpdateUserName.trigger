trigger UpdateUserName on User (after insert, after update) {
    // Updated by Amit Goyal on 10/22/2019 for S20-374 - Starts Here
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if(!UserTriggerHandler.hasAlreadyRanAfterInsert){
                UserTriggerHandler.handleAfterInsert(Trigger.NewMap);
            }
        }else{
            if(!UserTriggerHandler.hasAlreadyRanAfterUpdate){
                UserTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
            }
        }
        
    }
    // Updated by Amit Goyal on 10/22/2019 for S20-374 - Ends Here
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        
        Set<id> userSetId = new Set<id>();
        
        for(Id userId:Trigger.newMap.keySet()){
            
            if(Trigger.oldMap.get(userId).Email != Trigger.newMap.get(userId).Email && Trigger.oldMap.get(userId).ContactId != null){
                
                userSetId.add(Trigger.oldMap.get(userId).Id);
                
            }
            
        }
        if (userSetId.isEmpty() == False) {
            
            system.debug('------>userSetId'+userSetId);
            SFSPortal_PortalIdentityServiceHandler.updateUserName1(userSetId);
            
        }
        
    }
    
}