trigger caseTrigger on Case (after insert, after update) {

if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
caseTriggerHandler.populateProgramOnAccountPopulation(Trigger.new, Trigger.oldMap, Trigger.isInsert);
}
}