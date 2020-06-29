trigger SfsSummonTrigger on Summon__c (after Insert, after Update, after Delete, after Undelete) {
	if(Trigger.isAfter){
    
        if(Trigger.isInsert){
                SfsSummonHandler.handlerAfterInsert(Trigger.newMap);
        }
        If(Trigger.isUpdate){
                SfsSummonHandler.handlerAfterUpdate(Trigger.newMap, Trigger.newMap);
        }
        if(Trigger.isDelete){
                SfsSummonHandler.handlerAfterDelete(Trigger.oldMap);
        }
        if(Trigger.isUndelete){
                SfsSummonHandler.handlerAfterUndelete(Trigger.newMap);
        }
        
    }
    
}

/*
list<Summon__c> sfsCases = [Select Id, Hot_Potato__c, Tradeline__c, Owner.Name, CreatedDate From Summon__c Where Hot_Potato__c != null AND Tradeline__r.Hot_Potato__c=Null];
set<String> tradlineIds = new set<String>();
if(sfsCases != null && sfsCases.size()>0){
	for(Summon__c smn: sfsCases){
		tradlineIds.add(smn.Tradeline__c);
	}
}
system.debug('### tradlineIds Size: '+tradlineIds.size());

List<nu_dse__Tradeline__c> trdlne = [SELECT Id, Is_sfs_case_present__c, SFS_Owner__c, Hot_Potato__c,(Select Id, Hot_Potato__c,Owner.Name From Summons__r ORDER BY CreatedDate DESC) From nu_dse__Tradeline__c where Id=: tradlineIds limit 100];
for(nu_dse__Tradeline__c udtrdlne: trdlne){
    if(udtrdlne.Summons__r != null && udtrdlne.Summons__r.size()> 0){
        if(udtrdlne.Summons__r[0].Hot_Potato__c != null){
            udtrdlne.Hot_Potato__c = udtrdlne.Summons__r[0].Hot_Potato__c;
        }
        if(udtrdlne.Summons__r[0].OwnerId != null){
        	udtrdlne.SFS_Owner__c = udtrdlne.Summons__r[0].Owner.Name;
        }
    }else{
    	udtrdlne.SFS_Owner__c = NULL;
    }
}
update trdlne;
===================================================================================================================================================================

this script works on hot potato:

List<nu_dse__Tradeline__c> trdlne = [SELECT Id, Is_sfs_case_present__c, Hot_Potato__c,(Select Id, Hot_Potato__c From Summons__r Where Hot_Potato__c != null ORDER BY CreatedDate DESC) From nu_dse__Tradeline__c where Hot_Potato__c=NULL limit 100];
for(nu_dse__Tradeline__c udtrdlne: trdlne){
    if(udtrdlne.Summons__r != null && udtrdlne.Summons__r.size()> 0){
        if(udtrdlne.Summons__r[0].Hot_Potato__c != null){
            udtrdlne.Hot_Potato__c = udtrdlne.Summons__r[0].Hot_Potato__c;
        }
    }
}
update trdlne;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

This script works on sfs owner name

list<Summon__c> sfsCses = [Select Id, Hot_Potato__c, Tradeline__c, Owner.Name, CreatedDate From Summon__c Where OwnerId != null AND Tradeline__r.SFS_Owner__c=Null];
set<String> trdlineIds = new set<String>();
if(sfsCses != NULL && sfsCses.size()>0){
	for(Summon__c smmn: sfsCses){
		trdlineIds.add(smmn.Tradeline__c);
	}
}
system.debug('### tradlineIds Size on owner name: '+trdlineIds.size());

List<nu_dse__Tradeline__c> trdelne = [SELECT Id, SFS_Owner__c,(Select Id, Owner.Name From Summons__r Where OwnerId != null) From nu_dse__Tradeline__c where SFS_Owner__c=Null AND Id in: trdlineIds limit 10];
system.debug('#### tradeline records' + trdelne);
for(nu_dse__Tradeline__c udtrdlnes: trdelne){
    system.debug('#### tradeline update records' + udtrdlnes);
    if(udtrdlnes.Summons__r != null && udtrdlnes.Summons__r.size()> 0){
        system.debug('#### sfs owner update records' + udtrdlnes.Summons__r[0].OwnerId);
        if(udtrdlnes.Summons__r[0].OwnerId != null){
            system.debug('#### owner name records' + udtrdlnes.Summons__r[0].Owner.Name);
        	udtrdlnes.SFS_Owner__c = udtrdlnes.Summons__r[0].Owner.Name;
        }
    }else{
    	udtrdlnes.SFS_Owner__c = NULL;
    }
}
update trdelne;
*/