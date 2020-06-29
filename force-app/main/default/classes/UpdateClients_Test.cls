@isTest
public class UpdateClients_Test/* implements HttpCalloutMock*/ {

    public static String feeItemSObj = nu_dse__Fee_Item__c.sObjectType.getDescribe().getName();
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
        
    /*public UpdateClients_Test(Integer code, String status, String body,Map<String, String> responseHeaders){
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }*/
    
    static testMethod void testUpdateClients() {
    
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        nu_dse__Processor__c processor = new nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, External_Id__c = 'CFT', 
                                         nu_dse__Monthly_Service_Fee__c = 100);
        insert processor;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', nu_dse__Settlement_Pct__c = 10, nu_dse__Maximum_Program_Length__c = 20,
                                          External_Id__c = 'Test_FeeTempalteData', External_Fee_Id__c = '123433');
        insert feeTemp;
        
        List<RecordType> feeRectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Settlement_Fee' AND 
                       SObjectType =: feeItemSObj AND isActive = True];
                       
        if (!feeRectypeList.isEmpty()) {   
                   
            nu_dse__Fee_Item__c feeItem = new nu_dse__Fee_Item__c(Name = 'Test', nu_dse__Fee_Template__c = feeTemp.Id,
                                          nu_dse__Fee_Amount__c = 100, nu_dse__Percent__c =10, RecordTypeId = feeRectypeList[0].Id);
            insert feeItem;
        }
        
        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>();
        nu_dse__Prospect__c prospect = new nu_dse__Prospect__c(nu_dse__First_Name__c = 'Test', nu_dse__MI__c = 'N', nu_dse__Last_name__c = 'Record',
                                       nu_dse__Home_Phone__c = '7854125478', nu_dse__Cell_Phone__c = '7854785421', nu_dse__Work_Phone__c = '7854128964',
                                       nu_dse__Address_Line_1__c = 'Test', nu_dse__City__c = 'Clio', nu_dse__State__c = 'AK', 
                                       //Changes made by Mayur for ND-86
                                       nu_dse__Postal_Code__c = '78542', nu_dse__SSN_ENC__c = '784-89-7854', nu_dse__Co_SSN__c= '123-45-6789', nu_dse__Email_Address__c = 'a@test.com',nu_dse__Dob__c= System.today().addYears(-10),
                                       nu_dse__CO_First_Name__c = 'CoTest', nu_dse__CO_MI__c = 'N', nu_dse__CO_Last_Name__c = 'Record', 
                                       nu_dse__CO_Home_Phone__c = '7854123652', nu_dse__CO_Cell_Phone__c = '7854123652', 
                                       nu_dse__CO_Work_Phone__c = '7854125412', nu_dse__CO_ADDLINE1__c = 'Test', nu_dse__CO_ST__c = 'Clio',
                                       nu_dse__CO_POSTAL__c = '78412', 
                                       nu_dse__Initial_Debit_Date__c=System.today(),
                                       nu_dse__Recurring_Payment_Day__c= 15
                                                              );
        prospectList.add(prospect);
        insert prospectList;
        
        prospect.Upd_External_Id__c = prospectList[0].Id; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
        update prospectList;
        
        List<nu_dse__Bank_Account__c> bankAccountList = new List<nu_dse__Bank_Account__c>();
        nu_dse__Bank_Account__c bankAccount = new nu_dse__Bank_Account__c(nu_dse__Bank_Account_Number__c = '784125896541',
                                              nu_dse__Holder_s_Name__c = 'Test', nu_dse__Account_Type__c = 'SAVING', External_Id__c = '252525',
                                              nu_dse__Routing_Number__c = '102000021', nu_dse__Prospect__c = prospectList[0].Id);
        bankAccountList.add(bankAccount);
        insert bankAccountList;
        
        List<nu_dse__Tradeline__c> tradelineList = new List<nu_dse__Tradeline__c>();
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(nu_dse__New_Account_Number__c = '785412569853', nu_dse__Sales_Creditor_Name__c = 'Test',
                                         nu_dse__Current_Balance__c = 1000, External_Id__c = 'Test_TradelineData', nu_dse__Original_Debt__c = 10000,
                                         nu_dse__Percentage__c = 10, nu_dse__Debt_Owner__c = 'Client', nu_dse__Prospect__c = prospectList[0].Id);
        tradelineList.add(tradeline);
        insert tradelineList;
        
        List<nu_dse__Financial_Profile__c> financialProfileList = new List<nu_dse__Financial_Profile__c>();
        nu_dse__Financial_Profile__c financialProfile = new nu_dse__Financial_Profile__c(nu_dse__Student_Loans__c = 1500,
                                                        nu_dse__Household_Items__c = 300, nu_dse__Clothing__c = 500,
                                                        nu_dse__Laundry_Dry_Cleaning__c = 100, nu_dse__Source_Of_Additional_Financial_Assistanc__c = 'Test',
                                                        nu_dse__Housing_Type__c = 'Apartment', nu_dse__afford_to_put_aside__c = 500,
                                                        nu_dse__Alimony_Child_Support_Payments__c = 500, nu_dse__Amount_Owed_on_Home__c = 'Test',
                                                        nu_dse__Annuities__c = 'Test', nu_dse__Automobile_Insurance__c = 200, nu_dse__Back_Taxes__c = 300,
                                                        nu_dse__Balance_of_401K__c = 100, nu_dse__Bankruptcy_Type__c = 'Test', 
                                                        nu_dse__Budgeted_Monthly_Payment_Estimate__c = 500, nu_dse__Business_Interests__c = '10',
                                                        nu_dse__Car_Maintenance__c = 600, nu_dse__Car_Payment__c = 700, nu_dse__Cash_Assets__c = '100',
                                                        nu_dse__Child_Care_Day_Care__c = 550, nu_dse__Prospect__c = prospectList[0].Id, External_Id__c = 'Test');
        financialProfileList.add(financialProfile);
        insert financialProfileList;
        
        List<nu_dse__Quote__c> quoteList = new List<nu_dse__Quote__c>();
        nu_dse__Quote__c quote = new nu_dse__Quote__c(nu_dse__Prospect__c = prospectList[0].Id, nu_dse__Payment_Frequency__c = 'Monthly', 
                                 nu_dse__Fee_Template__c = feeTemp.Id, nu_dse__Program_Length__c = 10, nu_dse__Processor__c = processor.Id,
                                 nu_dse__Status__c = 'New', nu_dse__Third_Party_Fees_Total__c = 1000, nu_dse__Third_Party_Monthly_Fee__c = 5000,
                                 external_id__c = 'Test_QuoteData' );
        
        quoteList.add(quote);
        insert quoteList;
        
        List<UpdateClients.prospects> prospects = new List<UpdateClients.prospects>(); 
        
        
        for(nu_dse__Prospect__c p: prospectList){
            
            UpdateClients.prospects prospect2 = new updateClients.prospects(); 
                    prospect2.First_Name = p.nu_dse__First_Name__c; 
                     
                     prospect2.MI =   p.nu_dse__MI__c;
                    
                     prospect2.MI = p.Middle_Name__c; 
                    
                     prospect2.Last_name = p.nu_dse__Last_name__c; 
                   
                     prospect2.Home_Phone = p.nu_dse__Home_Phone__c; 
                    
                     prospect2.Cell_Phone = p.nu_dse__Cell_Phone__c; 
                    
                     prospect2.Work_Phone = p.nu_dse__Work_Phone__c; 
                    
                     prospect2.Address_Line_1 = p.nu_dse__Address_Line_1__c; 
                    
                     prospect2.City = p.nu_dse__City__c; 
                    
                     prospect2.State = p.nu_dse__State__c; 
                    
                     prospect2.Email_Address = p.nu_dse__Email_Address__c; 
                     prospect2.External_Id = p.Upd_External_Id__c;  // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                    
               prospects.add(prospect2);
        }
        
         UpdateClients.BankAccount ba = new UpdateClients.BankAccount();
      
        List<UpdateClients.BankAccount> bankAccountsList = new List<UpdateClients.BankAccount>(); 
        bankAccountsList.add(ba);
        UpdateClients.Velocify objVelocify = new UpdateClients.Velocify();
        objVelocify.leads = prospects;
        objVelocify.bankAccounts = bankAccountsList;
        objVelocify.debts = tradelineList;
        objVelocify.financialProfile = financialProfileList;
        objVelocify.quotes = quoteList;
        
        UpdateClients.RequestWrapper objRequestWrapper = new UpdateClients.RequestWrapper();
        objRequestWrapper.velocify = objVelocify;
        
        String reqJSON = JSON.serialize(objRequestWrapper);
        
        Test.startTest();
            
            //UpdateClients.Debt debts = new UpdateClients.Debt('785412569853', 'Test', '1000', 'Test_TradelineData', '10000', String.ValueOf(prospectList[0].Id));
            //UpdateClients_Test resp = new UpdateClients_Test(200, 'Complete', reqJSON,null);
            //Test.setMock(HttpCalloutMock.class, resp);
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/LeadService/UpdateLeads/test';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(reqJSON);
            
            RestContext.request = req;
            RestContext.response = res;
            UpdateClients.doPost();
            
        Test.stopTest();  
        
        List<nu_dse__Bank_Account__c> bankList = [SELECT Id, External_Id__c FROM nu_dse__Bank_Account__c ];
        System.assertEquals('252525', bankList[0].External_Id__c);     
        
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}