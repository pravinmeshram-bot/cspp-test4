@isTest
private class SFSPortal_SMSPluginTest {
    
    static testmethod void flowTaskTest(){
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        SMSPlugin plugin = new SMSPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        
        inputParams.put('AccountSid', 'AC296e36ad438d161707dc46a81125b3f9');
        inputParams.put('Token', 'f3746124968320cc7d744063531ce102');
        inputParams.put('To', '76546789876');
        inputParams.put('From','6179342857');
        inputParams.put('Message','Test code');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
        
        System.debug('**** result-->' + result);
        System.assert(result != null);
    }

}