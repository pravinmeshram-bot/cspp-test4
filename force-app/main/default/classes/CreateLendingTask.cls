@RestResource(urlMapping='/CreateLendAppTask/*')
global class CreateLendingTask {
   @HttpPost
    
  global Static void CreateTasks(){
        String jsonString;
        list<nu_dse__Group_Task__c> lsttsk=new list<nu_dse__Group_Task__c>();
        RestRequest request = RestContext.request;
        RestResponse response=RestContext.response;  
        if(!Test.isRunningTest()){
           jsonString =  request.requestBody.toString();
        }else {
            nu_dse__Group_Task__c t=new nu_dse__Group_Task__c();   
            t.id = [Select Id from nu_dse__Group_Task__c limit 1].Id;
            t.nu_dse__Status__c = 'Completed';
            lsttsk.add(t);
            jsonString = JSON.serialize(lsttsk);
        }
       System.debug('jsonString:---->'+jsonString);
                
        list<nu_dse__Group_Task__c> TaskList =(list<nu_dse__Group_Task__c>) JSON.deserialize(jsonString, list<nu_dse__Group_Task__c>.class);
        
         List<nu_dse__Group_Task__c> insertTaskList = new List<nu_dse__Group_Task__c>();
        System.debug('TaskList = '+TaskList);
           Group negotiatorGroup=[select Id, Name from Group where Type = 'Queue' AND NAME = 'DNL Negotiation' Limit 1];  //DNL Negotiatiators   DNL Negotiation
            Id NegotiationsRecordTypeId = Schema.SObjectType.nu_dse__Group_Task__c.getRecordTypeInfosByName().get('Negotiations').getRecordTypeId(); 
            if(!TaskList.isEmpty()){
                set<id> prgId=new set<id>();
                String prgName;
                for(nu_dse__Group_Task__c gt:TaskList)
                    prgId.add(gt.Program_Import_ID__c);
                map<id,nu_dse__Program__c> mapPrgGT = new map<id,nu_dse__Program__c>([Select id,Name,Attorney__c from nu_dse__Program__c where id in:prgId]);
                System.debug('##mapPrgGT '+mapPrgGT);
                for(nu_dse__Group_Task__c eachTask : TaskList){
                    nu_dse__Group_Task__c newTask = new nu_dse__Group_Task__c();
                    newTask.nu_dse__Subject__c = eachTask.nu_dse__Subject__c;
                    newTask.nu_dse__Status__c = eachTask.nu_dse__Status__c;
                    newTask.Subject_Picklist__c='DNL Negotiations Review Request';
                    newTask.Priority__c = eachTask.Priority__c;
                    newTask.nu_dse__ActivityDate__c = eachTask.nu_dse__ActivityDate__c;
                    newTask.Program__c=eachTask.Program_Import_ID__c;
                    String Descrptn = eachTask.nu_dse__Description__c;
                    String PrgIdStr = eachTask.Program_Import_ID__c;
                    String ThreedigId = PrgIdStr.substring(0,3);
                    Integer index = Descrptn.indexOf(ThreedigId);
                    String oldstr = Descrptn.mid(index, 18);
                    
                    if(mapPrgGT.containsKey(newTask.Program__c))
                        prgName=mapPrgGT.get(newTask.Program__c).name;
                    String FinalStr = Descrptn.replace(oldstr,prgName);
                    System.debug('##FinalStr'+FinalStr);
                    newTask.nu_dse__Description__c = FinalStr;
                   //newTask.nu_dse__Description__c=eachTask.nu_dse__Description__c;
                    newTask.RecordTypeId = NegotiationsRecordTypeId; 
                    newTask.OwnerId = negotiatorGroup.Id;
                    insertTaskList.add(newTask);  
                  
                }
            }
        
        System.debug('insertTaskList = '+insertTaskList.size());
        if(!insertTaskList.isEmpty()){
            insert insertTaskList;  
        }
     
  }  
}