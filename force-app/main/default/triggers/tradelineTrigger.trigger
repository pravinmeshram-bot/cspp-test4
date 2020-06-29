trigger tradelineTrigger on nu_dse__TradeLine__c (before update, before insert, after update) {
	     
    if (Trigger.isBefore) {    	
        if (Trigger.isInsert || Trigger.isUpdate) {
        	// For S20-136 - Amit Goyal - Starts here        	
        	TradelineHandler.updateIncludedintheProgram(Trigger.new, Trigger.oldMap);
            // For S20-136 - Amit Goyal - Ends here            
            TradelineHandler.updateLitDefStage(Trigger.oldMap, Trigger.new, Trigger.isInsert, Trigger.isUpdate); 
            
            TradelineHandler.updateResponseDate(Trigger.oldMap, Trigger.new);
            //S20-340
            TradelineHandler.updateCreditorStandardization(Trigger.oldMap, Trigger.new);            
        }    
        
        //***S20-458*** Starts**
        if (Trigger.isUpdate) { 
        
            TradelineHandler.checkingLitigationStageForAssigningLitSupport(Trigger.oldMap, Trigger.new);        
        }       
        //***S20-458*** Ends**
                       
    } else if(Trigger.isAfter){
        
        if (Trigger.isUpdate) {
        
            //S20-25
            //TradelineHandler.changesRelatedToCases(Trigger.new);
        
            //S20-37
            TradelineHandler.changesRelatedToSummons(Trigger.oldMap, Trigger.new);
            
            //S20-373
            TradelineHandler.changesRelatedToSummonsGroupTask(Trigger.oldMap, Trigger.new);
             
        }          
    }
}