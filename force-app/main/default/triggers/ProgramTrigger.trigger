trigger ProgramTrigger on nu_dse__Program__c (before Insert,before update, after update, after insert) {


    // Added By Amit Goyal for S20-459 on 11/14/2019 - Starts here
    if(Trigger.isAfter && Trigger.isUpdate){
        if(!ProgramTriggerHandler.hasAlreadyRanAfterUpdate){
            ProgramTriggerHandler.handleAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        }
        ProgramTriggerHandler.updateTradeLineNegotiatorAndChargeOfDate(Trigger.New, Trigger.OldMap); // Praveen ND-305 and ND-306
        ProgramTriggerHandler.retentionEmailSplitPerPortfolio(Trigger.New, Trigger.OldMap); // Praveen ND-307
        ProgramTriggerHandler.portfolioBasedReferToBK(Trigger.New, Trigger.OldMap); // Praveen ND-332
        ProgramTriggerHandler.createGroupTaskOnDNLStatusChange(Trigger.New, Trigger.OldMap); // Added by Mayur for ND-334
        ProgramTriggerHandler.setLendingApplicationDRPGraduated(Trigger.New, Trigger.OldMap); // Milan DV-591
    }
    // Added By Amit Goyal for S20-459 on 11/14/2019 - Ends here
  
  //By Mayur for S20-578  
   
    if(trigger.isAfter){
        Attorney_CreateOrUpdateNDSProgramHandler.populateTestClient();
    }
    
    if(trigger.isUpdate && (Trigger.New[0].RecordType.Name != 'Data-Temp' || Trigger.Old[0].RecordType.Name != 'Data-Temp') 
       && Trigger.New[0].Attorney__c == FALSE && Trigger.old[0].Attorney__c == False) {
           
           if(Trigger.New[0].Timberline__c || Trigger.Old[0].Timberline__c){
               
               /*This line was creating issue because Selas commented the method in handler class but not in trigger
                This functionality is moved into Velocify_ProgramHandler developed by Mayur. JiraTicket: NMI-187 
                
                ProgramHandler.handle(trigger.oldMap, trigger.newMap); 
                */
               
               if (Trigger.isAfter && Trigger.isUpdate) {
                   //ProgramHandler.pushClientDetailsToVersara(Trigger.oldMap, Trigger.newMap);
                   ProgramHandler.createOrUpdateClientInLeadTrac(Trigger.oldMap, Trigger.new);
               }
           }
           
           if (Trigger.isBefore && Trigger.isUpdate) {
               ProgramHandler.updateFeeTemplate(Trigger.oldMap, Trigger.new);
           }
    }
    
    //Merge Program Trigger by Rajesh
    if(Attorney_StaticVariableUtility.isProgramTriggerExecuted == false) {
        
        if(Trigger.New[0].Attorney__c == TRUE) {
            
            AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'ProgramTrigger'];
            AttorneyTriggerActivate__mdt DuplicatePayment =[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'DuplicatePayment'];
                        
            if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter) {
                Attorney_CreateOrUpdateNDSProgramHandler.PrimaryWorkfow(Trigger.New, trigger.OldMap);                
            }
            
            Boolean apiuser = Attorney_StaticVariableUtility.apiuser;
            
            if(TriggerFlag.isActive__c){
                if(trigger.IsUpdate && trigger.isAfter){
                    if(!apiuser){
                        Attorney_CreateOrUpdateNDSProgramHandler.CreateOrUpdateNDSProgram(Trigger.new, trigger.OldMap);
                    }
                }
                
            }
            
            if(Trigger.isAfter && Trigger.isUpdate && DuplicatePayment.isActive__c && apiuser){
                Attorney_CreateOrUpdateNDSProgramHandler.onChangeDraftPlanId(Trigger.new, Trigger.oldMap);
            }
            //      if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter)
            //          if(Attroney_checkRecursive.runOnce())
            //             Attorney_CreateOrUpdateNDSProgramHandler.createFeeTemplate(Trigger.New);
        }
    }
    if(!Velocify_ProgramHandler.VelocifyExecuted){    
        
        VelocifyTriggerActive__mdt VelocifyTrigger = [Select Id,isActive__c from VelocifyTriggerActive__mdt where DeveloperName ='ProgramTriggerActive'];
        system.debug('VelocifyTrigger --->'+VelocifyTrigger);
        
        If(VelocifyTrigger.IsActive__c)  {
            //                User currentUser = [Select id, Velocify_Admin__c from User where Id =: UserInfo.getUserId()];  
            
            if(Trigger.isUpdate && Trigger.isAfter && !Attorney_staticVariableUtility.VelocifyAdmin) {
                system.debug('########');
                Velocify_ProgramHandler.UpdateLeadStatus(Trigger.new, trigger.OldMap,trigger.newMap);
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.New[0].Attorney__c == TRUE){
        
        Attorney_CreateOrUpdateNDSProgramHandler.PopulateProcessorAndPortfolio();
        // Attorney_CreateOrUpdateNDSProgramHandler.UpdateFeeTemplateBatch();  //@ Before change for 684
        Attorney_CreateOrUpdateNDSProgramHandler.UpdateFeeTemplateBatch(trigger.isUpdate); // Commented for NMI-1183 //Uncommeted on July 12
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        Attorney_CreateOrUpdateNDSProgramHandler.CancelPayments(Trigger.new, Trigger.oldMap);
        Prizm_ProgramHandler.createGroupTask();
        ProgramHandler_Selas.updateOfferRenegotiable(Trigger.oldMap, Trigger.new);
    }
   
    if(Trigger.isAfter && !PolicyGroupAssignmentHandler.QueueableMethodCalled) { 
      PolicyGroupAssignmentHandler.filterProgList(Trigger.oldMap, Trigger.newMap , Trigger.new , Trigger.IsInsert);
       // Prizm_ProgramHandler.TotalFeesUpdate();
     //  System.enqueueJob(new PolicyGroupAssignmentHandler.QueueableMethod(Trigger.oldMap, Trigger.newMap , Trigger.new , Trigger.IsInsert));
              PolicyGroupAssignmentHandler.QueueableMethodCalled = true;
    }   
    
    // added by Praveen - Decommissioned - Process Bbuilder : Populate Portfolio on Client Accounts
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
    Attorney_CreateOrUpdateNDSProgramHandler.populatePortfolioOnAccount(Trigger.New , Trigger.OldMap);
    }    
}