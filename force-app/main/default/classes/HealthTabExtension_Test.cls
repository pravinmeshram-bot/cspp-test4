@isTest
public class HealthTabExtension_Test {
    
    @isTest
    public static void healthTabExtension() {
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c();
        insert programInstance;
        
        Test.startTest();
        
        ApexPages.CurrentPage().getparameters().put('pid', programInstance.Id);
        HealthTabExtension inst = new HealthTabExtension();
        inst.parameterValue = 'testValue';
        
        Test.stopTest();
        
    }
}