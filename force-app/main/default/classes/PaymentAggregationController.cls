public class PaymentAggregationController {
    
    public Id programId{get; set{
        if (programId == null) {
        
            programId = value;
            PaymentAggregation();
        }
    }}
    public List<nu_dse__Program__c> program{get; set;}
    public Map<String,List<String>> paymentAggregationMap{get; set;}    
    public List<String> paymentHeadingList{get; set;}
    public List<String> paymentTypeList{get; set;}
        
    public PaymentAggregationController() {
        
        program = new List<nu_dse__Program__c>();       
                                                            
        paymentHeadingList = new List<String>{'Payment Type','Total', 'Paid', 'Remaining'};
        paymentTypeList = new List<String>{'Accumulation', 'Program Fee', 'Maintenance Fee', 'Third Party Fee', 'Retainer Fee', 
                                         'Service Fee', 'Admin Fee', 'Processor Fee'};
                                         
        paymentAggregationMap = new Map<String,List<String>>{'Accumulation' => new List<String>{'Expected_Accumulation__c','Current_Accumulation__c','Remaining_Accumulation__c'},
                                                         'Program Fee' => new List<String>{'Expected_Program_Fee__c', 'Current_Program_Fee__c', 'Remaining_Program_Fee__c'},
                                                         'Maintenance Fee' => new List<String>{'Expected_Mainteance_Fee__c', 'Current_Maintenance_Fee__c', 'Remaining_Maintenance_Fee__c'},
                                                         'Third Party Fee' => new List<String>{'Expected_Third_Party_Fee__c', 'Current_Third_Party_Fee__c', 'Remaining_Third_Party_Fee__c'},
                                                         'Retainer Fee' => new List<String>{'Expected_Retainer_Fee__c', 'Current_Retainer_Fee__c', 'Remaining_Retainer_Fee__c'},
                                                         'Service Fee' => new List<String>{'Expected_Service_Fee__c', 'Current_Service_Fee__c', 'Remaining_Service_Fee__c'},
                                                         'Admin Fee' => new List<String>{'Expected_Admin_Fee__c', 'Current_Processor_Fee__c', 'Remaining_Admin_Fee__c'},
                                                         'Processor Fee' => new List<String>{'Expected_Processor_Fee__c', 'Current_Admin_Fee__c', 'Remaining_Processor_Fee__c'}};
        
    }

    public void PaymentAggregation() {
        
        program = [SELECT Id, Expected_Accumulation__c, Expected_Admin_Fee__c, 
                   Expected_Mainteance_Fee__c, Expected_Processor_Fee__c, Expected_Program_Fee__c, Expected_Retainer_Fee__c,
                   Expected_Service_Fee__c, Expected_Third_Party_Fee__c, Current_Accumulation__c, Current_Admin_Fee__c,
                   Current_Maintenance_Fee__c, Current_Processor_Fee__c, Current_Program_Fee__c, Current_Third_Party_Fee__c,
                   Current_Retainer_Fee__c, Current_Service_Fee__c, Remaining_Accumulation__c,
                   Remaining_Admin_Fee__c, Remaining_Maintenance_Fee__c,
                   Remaining_Processor_Fee__c, Remaining_Program_Fee__c, Remaining_Retainer_Fee__c,
                   Remaining_Service_Fee__c, Remaining_Third_Party_Fee__c FROM nu_dse__Program__c 
                   WHERE Id =:programId LIMIT 1];
    }
}