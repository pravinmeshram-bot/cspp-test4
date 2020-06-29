trigger IVRConfigurationTrigger on IVR_Configuration__c (before insert,before update) {
    IVRConfigurationTriggerHandler.validate(Trigger.New);
}