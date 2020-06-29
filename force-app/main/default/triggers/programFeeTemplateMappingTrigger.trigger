trigger programFeeTemplateMappingTrigger on nu_dse__Program__c (before insert, before update) {
    
     if (Trigger.isBefore) {
         
         if (Trigger.isInsert) {
             
             //S20-209 To populate Enrollment date in Program...
             PolicyGroupAssignmentHandler.populatingEnrollmentDateAndStrategyCallDate(Trigger.oldMap, Trigger.new);
         }
         
         if (Trigger.isUpdate) {
             
             //S20-209 To populate Enrollment date in Program...
             PolicyGroupAssignmentHandler.populatingEnrollmentDateAndStrategyCallDate(Trigger.oldMap, Trigger.new);
             
             //ProgramFeeTemplateMappingTriggerHandler.ProgramFeeTemplateMapping(trigger.oldMap, trigger.new);
            
           //  PolicyGroupAssignmentHandler.invokeFeeTemplateAssignment();
             
             //S20-154 ~ To populate GCS Policy Group, Program Type and Fee Template when Total Debt Included changes in the Program.
             // PolicyGroupAssignmentHandler.programPolicyGroupMapping(trigger.oldMap, trigger.new);
         }
     }
}