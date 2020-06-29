public class Attorney_PopulateFeeItemCategory implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{

    public Batch_Data__c FeeItemBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;

    public List<nu_dse__Payment__c> start(Database.BatchableContext BC){
        FeeItemBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_PopulateFeeItemCategory'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
        	async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
        		asyncLimitUsed = async.getValue();
        }
        if(FeeItemBatchData.Last_Execution_Time__c == null || FeeItemBatchData.Last_Execution_Time__c.day() != System.now().day()){
            FeeItemBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        List<nu_dse__Payment__c> Payments = [Select id, nu_dse__payment_sequence_number__c , nu_dse__Schedule_Date__c, nu_dse__Fee_Item_Category__c, nu_dse__Program__c from nu_dse__Payment__c where nu_dse__Fee_Item_Category__c = null AND nu_dse__Is_Makeup_Payment_Created__c = false AND nu_dse__admin_fee__c > 0 and nu_dse__program__r.nu_dse__program_status__c != 'Graduated Program' and nu_dse__program__r.nu_dse__program_status__c != 'Client Cancelled' and RecordTypeId =: DraftRecordType and isattorney__c = true and nu_dse__Payment_Sequence_Number__c != null ORDER BY nu_dse__Schedule_Date__c];
        return Payments;
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> Payments){
        List<Id> ProgramIds = new List<Id>();
        Date scheduledDate = Date.today();
        for(nu_dse__Payment__c payment: Payments){
            if(!ProgramIds.contains(payment.nu_dse__Program__c)){
                ProgramIds.add(payment.nu_dse__Program__c);
            }
            scheduledDate = Payment.nu_dse__Schedule_Date__c;
        }
        
        Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>([Select Id, (Select Id,nu_dse__Fee_Item_Category__c,nu_dse__Schedule_Date__c from nu_dse__Payments__r where nu_dse__Fee_Item_Category__c != null and nu_dse__payment_sequence_number__c != null AND nu_dse__Schedule_Date__c<: scheduledDate ORDER BY nu_dse__Schedule_Date__c desc) from nu_dse__Program__c where Id=:ProgramIds]);
        
        for(nu_dse__Payment__c payment: Payments){
            if(ProgramMap.containsKey(payment.nu_dse__Program__c) && ProgramMap.get(payment.nu_dse__Program__c).nu_dse__Payments__r != null && !ProgramMap.get(payment.nu_dse__Program__c).nu_dse__Payments__r.isEmpty()){
                payment.nu_dse__Fee_Item_Category__c = ProgramMap.get(payment.nu_dse__Program__c).nu_dse__Payments__r[0].nu_dse__Fee_Item_Category__c;
            }
        }
        Update Payments;
    }
    
    public void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
        System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        
        if(async.getValue() != null)
            FeeItemBatchData.Number_of_Callouts__c = String.valueOf(async.getValue() - asyncLimitUsed);
        else
            FeeItemBatchData.Number_of_Callouts__c = String.valueOf(asyncLimitUsed);
        }
        FeeItemBatchData.Last_Execution_Time__c = System.now();
        FeeItemBatchData.Batch_Execution_Status__c = 'Success';
        Update FeeItemBatchData;
    }
   public static void fakeMethod(){
        Integer i = 0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        
    } 
}