public class CalculatePaymentsCurrentAmount {

    public static Set<String> completedPaymentStatusesSet = new Set<String>{'Completed', 'Cleared'};
    
    public static Map<String, String> calculateTotalAmountMap = new Map<String, String> {
    
        'Admin Fee' => 'Total_Admin_Fee__c'
    };
    
    public static Map<String, String> calculateCurrentAmountMap = new Map<String, String> {
    
        'Deposit' => 'Current_Accumulation__c',
        'Fee Withdrawal' => 'Current_Program_Fee__c',
        'Maintenance Fee' => 'Current_Maintenance_Fee__c',
        'Affiliate Fee' => 'Current_Third_Party_Fee__c',
        'Retainer Fee' => 'Current_Retainer_Fee__c',
        'Service Fee' => 'Current_Service_Fee__c',
        'Admin Fee' => 'Current_Admin_Fee__c'
    };
    
    public static List<nu_dse__Program__c> calculateCurrentAmount(Set<Id> programIdSet) {
    
        Map<String, nu_dse__Program__c> programsToUpdateMap = new Map<String, nu_dse__Program__c>();
        
        if (programIdSet != null && programIdSet.isEmpty() == False) {
        
            //Calculate Expected Admin Fee
            for (AggregateResult aggregateResultInstance : [SELECT nu_dse__Program__c programId, SUM(nu_dse__Amount__c) amount
                                                                    FROM nu_dse__Payment__c WHERE nu_dse__Program__c IN :programIdSet 
                                                                    AND nu_dse__Payment_Type__c = 'Admin Fee'
                                                                    AND nu_dse__Program__c != null GROUP BY nu_dse__Program__c]) {
            
                Id programIdValue = String.valueOf(aggregateResultInstance.get('programId'));
                
                nu_dse__Program__c programRecToUpdate = new nu_dse__Program__c(Id = programIdValue);
                
                if (programsToUpdateMap.containsKey(programIdValue)) {
                
                    programRecToUpdate = programsToUpdateMap.get(programIdValue);
                }
                
                Double adminFee = Double.valueOf(aggregateResultInstance.get('amount'));
                programRecToUpdate.put('Expected_Admin_Fee__c', adminFee);
                
                programsToUpdateMap.put(programRecToUpdate.Id, programRecToUpdate);
            }
            
            //Calculate Current Payments
            for (AggregateResult aggregateResultInstance : [SELECT nu_dse__Program__c programId, nu_dse__Payment_Type__c paymentType, 
                                                                    SUM(nu_dse__Amount__c) amount, SUM(nu_dse__Processor_Fee__c) processorFee 
                                                                    FROM nu_dse__Payment__c WHERE nu_dse__Program__c IN :programIdSet
                                                                    AND nu_dse__Transaction_status__c IN :completedPaymentStatusesSet
                                                                    AND nu_dse__Program__c != null
                                                                    GROUP BY nu_dse__Program__c, nu_dse__Payment_Type__c]) {
            
                Id programIdValue = String.valueOf(aggregateResultInstance.get('programId'));
                
                nu_dse__Program__c programRecToUpdate = new nu_dse__Program__c(Id = programIdValue);
                
                if (programsToUpdateMap.containsKey(programIdValue)) {
                
                    programRecToUpdate = programsToUpdateMap.get(programIdValue);
                }
                
                popuateAmountInProgram(programRecToUpdate, aggregateResultInstance);
                
                if (aggregateResultInstance.get('paymentType') == 'Deposit' 
                       && aggregateResultInstance.get('processorFee') != null) {
                
                    Double processorFee = Double.valueOf(programRecToUpdate.get('Current_Processor_Fee__c'));
                    processorFee = (processorFee != null ? processorFee : 0) + Double.valueOf(aggregateResultInstance.get('processorFee'));
                    programRecToUpdate.put('Current_Processor_Fee__c', processorFee);
                }
                
                programsToUpdateMap.put(programRecToUpdate.Id, programRecToUpdate);
            }
        }
        return programsToUpdateMap.values();
    }
    
    public static void popuateAmountInProgram(nu_dse__Program__c programRecToUpdate, AggregateResult aggregateResultInstance) {
    
        if (aggregateResultInstance != null && aggregateResultInstance.get('paymentType') != null) {
        
            if (calculateCurrentAmountMap.containsKey(String.valueOf(aggregateResultInstance.get('paymentType')))) {
            
                programRecToUpdate.put(calculateCurrentAmountMap.get(String.valueOf(aggregateResultInstance.get('paymentType'))), Double.valueOf(aggregateResultInstance.get('amount')));
            }
        }
    }
}