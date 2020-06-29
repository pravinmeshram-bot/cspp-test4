@isTest
public class SettlementPlan_Test{

    static testMethod void testClass() {
        
        Id debtSettlementRecTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
        
        Id debtFeeRecTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Fee'); //Schema.SObjectType.nu_dse__Payment__c .getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        Portfolio__c portfolio = TestRecordCreator.createportfolio();
        portfolio.Name = 'Timberline';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c (nu_dse__Account__c = accountInstance.id,
                                                                      nu_dse__Fee_Template__c = feeTemp.Id,
                                                                      Portfolio__c = portfolio.Id);
        insert programInstance;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 1500, 1500, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        insert offerInstance;
        
        List<nu_dse__Payment__c> activePaymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c depositPayment1 = TestRecordCreator.createPayment(programInstance.Id, 'Completed', 'Withdrawal', debtSettlementRecTypeId, null);
        depositPayment1.nu_dse__Offer__c = offerInstance.Id;
        depositPayment1.nu_dse__Processor_Fee__c = 100;
        activePaymentList.add(depositPayment1);
        
        nu_dse__Payment__c depositPayment2 = TestRecordCreator.createPayment(programInstance.Id, 'Completed', 'Withdrawal', debtSettlementRecTypeId, null);
        depositPayment2.nu_dse__Processor_Fee__c = 200;
        depositPayment2.nu_dse__Offer__c = offerInstance.Id;
        activePaymentList.add(depositPayment2);
        
        nu_dse__Payment__c depositPayment3 = TestRecordCreator.createPayment(programInstance.Id, 'In Progress', 'Withdrawal', debtSettlementRecTypeId, null);
        depositPayment3.nu_dse__Processor_Fee__c = 150;
        depositPayment3.nu_dse__Offer__c = offerInstance.Id;
        activePaymentList.add(depositPayment3);
        
        nu_dse__Payment__c adminFeePayment1 = TestRecordCreator.createPayment(programInstance.Id, 'Completed', 'Fee Withdrawal', debtFeeRecTypeId , null);
        adminFeePayment1.nu_dse__Processor_Fee__c = 100;
        adminFeePayment1.nu_dse__Offer__c = offerInstance.Id;
        activePaymentList.add(adminFeePayment1);
        
        nu_dse__Payment__c adminFeePayment2 = TestRecordCreator.createPayment(programInstance.Id, 'Completed', 'Fee Withdrawal', debtFeeRecTypeId , null);
        adminFeePayment2.nu_dse__Processor_Fee__c = 200;
        adminFeePayment2.nu_dse__Offer__c = offerInstance.Id;
        activePaymentList.add(adminFeePayment2);
        
        nu_dse__Payment__c adminFeePayment3 = TestRecordCreator.createPayment(programInstance.Id, 'In Progress', 'Fee Withdrawal', debtFeeRecTypeId , null);
        adminFeePayment3.nu_dse__Processor_Fee__c = 150;
        adminFeePayment3.nu_dse__Offer__c = offerInstance.Id;
        activePaymentList.add(adminFeePayment3);
        
        insert activePaymentList;
        
        ApexPages.currentPage().getParameters().put('id', offerInstance.Id);
        SettlementPlan settplan = new SettlementPlan();
        settplan.autoPaymentAdjustments();
        settplan.recordType = 'Fee';
        settplan.addNewSettlementPayment();
        settplan.paymentList[6].nu_dse__Amount__c = 1500;
        settplan.recordType = 'Settlement';
        settplan.addNewSettlementPayment();
        settplan.paymentList[7].nu_dse__Amount__c = 1500;
        settplan.SavePayments();
        settplan.updateScheduleDate();
        settplan.deletePayment();
        
        SettlementPlan settplan2 = new SettlementPlan();
        offerInstance.nu_dse__Offer_Amount__c = 3500; 
        offerInstance.nu_dse__Program_Fee__c = 3500; 
        update offerInstance;
        for (nu_dse__Payment__c  pay : activePaymentList) {
            pay.nu_dse__Amount__c = 100;
        }
        update activePaymentList;
        settplan2.SavePayments();
        
        
        SettlementPlan settplan1 = new SettlementPlan();
        for (nu_dse__Payment__c  pay : activePaymentList) {
            pay.nu_dse__Amount__c = 1000;
        }
        update activePaymentList;
        settplan1.SavePayments();
                
    }
}