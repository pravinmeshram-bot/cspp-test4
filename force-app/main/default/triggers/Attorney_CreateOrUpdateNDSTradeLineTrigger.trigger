trigger Attorney_CreateOrUpdateNDSTradeLineTrigger on nu_dse__TradeLine__c (after Insert,after update,before Insert, before Update) {
    
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSTradeLineTrigg'];
    if(Trigger.isAfter){
    
        if(TriggerFlag.isActive__c){
            if(Attorney_StaticVariableUtility.isTradeLineTriggerExecuted == false)
            {
            
            if(Trigger.New[0].Isattorney__c)
            {
                Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true; 
                Attorney_CreateOrUpdateNDSTradeHandler.CreateOrUpdateNDSTradeLine(Trigger.new, trigger.OldMap, trigger.NewMap); 
                
            }
            }
        }
        //DV-156
       /* if(!Prizm_TradelineHandler.isTradelineUpdated){
            SYstem.debug('*****Tradeline trigger');
            Prizm_TradelineHandler.Prizm_UpdateLeadFields(Trigger.new, trigger.OldMap, Trigger.isInsert);
        }  */
        //changes for NMI - 532 by Rajesh
        if(Trigger.isUpdate){
            Attorney_CreateOrUpdateNDSTradeHandler.UpdateProgramFuturePayments();
        }
    }
    //public static boolean CreditorUpdated =false;
    if(Trigger.isBefore && TriggerFlag.isActive__c){
        
        //if(!CreditorUpdated){
        Attorney_CreateOrUpdateNDSTradeHandler.UpdateCreditorData(Trigger.new, trigger.NewMap, trigger.OldMap); 
        //CreditorUpdated = true;
        //}
    }
    
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
    
        TradelineStatusUpdateHandler.updateTradelineStatus(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isBefore){
        Prizm_TradelineHandler.updateDNLPercent();
    }
    
     if(Trigger.isAFter){
        Attorney_CreateOrUpdateNDSTradeHandler.populateGCSIdOnProspect();
    }
    
    }