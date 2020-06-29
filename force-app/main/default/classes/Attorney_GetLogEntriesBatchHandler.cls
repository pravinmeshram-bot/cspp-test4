public class Attorney_GetLogEntriesBatchHandler {
    
    public Integer executeLogPages(LeadtracNetClient.GetCompanyLogEntries_element request_x){
        
        //try
        //{
            
            System.debug('++++++++++++++++ request' + json.serialize(request_x));
            
            LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
            LeadtracNetClient.GetCompanyLogEntriesResponse_element logEntriesResponse = new LeadtracNetClient.GetCompanyLogEntriesResponse_element();
            
            logEntriesResponse = soap.GetCompanyLogEntriesClone(request_x);
            System.debug('++++++++++++++++ response' + json.serialize(logEntriesResponse));
            
            List<Task> sfTaskNoteList = new List<Task>();
            LeadtracNetClient.GetLogEntriesResult LogLogEntriesResult = logEntriesResponse.GetCompanyLogEntriesResult;
            
            if(LogLogEntriesResult.IsSuccessful == true)
            {
                LeadtracNetClient.ArrayOfLogEntry arryofLogEntry = LogLogEntriesResult.Entries;
                
                Set<string> filenumber = new Set<string>();
                if(arryofLogEntry != null && arryofLogEntry.LogEntry != null){
                for(LeadtracNetClient.LogEntry log: arryofLogEntry.LogEntry)
                    filenumber.add(log.FileNumber);
                }
                
                Map<String,nu_dse__Program__c>  progamMap = new  Map<string,nu_dse__Program__c>();
                for(nu_dse__Program__c p : [Select Id,Import_Id__c,Attorney__c,Test_Program__c from nu_dse__Program__c where Import_ID__c=:filenumber])
                    progamMap.put(p.Import_Id__c,p);
                
                if(arryofLogEntry != null && arryofLogEntry.LogEntry != null){
                for(LeadtracNetClient.LogEntry log: arryofLogEntry.LogEntry)
                {
                    Task t = new  Task();
                    
                    if(log.entry != null && log.entry.Length() < 32001)
                    {
                    t.Description = log.Entry.replace('&amp;','').replace('amp;','').replace('&nbsp;','').replace('nbsp;','');
                    }
                    else
                    {
                    t.Description = 'Clean up required in NDS';
                    }
                    t.FileNumber__c = log.FileNumber;
                    t.Attorney__c = true;
                    
                    t.NDS_Assigned__c = log.CreatedBy;
                    //Change made by Vaibhav for stories NMI-442 and NMI-263
                    t.NDS_Created_Date__c = Date.valueOf(log.CreatedOn);
                    t.ActivityDate = Date.valueOf(log.CreatedOn);
                    
                    if(progamMap.containsKey(log.FileNumber))
                        t.WhatId = progamMap.get(log.FileNumber).Id;
                    
                    LeadtracNetClient.LogCategory c = log.Category;
                    t.Category__c = c.Category;
                    t.IsNote__c = true;
                    t.nu_dse__Is_Noted__c = true;
                    t.Status = 'Completed';
                    t.Subject = 'NDS Notes';
                    t.Notes_Id__c = string.valueOf(log.Id);  
                    t.Last_Modified_By_NDS__c = System.now();
                    sfTaskNoteList.add(t);
                }
                
                System.debug('++++++++++++++ sfTaskNoteList' + sfTaskNoteList);
                Schema.SObjectField f = Task.Fields.Notes_Id__c;
                Database.UpsertResult [] updateResults = Database.upsert(sfTaskNoteList, f, false);
                String errorString = '';
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        system.debug('++++++++ Failed ID '+ updateResults.get(i).getErrors().get(0));
                         
                            for(Database.Error err : updateResults.get(i).getErrors())
                                errorString += err;
                        
                    }
                    
                }
                 if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        if (!Test.isRunningTest ())
                            throw e;
                }
                }
                System.debug('****'+logEntriesResponse.totalPages);
                return logEntriesResponse.totalPages;
            }
        //}
       /*catch(Exception e)
        {
            System.debug('++++++++++++++ errror' + e.getMessage());
            System.debug('****'+e.getStackTraceString());
        }*/
        
        return 0;
        
    }
    
    public static List<LeadTracProgramType__mdt> getLeadtrackProgramLst(){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst = [Select Id,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type'];    
        return leadtrckProgramTypeLst;
    }
    
    
    
    
}