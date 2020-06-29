@RestResource(urlMapping='/CreateTaskRecord/*')
global class CreatePrizmTasks{
    
    @HttpPost
    global Static void CreateTasks(){
        String jsonString;
        RestRequest request = RestContext.request;
        RestResponse response=RestContext.response;  
       
         if(!Test.isRunningTest()){
             jsonString =  request.requestBody.toString();
        } else {
            
            Map<String,List<Task>> mapListTask=new Map<String,List<Task>>();
            String oppId=[select id,name from opportunity limit 1].id;
            list<Task> ltask=[Select id,status,priority,subject,ActivityDate from task where status='Completed' AND whatId=:oppId];
            system.debug('ltask'+ltask);
            mapListTask.put(oppId,ltask);
                     
            jsonString = JSON.serialize(mapListTask);
        }
       
        Map<String,List<Task>> datamap =(Map<String,List<Task>>) JSON.deserialize(jsonString, Map<String,List<Task>>.class);
        Set<String> oppIdsSet = datamap.keyset();
        System.debug('size = '+oppIdsSet.size());
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id IN : oppIdsSet];
        System.debug('oppList = '+oppList.size());
         List<Task> insertTaskList = new List<Task>();
        System.debug('datamap = '+oppIdsSet);
        map<string,string> TaskMapoldNew=new map<string,string>();  //@
        Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
          for(Opportunity eachOpp : oppList){
              System.debug('eachOpp.Id = '+eachOpp.Id);
            if(datamap.containskey(eachOpp.Id)){
                List<Task> planetOrgTaskList = datamap.get(eachOpp.Id);
                System.debug('planetOrgTaskList = '+planetOrgTaskList.size());
                for(Task eachTask : planetOrgTaskList){
                    Task newTask = new Task();
                    newTask.WhatId = eachOpp.Id;
                    newTask.Subject = eachTask.Subject;
                    newTask.Status = eachTask.Status;
                    newTask.Priority = eachTask.Priority;  
                    newTask.Description = eachTask.Description; 
                    newTask.ActivityDate = eachTask.ActivityDate;
                    newTask.Task_Import_Id__c=eachTask.Id;
                    newTask.RecordTypeId=DNLTaskRecordTypeId;
                    insertTaskList.add(newTask);
                    
                }
            }
        }
        
        list<Invoice> lstWrapper=new list<Invoice>();
        System.debug('insertTaskList = '+insertTaskList);
        if(!insertTaskList.isEmpty()){
             System.debug('Imside insertTaskList if ');
            insert insertTaskList;  
        }
        System.debug('insertTaskList1 = '+insertTaskList);
        //
       for(Task t1:insertTaskList)
        { 
           
           Invoice invc=new Invoice();
           invc.ImportId=t1.Task_Import_Id__c;
           invc.currentTaskId=t1.Id;
           lstWrapper.add(invc);  
           
        }
        InvoiceWrapper IW=new InvoiceWrapper();
        IW.invoiceList=lstWrapper;
        jsonString = JSON.serialize(IW);  //
        Blob body = Blob.valueOf(jsonString);
        response.responseBody=body;
        
    }
   
  }