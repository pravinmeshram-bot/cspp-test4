@isTest
public class Test_BatchDataController {

    @isTest
    public Static void testMethod1(){
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Batch_Data__c>());
			BatchDataController bdc = new BatchDataController(sc);
        bdc.saveData();
    }
    
}