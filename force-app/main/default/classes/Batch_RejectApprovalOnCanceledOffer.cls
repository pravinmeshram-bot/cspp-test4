//S20-178 ****Starts**** ~ One time batch to reject the pending approvals on already existing canceled offers.
global with sharing class Batch_RejectApprovalOnCanceledOffer implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
       String query = 'SELECT Id FROM nu_dse__Offer__c WHERE nu_dse__Status__c = \'Canceled\'';
       
       system.debug('query--->'+query);
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Offer__c> offerList) {

        Set<Id> processInstanceWorkItems = new Set<Id>();
        Set<Id> offerIds = new Set<Id>();
        
        for (nu_dse__Offer__c offer : offerList) {
            offerIds.add(offer.Id);
        }
       
        for (ProcessInstanceWorkitem instanceWork : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                        FROM ProcessInstanceWorkitem  
                                                        WHERE ProcessInstance.TargetObjectId IN :offerIds
                                                        Order By CreatedDate]) {

            if (offerIds.contains(instanceWork.ProcessInstance.TargetObjectId)) {

                processInstanceWorkItems.add(instanceWork.Id);
                
                offerIds.remove(instanceWork.ProcessInstance.TargetObjectId);
            }
        }
        System.debug('processInstanceWorkItems----->'+processInstanceWorkItems);
        System.debug('offerIds----->'+offerIds);
        
        if (processInstanceWorkItems.isEmpty() == False) {
        
            List<Approval.ProcessWorkitemRequest> workItemRequests = new List<Approval.ProcessWorkitemRequest>();

            for (Id workItems : processInstanceWorkItems) {

                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Reject');
                req.setWorkitemId(workItems);
                workItemRequests.add(req);
            }
            System.debug('workItemRequests--->'+workItemRequests);

            Approval.ProcessResult[] result2 =  Approval.process(workItemRequests);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
            
    }   
}
//S20-178 ****Ends****