global class BatchDailyReport implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    global String fileContent;
    global List<String> lstFileContent = new List<String>();
    
    global List<nu_dse__TradeLine__c> start(Database.BatchableContext BC) {
        fileContent = '#TradeLine,New Creditor,Original Creditor,New Account Number,Original Account Number,Program Status,Program Name,Client Number,First Name,Last Name, Co First Name, Co Last Name,Mailing Street,Mailing City,Mailing State,Mailing Zip,Mailing Country,Home Phone,Mobile Phone,Created Date\n';
        String query = 'Select id,name,nu_dse__New_Creditor__r.name,nu_dse__Original_Creditor__r.name,nu_dse__New_Account_Number__c,'
                       +'nu_dse__Original_Account_Number__c,nu_dse__Program__r.nu_dse__Program_Status__c,'
                       +'nu_dse__Program__r.Program_Name__c,'
                       +'nu_dse__Account__r.nu_dse__Client_Number__c,nu_dse__Account__r.FirstName,nu_dse__Account__r.LastName,'
                       +'nu_dse__Account__r.nu_dse__Co_First_Name__c,nu_dse__Account__r.nu_dse__Co_Last_Name__c,'
                       +'nu_dse__Account__r.PersonMailingStreet,nu_dse__Account__r.PersonMailingCity,nu_dse__Account__r.PersonMailingState,'
                       +'nu_dse__Account__r.PersonMailingPostalCode,nu_dse__Account__r.PersonMailingCountry,nu_dse__Account__r.PersonHomePhone,'
                       +'nu_dse__Account__r.PersonMobilePhone,nu_dse__Account__r.CreatedDate'
                       +' from nu_dse__TradeLine__c limit 5000';
        return DataBase.query(query);
    }

    global void execute(Database.BatchableContext BC, List<nu_dse__TradeLine__c> scopeList) {
        if(scopeList != null && !scopeList.isEmpty()){
            //List<nu_dse__TradeLine__c> lstTradeLine = (List<nu_dse__TradeLine__c>)scopeList;
            for(nu_dse__TradeLine__c a: scopeList){
               string recordString = '"'+a.id+'","'+a.nu_dse__New_Creditor__r.name+'","'+a.nu_dse__Original_Creditor__r.name+'","'+a.nu_dse__New_Account_Number__c +'","'+a.nu_dse__Original_Account_Number__c+'","'+a.nu_dse__Program__r.nu_dse__Program_Status__c+'","'+a.nu_dse__Program__r.Program_Name__c+'","'+a.nu_dse__Account__r.nu_dse__Client_Number__c+'","'+a.nu_dse__Account__r.FirstName+'","'+a.nu_dse__Account__r.LastName+'","'+a.nu_dse__Account__r.nu_dse__Co_First_Name__c+'","'+a.nu_dse__Account__r.nu_dse__Co_Last_Name__c+'","'+a.nu_dse__Account__r.PersonMailingStreet+'","'+a.nu_dse__Account__r.PersonMailingCity+'","'+a.nu_dse__Account__r.PersonMailingState+'","'+a.nu_dse__Account__r.PersonMailingPostalcode+'","'+a.nu_dse__Account__r.PersonMailingCountry+'","'+a.nu_dse__Account__r.PersonHomePhone+'","'+a.nu_dse__Account__r.PersonMobilePhone+'","'+a.nu_dse__Account__r.CreatedDate+'"\n';
               fileContent = fileContent +recordString;
            }
        }
    }  

    global void finish(Database.BatchableContext BC) { 
        uploadFileToBox();
    }
    
    global void uploadFileToBox(){
        DailyReport_FolderId__c DailyReportId = new DailyReport_FolderId__c();
        DailyReportId = DailyReport_FolderId__c.getValues('DailyReport');
       
        String selectedFolder = DailyReportId.FolderId__c;
        Blob uploadContent = Blob.valueOf(fileContent);//generateCSVFile(); // Returns blob content of CSV file.
        String uploadFilename = 'Report For '+System.now()+'.csv';
        String accessToken ='';
        
        Box_settings__c settings=new Box_settings__c();
        settings = Box_settings__c.getValues('Daily Report');
        
        if(settings !=null && settings.Client_id__c != null && settings.Client_Secret__c != null && settings.Refresh_Token__c !=null){
           accessToken=settings.access_token__c;
        }
        
        blob base64EncodeFile=base64EncodeFileContent(uploadContent,uploadFilename);
        String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+selectedFolder;
        String boundaryTmp = '----------------------------741e90d31eff';
        HttpRequest req = new HttpRequest();
        req.setBodyAsBlob(base64EncodeFile);
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundaryTmp);
        req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setEndpoint(uploadEndPointURL);
        req.setMethod('POST');
        req.setTimeout(120000);
        //Send request to Box
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String Response=res.getBody();
        System.debug('**Files upload Response:'+Response);
        Integer uploadStatusCode=res.getStatusCode();
        if(uploadStatusCode==201){
            system.debug('File uploaded successfully.');
        }else{
            system.debug('Error encountered. Status Code;'+uploadStatusCode);
        }
    }
    
    global blob base64EncodeFileContent(Blob file_body, String file_name){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
    
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
    
        return bodyBlob;
    }
}