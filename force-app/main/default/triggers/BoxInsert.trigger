trigger BoxInsert on Account (after insert) {
    for (Account objAccount : Trigger.new) {
        ClientFolderCreation.createFolder(objAccount.ClientNumber__c,objAccount.Id);
    }
}