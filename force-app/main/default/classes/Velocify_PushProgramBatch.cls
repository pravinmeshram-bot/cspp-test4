public class Velocify_PushProgramBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{

    public List<nu_dse__Program__c> start(Database.BatchableContext BC){
        return [Select Id, nu_dse__Program_Status__c, Velocify_Lead_Status__c, Velocify_Last_Integrated__c , Velocify_Integration_Status__c, External_Id__c from nu_dse__Program__c where Velocify_Integration_Status__c = 'Initiated' OR Velocify_Integration_Status__c = 'Failed'];
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Program__c> ProgramList){
        
        Map<Integer,Integer> LeadStatusMap = new map<Integer,Integer>();
        
        for(nu_dse__Program__c Program: ProgramList){
            LeadStatusMap.put(Integer.ValueOf(Program.External_Id__c),Integer.ValueOf(Program.Velocify_Lead_Status__c));
            Program.Velocify_Integration_Status__c = 'Success';
            Program.Velocify_Last_Integrated__c = system.now();
        }
        
        if(LeadStatusMap.size()>0){
            LeadStatusUpdateInVelocify(LeadStatusMap);
        }
        Update ProgramList;
    }
    
    public static void LeadStatusUpdateInVelocify(Map<Integer,Integer> LeadStatusMap){
        VelocifyCredentials__c credentials =  VelocifyCredentials__c.getValues('VelocifyCredentials');
        serviceLeads360Com.ClientServiceSoap  soap = new serviceLeads360Com.ClientServiceSoap();
        for(Integer LeadId : LeadStatusMap.keySet()){
        if(!test.isRunningTest())
         //  soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,LeadId,LeadStatusMap.get(LeadId));
           
          soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,876536,LeadStatusMap.get(LeadId));
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }

}