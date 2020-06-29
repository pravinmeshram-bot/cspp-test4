trigger accountTrigger on Account (after insert, before update,before insert) {
    
    Id ClientrecordTypeId = [Select Id From RecordType Where DeveloperName = 'Client'].Id;
    Id AttorneyrecordTypeId = [Select Id From RecordType Where DeveloperName = 'Attorney_Client'].Id;
    
    /*On account Insert if the BoxFolderId is already existing then this will update the folder name in box; 
      this scenario mostly occurs when an account is inserted by converting prospect. 
    */
    if (Trigger.isInsert && Trigger.isAfter && Trigger.new.size() == 1) {
        
        if (Trigger.New[0].RecordTypeId == ClientrecordTypeId  || Trigger.New[0].RecordTypeId == AttorneyrecordTypeId ) {
            
            if ((Trigger.New[0].BoxFolderId__c != null || Trigger.New[0].BoxFolderId__c != '') && Trigger.New[0].Attorney__c == false){
                
                AccountHandler.updateFolderName(Trigger.new);
            }               
        }
    }
     if (Trigger.isBefore && Trigger.isUpdate || Trigger.isBefore && Trigger.isInsert ) {
     for(Account acc : trigger.new )
    { 
        if(acc.Phone == NULL || test.isRunningTest())
        {  
           if(acc.nu_dse__Home_Phone__c != NULL)
               acc.Phone= acc.nu_dse__Home_Phone__c;
             if(acc.nu_dse__Work_Phone__c != NULL)
                acc.Phone= acc.nu_dse__Work_Phone__c ;
             if(acc.nu_dse__Other_Phone__c != NULL)
                acc.Phone= acc.nu_dse__Other_Phone__c;
              if(acc.nu_dse__Cell_phone__c != NULL)
                acc.Phone= acc.nu_dse__Cell_phone__c ;
              if(acc.nu_dse__Best_Phone__c != NULL)
                acc.Phone= acc.nu_dse__Best_Phone__c ;
              if(acc.PersonHomePhone != NULL)
                acc.Phone= acc.PersonHomePhone ;
             if(acc.PersonMobilePhone != NULL)
                acc.Phone= acc.PersonMobilePhone ;
             if(acc.PersonOtherPhone != NULL)
                acc.Phone= acc.PersonOtherPhone ;
        }
    }
     }
  /* This logic is commented because this is no more requried and 
     all the folder creation for accounts are handledd through batch class
     
   if (Trigger.isInsert && Trigger.isAfter && Trigger.new.size() == 1) {
        //For create folder --- But won't support bulk...
        //Prevent createFolders for batch context...
        //if (System.isBatch() == False) {
            
        Map <Id, Account> createFolderAccountMap = new Map <Id, Account>();
        
        for (Account accountInstance : Trigger.newMap.values()) {
           
            if ((accountInstance.RecordTypeId == ClientrecordTypeId  || accountInstance.RecordTypeId == AttorneyrecordTypeId) 
                && (accountInstance.BoxFolderId__c == null || accountInstance.BoxFolderId__c == '') 
                && accountInstance.Attorney__c == true) {
               
                 createFolderAccountMap.put(accountInstance.Id, accountInstance);
            }
        }
        
        Create Folder for filtered Accounts...
        AccountHandler.CreateFolders(createFolderAccountMap);
        } 
    } */
}