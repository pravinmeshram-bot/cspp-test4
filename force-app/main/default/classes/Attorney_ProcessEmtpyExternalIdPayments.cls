public class Attorney_ProcessEmtpyExternalIdPayments implements Database.Batchable<Sobject>{

    public List<nu_dse__Payment__c> start(Database.BatchableContext BC){
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        id feeRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        List<nu_dse__Payment__c> Payments = [Select id, nu_dse__payment_sequence_number__c ,nu_dse__Transaction_Status__c, nu_dse__Schedule_Date__c, nu_dse__Fee_Item_Category__c, nu_dse__Program__c from nu_dse__Payment__c where nu_dse__program__r.nu_dse__program_status__c = 'Active Client' and nu_dse__External_CFT_Id__c = null and nu_dse__External_GCS_ID__c = null and nu_dse__External_RAMS_Id__c = null and (RecordTypeId =: DraftRecordType or RecordTypeId =: feeRecordType) AND (nu_dse__Transaction_Status__c = 'Completed' OR nu_dse__Transaction_Status__c = 'Cleared') AND nu_dse__Schedule_Date__c >: Date.today()];
        return Payments;
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> Payments){
        List<Id> ProgramIds = new List<Id>();
        Date scheduledDate = Date.today();
        for(nu_dse__Payment__c payment: Payments){
            payment.nu_dse__Transaction_Status__c = 'Pending';
        }
        
        Update Payments;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}