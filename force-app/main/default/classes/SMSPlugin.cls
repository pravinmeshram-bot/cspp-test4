global class SMSPlugin implements Process.Plugin {

global Process.PluginDescribeResult describe() {

    Process.PluginDescribeResult result = new Process.PluginDescribeResult();
    result.tag='Identity';
    result.name='SMS Plugin';
    result.description='Two factor authentication with SMS';
    
    result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
        new Process.PluginDescribeResult.InputParameter('AccountSid', Process.PluginDescribeResult.ParameterType.STRING, true),
        new Process.PluginDescribeResult.InputParameter('Token', Process.PluginDescribeResult.ParameterType.STRING, true),
        new Process.PluginDescribeResult.InputParameter('To', Process.PluginDescribeResult.ParameterType.STRING, true),
        new Process.PluginDescribeResult.InputParameter('From', Process.PluginDescribeResult.ParameterType.STRING, true),
        new Process.PluginDescribeResult.InputParameter('Message', Process.PluginDescribeResult.ParameterType.STRING, true)
    };
    
    result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
        new Process.PluginDescribeResult.OutputParameter('Status', Process.PluginDescribeResult.ParameterType.STRING),
        new Process.PluginDescribeResult.OutputParameter('VerificationCode', Process.PluginDescribeResult.ParameterType.STRING)
    };
    
    return result;

}


global Process.PluginResult invoke(Process.PluginRequest request) {   

    Map<String, Object> result = new Map<String, Object>();  
    String AccountSid = (String)request.inputParameters.get('AccountSid');
    String token = (String)request.inputParameters.get('Token');
    String To = (String)request.inputParameters.get('To');
    String From_a = (String)request.inputParameters.get('From');
    String Message = (String)request.inputParameters.get('Message');
    if (Message == null) Message = 'Your verification code is: ';
    
    TwilioRestClient client = new TwilioRestClient(AccountSid, Token);
    TwilioSMS sms;
    
    Integer rand = Math.round(Math.random()*100000);
    String VerificationCode = string.valueOf(rand);
    String Body = Message + VerificationCode;
    
    Map<String,String> params = new Map<String,String> {
        'To'   => To,
        'From' => From_a,
        'Body' => Body
    }; 
 
    try {
        sms = client.getAccount().getSMSMessages().create(params);
        result.put('Status', sms.getStatus());
        system.debug('-----Status'+sms.getStatus());
    } catch(Exception ex) {
        result.put('Status', 'Failure');
    }
        result.put('VerificationCode', VerificationCode);
       return new Process.PluginResult(result);
  }
}