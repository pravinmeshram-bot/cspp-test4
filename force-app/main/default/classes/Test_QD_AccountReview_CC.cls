@isTest
public class Test_QD_AccountReview_CC {

    
    
    public static testmethod void QDTest1(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Verified_Last_4_Digtit_SSN__c = true;
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
    //    insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        //QDSCR1.Name='Attorney'+'-'+'Month 1';
        QDSCR1.Name = QD1.Portfolio__c+'-'+QD1.MonthReview__c;
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
        QDAcc1.QD = QD1;
        QDAcc1.DescriptionQD();
        QDAcc1.saveQD();
        QDAcc1.getselection();
        
    }
    
    public static testmethod void QDTest11(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Contingency';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Verified_Last_4_Digtit_SSN__c = true;
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
    //    insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        //QDSCR1.Name='Attorney'+'-'+'Month 1';
        QDSCR1.Name = QD1.Portfolio__c+'-'+QD1.MonthReview__c;
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
        QDAcc1.QD = QD1;
        QDAcc1.DescriptionQD();
        QDAcc1.saveQD();
        QDAcc1.getselection();
        
    }
    
    public static testmethod void QDTest2(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Timberline';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Verified_Last_4_Digtit_SSN__c = true;
        QD1.Completed_Strategy_Call__c = true;
     //   insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        QDSCR1.Name = QD1.Portfolio__c+'-'+'Strategy';
        QDSCR1.Name__c = 'TestName';
        QDSCR1.Fax__c = 'TestFax';
        QDSCR1.Email__c = 'TestEmail@Test.com';
        QDSCR1.Phone__c = 'TestPhone';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD = QD1;
       QDAcc1.QD1 = QD1;
        QDAcc1.StrategyPage();
        QDAcc1.saveQDStrategy();
        
    }
    
    public static testmethod void QDTest22(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Royal';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Verified_Last_4_Digtit_SSN__c = true;
        QD1.Completed_Strategy_Call__c = true;
     //   insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        QDSCR1.Name = QD1.Portfolio__c+'-'+'Strategy';
        QDSCR1.Name__c = 'TestName';
        QDSCR1.Fax__c = 'TestFax';
        QDSCR1.Email__c = 'TestEmail@Test.com';
        QDSCR1.Phone__c = 'TestPhone';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD = QD1;
       QDAcc1.QD1 = QD1;
        QDAcc1.StrategyPage();
        QDAcc1.saveQDStrategy();
        
    }
    
    public static testmethod void QDTes3(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Date_Requested_NSF__c = system.today();
        QD1.Date_Skipped__c = system.today();
        QD1.Current_Date_Draft__c = system.today();
        QD1.Date_Requested_Draft__c = system.today();
        QD1.Current_Date_Draft1__c = system.today();
        QD1.Date_Requested_Draft1__c = system.today();
        QD1.Draft_Date_Estimate__c = system.today();
        QD1.Draft_Date__c = system.today();
        QD1.Task_Date__c = system.today();
        QD1.Other_Than_POA__c = true;
        QD1.Call_Type_Payments__c = 'NSF';
        
   //     insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
     //   QDAcc1.showPanel = TRUE;
        QDAcc1.CustomerServicePage();
        QDAcc1.saveQDPayments();
        QDAcc1.CustomerServicePage_Payment();
        
    }
    
    public static testmethod void QDTes4(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Date_Requested_NSF__c = system.today();
        QD1.Date_Skipped__c = system.today();
        QD1.Current_Date_Draft__c = system.today();
        QD1.Date_Requested_Draft__c = system.today();
        QD1.Current_Date_Draft1__c = system.today();
        QD1.Date_Requested_Draft1__c = system.today();
        QD1.Draft_Date_Estimate__c = system.today();
        QD1.Draft_Date__c = system.today();
        QD1.Task_Date__c = system.today();
        QD1.Other_Than_POA__c = true;
        
   //     insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
        QDACC1.QD = QD1;
        QDAcc1.showPanel = TRUE;
        QDAcc1.PendingCancellation();
        QDAcc1.saveQDCancelPayment();
        
    }
    
    public static testmethod void QDTes5(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Caller_List__c = 'Send LOR/POA';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Date_Requested_NSF__c = system.today();
        QD1.Date_Skipped__c = system.today();
        QD1.Current_Date_Draft__c = system.today();
        QD1.Date_Requested_Draft__c = system.today();
        QD1.Current_Date_Draft1__c = system.today();
        QD1.Date_Requested_Draft1__c = system.today();
        QD1.Draft_Date_Estimate__c = system.today();
        QD1.Draft_Date__c = system.today();
        QD1.Task_Date__c = system.today();
        QD1.Other_Than_POA__c = true;
        QD1.Send_LOR_POA__c = true;
    //    insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        QDSCR1.Name = 'Attorney';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
    //    QDAcc1.showPanel = TRUE;
        QDAcc1.Documents();
        QDAcc1.saveQDDocuments();
        QDAcc1.Documents_d();
        
    }
    
    public static testmethod void QDTes6(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Date_Requested_NSF__c = system.today();
        QD1.Date_Skipped__c = system.today();
        QD1.Current_Date_Draft__c = system.today();
        QD1.Date_Requested_Draft__c = system.today();
        QD1.Current_Date_Draft1__c = system.today();
        QD1.Date_Requested_Draft1__c = system.today();
        QD1.Draft_Date_Estimate__c = system.today();
        QD1.Draft_Date__c = system.today();
        QD1.Task_Date__c = system.today();
        QD1.Other_Than_POA__c = true;
        QD1.Call_Type_Miscellaneous__c = 'FDCPA';
        
    //    insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
        QDAcc1.Miscellaneous();
        QDAcc1.saveQDMiscellaneous();
        QDAcc1.Miscellaneous_M();
        
    }
    
