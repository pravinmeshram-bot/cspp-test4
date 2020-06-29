public class HealthTabExtension {

public String currentRecordId {get;set;}
public String parameterValue {get;set;}
public nu_dse__Program__c prog {get;set;}
 
    public HealthTabExtension() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('pid');
        if(currentRecordId != null && currentRecordId.trim().length()>0){
            list<nu_dse__Program__c> programs = [select id,Subscribed_to_ALLG__c,Portfolio__r.name , OwnerId, Owner.Name, Assigned_to_Legal__c, DNL_Status__c  from nu_dse__Program__c where id =: currentRecordId];
            prog = programs != null && programs.size()>0 ? programs[0] : new nu_dse__Program__c();
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Id not specified.'));
        }
    }
}