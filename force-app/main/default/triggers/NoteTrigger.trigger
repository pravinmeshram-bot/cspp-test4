trigger NoteTrigger on Note (after Insert, after Update, before delete) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(!Attorney_StaticVariableUtility.apiUser){
            Attorney_NoteHandler.createNotesInNDS();
            }
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        list<Profile> profiles = [SELECT Id, Name FROM Profile Where name = 'System Administrator' or name='Negotiations Manager'];
        
        String sa_ProfileId;
        String ng_ProfileId;
        for(Profile pro: profiles){
            if(pro.name =='System Administrator'){
                sa_ProfileId =  Pro.Id;
            }
            if(pro.name == 'Negotiations Manager'){
                ng_ProfileId =  Pro.Id;
            }
        }
        
        String offerKeyPrefix = Schema.getGlobalDescribe().get('nu_dse__Offer__c').getDescribe().getKeyPrefix();
        set<String> ofrIds = new set<String>();
        
        for(Note att: Trigger.Old){
            if(String.valueOf(att.ParentId).startsWith(offerKeyPrefix)){
                ofrIds.add(att.ParentId);
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            Map<Id, nu_dse__Offer__c> offersmap = new Map<Id, nu_dse__Offer__c>([SELECT Id, name, CreatedById FROM nu_dse__Offer__c where Id IN: ofrIds]);
            for(Note att: Trigger.Old){
                if(String.valueOf(att.ParentId).startsWith(offerKeyPrefix)){
                    Boolean isDeletable = false;
                    nu_dse__Offer__c resultOffer = offersmap.get(att.ParentId);
                    if(resultOffer.CreatedById == UserInfo.getUserId() || att.CreatedById == UserInfo.getUserId() || ng_ProfileId == UserInfo.getProfileId() || sa_ProfileId == UserInfo.getProfileId()){
                        isDeletable=true;
                    }
                    if(!isDeletable){
                        att.addError('you do not have right to delete an Notes');
                    }
                }
            }
        }
    }
}