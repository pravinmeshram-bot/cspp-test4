public class ProgramHandler {
    
  
    public static void handle(Map<id,nu_dse__Program__c> oldPrograms, Map<id,nu_dse__Program__c> newPrograms){
        
        Map<id,decimal> programDelta = new Map<id,decimal>(); 
        List<nu_dse__Program__c> cancelledPrograms = new LIst<nu_dse__Program__c>(); 
        
        if(trigger.isUpdate){ 
            
            for(id pId: newPrograms.keySet()){
                
                if(newPrograms.get(pId).nu_dse__Total_Debt_Included__c != oldPrograms.get(pId).nu_dse__Total_Debt_Included__c){
                    
                    decimal newDebt = newPrograms.get(pId).nu_dse__Total_Debt_Included__c != null ? newPrograms.get(pId).nu_dse__Total_Debt_Included__c : 0.00; 
                    decimal oldDebt = oldPrograms.get(pId).nu_dse__Total_Debt_Included__c !=null ? oldPrograms.get(pId).nu_dse__Total_Debt_Included__c : 0.00;
                   decimal delta = newDebt - oldDebt; 
                    
                    programDelta.put(pId,delta);
                }
            
                if( (newPrograms.get(pId).nu_dse__Program_Status__c != oldPrograms.get(pId).nu_dse__Program_Status__c) && (newPrograms.get(pId).nu_dse__Program_Status__c =='Cancelled')){
                    
                    cancelledPrograms.add(newPrograms.get(pId));
                }

            }
        
        }
        system.debug('programDelta-->'+programDelta);
        
        if(programDelta.size()>0){
            
            modifyLeadsPayments(programDelta);
        }
        
        if(cancelledPrograms.size()>0){
            
            CancelVelocifyPrograms cancelPrograms = new CancelVelocifyPrograms(cancelledPrograms); 
            
            ID jobID = System.enqueueJob(cancelPrograms);

            
        }
    }
    
    
    @future(callout=true)
    public static void modifyLeadsPayments( Map<id,decimal> programDelta){
        
        Map<id,nu_dse__program__c> programs = new Map<id,nu_dse__program__c>([select id,nu_dse__Total_Debt_Included__c, external_id__c from nu_dse__Program__c where id in:programDelta.keySet()]);
        
        List<ServiceLeads360.Lead> sLeads = new  List<ServiceLeads360.Lead>(); 
        
        List<ServiceLeads360.FieldValues> fieldValues; 
        
         for(id pId: programDelta.keySet()){
                
            if(programs.get(pId)!=null){
                    
              fieldValues = new List<ServiceLeads360.FieldValues>();
                    
              decimal debtDelta = programDelta.get(pId);
                    
              fieldValues.add(new ServiceLeads360.FieldValues('Debt Submitted Changed Amount',String.valueOF(debtDelta)));
                    
              sLeads.add(new ServiceLeads360.Lead(programs.get(pId).external_id__c,fieldValues) );
            }
         }
         system.debug('sLeads-->'+sLeads);
        
         ServiceLeads360 lead360 = new ServiceLeads360(); 
          if(!sLeads.isempty() && sLeads != null && !test.isrunningtest())
         lead360.modifyLeadPayments(sLeads);
        
    }
  
    public static void updateFeeTemplate(Map<Id, nu_dse__Program__c> oldProgramMap, List<nu_dse__Program__c> newProgramList) {
    
        List<nu_dse__Program__c> programsToProcessList = new List<nu_dse__Program__c>();
        Map<String, Id> settlementValFeeTempIdMap = new Map<String, Id>();
        Map<Id, String> existingFeeTempIdPrgmStatusMap = new Map<Id, String>();
        Map<Id, Id> oldFeeTempIdNewFeeTempIdMap = new Map<Id, Id>();
        Set<Decimal> estimatedSettlementPercentageSet = new set<Decimal>();
        Set<Decimal> settlementFeePercentageSet = new Set<Decimal>();
        Map<String, String> prgmStatusFeeTempExtIdMap = new Map<String, String>{'Versara Funding' => '80406', 'Versara NDS Graduated' => '80408'};
        
        if (newProgramList != null && newProgramList.isEmpty() == False) {
        
            for (nu_dse__Program__c programRec : newProgramList) {
            
                if (programRec.nu_dse__Fee_Template__c != null && programRec.nu_dse__Program_Status__c != oldProgramMap.get(programRec.Id).nu_dse__Program_Status__c
                        && (programRec.nu_dse__Program_Status__c == 'Versara Funding' || programRec.nu_dse__Program_Status__c == 'Versara NDS Graduated')) {
                
                    programsToProcessList.add(programRec);
                    
                    if (prgmStatusFeeTempExtIdMap.containsKey(programRec.nu_dse__Program_Status__c)) {
                    
                        existingFeeTempIdPrgmStatusMap.put(programRec.nu_dse__Fee_Template__c, prgmStatusFeeTempExtIdMap.get(programRec.nu_dse__Program_Status__c));
                    }
                }
            }
            
            if (existingFeeTempIdPrgmStatusMap.isEmpty() == False) {
            
                for (nu_dse__Fee_Template__c feeTemp : [SELECT Id, Name, nu_dse__GCS_Fee_Group_Id__c, nu_dse__Settlement_Pct__c, Is_With_ALLG__c,
                                                            nu_dse__Settlement_Fee_Percentage__c FROM nu_dse__Fee_Template__c 
                                                            WHERE Id IN :existingFeeTempIdPrgmStatusMap.keySet() AND nu_dse__Settlement_Pct__c != null
                                                            AND nu_dse__Settlement_Fee_Percentage__c != null]) {
                
                    String settlementValString = feeTemp.nu_dse__Settlement_Pct__c + '-' + feeTemp.nu_dse__Settlement_Fee_Percentage__c + '-' + feeTemp.Is_With_ALLG__c;
                    settlementValFeeTempIdMap.put(settlementValString, feeTemp.Id);
                    estimatedSettlementPercentageSet.add(feeTemp.nu_dse__Settlement_Pct__c);
                    settlementFeePercentageSet.add(feeTemp.nu_dse__Settlement_Fee_Percentage__c);
                }
            }
            
            if (settlementValFeeTempIdMap.isEmpty() == False) {
            
                for (nu_dse__Fee_Template__c feeTemp : [SELECT Id, Name, nu_dse__GCS_Fee_Group_Id__c, nu_dse__Settlement_Pct__c, 
                                                            nu_dse__Settlement_Fee_Percentage__c, Is_With_ALLG__c 
                                                            FROM nu_dse__Fee_Template__c 
                                                            WHERE nu_dse__GCS_Fee_Group_Id__c IN :prgmStatusFeeTempExtIdMap.values()
                                                            AND nu_dse__Settlement_Pct__c IN :estimatedSettlementPercentageSet
                                                            AND nu_dse__Settlement_Fee_Percentage__c IN :settlementFeePercentageSet
                                                            AND Is_With_Versera__c = True]) {
                
                    String settlementValString = feeTemp.nu_dse__Settlement_Pct__c + '-' + feeTemp.nu_dse__Settlement_Fee_Percentage__c + '-' + feeTemp.Is_With_ALLG__c;
                    
                    if (settlementValFeeTempIdMap.containsKey(settlementValString)) {
                    
                        Id feeTempId = settlementValFeeTempIdMap.get(settlementValString);
                        
                        if (existingFeeTempIdPrgmStatusMap.containsKey(feeTempId)) {
                        
                            if (existingFeeTempIdPrgmStatusMap.get(feeTempId) == feeTemp.nu_dse__GCS_Fee_Group_Id__c) {
                        
                                oldFeeTempIdNewFeeTempIdMap.put(feeTempId, feeTemp.Id);
                                
                            } 
                        }
                    }
                }
                
                for (nu_dse__Program__c programRec : programsToProcessList) {
                
                    if (oldFeeTempIdNewFeeTempIdMap.containsKey(programRec.nu_dse__Fee_Template__c)) {
                    
                        programRec.nu_dse__Fee_Template__c = oldFeeTempIdNewFeeTempIdMap.get(programRec.nu_dse__Fee_Template__c);
                    }
                }
            }
        }
    }
    
    public static Set<String> accountFieldsToVersara = new Set<String> {'FirstName', 'LastName', 'nu_dse__SSN__c', 'PersonBirthDate', 
        'Phone', 'PersonMobilePhone', 'PersonMailingStreet', 'PersonMailingCity', 'personMailingState', 'personMailingCountry', 
        'personMailingpostalcode', 'PersonEmail', 'nu_dse__Co_First_Name__c', 'nu_dse__Co_Last_Name__c', 'nu_dse__Co_SSN__c', 'nu_dse__Co_Date_of_Birth__c', 
        'nu_dse__Co_Phone__c', 'nu_dse__Co_Address_Line__c', 'nu_dse__Co_City__c', 'nu_dse__Co_Postal_Code__c', 'nu_dse__Co_State__c', 'nu_dse__CO_Email_Address__c', 
        'nu_dse__External_CFT_ID__c', 'nu_dse__External_GCS_ID__c', 'nu_dse__Status__c', 'nu_dse__GCS_Synced__c','Leadtrac_SSN__c','Leadtrac_Co_SSN__c','LeadTrac_Co_Date_of_Birth__c','LeadTrac_PersonBirthdate__c'};
    
    public static void pushClientDetailsToVersara(Map<Id, nu_dse__Program__c> oldProgramMap, Map<Id, nu_dse__Program__c> newProgramMap) {
    
        Map<Id, CreateClient> programIdCreateClientDetailsMap = new Map<Id, CreateClient>();
        Map<Id, Set<Id>> accountIdProgramIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Id> programIdProcessorIdMap = new Map<Id, Id>();
        Map<Id, nu_dse__Processor__c> processorMap = new Map<Id, nu_dse__Processor__c>();
        Map<Id, Id> programIdFeeTemplateIdMap = new Map<Id, Id>();
        Map<Id, nu_dse__Fee_Template__c> programIdFeeTemplateMap = new Map<Id, nu_dse__Fee_Template__c>(); 
        
        if (newProgramMap != null && newProgramMap.isEmpty() == False) {
            
            Set<String> programLookupFields = getFieldsOfParticularDataTypeOrAll('nu_dse__Program__c', 'REFERENCE');
            system.debug('programLookupFields-->'+programLookupFields);
            
            for (nu_dse__Program__c programRec : newProgramMap.values()) {
            
                if (programRec.nu_dse__Program_Status__c != oldProgramMap.get(programRec.Id).nu_dse__Program_Status__c 
                        && (programRec.nu_dse__Program_Status__c == 'Versara Funding' || programRec.nu_dse__Program_Status__c == 'Graduated') 
                        && programRec.nu_dse__Account__c != null && programRec.nu_dse__Processor__c != null) {
                    
                    nu_dse__Program__c prgmRec = new nu_dse__Program__c();
                    prgmRec = programRec.clone(true);
                    prgmRec.recordTypeId = null;
                    
                    // Setting lookup field values as null
                    if (programLookupFields != null && programLookupFields.isEmpty() == False) {
                    
                        for (String prgmReferenceField : programLookupFields) {
                        
                            prgmRec.put(prgmReferenceField, null);
                        }
                    }
                    system.debug('prgmRec--->'+prgmRec);
                    
                    CreateClient createClientWrapper = new CreateClient();
                    createClientWrapper.Program = prgmRec;
                    programIdCreateClientDetailsMap.put(programRec.Id, createClientWrapper);
                    
                    programIdProcessorIdMap.put(programRec.Id, programRec.nu_dse__Processor__c);
                    
                    if (programRec.nu_dse__Fee_Template__c != null) {
                    
                        programIdFeeTemplateIdMap.put(programRec.Id, programRec.nu_dse__Fee_Template__c);
                    }
                    
                    if (accountIdProgramIdsMap.containsKey(programRec.nu_dse__Account__c) == False) {
                        accountIdProgramIdsMap.put(programRec.nu_dse__Account__c, new Set<Id>());
                    }
                    accountIdProgramIdsMap.get(programRec.nu_dse__Account__c).add(programRec.Id);
                }
            }
            
            if (accountIdProgramIdsMap.isEmpty() == False) {
            
                Set<Id> accountIdSet = new Set<Id>(accountIdProgramIdsMap.keySet());
                
                Set<String> accountLookupFields = getFieldsOfParticularDataTypeOrAll('Account', 'REFERENCE');
                
                String acctQuery = 'SELECT Id ';
                
                if (accountFieldsToVersara.isEmpty() == False) {
                
                    for (String acctField : accountFieldsToVersara) {
                    
                        acctQuery += ', ' + acctField;
                    }
                }
                
                acctQuery += ' FROM Account WHERE Id IN :accountIdSet';
                
                System.debug('acctQuery**: '+ acctQuery);
                for (Account acct : Database.query(acctQuery)) { 
                
                    for (Id prgmRecId : accountIdProgramIdsMap.get(acct.Id)) {
                    
                        if (programIdCreateClientDetailsMap.containsKey(prgmRecId)) {
                        
                            Account acctRec = new Account();
                            acctRec = acct.clone(true);
                            acctRec.recordTypeId = null;
                            
                            // Setting lookup field values as null
                            if (accountLookupFields != null && accountLookupFields.isEmpty() == False) {
                            
                                for (String acctReferenceField : accountLookupFields) {
                                
                                    acctRec.put(acctReferenceField, null);
                                }
                            }
                            CreateClient createClientWrapperInstance = programIdCreateClientDetailsMap.get(prgmRecId);
                            createClientWrapperInstance.Account = acctRec;
                            programIdCreateClientDetailsMap.put(prgmRecId, createClientWrapperInstance);
                        }
                    }
                }
            }
            
            if (programIdCreateClientDetailsMap.isEmpty() == False) {
            
                Set<Id> programIdSet = new Set<Id>(programIdCreateClientDetailsMap.keySet());
                
                Set<String> bankAccountLookupFields = getFieldsOfParticularDataTypeOrAll('nu_dse__Bank_Account__c', 'REFERENCE');
                
                for (nu_dse__Bank_Account__c bankAcctRec : Database.query('SELECT ' + nu_dse.utility.getQueryFields('nu_dse__Bank_Account__c') + ' FROM nu_dse__Bank_Account__c WHERE nu_dse__Program__c IN :programIdSet')) {
                
                    if (programIdCreateClientDetailsMap.containsKey(bankAcctRec.nu_dse__Program__c)) {
                        
                        nu_dse__Bank_Account__c bankAcctRecord = new nu_dse__Bank_Account__c();
                        bankAcctRecord = bankAcctRec.clone(true);
                        
                        // Setting lookup field values as null
                        if (bankAccountLookupFields != null && bankAccountLookupFields.isEmpty() == False) {
                        
                            for (String bankAcctReferenceField : bankAccountLookupFields) {
                            
                                bankAcctRecord.put(bankAcctReferenceField, null);
                            }
                        }
                        
                        CreateClient createClientWrapperInstance = programIdCreateClientDetailsMap.get(bankAcctRec.nu_dse__Program__c);
                        createClientWrapperInstance.BankAccount = bankAcctRecord;
                        programIdCreateClientDetailsMap.put(bankAcctRec.nu_dse__Program__c, createClientWrapperInstance);
                    }
                }
                
                if (programIdProcessorIdMap.isEmpty() == False) {
            
                    processorMap = new Map<Id, nu_dse__Processor__c>([SELECT Id, Name FROM nu_dse__Processor__c WHERE Id IN :programIdProcessorIdMap.values()]);
                }
                
                if (programIdFeeTemplateIdMap.isEmpty() == False) {
                
                    programIdFeeTemplateMap = new Map<Id, nu_dse__Fee_Template__c>([SELECT Id, Name, External_Id__c FROM nu_dse__Fee_Template__c WHERE Id IN :programIdFeeTemplateIdMap.values()]);
                }
                
                for (Id programRecId : programIdCreateClientDetailsMap.keySet()) {
                
                    if (programIdProcessorIdMap.containsKey(programRecId)
                            && processorMap.containsKey(programIdProcessorIdMap.get(programRecId))) {
                    
                        CreateClient createClientWrapperInstance = programIdCreateClientDetailsMap.get(programRecId);
                        createClientWrapperInstance.ProcessorName = processorMap.get(programIdProcessorIdMap.get(programRecId)).Name;
                        programIdCreateClientDetailsMap.put(programRecId, createClientWrapperInstance);
                    }
                    
                    if (programIdFeeTemplateIdMap.containsKey(programRecId)
                            && programIdFeeTemplateMap.containsKey(programIdFeeTemplateIdMap.get(programRecId))) {
                    
                        CreateClient createClientWrapperInstance = programIdCreateClientDetailsMap.get(programRecId);
                        createClientWrapperInstance.FeeTemplateExtId = programIdFeeTemplateMap.get(programIdFeeTemplateIdMap.get(programRecId)).External_Id__c;
                        programIdCreateClientDetailsMap.put(programRecId, createClientWrapperInstance);
                    }
                }
                pushClientDetailsFuture(JSON.serialize(programIdCreateClientDetailsMap.values()));
            }
        }
    }
    
    @future(callout=true)
    public static void pushClientDetailsFuture(String createClientDetailsString) {
    
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        
        if (String.isNotBlank(createClientDetailsString)) {
        
            system.debug('createClientDetailsString-->'+createClientDetailsString);
            
            try {
            
                String accessToken = getAccesTokenOfVersara();
                
                if (String.isNotBlank(accessToken)) {
                
                    Versara_Settings__c versaraSettings = Versara_Settings__c.getInstance();
                    String endpointInstanceURL, endPointURL;
                    
                    if (versaraSettings != null) {
                    
                        endpointInstanceURL = versaraSettings.Endpoint_Instance_URL__c;
                        
                        if (endpointInstanceURL != null) {
                        
                            endPointURL = endpointInstanceURL + '/services/apexrest/CreateClientDetails';
                        }
                    }
                    system.debug('endPointURL-->'+endPointURL);
                    
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Authorization', 'Bearer ' + accessToken);
                    req.setEndpoint(endPointURL);
                    req.setMethod('POST');
                    req.setHeader('content-type', 'application/json');
                    req.setBody(createClientDetailsString);
                    
                    Http http = new Http();
                    HttpResponse res = http.send(req);
                    String strResponse = res.getBody();
                    system.debug('strResponse-->'+strResponse);
                    
                    if (String.isNotBlank(strResponse)) {
                    
                        List<CreateClientResponse> createClientResList = (List<CreateClientResponse>)JSON.deserialize(strResponse, List<CreateClientResponse>.class);
                        
                        if (createClientResList != null && createClientResList.isEmpty() == False) {
                        
                            for (CreateClientResponse createClientRes : createClientResList) {
                            
                                nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ProgramHandler.PushClientDetailsToVersara', 
                                                 nu_dse__Message__c = createClientRes.errorMessage, nu_dse__User_Context__c = UserInfo.getName()); 
                                
                                errorLogList.add(errorlog);
                            }
                        }
                    }
                }
            
            } catch(Exception e) {
            
                 nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'ProgramHandler.PushClientDetailsToVersara', 
                                                     nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                                                     nu_dse__User_Context__c = UserInfo.getName());
                
                 errorLogList.add(errorlog);
            }
            
            if (errorLogList.isEmpty() == False) {
            
                insert errorLogList;
            }
        }
    }
    
    public static String getAccesTokenOfVersara() {
        
        String clientId, clientSecretKey, refreshToken, endPointURL, accessToken;
        
        try {
            
            Versara_Settings__c versaraSettings = Versara_Settings__c.getInstance();
            
            if(versaraSettings != null) {
            
                clientId = versaraSettings.Client_Id__c;
                clientSecretKey = versaraSettings.Client_Secret__c;
                refreshToken = versaraSettings.Refresh_Token__c;
                endPointURL = versaraSettings.End_Point_URL__c;
            }
            
            if(String.isNotBlank(clientId) && String.isNotBlank(clientSecretKey) 
                && String.isNotBlank(refreshToken) && String.isNotBlank(endPointURL)) {
            
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndPoint(endPointURL); 
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                
                String body = 'grant_type=refresh_token'
                            + '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') 
                            + '&client_secret=' + EncodingUtil.urlEncode(clientSecretKey, 'UTF-8')
                            + '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8');  
                            
                req.setBody(body);
                System.debug('***** req.body' + req.getBody());
                
                Http http = new Http();  
                HTTPResponse res = http.send(req);  
                
                System.debug('**** response' + res.getBody());
                System.debug('STATUS:'+res.getStatus());
                System.debug('STATUS_CODE:'+res.getStatusCode());
                
                if(res.getStatusCode() == 200) {
                
                    ResponseWrapper responseWrapperInstance = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
                    accessToken = responseWrapperInstance.access_token;
                }
                System.debug('**** accessToken --> ' + accessToken);
            }
        } catch(Exception e) {
        
            throw e;
        }
        return accessToken;
    }
    
    public static Set<String> getFieldsOfParticularDataTypeOrAll(String objectName, String type) {
    
        Set<String> fieldsSet = new Set<String>();
        
        if (String.isNotBlank(objectName)) {
        
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String>{objectName});
            
            if (results != null && results.isEmpty() == False) {
            
                if (String.isNotBlank(type)) {
                
                    for (Schema.SObjectField sobjDescription : results[0].fields.getMap().values()) {
                    
                        if (type == String.valueOf(sobjDescription.getDescribe().getType())) {
                        
                            if (type == 'REFERENCE' && sobjDescription.getDescribe().isCustom() == True
                                    /*&& sobjDescription.getDescribe().isDefaultedOnCreate() == False*/) {
                            
                                fieldsSet.add(sobjDescription.getDescribe().getName());
                            }
                        } 
                    }
                } else {
                
                    for (Schema.SObjectField sobjDescription : results[0].fields.getMap().values()) {
                    
                        fieldsSet.add(sobjDescription.getDescribe().getName());
                    }
                }
            }
        }
        return fieldsSet;
    }
    
    public class CreateClient {
        
        public Account Account;
        public nu_dse__Bank_Account__c BankAccount;
        public nu_dse__Program__c Program;
        public String ProcessorName;
        public String FeeTemplateExtId;
    }
    
    public class createClientResponse {
        
        public Id AccountId;
        public Boolean isSuccessful;
        public String errorMessage;
    }
    
    public class ResponseWrapper {
    
        public String access_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String signature;        
    }
    
    /*public static Set<String> accountFieldsToLeadTracSet = new Set<String> {'FirstName', 'LastName', 'nu_dse__SSN__c', 'PersonBirthDate', 
        'Phone', 'PersonMobilePhone', 'PersonMailingStreet', 'PersonMailingCity', 'personMailingState', 'personMailingCountry', 
        'personMailingpostalcode', 'PersonEmail', 'nu_dse__Co_First_Name__c', 'nu_dse__Co_Last_Name__c', 'nu_dse__Co_SSN__c', 'nu_dse__Co_Date_of_Birth__c', 
        'nu_dse__Co_Phone__c', 'nu_dse__Co_Address_Line__c', 'nu_dse__Co_City__c', 'nu_dse__Co_Postal_Code__c', 'nu_dse__Co_State__c', 'nu_dse__CO_Email_Address__c', 
        'nu_dse__External_CFT_ID__c', 'nu_dse__External_GCS_ID__c', 'nu_dse__Status__c','nu_dse__Work_Phone__c','PersonHomePhone' ,'LeadTrac_Co_Date_of_Birth__c', 'LeadTrac_PersonBirthdate__c','Leadtrac_SSN__c','Leadtrac_Co_SSN__c'};*/
    
    public static void createOrUpdateClientInLeadTrac(Map<Id, nu_dse__Program__c> oldProgramMap, List<nu_dse__Program__c> newProgramList) {
    
        List<LeadTrac.CreateUpdateClients> createUpdateClientsList = new List<LeadTrac.CreateUpdateClients>();
        Map<Id, nu_dse__Program__c> programMap = new Map<Id, nu_dse__Program__c>();
        List<nu_dse__Program__c> programsToProcessList = new List<nu_dse__Program__c>();
        Set<Id> feeTempIdSet = new Set<Id>();
        Set<Id> eligibleFeeTempIdSet = new Set<Id>();
        Map<Id, Id> accountIdProgramIdMap = new Map<Id, Id>();
        Set<Id> accountIdSet = new Set<Id>();
        set<id> programIds = new Set<Id>(); 
        Map<Id, nu_dse__Bank_Account__c> program_bankaccount = new Map<Id, nu_dse__Bank_Account__c>();
        Map<String, List<String>> dataMappingFieldsListMap = new Map<String, List<String>>();
        List<String> datamappingNameList = LeadTrac.datamappingNameList; 
        
        if (newProgramList != null && newProgramList.isEmpty() == False) {
        
            for (nu_dse__Program__c prgmRec : newProgramList) {
            
                // Updated on Jan22-2017
                if ((prgmRec.nu_dse__Program_Status__c == 'Versara Funding' || prgmRec.nu_dse__Program_Status__c == 'Graduated') 
                        && prgmRec.nu_dse__Program_Status__c != oldProgramMap.get(prgmRec.Id).nu_dse__Program_Status__c
                        && prgmRec.nu_dse__Account__c != null) {
                    
                    accountIdSet.add(prgmRec.nu_dse__Account__c);
                    accountIdProgramIdMap.put(prgmRec.nu_dse__Account__c, prgmRec.Id);
                    programMap.put(prgmRec.Id, prgmRec); 
                    programIds.add(prgmRec.id);
                    
                }
            }
            
            if (programMap.isEmpty() == False) {
                
                system.debug('datamappingNameList-->'+datamappingNameList);
                
                if (datamappingNameList != null && datamappingNameList.isEmpty() == False) {
                
                    for (nu_dse__Field_mapping__c fieldMapping : [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Data_Mapping__r.Name 
                                                                    FROM nu_dse__Field_mapping__c WHERE nu_dse__Data_Mapping__r.Name IN :datamappingNameList
                                                                    AND nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c != null]) {
                    
                        if (dataMappingFieldsListMap.containsKey(fieldMapping.nu_dse__Data_Mapping__r.Name) == False) {
                        
                            dataMappingFieldsListMap.put(fieldMapping.nu_dse__Data_Mapping__r.Name, new List<String>());
                        }
                        dataMappingFieldsListMap.get(fieldMapping.nu_dse__Data_Mapping__r.Name).add(fieldMapping.nu_dse__Source_Field__c);
                    }
                }
                
                if (dataMappingFieldsListMap.isEmpty() == False && dataMappingFieldsListMap.containsKey('BankAccountToLeadTrac')) {
                
                    String bankAcctQuery = 'SELECT Id, nu_dse__Program__c';
                    
                    for (String bankAcctField : dataMappingFieldsListMap.get('BankAccountToLeadTrac')) {
                    
                        if (bankAcctField == 'Id' || bankAcctField == 'nu_dse__Program__c') {
                            continue;
                        }
                        bankAcctQuery += ', ' + bankAcctField;
                    }
                    bankAcctQuery += ' FROM nu_dse__Bank_Account__c WHERE nu_dse__Program__c IN :programIds';
                    system.debug('bankAcctQuery--->'+bankAcctQuery);
                
                    for (nu_dse__Bank_Account__c  bankAcctRec : Database.query(bankAcctQuery)) {
                        
                        program_bankaccount.put(bankAcctRec.nu_dse__Program__c,bankAcctRec);
                    }
                }
            }
            
            if (accountIdSet.isEmpty() == False) {
            
                if (dataMappingFieldsListMap.isEmpty() == False && dataMappingFieldsListMap.containsKey('AccountToLeadTrac')) {
                
                    String query = 'SELECT Id';
                    
                    for (String accountField : dataMappingFieldsListMap.get('AccountToLeadTrac')) {
                    
                        if (accountField == 'Id') {
                            continue;
                        }
                        query += ', ' + accountField;
                    }
                    query += ' FROM Account WHERE Id IN :accountIdSet';
                    System.debug('acctQuery**: '+ query);
                    
                    for (Account acct : Database.query(query)) {
                
                        if (accountIdProgramIdMap.containsKey(acct.Id)) {
                        
                                Id programId = accountIdProgramIdMap.get(acct.Id);
                            
                            if (programMap.containsKey(programId)) {
                            
                                LeadTrac.CreateUpdateClients createUpdateClientsInstance = new LeadTrac.CreateUpdateClients();
                                createUpdateClientsInstance.acctRec = acct;
                                createUpdateClientsInstance.programRec = programMap.get(programId);
                                if(program_bankaccount.containsKey(programId)){
                                    
                                    createUpdateClientsInstance.bankAccount = program_bankaccount.get(programId);
                                }
                                createUpdateClientsList.add(createUpdateClientsInstance);
                            }
                        }
                    }
                } 
            }
            
            if (createUpdateClientsList.isEmpty() == False) {
            
                createOrUpdateClientInLeadTracFuture(JSON.serialize(createUpdateClientsList));
            }
        }
    }
    
    @future(callout=true) 
    public static void createOrUpdateClientInLeadTracFuture(String createUpdateClientsString) {
    
        if (String.isNotBlank(createUpdateClientsString)) {
        
            List<LeadTrac.CreateUpdateClients> createUpdateClientsList = (List<LeadTrac.CreateUpdateClients>)JSON.deserialize(createUpdateClientsString, List<LeadTrac.CreateUpdateClients>.class);
            
            if (createUpdateClientsList.isEmpty() == False) {
            
                LeadTrac.createOrUpdateClient(createUpdateClientsList);
            }
        }
    }

}