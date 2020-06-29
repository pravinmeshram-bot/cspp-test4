@isTest
public class Test_QuickDoc_CC {
    public static testmethod void Quickdoc(){
       QuickDoc_CC QD = new QuickDoc_CC();
        QD.newCCF();
        QD.Onboarding();
        QD.Strategy();
        QD.SettlementSpread();
        QD.PendingCancellation();
        QD.Documents();
        QD.Miscellaneous();
        QD.Payments();
        QD.closePopup();
        QD.showPopup();
        QD.Accrecord();
    }
}