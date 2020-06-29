public with sharing class Attorney_FinancialProfileHandler{

    public static void CreateOrUpdateNDSFinancialProfile(List<nu_dse__Financial_Profile__c> financialProfileLst, Map<Id,nu_dse__Financial_Profile__c> financialProfileOldMap){
        Map<String,String> financialProfileUpdMap = new Map<String,String>();
        Boolean apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()].attorney_admin__c;
        for(nu_dse__Financial_Profile__c financialProfile: financialProfileLst){
            if(financialProfile.isAttorney__c && !apiuser && (financialProfile.nu_dse__Automobile_Insurance__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Automobile_Insurance__c
                ||financialProfile.nu_dse__Car_Payment__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Car_Payment__c  
                ||financialProfile.nu_dse__Car_Maintenance__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Car_Maintenance__c
                ||financialProfile.nu_dse__Back_Taxes__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Back_Taxes__c
                ||financialProfile.nu_dse__Television_Cable_Satellite__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Television_Cable_Satellite__c
                ||financialProfile.nu_dse__Charity_Donations__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Charity_Donations__c
                ||financialProfile.nu_dse__Number_of_Dependants__c!= financialProfileOldMap.get(financialProfile.Id).nu_dse__Number_of_Dependants__c
               
                ||financialProfile.nu_dse__Child_Care_Day_Care__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Child_Care_Day_Care__c
                ||financialProfile.nds_DiscretionaryIncome__c != financialProfileOldMap.get(financialProfile.Id).nds_DiscretionaryIncome__c
                ||financialProfile.nds_Discretionary_Percentage__c != financialProfileOldMap.get(financialProfile.Id).nds_Discretionary_Percentage__c
                ||financialProfile.nu_dse__Education__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Education__c
                ||financialProfile.nu_dse__Entertainment__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Entertainment__c
                ||financialProfile.nu_dse__Food_Groceries_Eating_Out__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Food_Groceries_Eating_Out__c
                ||financialProfile.nu_dse__Gym_Health__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Gym_Health__c
                ||financialProfile.nu_dse__Home_Status__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Home_Status__c
                ||financialProfile.nu_dse__Homeowner_s_Renter_s_Insurance__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Homeowner_s_Renter_s_Insurance__c
                ||financialProfile.nu_dse__Household_Items__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Household_Items__c
                ||financialProfile.nu_dse__Laundry_Dry_Cleaning__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Laundry_Dry_Cleaning__c
                ||financialProfile.nu_dse__Life_Insurance__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Life_Insurance__c
                ||financialProfile.nu_dse__Medical__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Medical__c
                ||financialProfile.nu_dse__Rent_Mortgage_payment__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Rent_Mortgage_payment__c
             //   ||financialProfile.nu_dse__Additional_Income__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Additional_Income__c
                ||financialProfile.nu_dse__Net_Monthly_Income__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Net_Monthly_Income__c
                ||financialProfile.Is_Self_Employed__c != financialProfileOldMap.get(financialProfile.Id).Is_Self_Employed__c
             //   ||financialProfile.Co_Client_Annual_Base_Salary_Velocify__c != financialProfileOldMap.get(financialProfile.Id).Co_Client_Annual_Base_Salary_Velocify__c
                ||financialProfile.nu_dse__Co_Client_Gross_Income__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Co_Client_Gross_Income__c
                ||financialProfile.Is_Co_Applicant_Self_Employed__c != financialProfileOldMap.get(financialProfile.Id).Is_Co_Applicant_Self_Employed__c
                ||financialProfile.nu_dse__Other_1_Payments__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Other_1_Payments__c
                ||financialProfile.nu_dse__Other_1_Payments_Description__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Other_1_Payments_Description__c
                ||financialProfile.nu_dse__Extra_Income_Amount_1__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Extra_Income_Amount_1__c
                ||financialProfile.nu_dse__Extra_Income_Amount_2__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Extra_Income_Amount_2__c
                ||financialProfile.nu_dse__Extra_Income_Description_1__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Extra_Income_Description_1__c
                ||financialProfile.nu_dse__Extra_Income_Description_2__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Extra_Income_Description_2__c
                ||financialProfile.nu_dse__Personal_Care__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Personal_Care__c
                ||financialProfile.nu_dse__Student_Loans__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Student_Loans__c
                ||financialProfile.nu_dse__Total_Expenses__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Total_Expenses__c
                ||financialProfile.nu_dse__Total_Income__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Total_Income__c
                ||financialProfile.nu_dse__Bankruptcy_Type__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Bankruptcy_Type__c
                ||financialProfile.nu_dse__Utilities__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Utilities__c
                ||financialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Co_Year_Filed_for_Bankruptcy__c
                ||financialProfile.nu_dse__Credit_Score__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Credit_Score__c
                ||financialProfile.nu_dse__Home_Value__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Home_Value__c
                ||financialProfile.nu_dse__Client_Has_Filed_Bankruptcy__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Client_Has_Filed_Bankruptcy__c
                ||financialProfile.nu_dse__Amount_Owed_on_Home__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Amount_Owed_on_Home__c
                ||financialProfile.nu_dse__Hardship_Description__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Hardship_Description__c
                ||financialProfile.nu_dse__Hardship_Reason__c!= financialProfileOldMap.get(financialProfile.Id).nu_dse__Hardship_Reason__c
                
                ||financialProfile.nu_dse__Extra_Income_Amount_1__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Extra_Income_Amount_1__c 
                ||financialProfile.nu_dse__Net_Monthly_Income__c != financialProfileOldMap.get(financialProfile.Id).nu_dse__Net_Monthly_Income__c 
                ||financialProfile.nds_DiscretionaryIncome__c != financialProfileOldMap.get(financialProfile.Id).nds_DiscretionaryIncome__c 
                ||financialProfile.nds_Discretionary_Percentage__c!= financialProfileOldMap.get(financialProfile.Id).nds_Discretionary_Percentage__c
                ||financialProfile.Is_Self_Employed__c!= financialProfileOldMap.get(financialProfile.Id).Is_Self_Employed__c
                ||financialProfile.Is_Co_Applicant_Self_Employed__c!= financialProfileOldMap.get(financialProfile.Id).Is_Co_Applicant_Self_Employed__c
                ||financialProfile.nu_dse__Co_Client_Gross_Income__c!= financialProfileOldMap.get(financialProfile.Id).nu_dse__Co_Client_Gross_Income__c))
                {
                    
                financialProfileUpdMap = new Map<String,String>();
                financialProfileUpdMap.put('AutoInsuranceCost',String.valueOf(financialProfile.nu_dse__Automobile_Insurance__c));
                financialProfileUpdMap.put('AutoLoanCost',String.valueOf(financialProfile.nu_dse__Car_Payment__c));
                financialProfileUpdMap.put('AutoOther',String.valueOf(financialProfile.nu_dse__Car_Maintenance__c));
                financialProfileUpdMap.put('BackTaxes',String.valueOf(financialProfile.nu_dse__Back_Taxes__c));
                financialProfileUpdMap.put('CableSatelliteCost',String.ValueOf(financialProfile.nu_dse__Television_Cable_Satellite__c));
                financialProfileUpdMap.put('CharityCost',String.ValueOf(financialProfile.nu_dse__Charity_Donations__c));
                financialProfileUpdMap.put('ChildCareCost',String.ValueOf(financialProfile.nu_dse__Child_Care_Day_Care__c));
                financialProfileUpdMap.put('DiscretionaryIncome',String.ValueOf(financialProfile.nds_DiscretionaryIncome__c));
                financialProfileUpdMap.put('DiscretionaryPercentage',String.ValueOf(financialProfile.nds_Discretionary_Percentage__c));
                financialProfileUpdMap.put('EducationCost',String.ValueOf(financialProfile.nu_dse__Education__c));
                financialProfileUpdMap.put('EntertainmentCost',String.ValueOf(financialProfile.nu_dse__Entertainment__c));
                financialProfileUpdMap.put('FoodCost',String.ValueOf(financialProfile.nu_dse__Food_Groceries_Eating_Out__c));
                financialProfileUpdMap.put('GymFees',String.ValueOf(financialProfile.nu_dse__Gym_Health__c));
                
                if(financialProfile.nu_dse__Home_Status__c != null && financialProfile.nu_dse__Home_Status__c != '' && financialProfile.nu_dse__Home_Status__c == 'Own')
                {
                                financialProfileUpdMap.put('Homeowner','Yes');

                }
                
                else if(financialProfile.nu_dse__Home_Status__c != null && financialProfile.nu_dse__Home_Status__c != '' && financialProfile.nu_dse__Home_Status__c == 'Rent')
                
                {
                                financialProfileUpdMap.put('Homeowner','No');

                }
                
                else
                {
                financialProfileUpdMap.put('Homeowner',String.ValueOf(financialProfile.nu_dse__Home_Status__c));
                }
           
                financialProfileUpdMap.put('HomeRentInsuranceCost',String.ValueOf(financialProfile.nu_dse__Homeowner_s_Renter_s_Insurance__c));
                financialProfileUpdMap.put('HouseholdItemsCost',String.ValueOf(financialProfile.nu_dse__Household_Items__c));
                financialProfileUpdMap.put('LaundryCost',String.ValueOf(financialProfile.nu_dse__Laundry_Dry_Cleaning__c));
                financialProfileUpdMap.put('LifeInsuranceCost',String.ValueOf(financialProfile.nu_dse__Life_Insurance__c));
                financialProfileUpdMap.put('MedicalCareCost',String.ValueOf(financialProfile.nu_dse__Medical__c));
                financialProfileUpdMap.put('MortgageRentCost',String.ValueOf(financialProfile.nu_dse__Rent_Mortgage_payment__c));
            //    financialProfileUpdMap.put('Name1AnnualIncome',String.ValueOf(financialProfile.nu_dse__Additional_Income__c));
                financialProfileUpdMap.put('Name1MonthlyIncome',String.ValueOf(financialProfile.nu_dse__Net_Monthly_Income__c));
                financialProfileUpdMap.put('Name1SelfEmployed',String.ValueOf(financialProfile.Is_Self_Employed__c));
            //    financialProfileUpdMap.put('Name2AnnualIncome',String.ValueOf(financialProfile.Co_Client_Annual_Base_Salary_Velocify__c));
                financialProfileUpdMap.put('Name2MonthlyIncome',String.ValueOf(financialProfile.nu_dse__Co_Client_Gross_Income__c));
                financialProfileUpdMap.put('Name2SelfEmployed',String.ValueOf(financialProfile.Is_Co_Applicant_Self_Employed__c));
                financialProfileUpdMap.put('Other1Cost',String.ValueOf(financialProfile.nu_dse__Other_1_Payments__c));
                
                If(financialProfile.nu_dse__Other_1_Payments_Description__c != 'Data Clean Up Needed in NDS')
                {
                financialProfileUpdMap.put('Other1Name',String.ValueOf(financialProfile.nu_dse__Other_1_Payments_Description__c));
                }
                financialProfileUpdMap.put('OtherIncomeAmount',String.ValueOf(financialProfile.nu_dse__Extra_Income_Amount_1__c));
                financialProfileUpdMap.put('OtherIncomeAmount2',String.ValueOf(financialProfile.nu_dse__Extra_Income_Amount_2__c));
                financialProfileUpdMap.put('OtherIncomeReason',String.ValueOf(financialProfile.nu_dse__Extra_Income_Description_1__c));
                financialProfileUpdMap.put('OtherIncomeReason2',String.ValueOf(financialProfile.nu_dse__Extra_Income_Description_2__c));
                financialProfileUpdMap.put('PersonalCare',String.ValueOf(financialProfile.nu_dse__Personal_Care__c));
                financialProfileUpdMap.put('StudentLoans',String.ValueOf(financialProfile.nu_dse__Student_Loans__c));
                financialProfileUpdMap.put('TotalCostOfLiving',String.ValueOf(financialProfile.nu_dse__Total_Expenses__c));
                financialProfileUpdMap.put('TotalIncome',String.ValueOf(financialProfile.nu_dse__Total_Income__c));
                financialProfileUpdMap.put('BankruptcyChapter',String.ValueOf(financialProfile.nu_dse__Bankruptcy_Type__c));
                financialProfileUpdMap.put('UtilitiesCost',String.ValueOf(financialProfile.nu_dse__Utilities__c));
                financialProfileUpdMap.put('BankruptcyYear',String.ValueOf(financialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c));
                //financialProfileUpdMap.put('BankruptcyYear',String.ValueOf(financialProfile.nu_dse__Co_Year_Filed_for_Bankruptcy__c));
                financialProfileUpdMap.put('CreditScore1',String.ValueOf(financialProfile.nu_dse__Credit_Score__c));
                financialProfileUpdMap.put('EstimatedHomeValue',String.ValueOf(financialProfile.nu_dse__Home_Value__c));
                financialProfileUpdMap.put('FiledBankruptcy',String.ValueOf(financialProfile.nu_dse__Client_Has_Filed_Bankruptcy__c));
                financialProfileUpdMap.put('MortgageBalance',String.ValueOf(financialProfile.nu_dse__Amount_Owed_on_Home__c));
                financialProfileUpdMap.put('HardshipReason',String.ValueOf(financialProfile.nu_dse__Hardship_Description__c));
                financialProfileUpdMap.put('Hardship',String.ValueOf(financialProfile.nu_dse__Hardship_Reason__c));
                
                financialProfileUpdMap.put('Name2MonthlyIncome',String.ValueOf(financialProfile.nu_dse__Co_Client_Gross_Income__c));
                                financialProfileUpdMap.put('Dependants',String.ValueOf(financialProfile.nu_dse__Number_of_Dependants__c));

                
                
                financialProfileUpdMap.put('OtherIncomeAmount',String.ValueOf(financialProfile.nu_dse__Extra_Income_Amount_1__c));
                financialProfileUpdMap.put('Name1MonthlyIncome',String.ValueOf(financialProfile.nu_dse__Net_Monthly_Income__c));
                financialProfileUpdMap.put('DiscretionaryIncome',String.ValueOf(financialProfile.nds_DiscretionaryIncome__c));
                financialProfileUpdMap.put('DiscretionaryPercentage',String.ValueOf(financialProfile.nds_Discretionary_Percentage__c));
                financialProfileUpdMap.put('Name1SelfEmployed',String.ValueOf(financialProfile.Is_Self_Employed__c));
                financialProfileUpdMap.put('Name2SelfEmployed',String.ValueOf(financialProfile.Is_Co_Applicant_Self_Employed__c));
                
                system.debug('###financialProfileUpdMap::'+financialProfileUpdMap);
                if(!financialProfileUpdMap.isEmpty())
                    calloutToNDS(financialProfileUpdMap, financialProfile.campaignId__c, financialProfile.Import_ID__c);
            }
                
        }
    }
    @future(callout=TRUE)
    public static void calloutToNDS(Map<String,String> financialProfileUpdMap, String campaignId, String FileNumber){
        leadtracNetclient.ClientServiceSoap soap = new leadtracNetclient.ClientServiceSoap();
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        leadtracNetclient.ArrayOfClientProperty propertyArray;
        leadtracNetclient.ClientProperty property;
        List<leadtracNetclient.ClientProperty> propLst;
        propLst = new List<leadtracNetclient.ClientProperty>();
        propertyArray = new leadtracNetclient.ArrayOfClientProperty();
        property = new leadtracNetclient.ClientProperty();
        property.Name = 'FileNumber';
        property.Value = FileNumber;
        propLst.add(property);
        for(String str: financialProfileUpdMap.keySet()){
            if(financialProfileUpdMap.containsKey(Str)){
                property = new leadtracNetclient.ClientProperty();
                property.Name = str;
                property.Value = financialProfileUpdMap.get(str);
                propLst.add(property);    
            }
        }
        propertyArray.ClientProperty = propLst;
      
       
        String retunedString = soap.CreateOrUpdateClient(credentials.UserName__c, credentials.Password__c,campaignId,propertyArray);        
        system.debug('###retunedString::'+retunedString);
    }
    
}