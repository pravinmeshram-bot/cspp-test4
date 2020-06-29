/**
* Name:          EmailMessageTriggerHandler
* Author:        Amit Goyal
* CreatedDate:   10/24/2019 - S20-270 - Amit Goyal
* Modified By:   
* Description:   To Create child cases if the related case is closed and email received after closer
*/
public class EmailMessageTriggerHandler {
	// variables to handler recurssion
    public static boolean hasAlreadyRanAfterInsert = false;
    
    public static void handleAfterInsert(map<Id, EmailMessage> newEmailMessages){
        // Method to execute from Trigger on after insertion of sop
        if(!hasAlreadyRanAfterInsert){
            hasAlreadyRanAfterInsert=true;
        }
    	
        // To collect all case Ids
        set<Id> caseIds = new set<Id>();
        String casePrefix=Case.sObjectType.getDescribe().getKeyPrefix();
        if(newEmailMessages != null && newEmailMessages.size()>0){
            for(EmailMessage em: newEmailMessages.values()){
                if(em.ParentId!=null){
                    if(String.valueOf(em.ParentId).startsWith(casePrefix)){
                        caseIds.add(em.ParentId);
                    }
                }
            }
            
            if(caseIds != null && caseIds.size()>0){
                list<Case> newChildCases = new list<Case>();
                // get the cases which has been closed to create child cases with the new emails after closing the case
                map<Id, Case> casesMap = new map<Id, Case>([Select Id, Subject, Status From Case Where Id IN: caseIds AND Status='Closed']);
                if(casesMap != null && casesMap.size()>0){
                    for(EmailMessage em: newEmailMessages.values()){
                        if(em.ParentId!=null){
                            if(String.valueOf(em.ParentId).startsWith(casePrefix)){
                                if(casesMap.containsKey(em.ParentId)){
                                    Case closedCase=casesMap.get(em.ParentId);
                                    Case childCase=closedCase.clone();
                                    childCase.Status='New';
                                    childCase.Origin='Email';
                                    childCase.ParentId=closedCase.Id;
                                    newChildCases.add(childCase);
                                }
                            }
                        }
                    }
                    
                    if(newChildCases != null && newChildCases.size()>0){
                        insert newChildCases;
                    }
                }
            }
        }
    }
}