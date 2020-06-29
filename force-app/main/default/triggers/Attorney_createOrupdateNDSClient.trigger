trigger Attorney_createOrupdateNDSClient on Account (after Update) {
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_createOrupdateNDSClient'];
    if(TriggerFlag.isActive__c && Trigger.New[0].Attorney__c){
        if(Attorney_StaticVariableUtility.isClientTriggerExecuted == false)
        {
            Attorney_StaticVariableUtility.isClientTriggerExecuted = true;
            Attorney_createOrupdateNDSClientHandler.createOrupdateNDSClientMeth(Trigger.New,Trigger.Oldmap);    
        }
    }

//By Mayur for S20-578    
    if(trigger.isAfter){
        Attorney_createOrupdateNDSClientHandler.populateTestProgram();
        Attorney_createOrupdateNDSClientHandler.populateGCSIdOnProspect();
    }
}