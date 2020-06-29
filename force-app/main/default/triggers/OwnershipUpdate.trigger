trigger OwnershipUpdate on nu_dse__TradeLine__c (before insert,before update) {    
   Set<String> setProgramIds = new Set<String>();
    Map<String,String> mapQueueNameAndId = new Map<String,String>();
    Map<String,nu_dse__Program__c> mapPrograms = new Map<String,nu_dse__Program__c>();
    if(Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)){
        
        for(nu_dse__TradeLine__c t: Trigger.new){
        /****Modified By Ramesh :  Added attorney condition to make this functionlity not running for pull jobs****/
            if(!t.Attorney__c && !t.isAttorney__c){
            if(Trigger.isUpdate){
                nu_dse__TradeLine__c oldObjtradeline = Trigger.oldMap.get(t.Id);
                 if(oldObjtradeline != null){
                     if(t.In_Litigation__c != oldObjtradeline.In_Litigation__c){
                        setProgramIds.add(t.nu_dse__Program__c);
                     }
                 }
            }
            if(Trigger.isInsert){
                if(t.In_Litigation__c != null)
                    setProgramIds.add(t.nu_dse__Program__c);
            } 
            }
        } 
        if(setProgramIds != null && !setProgramIds.isEmpty()){
            List<nu_dse__Program__c> lstProgram = [SELECT Id,Name,ownerId,Subscribed_to_ALLG__c FROM nu_dse__Program__c WHERE ID IN:setProgramIds];
            if(lstProgram != null && !lstProgram.isEmpty()){
                for(nu_dse__Program__c objProgram : lstProgram){
                    mapPrograms.put(objProgram.Id,objProgram);
                }
            }
            List<Group> lstGroup = [select Id,Name from Group where Type = 'Queue' and name in('ALLG','In-House Litigation','Negotiators')];
            if(lstGroup != null && !lstGroup.isEmpty()){
                for(Group objGroup : lstGroup){
                    mapQueueNameAndId.put(objGroup.Name,objGroup.Id);
                }
            }
        }
        boolean flag = false;
        for(nu_dse__TradeLine__c t: Trigger.new){
            if(!t.Attorney__c && !t.isAttorney__c){
            flag = false;
            if(Trigger.isUpdate){
                nu_dse__TradeLine__c oldObjtradeline = Trigger.oldMap.get(t.Id);
                 if(oldObjtradeline != null){
                     if(t.In_Litigation__c != oldObjtradeline.In_Litigation__c){
                         flag = true;
                     }
                 }
            }
            if(Trigger.isInsert){
                if(t.In_Litigation__c != null)
                    flag = true;
            } 
            if(true){
                if(t.In_Litigation__c == true){
                    
                    nu_dse__Program__c program = mapPrograms.get(t.nu_dse__Program__c);
                    if(program != null){
                        if(program.Subscribed_to_ALLG__c == true){
                            t.ownerId = mapQueueNameAndId.get('ALLG');
                            program.ownerId = mapQueueNameAndId.get('ALLG');
                        }    
                        if(program.Subscribed_to_ALLG__c == false){
                            t.ownerId = mapQueueNameAndId.get('In-House Litigation');
                            program.ownerId = mapQueueNameAndId.get('In-House Litigation');
                        }    
                    }
                }
                if(t.In_Litigation__c == false){
                    if(!mapQueueNameAndId.isEmpty())
                    t.ownerId = mapQueueNameAndId.get('Negotiators');
                    if(!mapPrograms.isEmpty())
                    mapPrograms.get(t.nu_dse__Program__c).ownerId = mapQueueNameAndId.get('Negotiators');
                }
            }
        } 
        }
        if(mapPrograms != null && !mapPrograms.isEmpty())
            update mapPrograms.values();
            
    }
}