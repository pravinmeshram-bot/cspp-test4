public Class TestRecordCreator {

     public static Account createAccount (String lstName, Id recordTypeId) {
        //Changes made by Mayur to populate only Name and not First and Last Name as this is creditor account.
        
        Account accountInstance = new Account(FirstName = 'Test', 
                                              LastName = lstName,
                                              //Below line is added on Sept 4, 2019 to fix the Validation Error
                                              Phone  = '9845764876',
                                              RecordTypeId = recordTypeId);
        return accountInstance;
    }
    
    //Added below code by Mayur
    public static Account createAccountPer (String lstName, Id recordTypeId) {
        //Changes made by Mayur to populate only Name and not First and Last Name as this is creditor account.
        
        Account accountInstancePer = new Account(FirstName = 'Test', 
                                              LastName = lstName,
                                              //Below line is added on Sept 4, 2019 to fix the Validation Error
                                              Phone  = '9845764876',
                                              RecordTypeId = recordTypeId);
        return accountInstancePer;
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
        
        nu_dse__TradeLine__c trdLine = new nu_dse__TradeLine__c(
            //nu_dse__Original_Creditor__c = AccId,
                                                nu_dse__Program__c = programId,
                                                nu_dse__Percentage__c = 10,
                                                nu_dse__Original_Debt__c = 10000,
                                                //Below line is added on Sept 4, 2019 to fix the Validation Error on S20-35
                                                SFS_Current_Balance__c = 10000,
                                                nu_dse__Original_Account_Number__c = '8746876756');
        return trdLine;
    }
    
    
      public static nu_dse__Processor__c createProcessor(String processorName){
        
        nu_dse__Processor__c newProcessor = New nu_dse__Processor__c(Name = processorName, nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT');
        return newProcessor;
    }
     public static nu_dse__Program__c createProgram(Id accountId, Id processorId) {
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c(nu_dse__Account__c = accountId, 
                                                                    nu_dse__Processor__c = processorId,
                                                                    
                                                                    nu_dse__Payment_Frequency__c = 'Monthly',
                                                                    nu_dse__Program_Length__c = 2);
        return programInstance;
    }
    
     public static nu_dse__Payment__c createPayment(Id programId, String transactionStatus, String paymentType, Id recordTypeId, Id offerId){
        
        nu_dse__Payment__c newPayment = new nu_dse__Payment__c(nu_dse__Program__c = programId, 
                                                                nu_dse__Transaction_Status__c = transactionStatus, 
                                                                nu_dse__Payment_Type__c = paymentType, 
                                                                nu_dse__Schedule_Date__c = system.today() + 1, 
                                                                nu_dse__Amount__c = 500, 
                                                                RecordTypeId = recordTypeId, 
                                                                nu_dse__Offer__c = offerId);
        return newPayment;
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
    
    public static Account createAccount(Id recTypId) {
       
       Account ac = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), 
                                   Phone  = '9845764876', PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', 
                                   PersonMailingCity = 'city', personMailingState = 'AL', personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', 
                                   PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', 
                                   RecordTypeId = recTypId);
       return ac;
    } 
    
       public static Velocify_Settings__c  createVelocifySettings(){
        Velocify_Settings__c settings =  Velocify_Settings__c.getInstance(); 
        settings.Username__c='test@gmail.com';
        settings.Password__c = 'test'; 
        settings.SetupOwnerId = UserInfo.getUserId(); 
        
            
        return settings; 
            }
    
    public static Account createCreditorAccount(Id recTypId) {
    
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403', BillingCountry = 'US',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = recTypId);
        return acct;
    }
    
    public static nu_dse__Data_Mapping__c createDataMapping(String dataMapName, String sourceObject, String targetObject) {
            
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c ( Name = dataMapName,
                                                                                    nu_dse__Source_sObject__c = sourceObject,
                                                                                    nu_dse__Target_sObject__c = targetObject );
        return dataMappingInstance;
    }
    
    public static Batch_Execution__c createBatchExecution(Id dataMappingId, Id sObjectcId) {
        
        DateTime scheduleDateTime = System.Now().addMinutes(2);
        
        Batch_Execution__c batchExecutionInstance = new Batch_Execution__c ( Data_Mapping__c = dataMappingId,
                                                                             Is_Active__c = true,
                                                                             CRON_Expression__c = '0 '+scheduleDateTime.minute()+' '+scheduleDateTime.hour()+' * * ?',
                                                                             Filter_Criteria__c = 'Id = \''+sObjectcId+ '\'' );
        return batchExecutionInstance;
    }
    
    public static nu_dse__Field_mapping__c createFieldMapping(Id dataMappingId, String sourceField, String targetField) {
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c ( nu_dse__Data_Mapping__c = dataMappingId,
                                                                                       nu_dse__Source_Field__c = sourceField,
                                                                                       nu_dse__Target_Field__c = targetField );
        return fieldMappingInstance;
    }
    
    public static nu_dse__Prospect__c createProspect() {
        
        nu_dse__Prospect__c prospectInstance = new nu_dse__Prospect__c( nu_dse__Last_name__c = 'Testing', 
                                                                        nu_dse__first_name__c = 'Prospect' );
        return prospectInstance;
    }
    
    public static nu_dse__Program__c createProgram() {
    
        nu_dse__Program__c programInstance = new nu_dse__Program__c ();
        
        return programInstance;
    }
    
    public static nu_dse__Program__c createProgram(Id accId, Id ProcessorId, String processorStatus) {
    
        nu_dse__Program__c programInstance = new nu_dse__Program__c (nu_dse__Account__c = accId, nu_dse__Processor__c = ProcessorId, nu_dse__Processor_Status__c = processorStatus);
        
        return programInstance;
    }
    
    public static nu_dse__Processor__c createGCSProcessor() {
        
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'GCS', nu_dse__Type__c = 'GCS');
        return processorInstance;
    }
    
    
    public static Task createTask(Id whatId) {
        
        Task taskInstance = new Task( Subject = 'Testing ', 
                                      Description = 'to use it in test class', 
                                      WhatId = whatId, 
                                      Status = 'In Progress',
                                      ActivityDate = System.today() );
        return taskInstance;
    }
    
    public static nu_dse__Payment__c createPayment(Id prospectId, Id recordTypeId, String paymentType) {
        
        nu_dse__Payment__c paymentInstance = new nu_dse__Payment__c( nu_dse__Payment_Type__c = paymentType,
                                                                     nu_dse__Schedule_Date__c = system.today() + 1, 
                                                                     nu_dse__Amount__c = 500,
                                                                     nu_dse__Transaction_Status__c = 'Pending',
                                                                     nu_dse__Prospect__c = prospectId,
                                                                     RecordTypeId = recordTypeId);
        
        return paymentInstance;
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
    
    public static Portfolio__c createportfolio() {
        
        Portfolio__c portfolioinstance = new Portfolio__c ( Name = 'Portfolio Test Record'
        );
        return portfolioinstance ;
    }
    
    public static nu_dse__Communication_Template__c createcommuncation (String recordtypeName) {
    
        nu_dse__Communication_Template__c communicationinstance = new nu_dse__Communication_Template__c(RecordTypeId = getRecordTypeId ('nu_dse__Communication_Template__c' ,'Voice Broadcast'),Name = 'Test template'
        );
        return communicationinstance;
    }
    public static Document createdocument (String Name) {
        
        document documentInstance = new document(ContentType = 'application/pdf',IsPublic = true,Name = name);

        return documentInstance;
    }
    public static Voice_Recordings__c createVoiceRecording(Id communicationTempId, Id portfolioId, String twilioAnswerType) {
        
        Voice_Recordings__c voiceRecordingInstance = new Voice_Recordings__c(Communication_Template__c = communicationTempId, 
                                                         Recording_Name__c = 'Test voice record',
                                                         Portfolio__c = portfolioId,
                                                         twilio_answer_type__c = twilioAnswerType);
        return voiceRecordingInstance;
    }
    
    // Below classes Added on May 7
    
    public static nu_dse__Communication_Notification_Settings__c createCommunicationNotificationSettings() {
    
        nu_dse__Communication_Notification_Settings__c communicationSettings = new nu_dse__Communication_Notification_Settings__c(
                                                                                                      nu_dse__Email_Daily_Limit__c = 10, 
                                                                                                      nu_dse__Email_Hourly_Limit__c = 10, 
                                                                                                      nu_dse__SMS_Daily_Limit__c = 10, 
                                                                                                      nu_dse__SMS_Hourly_Limit__c = 10, 
                                                                                                      nu_dse__Voice_BC_Daily_Limit__c = 10, 
                                                                                                      nu_dse__Voice_BC_Hourly_Limit__c =10 );
        return communicationSettings;
    }
    
    public static nu_dse__Holidays_Settings__c createholidaySetting() {
    
        nu_dse__Holidays_Settings__c holidaySetting = new nu_dse__Holidays_Settings__c(nu_dse__Consider_Holiday__c = True, 
                                                                                       nu_dse__Consider_WeekEnd__c = True);
        return holidaySetting;
    }
    
    public static nu_dse__Processor__c createProcessor(){
        
        nu_dse__Processor__c NewProcessor = New nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT');
        return NewProcessor;
    }
    
    public static nu_dse__Payment__c createPayments(Id programId) {
    
        nu_dse__Payment__c newPayment = new nu_dse__Payment__c(nu_dse__Program__c = programId, nu_dse__Schedule_Date__c = system.today() + 1, nu_dse__Amount__c = 500);
        return newPayment;
    }
    
    public static nu_dse__Communication_Template__c createCommunicationTemplate(String actionType) {
    
        nu_dse__Communication_Template__c comTemp = new nu_dse__Communication_Template__c(nu_dse__Action_Type__c = actionType);
        return comTemp;
    }
    
    public static Task createTask(Id ownerIdVal, Id whatIdVal) {
    
        Task taskRec = new Task(OwnerId = ownerIdVal, WhatId = whatIdVal, Subject = 'Test', Description = 'Test Description', Status='In Progress', Priority='Normal', ActivityDate = system.today());
        return taskRec;
    }
    
    public static portfolio__c createPortfolio(String phoneNumber) {
        
        Portfolio__c portfolioInstance = new Portfolio__c(Support_Email__c = 'support@test.com', 
                                                               Support_Phone_Number__c = phoneNumber); //'5618889140'
        return portfolioInstance;
    }
    
    //Below changes are added on Sept 4, 2019
    public static User createUser(String profileName) {
        
        User userInstance = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
             Attorney_Admin__c = false,
             FirstName = 'First',
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        return userInstance;
    }
}