public class CaseResponseCtrl {
    
    public String recId {get;set;}
    public String responseCode {get;set;}
    public boolean showFeedbackPanel{get; set;}
    public boolean showAlreadyAcceptedPanel{get; set;}
    public boolean showAlreadyRejectedPanel{get; set;}
    public boolean showAlreadyPartiallyAcceptedPanel{get; set;}
    
    public CaseResponseCtrl() {
        
        showFeedbackPanel = False;
        showAlreadyAcceptedPanel = False;
        showAlreadyRejectedPanel = False;
        showAlreadyPartiallyAcceptedPanel = False;
        recId = ApexPages.currentPage().getParameters().get('recId');
        responseCode = ApexPages.currentPage().getParameters().get('caseResp');
    }
    
    public void storeResponse() {
        
        if (recId != null && responseCode != null) {
           
            List<Summon__C> summonList = [SELECT Id, Accepted__c, Partially_Accepted__c, Rejected__c,Email2_Accepted__c,Email2_Rejected__c FROM Summon__C WHERE Id = :recId LIMIT 1];
            
            if (summonList.size() > 0) {
                
                Summon__c summonInstance = summonList[0];
                
                if (summonInstance.Accepted__c == True || summonInstance.Email2_Accepted__c == True) {
                    
                    showAlreadyAcceptedPanel = True;
                    showAlreadyRejectedPanel = False;
                    showAlreadyPartiallyAcceptedPanel = False;
                    showFeedbackPanel = False;
                    
                } else if (summonInstance.Rejected__c == True || summonInstance.Email2_Rejected__c == True) {
                    
                    showAlreadyAcceptedPanel = False;
                    showAlreadyRejectedPanel = True;
                    showAlreadyPartiallyAcceptedPanel = False;
                    showFeedbackPanel = False;
                
                } else if (summonInstance.Partially_Accepted__c == True && responseCode != 'Email2Accepted' && responsecode !='Email2Rejected') {
                    
                    showAlreadyAcceptedPanel = False;
                    showAlreadyRejectedPanel = False;
                    showAlreadyPartiallyAcceptedPanel = True;
                    showFeedbackPanel = False;
                    
                } else {
                    
                    if (responseCode == 'Accepted') {
                        
                        summonInstance.Accepted__c = True;
                        update summonInstance;
                        
                    } else if (responseCode == 'Rejected') {
                        
                        summonList[0].Rejected__c = True;
                        update summonInstance;
                        
                    } else if (responseCode == 'PrtlyAccepted') {
                        
                        summonList[0].Partially_Accepted__c = True;
                        update summonInstance;
                    }else if(responseCode == 'Email2Accepted'){
                        
                        summonList[0].Email2_Accepted__c = true;
                         update summonInstance;
                    }else if(responseCode=='Email2Rejected'){
                        
                        summonList[0].Email2_Rejected__c = true;
                         update summonInstance;
                    }
                    showAlreadyAcceptedPanel = False;
                    showAlreadyRejectedPanel = False;
                    showAlreadyPartiallyAcceptedPanel = False;
                    showFeedbackPanel = True;
                }
            }
        }
    }
}