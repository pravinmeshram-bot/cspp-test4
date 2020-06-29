//s20-463 Is_sfs_case_present is check when sfs case is create, update, delete or undelete 
public class SfsSummonHandler {

    public static void rollupSummonSFSCasecheck(Set<String> tdlineIds, String action){
        
        Map<Id, nu_dse__Tradeline__c> tradelineSFSMap = new Map<Id, nu_dse__Tradeline__c>([SELECT Id, Is_sfs_case_present__c, Hot_Potato__c, SFS_Owner__c,
                                                                                           (Select Id, Hot_Potato__c, OwnerId, Owner.Name From Summons__r
                                                                                           ORDER BY CreatedDate DESC )
                                                                                           From nu_dse__Tradeline__c
                                                                                           Where Id IN: tdlineIds]);
        if(tradelineSFSMap != null && tradelineSFSMap.size()>0){
            for(nu_dse__Tradeline__c ndtl: tradelineSFSMap.values()){
                if(ndtl.Summons__r != null && ndtl.Summons__r.size() >0){
                    if(ndtl.Summons__r[0].Hot_Potato__c != NUll){
                        ndtl.Hot_Potato__c= ndtl.Summons__r[0].Hot_Potato__c;
                    }
                    
                    if(ndtl.Summons__r[0].OwnerId != NULL){
                        if(action != 'delete'){
                            ndtl.SFS_Owner__c = ndtl.Summons__r[0].Owner.Name;
                            system.debug('### sfs owner'+ndtl.SFS_Owner__c);
                        }
                        else{
                            ndtl.SFS_Owner__c = NULL;
                            system.debug('### sfs owner'+ndtl.SFS_Owner__c);
                        }
                    }
                    ndtl.Is_sfs_case_present__c = true; 
                }else{
                    ndtl.Is_sfs_case_present__c = false;
                    ndtl.SFS_Owner__c = NULL;
                }
            }
        }
        update tradelineSFSMap.values();
    }
    
    
    public static void handlerAfterInsert(Map<Id, Summon__c> newSummon){
        
        set<String> tdlineIds = new Set<String>();
        if(newSummon != null && newSummon.size()>0){
            for(Summon__c sum: newSummon.values()){
                if(sum.Tradeline__c != Null){
                    tdlineIds.add(sum.Tradeline__c);    
                }
            } 
        }
        if(tdlineIds != null && tdlineIds.size()>0){
            rollupSummonSFSCasecheck(tdlineIds , 'insert');
        }
    }
    
    public static void handlerAfterUpdate(Map<Id, Summon__c> newSummon, Map<Id, Summon__c> OldSummon){
        set<String> tdlineIds = new Set<String>();
        if(newSummon != null && newSummon.size()>0){
            for(Summon__c sum: newSummon.values()){
                if(sum.Tradeline__c != Null){
                    tdlineIds.add(sum.Tradeline__c);    
                }
                if(sum.Tradeline__c != oldSummon.get(sum.Id).Tradeline__c && oldSummon.get(sum.Id).Tradeline__c != Null){
                    tdlineIds.add(oldSummon.get(sum.Id).Tradeline__c);
                }
            } 
        }
        if(tdlineIds != null && tdlineIds.size()>0){
            rollupSummonSFSCasecheck(tdlineIds, 'update');
        }
    }
    
    public static void handlerAfterDelete(Map<Id, Summon__c> OldSummon){
        system.debug('###delete');
        set<String> tdlineIds = new Set<String>();
        if(oldSummon != null && oldSummon.size()>0){
            for(Summon__c sum: oldSummon.values()){
                if(sum.Tradeline__c != Null){
                    tdlineIds.add(sum.Tradeline__c);    
                }
            } 
        }
        if(tdlineIds != null && tdlineIds.size()>0){
            rollupSummonSFSCasecheck(tdlineIds, 'delete');
        }
    }
    
    public static void handlerAfterUndelete(Map<Id, Summon__c> NewSummon){
        set<String> tdlineIds = new Set<String>();
        if(newSummon != null && NewSummon.size()>0){
            for(Summon__c sum: NewSummon.values()){
                if(sum.Tradeline__c != Null){
                    tdlineIds.add(sum.Tradeline__c);    
                }
            } 
        }
        if(tdlineIds != null && tdlineIds.size()>0){
            rollupSummonSFSCasecheck(tdlineIds, 'undelete');
        }
    }//s20-463 ends
}