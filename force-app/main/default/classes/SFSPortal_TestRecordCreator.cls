public Class SFSPortal_TestRecordCreator {

    public static Account createAccount (String lstName, Id recordTypeId) {
        
        Account accountInstance = new Account(FirstName = 'Test',
                                              LastName = lstName,
                                              RecordTypeId = recordTypeId,
                                              nu_dse__Home_Phone__c = '5617625362');
        return accountInstance;
    }
    
    public static Account createCreditorAccount (String name, Id recordTypeId) {
        
        Account accountInstance = new Account(Name = name,
                                              RecordTypeId = recordTypeId,
                                              BillingStreet = 'test',
                                              BillingCity = 'test',
                                              BillingState = 'test',
                                              BillingPostalCode = '12231',
                                              BillingCountry = 'us');
        return accountInstance;
    }
    
    public static nu_dse__Processor__c  createProcessor() {
        
        nu_dse__Processor__c processorInstance = new nu_dse__Processor__c(Name = 'CFT',
                                                                          Processor_Name__c = 'CFT',
                                                                          nu_dse__Type__c = 'CFT',
                                                                          nu_dse__Endpoint__c = 'www.google.com',
                                                                          nu_dse__Subscriber_Id__c = '12345',
                                                                          nu_dse__Subscriber_Fee_Id__c = '12345',
                                                                          nu_dse__Username__c = 'test@test.com',
                                                                          nu_dse__Password__c = 'test123');
        return processorInstance;
    }
    
    public static nu_dse__Creditor_Processor_Info__c createCreditorProcessorInfo(Id processorId, Id creditorId) {
        
        nu_dse__Creditor_Processor_Info__c creditorProcessorInfoInstance = new nu_dse__Creditor_Processor_Info__c(
                                                                          nu_dse__Account__c = creditorId,
                                                                          nu_dse__Payee_Id__c = '123456',
                                                                          nu_dse__Processor__c = processorId );
        return creditorProcessorInfoInstance;
    }
    
    public static nu_dse__Bank_Account__c createBankAccount(Id programId) {
        
        nu_dse__Bank_Account__c bankAccountInstance = new nu_dse__Bank_Account__c(nu_dse__Program__c = programId,
                                                                                  nu_dse__Bank_Name__c = 'Test Bank', 
                                                                                  nu_dse__Account_Type__c = 'Saving', 
                                                                                  nu_dse__Bank_Account_Number__c = '1245225', 
                                                                                  nu_dse__Routing_Number__c = '41414141',
                                                                                  nu_dse__Holder_s_Name__c = 'TestHolderName');
        
        return bankAccountInstance;
    }
     
    public static nu_dse__Offer__c createoffer(Id programId, Id tradeId, Integer offerAmount, Integer programFee, Integer numOfFeePaymnts, Integer numOfPaymnts) {
        
        nu_dse__Offer__c offerInstance = new nu_dse__Offer__c(nu_dse__Program__c = programId, 
                                                                  nu_dse__TradeLine__c = tradeId, 
                                                                  nu_dse__Offer_Amount__c = offerAmount, 
                                                                  nu_dse__Program_Fee__c = programFee, 
                                                                  nu_dse__number_of_Fee_payments__c = numOfFeePaymnts, 
                                                                  nu_dse__Number_of_Payments__c = numOfPaymnts, 
                                                                  nu_dse__First_Payment_Date__c = System.today().addDays(1),
                                                                  nu_dse__Program_Fee_Start_Date__c= System.today().addDays(1));
        
        return offerInstance;
    }
    
    public static nu_dse__TradeLine__c createTradeLine(Id AccId, Id programId){
        
        nu_dse__TradeLine__c trdLine = new nu_dse__TradeLine__c(nu_dse__Original_Creditor__c = AccId,
                                                nu_dse__Program__c = programId,
                                                nu_dse__Percentage__c = 10,
                                                nu_dse__Original_Debt__c = 10000,
                                                nu_dse__Original_Account_Number__c = '8746876756',
                                                SFS_Current_Balance__c = 500);
        return trdLine;
    }
        
    public static nu_dse__Program__c createProgram(Id accountId, Id processorId) {
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c(nu_dse__Account__c = accountId, 
                                                                    nu_dse__Processor__c = processorId,
                                                                    nu_dse__Payment_Frequency__c = 'Monthly',
                                                                    nu_dse__Program_Length__c = 2);
        return programInstance;
    }
    
     public static Box_settings__c createBoxsettings() {
        
        Box_settings__c boxInstance = new Box_settings__c(name = 'box', Folder_Endpoint__c = 'https://api.box.com/2.0/folders', 
                                                            Client_id__c = 'bavh341hkej16rw7424nmkidvwc0i6ks', 
                                                            Client_Secret__c = 'rd0Sl7kuSZvd9BrRvCGPfQaBz0CruNvo', 
                                                            access_token__c = '1aMun9nbCuKEryECskLX4Bp8nDX2fwcy', 
                                                            Refresh_Token__c = 'jx5QziOZ6DMY8QzXYIvtiYORO78Q4ZljAp6T0gt4v5t0fYS50XCdlBehb5deUW1F', 
                                                            expires__c = '4077', 
                                                            lastRefresh__c = '1507031579432');

        return boxInstance;
    }
    
   
    public static nu_dse__Program__c createProgram() {
    
        nu_dse__Program__c programInstance = new nu_dse__Program__c ();
        
        return programInstance;
    }
    
    
    public static Task createTask(Id whatId) {
        
        Task taskInstance = new Task( Subject = 'Testing ', 
                                      Description = 'to use it in test class', 
                                      WhatId = whatId, 
                                      Call_Type__c = 'Strategy Calls',
                                      Status = 'In Progress',
                                      ActivityDate = System.today() );
        return taskInstance;
    }
    
    
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        Id recordTypeId;
        
        if (recordTypeMap.containsKey(recordTypeName)) {
            
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
            System.debug('**recordTypeId'+recordTypeId);
        }
        
        return recordTypeId;
        
    }
    
    
    public static nu_dse__Payment__c createPayments(Id programId) {
    
        nu_dse__Payment__c newPayment = new nu_dse__Payment__c(nu_dse__Program__c = programId, nu_dse__Schedule_Date__c = system.today() + 1, nu_dse__Amount__c = 500);
        return newPayment;
    }
    
    public static Portal_Settings__c createPortalEnhancement(Id portfolioId, Id recordTypeId) {
    
        Portal_Settings__c newPortal = new Portal_Settings__c(Action_Button_Color__c = 'Red', Is_Active__c = true, Logo_Name__c = 'TimberlineLoginLogo', 
                                                            Portfolio__c = portfolioId, Type__c = 'Background Image', 
                                                            Value__c = 'TimberlineLoginBackgroun', recordTypeId = recordTypeId);
        return newPortal;
    }
    
    public static Portal_Settings__c createPortalSettingForTaskInfo(Id portfolioId, Id recordTypeId, String CaseType) {
    
        Portal_Settings__c newPortal = new Portal_Settings__c(Is_Active__c = true, Portfolio__c = portfolioId, recordTypeId = recordTypeId, 
                                                              Call_Type__c = CaseType, Call_Type_Description__c = 'Test' );
        return newPortal;
    }
    
    public static portfolio__c createPortfolio(String phoneNumber) {
        
        Portfolio__c portfolioInstance = new Portfolio__c(Support_Email__c = 'support@test.com', Excela_Email__c='test@test.com',
                                                               Support_Phone_Number__c = phoneNumber,Domain_URL__c = 'www.google.com',
                                                               Active_Status__c = TRUE); //'5618889140'
        return portfolioInstance;
    }
    
    public static User createCommunityUser(Id contactId) {
        
        Id proflieId = [select id from profile where name='Customer Community User'].id;
        
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = proflieId, PostalCode = '54896', country='United States',IsActive =true,
                ContactId = contactId,MobilePhone = '8529637415', State = 'TN',
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        return user1;
    
    }
    
    public static ContentVersion createContentVersion() {
    
        ContentVersion contentVersionInstance = new ContentVersion(Title = 'xxxx',PathOnClient='image.jpg',VersionData = EncodingUtil.base64Decode('Test'));
        return contentVersionInstance;
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id documentId, Id linkedEntityId) {
    
        ContentDocumentLink contentLink = new ContentDocumentLink(ContentDocumentId = documentId, LinkedEntityId = linkedEntityId, ShareType = 'V', Visibility = 'AllUsers');
        return contentLink;
    }
    
    public static nu_dse__Group_Task__c groupTaskInstance(String relatedtoId, String subject) {
    
        return new nu_dse__Group_Task__c(Creditor_Name__c = 'test creditor', Creditor_Balance__c = 45, nu_dse__Subject__c = subject,
            nu_dse__Related_To__c = relatedtoId, Decision_Source__c = 'Portal'
        );
    }
    
    public static TwilioConfig__c getTwilioConfig() {
    
        return new TwilioConfig__c(AccountSid__c = 'test Account Id', ApplicationSid__c = 'testapplicationId', AuthToken__c = 'testauthtoken');
    }
}