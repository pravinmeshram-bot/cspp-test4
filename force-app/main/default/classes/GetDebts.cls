@RestResource(urlMapping='/DebtService/GetDebts/*')
global class GetDebts { 

    @HTTPPOST
    global static List<Debt> doPost(String clientId){
         
        List<Debt> debts = new List<Debt>();
        for(nu_dse__TradeLine__c t:[select id,Name,nu_dse__Program__r.nu_dse__Account__r.clientnumber__c,
                                        nu_dse__Classification__c,nu_dse__Current_Stage__c,
                                        nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_First_Name__c,nu_dse__Percentage__c,
                                        nu_dse__Last_Payment_Date__c,nu_dse__Minimum_Payment_Amount__c,
                                        nu_dse__Program__r.nu_dse__Account__r.nu_dse__Client_Status__c,
                                        nu_dse__Program__r.nu_dse__Account__r.firstName from nu_dse__TradeLine__c 
                                    where nu_dse__program__r.nu_dse__Account__r.clientnumber__c =: clientId]) {
            
            Debt d = new Debt(); 
            
            d.debtId = t.Id;
            d.debtName = t.Name; 
            d.DebtType = t.nu_dse__Classification__c; 
            d.NegotiationStatus = t.nu_dse__Current_Stage__c;
            d.settlementStatus = '';
            d.AccountStatus = t.nu_dse__Program__r.nu_dse__Account__r.clientnumber__c;
            d.primaryName = t.nu_dse__Program__r.nu_dse__Account__r.firstName; 
            d.SecondaryName = t.nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_First_Name__c; 
            d.MinimumPayment = t.nu_dse__Minimum_Payment_Amount__c; 
            d.InterestRate = t.nu_dse__Percentage__c;
            d.LastPaymentDate = t.nu_dse__Last_Payment_Date__c; 
            
            debts.add(d);
        }
        System.debug('::Debt::'+debts);
        return debts;
    }
    
    global class Debt {
        global String DebtId;
        global string debtName;
       //global string VendorId; //Required
       global String DebtType;
       global string NegotiationStatus;
       global string SettlementStatus; //Read-only
       global string AccountStatus;
       global string PrimaryName;
       global string SecondaryName;
       global string SecondaryNameRelation;
       global string AdditionalName;
       global string AdditionalRelation;
       global String ApplicantType;
       global decimal MinimumPayment;
       global DateTime LastStatementDate;
       global decimal InterestRate;
       global boolean IsCashOrTransfer;
       global DateTime LastPaymentDate;
       global DateTime EndedOn;
       global Payment[] SettlementPlan;
       //public DebtCreditor[] CreditorHistory;
       //public DebtCreditor[] SettlementPlan;
    }
    
    global class Payment {
        
    }
}