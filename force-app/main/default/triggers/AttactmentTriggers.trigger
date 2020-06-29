trigger AttactmentTriggers on Attachment (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        list<Profile> profiles = [SELECT Id, Name FROM Profile Where name = 'System Administrator' or name ='Negotiations Manager'];
        String sa_ProfileId;
        String ng_ProfileId;
        for(profile pro: profiles){
            If(pro.name == 'System Administrator'){
                sa_ProfileId = pro.Id;
            }
            if(pro.name == 'Negotiations Manager'){
                ng_ProfileId = pro.Id;
            }
        }
        
        String taskKeyPrefix = Schema.getGlobalDescribe().get('Task').getDescribe().getKeyPrefix();
        String offerKeyPrefix = Schema.getGlobalDescribe().get('nu_dse__Offer__c').getDescribe().getKeyPrefix();
        
        set<String> tskIds = new set<String>();
        set<String> ofrIds = new set<String>();
        for(Attachment att: Trigger.Old){
            if(String.valueOf(att.ParentId).startsWith(taskKeyPrefix) ){
                tskIds.add(att.ParentId);
            }else if(String.valueOf(att.ParentId).startsWith(offerKeyPrefix)){
                ofrIds.add(att.ParentId);
            }
        }
        if(ofrIds != null && ofrIds.size()>0){
            Map<Id, nu_dse__Offer__c> offersmap = new Map<Id, nu_dse__Offer__c>([SELECT Id, name, CreatedById FROM nu_dse__Offer__c where Id IN: ofrIds]);
            for(Attachment att: Trigger.Old){
                if(String.valueOf(att.ParentId).startsWith(taskKeyPrefix) ){
                    tskIds.add(att.ParentId);
                }else if(String.valueOf(att.ParentId).startsWith(offerKeyPrefix)){
                    Boolean isDeletable = false;
                    nu_dse__Offer__c resultOffer = offersmap.get(att.ParentId);
                    if(resultOffer.CreatedById == UserInfo.getUserId() || att.CreatedById == UserInfo.getUserId() || ng_ProfileId == UserInfo.getProfileId() || sa_ProfileId == UserInfo.getProfileId()){
                        isDeletable=true;
                    }
                    if(!isDeletable){
                        att.addError('you do not have right to delete an attachment');
                    }
                }     
            }  
        }
        
        system.debug('##### task id:'+tskIds.size());
        if(tskIds != null && tskIds.size()>0){
            map<Id, Task> tskMap = new map<Id, Task>([Select Id, WhatId From Task Where Id IN: tskIds]);
            for(Attachment att: Trigger.Old){
                if(String.valueOf(att.ParentId).startsWith(taskKeyPrefix)){
                    Task resultTask = tskMap.get(att.ParentId);
                    if(String.valueOf(resultTask.WhatId).startsWith(offerKeyPrefix)){   
                        Boolean isDeletable = false;
                        if(att.CreatedById == UserInfo.getUserId() || sa_ProfileId == UserInfo.getProfileId() || ng_ProfileId == UserInfo.getProfileId()){
                            isDeletable=true;
                        }
                        if(!isDeletable){
                            att.addError('you do not have right to delete an attachment');      
                        }
                    }
                }
            }
        }
        
        
    }
}