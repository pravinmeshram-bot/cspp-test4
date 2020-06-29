/**
* Name:          SOPTrigger
* Author:        Amit Goyal
* CreatedDate:   08/29/2019 - S20-197 - Amit Goyal
* Modified By:   
* Description:   To Create tasks for SOP Queues on SOP Update/Publish
*/

trigger SOPTrigger on SOP__kav (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if(!SOPTriggerHandler.hasAlreadyRanAfterInsert){
                SOPTriggerHandler.handleAfterInsert(Trigger.newMap);
            }
        }
        
        if(Trigger.isUpdate){
            if(!SOPTriggerHandler.hasAlreadyRanAfterUpdate){
                SOPTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    }
}