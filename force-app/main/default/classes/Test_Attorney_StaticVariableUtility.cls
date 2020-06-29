@isTest
public class Test_Attorney_StaticVariableUtility {
    @isTest static void schedulerTest () {
        Attorney_StaticVariableUtility obj = new Attorney_StaticVariableUtility ();
        Attorney_StaticVariableUtility.dateToUTC (Date.Today ());
    }
    
    private static testMethod void test_reProcessRecordCheck(){
        Set<String>stringSet = New Set<String>();
        stringSet.Add('TEst1');
        string IntegrationReason = 'TEst1';
        Attorney_StaticVariableUtility.reProcessRecordCheck(stringSet,IntegrationReason);
        Attorney_StaticVariableUtility.convertToDecimal('3.0');
    }
    
     private static testMethod void test_reProcessConfigs(){
        Set<String>stringSet = New Set<String>();
      
        Attorney_StaticVariableUtility.reProcessConfigs('Program',true);
        
    }
    
    static TestMethod void convertToDecimal(){
        Attorney_StaticVariableUtility.convertToDecimal('');
        Attorney_StaticVariableUtility.convertToDecimal('10');
    }
    
    static TestMethod void getAsyncMethodData(){
        Attorney_StaticVariableUtility.getAsyncMethodData('xx');
    }
    
    static TestMethod void dateToUTC(){
        Date myDate = Date.newInstance(2020, 1, 3);
        Attorney_StaticVariableUtility.dateToUTC(mydate);
    }
}