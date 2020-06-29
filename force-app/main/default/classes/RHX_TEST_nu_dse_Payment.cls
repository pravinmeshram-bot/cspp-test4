@isTest(SeeAllData=true)
public class RHX_TEST_nu_dse_Payment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM nu_dse__Payment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new nu_dse__Payment__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}