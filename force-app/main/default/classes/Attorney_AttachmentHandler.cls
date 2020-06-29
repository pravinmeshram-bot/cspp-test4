public class Attorney_AttachmentHandler {
	
    public static void pushAttachmentsToNDS(){
        List<Attachment> NewAttachmentList = Trigger.new;
        List<Id> TradelineIds = new List<Id>();
        List<Attachment> AttachmentList = new List<Attachment>();
        for(Attachment a: NewAttachmentList){
            System.debug(a);
            String sObjName = a.ParentId.getSObjectType().getDescribe().getName();
            if(Trigger.isInsert){
                if(sObjName.equalsIgnoreCase('nu_dse__TradeLine__c')){
                	TradelineIds.add(a.ParentId);
                    AttachmentList.add(a);
                }
            }
        }
        System.debug(AttachmentList);
        if(!AttachmentList.isEmpty()){
            System.enqueueJob(new createAttachments(AttachmentList,TradelineIds));
        }
    }
    
    public class createAttachments implements Queueable,Database.AllowsCallouts {
        
        List<Id> TradelineIds = new List<Id>();
        List<Attachment> Attachments = new List<Attachment>();
        
        public createAttachments(List<Attachment> Attachments,List<Id> TradelineIds){
            this.Attachments = Attachments;
            this.TradelineIds = TradelineIds;
        }
        
        public void execute(QueueableContext context) {
            leadtracNetDebt.DebtServiceSoap soap = new leadtracNetDebt.DebtServiceSoap();
            Map<Id,nu_dse__Tradeline__c> TradelineMap = new Map<Id,nu_dse__Tradeline__c>([Select Id,isAttorney__c,FileNumber__c,Import_Id__c from nu_dse__Tradeline__c where Id=:TradelineIds]);
            
            System.debug(Attachments);
            
            for(Attachment a: Attachments){
                if(TradelineMap.get(a.ParentId).isAttorney__c){
                    System.debug(a.Name);
                    leadtracNetDebt.ArrayOfDebtFile FileArray = new leadtracNetDebt.ArrayOfDebtFile();
                    leadtracNetDebt.DebtFile DebtFile = new leadtracNetDebt.DebtFile();
                    DebtFile.FileExtension = a.Name.subStringAfterLast('.').capitalize();
                    
                    DebtFile.FileContent = EncodingUtil.base64Encode(a.Body);
                    DebtFile.Name = a.Name;
                    DebtFile.AssetTypeId = 'c297570a-9922-4e49-9568-4b024e422f56';
                    FileArray.DebtFile = new List<leadtracNetDebt.DebtFile>();
                    FileArray.DebtFile.add(DebtFile);
                    if(!Test.isRunningTest()){
                    leadtracNetDebt.AddDebtAssetResult result = soap.AddAsset(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,TradelineMap.get(a.ParentId).FileNumber__c,Long.valueOf(TradelineMap.get(a.ParentId).Import_Id__c),FileArray);
                    System.debug(result);
                    }
                    /*if(result.isSuccessful && isInsert){
                        if(result.Entries != null && result.Entries.LogEntry != null){
                            logEntry = result.Entries.logEntry[0];
                            n.Title = n.Title + ' **('+ logEntry.id +')';
                        }
                    }*/
                }
                //logEntry.
            }
        }
        
    }
    
}