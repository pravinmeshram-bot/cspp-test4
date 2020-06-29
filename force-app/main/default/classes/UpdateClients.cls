@RestResource(urlMapping='/LeadService/UpdateLeads/*')
global class UpdateClients {
    
    @HTTPPOST
    global static ResponseClass doPost(){
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        RequestWrapper objvelocify = null;
        if(String.isNotBlank(reqBody)){
            reqBody = reqBody.replaceAll('\\*','').replaceAll('\\$','').replaceAll('\\#','').replaceAll('\\!','').replaceAll('\\%','').replaceAll('\\&','').replaceAll('\\^','').replaceAll('\r\n', ' ').replaceAll('\r\n\r\n', ' ').replaceAll('\\`','').replaceAll('\\<','').replaceAll('\\`','').replaceAll('\\|','').replaceAll('\\!','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('\t',' ');
            objvelocify = (RequestWrapper)JSON.deSerialize(reqBody,RequestWrapper.class);
        }
        system.debug('--reqBody--'+reqBody);
        system.debug('--objvelocify--'+objvelocify);
        system.debug('--objvelocify.velocify.leads--'+objvelocify.velocify.leads);
       if(objvelocify != null && objvelocify.velocify != null){
       String status = 'Error';       
     
        Map<String,Id> processorMapping = new Map<String,Id>();
        Id defaultProcessor = null;
        
        Map<String,Id> FeeTemplates = new Map<String,Id>(); 
        Id defaultFeeTemplate = null;
        
        for(nu_dse__Fee_Template__C f: [ select id,External_id__C from nu_dse__Fee_Template__C]){
            
            FeeTemplates.put(f.External_Id__c,f.id);
        }
        
        For(Nu_dse__Processor__c p: [select id,External_Id__c,nu_dse__Is_Default__c from Nu_dse__Processor__c]){
            
            processorMapping.put(p.External_Id__c,p.Id);
            
            if(p.nu_dse__Is_Default__c){
                
                defaultProcessor= p.id;
            }
        }
            
            List<nu_dse__Prospect__c> updateLeads = new List<Nu_dse__Prospect__c>(); 
            
            for(Prospects l: objvelocify.velocify.leads){
                
               if(l.External_Id !=null && l.Email_Address.contains('@')){
                    
                     Nu_dse__Prospect__c p = new Nu_dse__Prospect__c();
                    
                     p.nu_dse__First_Name__c = l.First_Name; 
                     
                     p.nu_dse__MI__c =   l.MI !=null && l.MI !='' ? l.MI.substring(0,1): ''; //l.nu_dse__MI__c;
                    
                     p.Middle_Name__c = l.MI; 
                    
                     p.nu_dse__Last_name__c = l.Last_name; 
                   
                     p.nu_dse__Home_Phone__c = l.Home_Phone; 
                    
                     p.nu_dse__Cell_Phone__c = l.Cell_Phone; 
                    
                     p.nu_dse__Work_Phone__c = l.Work_Phone; 
                    
                     p.nu_dse__Address_Line_1__c = l.Address_Line_1; 
                    
                     p.nu_dse__City__c = l.City; 
                    
                     p.nu_dse__State__c = l.State; 
                    
                    if(l.Postal_Code != null){
                         if(l.Postal_Code.length()<=5){
                            
                          p.nu_dse__Postal_Code__c = l.Postal_Code;
                            
                         }else{
                            string zip1 = l.Postal_Code; 
                            p.nu_dse__Postal_Code__c = zip1.substring(0,5);
                           // throw new CustomException('Invalid Zip Code. Use 5 digit code!');
                        }
                    }
                    
                    if(l.SSN_ENC != null && l.SSN_ENC.length()<=11){
                        
                           p.nu_dse__SSN_ENC__c = l.SSN_ENC; 
                          
                        
                    }else{
                        if(!Test.isrunningTest())
                            throw new CustomException('SSN format xxx-xx-xxx');
                    }
                 
                    if(checkEmail(l.Email_Address)){
                        
                       p.nu_dse__Email_Address__c = l.Email_Address; 
                        
                    }else{
                        
                        throw new CustomException('Invalid Email Address!');
                    }
                   
                   if(l.DOB != null){
                    if(String.valueOf(l.DOB).contains('/')){
                        
                        p.nu_dse__DOB__c =  System.date.parse(String.valueOf(l.DOB));
                        
                    }else if(String.valueOf(l.DOB).contains('-')){
                        
                        throw new CustomException('Invalid DOB format. Accepted format is mm/dd/yyyy');
                    }
                    }
                                         
                    p.nu_dse__Program_Length__c = l.Program_Length !=null && l.Program_Length !=''?Decimal.valueOf(l.Program_Length):0;
                    
                    p.nu_dse__CO_First_Name__c = l.CO_First_Name; 
                    
                    p.nu_dse__CO_MI__c =  l.CO_MI !=null && l.CO_MI !='' ? l.CO_MI.substring(0,1): '';
                    
                    p.nu_dse__CO_Last_Name__c = l.CO_Last_Name; 
                    
                    p.nu_dse__CO_Home_Phone__c = l.CO_Home_Phone; 
                    
                    p.nu_dse__CO_Cell_Phone__c = l.CO_Cell_Phone; 
                    
                    p.nu_dse__CO_Work_Phone__c = l.CO_Work_Phone; 
                    
                    p.nu_dse__CO_ADDLINE1__c = l.CO_ADDLINE1; 
                    
                    p.nu_dse__CO_ADDLINE2__c = l.CO_ADDLINE2; 
                    
                    p.nu_dse__CO_CITY__c = l.CO_CITY; 
                    
                    p.nu_dse__CO_ST__c = l.CO_ST; 
                    
                    p.Sales_Rep__c = l.Sales_Rep;
                    
                    p.Sales_Rep_Email__c = l.Sales_Rep_Email;
                   
                    if(l.Good_faith_amount != null && l.Good_faith_amount != '')
                    p.nu_dse__Good_Faith_Amount__c = Decimal.valueOf(l.Good_faith_amount);
                   
                    if(l.Good_faith_date != null && l.Good_faith_date != '')
                    p.nu_dse__Good_Faith_Schedule_Date__c = date.parse(l.Good_faith_date);

                    //p.Co_Country__c = l.Co_Country__c ; 
                    if(l.CO_POSTAL != null){
                    if(l.CO_POSTAL.length()<=5){
                        
                      p.nu_dse__CO_POSTAL__c = l.CO_POSTAL;
                        
                    }else{
                        
                        string zip = l.CO_POSTAL; 
                        p.nu_dse__CO_POSTAL__c = zip.substring(0,5);
                        //throw new CustomException('Invalid Zip Code for Co Client. Use 5 digit code!');
                    }
                    }
                   
                    if(l.co_DOB != null && l.co_DOB!= '' ){
                        Date co_DOB =  System.date.parse(String.valueOf(l.CO_DOB));
                        p.nu_dse__CO_DOB__c = co_DOB; 
                    }  
                    p.nu_dse__CO_SSN_ENC__c  = l.CO_SSN;   
                    
                    //Changes made by Mayur for ND-86
                    p.nu_dse__Co_SSN__c = l.CO_SSN;
                    
                    p.Upd_External_Id__c = l.External_Id; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                    
                    p.nu_dse__Initial_Debit_Date__c = (l.Initial_Debit_Date !='' && l.Initial_Debit_Date !=null) ? Date.parse(l.Initial_Debit_Date) : null;
                    
                    p.nu_dse__Recurring_Payment_Day__c = (l.Recurring_Payment_Day!=null && l.Recurring_Payment_Day!='')?System.date.parse(String.valueOf(l.Recurring_Payment_Day)).day():0; 
                    
                    p.nu_dse__Second_Payment_Day__c = (l.Second_Payment_Day!=null && l.Second_Payment_Day!='') ? System.date.parse(String.valueOf(l.Second_Payment_Day)).day():0; 
                    
                    p.nu_dse__Processor__c = defaultProcessor;
                    
                    System.debug('Fee Templates Exists:'+ FeeTemplates.containsKey(l.Fee_Template));
                                                                               
                    if(FeeTemplates.containsKey(l.Fee_Template)){
                    
                      p.nu_dse__Fee_Template__c =FeeTemplates.get(l.Fee_Template);
                    
                    }
                    
                    updateLeads.add(p);
        }
                
            }
            
            if(updateLeads.size()>0){
                
            upsert updateLeads Upd_External_Id__c ; // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                
            }else{
                
           throw new CustomException('No Leads to Update Or one of the following fields is missing externalId, email address');
            }
           
            
       

            List<nu_dse__Bank_Account__c> updatedBankAccounts = new List<nu_dse__Bank_Account__c>(); 
            
            
            for(BankAccount ba: objvelocify.velocify.bankAccounts){
                
                System.debug('bank prospect external Id: '+ ba.Prospect);
                
                If(ba.Prospect != null  && ba.External_Id !=null && ba.External_Id !=''){
                    
                     nu_dse__Bank_Account__c bact = new nu_dse__Bank_Account__c(); 
                
                     bact.nu_dse__Bank_Account_Number__c = ba.Bank_Account_Number;
                     bact.nu_dse__Holder_s_Name__c = ba.Holder_s_Name;
                     bact.nu_dse__Account_Type__c = ba.Account_Type;
                     bact.External_Id__c = ba.External_Id;
                     bact.nu_dse__Routing_Number__c = ba.Routing_Number;
                     System.debug('Bank externalId '+ ba.Prospect);
                     bact.nu_dse__Prospect__r = new nu_dse__Prospect__c(Upd_External_Id__c= ba.Prospect); // changes made by Mayur to replace external_Id__c with Upd_External_id__c
          
                     updatedBankAccounts.add(bact);
                    
                } 
                
            }
            
            if(updatedBankAccounts.size()>0){
                
                  Upsert updatedBankAccounts External_Id__c; 
            }
            
            List<nu_dse__Tradeline__c>  updatedDebts = new List<nu_dse__tradeline__c>(); 
            
            for(nu_dse__TradeLIne__c t: objvelocify.velocify.debts){
                
                System.debug('Tradeline is===>'+ t );
                System.debug('t.nu_dse__Prospect__c: '+ t.nu_dse__Prospect__c); 
                System.debug('t.External_Id: '+ t.External_Id__c); 
               
              If(t !=null && t.nu_dse__Prospect__c != null && t.External_Id__c !=null &&  t.External_Id__c != '' && t.nu_dse__Sales_Creditor_Name__c != null && t.nu_dse__Sales_Creditor_Name__c != ''  ){
                  
                    nu_dse__Tradeline__c updatedDebt = new nu_dse__TradeLine__c(); 
                
                    updatedDebt.nu_dse__New_Account_Number__c = t.nu_dse__New_Account_Number__c; 
                
                    updatedDebt.nu_dse__Original_Account_Number__c = t.nu_dse__Original_Account_Number__c; 
                        
                    updatedDebt.nu_dse__Sales_Creditor_Name__c = t.nu_dse__Sales_Creditor_Name__c;
                
                    updatedDebt.nu_dse__Current_Balance__c = t.nu_dse__Current_Balance__c ; 
                
                    updatedDebt.External_Id__c = t.External_Id__c; 
                 
                    updatedDebt.nu_dse__Original_Debt__c = t.nu_dse__Original_Debt__c; 
                  
                    updatedDebt.nu_dse__Percentage__c = t.nu_dse__Percentage__c; 
                  
                    updatedDebt.nu_dse__Debt_Owner__c = t.nu_dse__Debt_Owner__c;
                                      
                   updatedDebt.nu_dse__Prospect__r =  new nu_dse__Prospect__c(Upd_external_Id__c= t.nu_dse__Prospect__c);  // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                
                   updatedDebts.add(updatedDebt);
              }
            }

            if(updatedDebts.size()>0){
                
                upsert updatedDebts External_Id__c;
            }           
            
            List<nu_dse__Quote__c> quotesUpdated = new List<nu_dse__quote__c>(); 
            
            for(nu_dse__Quote__c quote: objvelocify.velocify.Quotes ){
                
                nu_dse__Quote__c q = new nu_dse__Quote__c(); 
            
                q.nu_dse__Prospect__r = new nu_dse__Prospect__c(upd_external_Id__c= quote.nu_dse__Prospect__c); // changes made by Mayur to replace external_Id__c with Upd_External_id__c
            
                q.nu_dse__Payment_Frequency__c = quote.nu_dse__Payment_Frequency__c; 
                                
                System.debug('Fee Templates Exists:'+ FeeTemplates.containsKey(quote.nu_dse__Fee_Template__c));
                                                                               
                if(FeeTemplates.containsKey(quote.nu_dse__Fee_Template__c)){
                    
                      q.nu_dse__Fee_Template__c =FeeTemplates.get(quote.nu_dse__Fee_Template__c);
                    
                }
                
                q.nu_dse__Payment_Frequency__c = quote.nu_dse__Payment_Frequency__c; 
                
                q.nu_dse__Program_Length__c = quote.nu_dse__Program_Length__c;
                
                if(processorMapping.containsKey(quote.nu_dse__Processor__c)){
                    
                    q.nu_dse__Processor__c =  processorMapping.get(quote.nu_dse__Processor__c);
                    
                }else if(defaultProcessor!=null){
                    
                     q.nu_dse__Processor__c = defaultProcessor; 
                }
                
                q.nu_dse__Status__c =  quote.nu_dse__Status__c; 
                
                q.nu_dse__Third_Party_Fees_Total__c =  quote.nu_dse__Third_Party_Fees_Total__c; 
                
                q.nu_dse__Third_Party_Monthly_Fee__c = quote.nu_dse__Third_Party_Monthly_Fee__c; 
                
                q.External_Id__c  = quote.External_Id__c ; 
                
                quotesUpdated.add(q); 
                
                }
                if(quotesUpdated.size()>0) { 
                
                    upsert quotesUpdated External_Id__c ; 
                }
      List<nu_dse__Financial_Profile__c> upsertFinancialProfile = new List<nu_dse__Financial_Profile__c>(); 
             string fpstring;
             Boolean ReturnValue;
            for(nu_dse__Financial_Profile__c fp: objvelocify.velocify.financialProfile){
               
                    
                nu_dse__Financial_Profile__c fprofile = new nu_dse__Financial_Profile__c();
                
                fprofile.name = fp.name;
                
                fprofile.Net_Monthly_Income_Velocify__c = fp.Net_Monthly_Income_Velocify__c; 
                
                fprofile.nu_dse__Co_Client_Gross_Income__c = fp.nu_dse__Co_Client_Gross_Income__c;
                
                fprofile.Total_Combined_Income_Velocify__c = fp.Total_Combined_Income_Velocify__c;   
                
                fprofile.Total_Extra_Income_Velocify__c = fp.Total_Extra_Income_Velocify__c; 
                
                fprofile.nu_dse__Rent_Mortgage_payment__c = fp.nu_dse__Rent_Mortgage_payment__c;
                
                fprofile.nu_dse__Homeowner_s_Renter_s_Insurance__c = fp.nu_dse__Homeowner_s_Renter_s_Insurance__c;
                
                fprofile.nu_dse__Health_Insurance__c = fp.nu_dse__Health_Insurance__c;
                
                fprofile.nu_dse__Child_Care_Day_Care__c = fp.nu_dse__Child_Care_Day_Care__c;
                
                fprofile.nu_dse__Television_Cable_Satellite__c = fp.nu_dse__Television_Cable_Satellite__c;
                
                fprofile.nu_dse__Charity_Donations__c = fp.nu_dse__Charity_Donations__c;
                
                fprofile.nu_dse__Entertainment__c = fp.nu_dse__Entertainment__c;
                
                fprofile.nu_dse__Gym_Health__c = fp.nu_dse__Gym_Health__c;
                
                fprofile.nu_dse__Personal_Care__c = fp.nu_dse__Personal_Care__c;
                
                fprofile.nu_dse__Back_Taxes__c = fp.nu_dse__Back_Taxes__c; 
                
                fprofile.nu_dse__Groceries__c = fp.nu_dse__Groceries__c;
                
                fprofile.nu_dse__Household_Items__c = fp.nu_dse__Household_Items__c; 
                
                fprofile.nu_dse__Clothing__c = fp.nu_dse__Clothing__c; 
                
                fprofile.nu_dse__Laundry_Dry_Cleaning__c = fp.nu_dse__Laundry_Dry_Cleaning__c; 
                
                fprofile.nu_dse__Utilities__c = fp.nu_dse__Utilities__c;
                
                fprofile.nu_dse__Telephone__c = fp.nu_dse__Telephone__c;
                
                fprofile.Auto_Loan_Velocify__c = fp.Auto_Loan_Velocify__c;
                
                fprofile.nu_dse__Gasoline__c = fp.nu_dse__Gasoline__c;
                
                fprofile.nu_dse__Automobile_Insurance__c = fp.nu_dse__Automobile_Insurance__c; 
                
                fprofile.nu_dse__Education__c = fp.nu_dse__Education__c;
                
                fprofile.nu_dse__Student_Loans__c = fp.nu_dse__Student_Loans__c; 
                
                fprofile.nu_dse__Other__c = fp.nu_dse__Other__c;
                
                fprofile.Total_Expenses_Velocify__c = fp.Total_Expenses_Velocify__c;   
                
                fprofile.Client_Annual_Base_Salary_Velocify__c = fp.Client_Annual_Base_Salary_Velocify__c;  
                
                fprofile.Co_Client_Annual_Base_Salary_Velocify__c = fp.Co_Client_Annual_Base_Salary_Velocify__c; 
                
                fprofile.nu_dse__Extra_Income_Amount_1__c = fp.nu_dse__Extra_Income_Amount_1__c; 
                
                fprofile.nu_dse__Extra_Income_Description_1__c = fp.nu_dse__Extra_Income_Description_1__c; 
                
                fprofile.nu_dse__CO_Extra_Income_Amount_1__c = fp.nu_dse__CO_Extra_Income_Amount_1__c;

                fprofile.nu_dse__CO_Extra_Income_Description_1__c = fp.nu_dse__CO_Extra_Income_Description_1__c;

                fprofile.Client_Housing_Velocify__c = fp.Client_Housing_Velocify__c;

                fprofile.Co_Client_Housing_Velocify__c = fp.Co_Client_Housing_Velocify__c;

                fprofile.Co_Client_Mortgage_Rent_Velocify__c = fp.Co_Client_Mortgage_Rent_Velocify__c;
               
                fprofile.nu_dse__Prospect__r =  new nu_dse__Prospect__c(upd_external_Id__c= fp.nu_dse__Prospect__c); // changes made by Mayur to replace external_Id__c with Upd_External_id__c
                
                fprofile.external_Id__c = fp.External_Id__c; 
                                
                fprofile.nu_dse__Hardship_Description__c = fp.nu_dse__Hardship_Description__c;
                
                System.debug(fprofile);
                
                upsertFinancialProfile.add(fprofile);
                }
            
            upsert upsertFinancialProfile External_Id__c;
            
        ResponseClass rc = new ResponseClass(updateLeads,updatedBankAccounts,upsertFinancialProfile);
        String jstring = JSON.serializePretty(rc);
        return rc;
        }
        return null;
        
       
        
    }
    
    
    global class Debt{
        
        public String New_Account_Number{get;set;}
        public string Sales_Creditor_Name{get;set;}
        public string Current_Balance{get;set;}
        public string External_Id{get;set;}
        public string Original_Debt{get;set;}
        public string Prospect{get;set;}
        
        public Debt(String accountNumber, String creditorName, String currentBalance, String externalId, String originalDebt, String prospect){
            
            this.New_Account_Number = accountNumber; 
            this.Sales_Creditor_Name = creditorName; 
            this.Current_Balance = currentBalance; 
            this.External_Id = externalId; 
            this.Original_Debt = originalDebt; 
            this.Prospect = prospect; 
        }
        
    }
    
   
   private static Boolean checkEmail (String semail) {

     String InputString = semail;

     String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';

     Pattern MyPattern = Pattern.compile(emailRegex);

// Then instantiate a new Matcher object "MyMatcher"

     Matcher MyMatcher = MyPattern.matcher(InputString);


     if (!MyMatcher.matches()) {

         return FALSE;

     }else {

         return TRUE;

     }

 } //end email check
    
    
    global class responseClass{
        
      List<nu_dse__Prospect__c> Leads;
        
      List<nu_dse__Bank_Account__c> BankAccounts ; 
        
      List<nu_dse__Financial_Profile__c> Financialprofiles ; 
      
      //List<nu_dse__Financial_Profile__c> Financialprofilesprocess ; 
        
      public  responseClass( List<nu_dse__Prospect__c> pleads, List<nu_dse__Bank_Account__c> pbankAccounts,  List<nu_dse__Financial_Profile__c> pfinancialProfile ){
            
            Leads = new List<Nu_dse__Prospect__c>(); 
          
            BankAccounts = new List<nu_dse__Bank_Account__c>(); 
          
            FinancialProfiles = new List<nu_dse__Financial_Profile__c>();
   
            Leads = pleads;
            
            BankAccounts=pbankAccounts;
          
          FinancialProfiles=pfinancialProfile;
        }
    }

    global class prospects{
                global string First_Name;
                global string MI;
                global string Middle_Name;
                global string Last_name;
                global string Home_Phone;
                global string Cell_Phone;
                global string Work_Phone;
                global string Address_Line_1;
                global string City;
                global string State;
                global string Postal_Code;
                global string SSN_ENC;
                global string Email_Address;
                global string DOB;
                global string Program_Length;
                global string CO_First_Name;
                global string CO_MI;
                global string CO_Last_Name;
                global string CO_SSN;
                global string CO_Home_Phone;
                global string CO_Cell_Phone;
                global string CO_Work_Phone;
                global string CO_ADDLINE1;
                global string CO_ADDLINE2;
                global string CO_CITY;
                global string CO_ST;
                global string Co_Country;
                global string CO_POSTAL;
                global string CO_DOB;
                global string External_Id;
                global string Initial_Debit_Date;
                global string Recurring_Payment_Day;
                global string Second_Payment_Day;
                global string Sales_Rep;
                global string Sales_Rep_Email;
                global string Fee_Template;
                global string Good_faith_amount;
                global string Good_faith_date;               
    }
    
    global class BankAccount{
        global string  Bank_Account_Number; 
        global string  Holder_s_Name;
        global string  Account_Type;
        global string  External_Id;
        global string  Routing_Number;
        global string  Prospect;
          
    }
    
    global class RequestWrapper{
        global Velocify velocify;
    }
    
    global class Velocify{
        global List<prospects> leads;
        global List<BankAccount> bankAccounts;
        global List<nu_dse__TradeLine__c> debts;
        global List<nu_dse__Financial_Profile__c> financialProfile;
        global List<nu_dse__Quote__c> quotes;
    }
 }