public class quickDocTriggerHandler{
    public static void CreateActivityOnQuickDocCreation(List<Quick_Doc__c> quickDocLst){
        List<Quick_Doc__c> accountReviewQucikDocLst = new List<Quick_Doc__c>();
        ID RecordtypeId = [Select Id from RecordType where Name = 'Account Review'].id;
        ID RecordtypeId1 = [Select Id from RecordType where Name = 'OnBoarding Call'].id;
        ID RecordtypeId2 = [Select Id from RecordType where Name = 'Strategy Call'].id;
        ID RecordtypeId3 = [Select Id from RecordType where Name = 'Negotiations' AND SobjectType = 'Quick_Doc__c'].id;
        ID RecordtypeId4 = [Select Id from RecordType where Name = 'Pending Cancellation'].id;
        ID RecordtypeId5 = [Select Id from RecordType where Name = 'Documents'].id;
        ID RecordtypeId6 = [Select Id from RecordType where Name = 'Miscellaneous'].id;
        ID RecordtypeId7 = [Select Id from RecordType where Name = 'Payments' AND SobjectType = 'Quick_Doc__c'].id;
        Set<Id> accountIdSet = new Set<Id>();
        string notes;
        string Recortype;
        string RecordId;
        string CallType;
        String CallTypeM;
        String CallTypeP;
        for(Quick_Doc__c doc: quickDocLst){
            if(doc.RecordTypeId == RecordtypeId || doc.RecordTypeId == RecordtypeId1 || doc.RecordTypeId == RecordtypeId2 || doc.RecordTypeId == RecordtypeId3 || doc.RecordTypeId == RecordtypeId4 || doc.RecordTypeId == RecordtypeId5 || doc.RecordTypeId == RecordtypeId6 || doc.RecordTypeId == RecordtypeId7){
                accountReviewQucikDocLst.add(doc);
                accountIdSet.add(doc.Account__c);
                string Note = doc.Notes__c;
                calltype = doc.Caller_List__c;
                CallTypeM = doc.Call_Type_Miscellaneous__c;
                CallTypeP = doc.Call_Type_Payments__c;
                if(!String.isEmpty(Note)){
                    system.debug('@@@@'+doc.Notes__c);
                 //   notes = Note + '\n' + DOC.Additional_Information__c;
                      notes = Note + '\n' + '';
                }else
                      notes = '';
                    // notes = DOC.Additional_Information__c; 
                RecordId = doc.RecordTypeId;
              //  Recortype = doc.RecordType.name;
                system.debug('Kra#'+RecordId);
            }
        }
        
     //   Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('RecordTypeLabel').getRecordTypeId();
        List<nu_dse__Program__c> programLst = [select id from nu_dse__Program__c where nu_dse__Account__c IN: accountIdSet];
        //List<Account> accLst = [select id,(select id from Programs__r) from Account where id IN: accountIdSet];
        List<Task> taskLst = new List<Task>();
        Task tas;
        for(nu_dse__Program__c prog: programLst){
            tas =new Task();
                tas.Description = notes;
                tas.Priority = 'Normal'; 
                tas.Status = 'Completed'; 
                system.debug('Kra@'+RecordId);
/************************************ hardcoding Record Type Ids will soon be replaced with Dynamic values***************************************/                
                if(RecordId == RecordtypeId){    
                    tas.Subject = 'Account Review Complete';
                }else
                if(RecordId == RecordtypeId1){
                    tas.Subject = 'Onboarding Call-Completed';
                }else
                if(RecordId == RecordtypeId2){
                    tas.Subject = 'Strategy Call-Completed';
                }else
                if(RecordId == RecordtypeId3){
                    tas.Subject = 'Negotiations-Completed';
                }else
                if(RecordId == RecordtypeId4){
                    tas.Subject = 'Pending Cancellation';
                }else
                if(RecordId == RecordtypeId5 && calltype == 'Send LOR/POA'){
                    tas.Subject = 'Letter of Representation';
                }else
                if(RecordId == RecordtypeId5 && calltype == 'Litigation'){
                    tas.Subject = 'Lit Elevation';
                }else
                if(RecordId == RecordtypeId5 && calltype == '1099C'){
                    tas.Subject = '1099';
                }else
                if(RecordId == RecordtypeId6 && (calltypem == 'FDCPA' || calltypem == 'FDCPA Lead Post')){
                    tas.Subject = 'Miscellaneous';
                }else
                if(RecordId == RecordtypeId6 && calltypem == 'Email Client'){
                    tas.Subject = 'Request for Information';
                }else
                if(RecordId == RecordtypeId6 && calltypem == 'Creditor Calls'){
                    tas.Subject = 'Creditor Correspondence';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Task Tool'){
                    tas.Subject = 'Payments';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'NSF'){
                    tas.Subject = 'Re-Schedule Payment Due to NSF';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Skip Draft'){
                    tas.Subject = 'Skip Draft Request';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Change Draft Date'){
                    tas.Subject = 'Draft Date Adjustments';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Change Draft Amount'){
                    tas.Subject = 'Draft Amount Change Request';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Change Bank'){
                    tas.Subject = 'Bank Information Change Request';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Refund Request'){
                    tas.Subject = 'Refund Request';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Add/Remove debt'){
                    tas.Subject = 'Add/Remove debt';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Default on Active Settlement'){
                    tas.Subject = 'Payments';
                }else
                if(RecordId == RecordtypeId7 && calltypep == 'Estimate to Complete'){
                    tas.Subject = 'Estimate To Complete the Program';
                }
                
                tas.IsReminderSet = true; 
                tas.ReminderDateTime = System.now()+1;
                tas.ActivityDate = System.today();
                tas.whatId = prog.Id;
                
                taskLst.add(tas);
            }            
        Insert taskLst;
    }    
}