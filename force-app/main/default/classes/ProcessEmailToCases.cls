/**
* Name:          ProcessEmailToCases
* Author:        Amit Goyal
* CreatedDate:   10/24/2019 - S20-270 - Amit Goyal
* Modified By:   
* Description:   To connect child cases with related case, which is closed and email received after closer
Getting invoked from ProcessChildCases Process Builder
*/
global class ProcessEmailToCases {
	@InvocableMethod
	global static void processCases(list<Id> caseIds){
        //system.debug('### caseIds: '+caseIds);
        map<Id, Case> processCaseMap = new map<Id, Case>();
        map<String, Case> removeCases = new map<String, Case>();
        set<String> caseNumbers = new set<String>();
        set<String> caseSubjects = new set<String>();
		list<Case> newCases = [Select Id, Subject, Case_Created_Origin__c, Child_Case__c, ParentId, Status, Description 
                               From Case 
                               Where Id IN: caseIds];
		if(newCases != null && newCases.size()>0){
			for(Case cs: newCases){
                //system.debug('### subject: '+cs.subject+' - '+cs.Case_Created_Origin__c+' - '+cs.Child_Case__c);
                if(cs.Subject.StartsWith('Re:')){
                    if(cs.Subject.contains('#')){
                        Integer startIndex=cs.Subject.indexOf('#');
                        //system.debug('### Start Index: '+startIndex);
                        //system.debug('### Case Number---1: '+cs.Subject.subString(startIndex+2, startIndex+10));
                        String csNumber=cs.Subject.subString(startIndex+2, startIndex+10);
                        //system.debug('### Case Number---2: '+csNumber);
                        caseNumbers.add(csNumber);
                    }
                    
                    if(cs.Subject.contains(':')){
                        list<String> rawData = cs.Subject.split(':');
                        if(rawData != null && rawData.size()>0){
                            String subject = rawData[rawData.size()-1];
                            //system.debug('### subject: '+subject);
                            caseSubjects.add(subject.trim());
                        }
                    }
                }
            }
			
            //system.debug('### caseNumbers: '+caseNumbers);
            if((caseNumbers != null && caseNumbers.size()>0) || (caseSubjects != null && caseSubjects.size()>0)){
                map<String, Case> casesMap = new map<String, Case>();
                list<Case> cases = [Select Id, CaseNumber, Status, Subject, ParentId, Description 
                                    From Case 
                                    Where CaseNumber In: caseNumbers OR Subject IN: caseSubjects];
                if(cases != null && cases.size()>0){
                    for(Case cs: cases){
                        casesMap.put(cs.CaseNumber, cs);
                        casesMap.put(cs.Subject, cs);
                        //system.debug('### Case Map---1: '+casesMap);
                    }
                    
                    if(casesMap != null && casesMap.size()>0){
                        for(Case cs: newCases){
                            //system.debug('### subject: '+cs.subject);
                            Boolean csNumberProcessed=false;
                            if(cs.Subject.StartsWith('Re:')){
                                if(cs.Subject.contains('#')){
                                    Integer startIndex=cs.Subject.indexOf('#');
                                    String csNumber=cs.Subject.subString(startIndex+2, startIndex+10);
                                    //system.debug('### Case Number---2: '+csNumber);
                                    if(casesMap.containsKey(csNumber)){
                                        csNumberProcessed=true;
                                        Case prevCase = casesMap.get(csNumber);
                                        if(prevCase.Status=='Closed'){
                                            cs.ParentId=prevCase.Id;
                                            processCaseMap.put(cs.Id, cs);
                                        }else{
                                            if(cs.Description != null){
                                                prevCase.Description+=' '+cs.Description;
                                                processCaseMap.put(prevCase.Id, prevCase);
                                            }
                                            removeCases.put(cs.Id, cs);
                                        }
                                    }
                                }
                                
                                if(csNumberProcessed==false){
                                    if(cs.Subject.contains(':')){
                                        list<String> rawData = cs.Subject.split(':');
                                        if(rawData != null && rawData.size()>0){
                                            String subject = rawData[rawData.size()-1];
                                            if(casesMap.containsKey(subject.trim())){
                                                Case prevCase = casesMap.get(subject.trim());
                                                if(prevCase.Status=='Closed'){
                                                    cs.ParentId=prevCase.Id;
                                                    processCaseMap.put(cs.Id, cs);
                                                }else{
                                                    if(cs.Description != null){
                                                        prevCase.Description+=' '+cs.Description;
                                                        processCaseMap.put(prevCase.Id, prevCase);
                                                    }
                                                    removeCases.put(cs.Id, cs);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // update cases
                if(processCaseMap != null && processCaseMap.size()>0){
                    update processCaseMap.values();
                }
                
                // delete new cases if previous case is not closed
                if(removeCases != null && removeCases.size()>0){
                    list<String> csIds = new list<String>();
                    for(String str: removeCases.keyset()){
                        csIds.add(str);
                    }
                    processCaseDeletion(csIds);
                }
            }
        }
	}
    
    @future
    public static void processCaseDeletion(list<String> caseIds) {
        list<Case> cases = new list<Case>();
        if(caseIds != null && caseIds.size()>0){
            for(Integer i=0;i<caseIds.size();i++){
                cases.add(new Case(Id=caseIds[i]));
            }
            delete cases;
        }
    }
}