    public static testmethod void QDTes7(){
        
        Account acc1 = new Account();
        acc1.name = 'testaccount';
        insert acc1;
        
        Quick_Doc_Scripts__c QDSCR1 = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst1 = new list<Quick_Doc_Scripts__c>();
        QDSCR1.Description__c = 'TestDescr';
        QDSCR1.Notes__c = 'TestNotes';
        lst1.add(QDSCR1);
        insert QDSCR1;
        
        Quick_Doc__c QD1 = new Quick_Doc__c();
        QD1.Account__c = acc1.Id;
        QD1.Portfolio__c ='Attorney';
        QD1.Conducted_Account_Review__c = true;
        QD1.MonthReview__c='Month 1';
        QD1.Additional_Information__c ='TestAdditional';
        QD1.Applicant__c = true;
        QD1.Co_Applicant__c = true;
        QD1.Date_Requested_NSF__c = system.today();
        QD1.Date_Skipped__c = system.today();
        QD1.Current_Date_Draft__c = system.today();
        QD1.Date_Requested_Draft__c = system.today();
        QD1.Current_Date_Draft1__c = system.today();
        QD1.Date_Requested_Draft1__c = system.today();
        QD1.Draft_Date_Estimate__c = system.today();
        QD1.Draft_Date__c = system.today();
        QD1.Task_Date__c = system.today();
        QD1.Other_Than_POA__c = true;
        QD1.Notes__c = lst1[0].Notes__c;
        
    //    insert QD1;
        
        nu_dse__Program__c prog1 = new nu_dse__Program__c();
        prog1.nu_dse__Account__c = acc1.Id;
        insert prog1;
        
        
        
        QD_AccountReview_CC QDAcc1 = new QD_AccountReview_CC();
        QDAcc1.QD1 = QD1;
        QDAcc1.SettlementSpreadPage();
        QDAcc1.saveQDSettlement();
    
    }
    
    
    public static testmethod void QDTest18(){
        
        Account acc = new Account();
        acc.name = 'testaccount';
        insert acc;
        
        Quick_Doc__c QD = new Quick_Doc__c();
        QD.Account__c = acc.Id;
        QD.Portfolio__c ='Timberline';
        QD.Conducted_Account_Review__c = true;
        QD.MonthReview__c='Month 1';
        QD.Additional_Information__c ='TestAdditional';
        QD.Applicant__c = true;
        QD.Co_Applicant__c = true;
    //    insert QD;
        
        nu_dse__Program__c prog = new nu_dse__Program__c();
        prog.nu_dse__Account__c = acc.Id;
        insert prog;
        
        Quick_Doc_Scripts__c QDSCR = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst = new list<Quick_Doc_Scripts__c>();
        QDSCR.Description__c = 'TestDescr';
        QDSCR.Notes__c = 'TestNotes';
        QDSCR.Name = QD.Portfolio__c;
        lst.add(QDSCR);
        insert QDSCR;
        
        QD_AccountReview_CC QDAcc = new QD_AccountReview_CC();
        QDAcc.QD = QD;
    	QDAcc.showPanel = TRUE;
        QDAcc.QD1 = QD;
        QDAcc.ContactPage();
        QDAcc.saveQDOnboard();
        
    } 
    
    public static testmethod void QDTest28(){
        
        Account acc = new Account();
        acc.name = 'testaccount';
        insert acc;
        
        Quick_Doc__c QD = new Quick_Doc__c();
        QD.Account__c = acc.Id;
        QD.Portfolio__c ='Royal';
        QD.Conducted_Account_Review__c = true;
        QD.MonthReview__c='Month 1';
        QD.Additional_Information__c ='TestAdditional';
        QD.Applicant__c = true;
        QD.Co_Applicant__c = true;
    //    insert QD;
        
        nu_dse__Program__c prog = new nu_dse__Program__c();
        prog.nu_dse__Account__c = acc.Id;
        insert prog;
        
        Quick_Doc_Scripts__c QDSCR = new Quick_Doc_Scripts__c();
        List<Quick_Doc_Scripts__c> lst = new list<Quick_Doc_Scripts__c>();
        QDSCR.Description__c = 'TestDescr';
        QDSCR.Notes__c = 'TestNotes';
        QDSCR.Name = QD.Portfolio__c;
        lst.add(QDSCR);
        insert QDSCR;
        
        QD_AccountReview_CC QDAcc = new QD_AccountReview_CC();
        QDAcc.QD = QD;
    	QDAcc.showPanel = TRUE;
        QDAcc.QD1 = QD;
        QDAcc.ContactPage();
        QDAcc.saveQDOnboard();
        
    } 
    
    public static testmethod void QDTest19(){
        QD_AccountReview_CC QDAcc = new QD_AccountReview_CC();
        QDAcc.closePopup();
        QDAcc.showPopup();
        QDAcc.NotePanQD();
    //    QDAcc.getselection();
    //    QDAcc.clearAll();
    }
    
    public static testmethod void QDTest20(){
        QD_AccountReview_CC QDAcc = new QD_AccountReview_CC();
        
        QDAcc.CancelQD();
        QDAcc.clearAll();
    }
}