public class caseTriggerHandler{

public static boolean firstRun = true;

public static void populateProgramOnAccountPopulation(List<Case> newCases, Map<Id,Case> oldCases, Boolean isInsert){

if(firstRun){
Map<id,Case> accIdMap = new Map<id,Case>();
List<Case> updateCases = new List<Case>();


for(Case cs : newCases){
if(!isInsert){
if(cs.accountId != oldCases.get(cs.Id).accountId){
accIdMap.put(cs.accountId,cs);
}
}else{
if(cs.accountId != null){
accIdMap.put(cs.accountId,cs);
}
}
}

system.debug('===='+accIdMap);

for(nu_dse__Program__c prgm : [select id,nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c IN:accIdMap.KeySet()]){

if(accIdMap.containsKey(prgm.nu_dse__Account__c)){
system.debug('===='+prgm.nu_dse__Account__c);
Case upCase = new Case();
upCase.id = accIdMap.get(prgm.nu_dse__Account__c).Id;
upCase.Program__c = prgm.id;
updateCases.add(upCase);
}
}
system.debug('===='+updateCases);
if(!updateCases.isEmpty()){
update updateCases;
firstRun = false;
}
}
}

}