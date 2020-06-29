trigger SFSPortal_portalIdentityServiceTrigger on Portal_Identity_Service__c (after update) {
    
    if (Trigger.isAfter && Trigger.isUpdate) {
    
        SFSPortal_PortalIdentityServiceHandler.updateUser(Trigger.new, Trigger.oldMap);
    }  

}