public class QD_AccountReview_CC {


   public boolean blnSendLOR{get;set;}
   public Boolean bln1099c{get;set;}
   Public Boolean blnSummons{get;set;}
   public boolean showAccountReview {get;set;}
    public boolean msgPanel{get;set;}
    public Quick_Doc__c QD {get; set;}
    public Quick_Doc__c QD1 {get; set;}
    public string Description {get; set;}
  //  public List<QuickDoc_CS__c> QDCS {get; set;}
    public List<Quick_Doc_Scripts__c> quickDocScripts{get; set;}
    public List<Quick_Doc_Scripts__c> quickDocScripts1{get; set;}
    public List<Quick_Doc_Scripts__c> quickDocScripts2{get; set;}
    public List<Quick_Doc_Scripts__c> quickDocScripts3{get; set;}
    public list<string> noteslist {get; set;}
    public boolean showPanel {get; set;}
    public boolean showname {get; set;}
    public boolean showEmail {get; set;}
    public boolean showPhone {get; set;}
    public boolean showFax {get; set;}
    public boolean showsave {get; set;}
    public boolean showmessage {get; set;}
    public boolean ShowAccount {get; set;}
    public boolean ShowError {get; set;}
    public boolean showinput {get; set;}
    public string name {get; set;}
    public boolean displayPopup {get; set;}
    public string scriptpane {get; set;}
    public string notespane {get; set;}
    public string Acc {get; set;}
    public string InputText {get; set;}
    public string notes {get; set;}
    public string CancelReason {get; set;}
    public string CreditorName {get; set;}
    public string CreditorName1 {get; set;}
    public string CreditorName2 {get; set;}
    public string CreditorName3 {get; set;}
    public string CreditorName4 {get; set;}
    public string Last4Account {get; set;}
    public string Last4Account1 {get; set;}
    public string Last4Account2 {get; set;}
    public string Last4Account3 {get; set;}
    public boolean showms {get; set;}
    public string EmailReason {get; set;}
    public string CreditorNameLead {get; set;}
    public string DraftAmount {get; set;}
    public string RefundReason {get; set;}
    public string AmountDebt {get; set;}
    public string AmountEstimate {get; set;}
    public string CreditorName11 {get; set;} 
    public boolean showmsa {get; set;}
    public boolean showmsb {get; set;}
    
    
    public QD_AccountReview_CC(){
     //   CreditorName11 = 'Chase';
        blnSummons =false;
        bln1099c =false;
        blnSendLOR = false;
        showAccountReview =false;
        showPanel = FALSE;
        showname = false;
        showphone = false;
        showemail = false;
        showfax = false;
        showsave = true;
        ShowAccount = true;
        displayPopup = false;
        showmessage = false;
        ShowError = false;
        showinput = false;
        showms = false;
        showmsa = false;
        showmsb = false;
        
        Acc = ApexPages.currentPage().getParameters().get('Account');
        system.debug('K@@@'+Acc);
        RecordType sRecordType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'OnBoarding Call'];
        RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Account Review'];
        QD = new Quick_Doc__c(RecordTypeId = sRecordType1.id);
      //  Account Ac = [select id, name from account where name =: Acc];
     //   system.debug('K###'+Ac.id);
     //   QD.Account__c= Ac.id;
        QD1 = new Quick_Doc__c(RecordTypeId = sRecordType.id);
        QD.Conducted_Account_Review__c = true;
        quickDocScripts = new List<Quick_Doc_Scripts__c>();
        noteslist = new list<string>();
        //  QD = [SELECT id, Caller__c, Conducted_Account_Review__c, Description__c, MonthReview__c, Portfolio__c, SSN_Verified__c,Applicant__c from Quick_Doc__c]; 
        
        
    
    }
    
    public Pagereference saveQD(){
     //   try{
        nu_dse__Program__c prog =Null;
             String objAccount = QD.Account__c;
             String portf = QD.Portfolio__c;
             String mnt = QD.MonthReview__c;
             
            // if(string.isEmpty(portf) && string.isEmpty(mnt) && string.isEmpty(objAccount)){
            if((QD.Portfolio__c=='None') && (QD.MonthReview__c=='None') && (string.isEmpty(QD.Account__c))){
              showms = true;
              showmsa = true;
              showmsb = true;
              return null;
          }else
          if(!string.isEmpty(portf) && portf == 'contingency' && string.isEmpty(mnt) && string.isEmpty(objAccount)){
              showms = true;
              showmsa = false;
              showmsb = true;
              return null;
          }else
          if(!string.isEmpty(portf) && portf == 'contingency' && string.isEmpty(mnt) && !string.isEmpty(objAccount)){
              showms = false;
              showmsa = false;
              showmsb = true;
              return null;
          }else
          if(!string.isEmpty(portf) && portf == 'contingency' && !string.isEmpty(mnt) && string.isEmpty(objAccount)){
              showms = true;
              showmsa = false;
              showmsb = false;
              return null;
          
        }else
        {
        
        RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Account Review'];
        if(showPanel){
            QD.Description__c = quickDocScripts[0].Description__c;
            QD.Notes__c = quickDocScripts[0].Notes__c;
        }
        
        QD.recordtypeid = sRecordType1.id;
        Database.upsert(QD);
      system.debug('####'+QD.id);
      
     //   nu_dse__Program__c prog;
       //   nu_dse__Program__c prog = [select id, name from nu_dse__Program__c where id =: 'a0L18000001ABLd'];
       if(QD.Account__c !=Null){
        prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD.Account__c];
       
   //   PageReference redirectPage = new PageReference('/'+QD.Id);
      
          PageReference redirectPage = new PageReference('/'+prog.Id);
          
         return redirectPage;
         }else{
           return Null;
         }
  
      }
    }
    
    public Pagereference saveQDOnboard(){
            nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             String portf = QD1.Portfolio__c;
        system.debug('@@test_kra'+objAccount);
        system.debug('@@test_kra1'+portf);
      //  if (QD1.Portfolio__c == null ) {
          if(string.isEmpty(portf)){
           //   showms = true;
              showmsa = true;
              return null;
          }else
          if(string.isEmpty(objAccount) && portf == 'Timberline'){
            showms = true;
       
            return null;
        }else{  
        

            RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'OnBoarding Call'];
            if(showPanel){
                QD1.Description__c = quickDocScripts1[0].Description__c;
                QD1.Notes__c = quickDocScripts1[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            system.debug('####'+QD1.id);
            if(QD1.Account__c==Null){
            showms = true;
            // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter value'));
             return null;
           
            }
            else{
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
           PageReference redirectPage = new PageReference('/'+prog.Id);
            return redirectPage;
            }
              
       }    
    }
    
    
    public Pagereference saveQDStrategy(){
     
        nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             String portf = QD1.Portfolio__c;
        system.debug('@@test_kra'+objAccount);
        system.debug('@@test_kra1'+portf);
      //  if (QD1.Portfolio__c == null ) {
          if(string.isEmpty(objAccount) && portf == 'Timberline'){
            showms = true;
       
            return null;
        }else{
            RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Strategy Call'];
            if(showPanel){
                QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts2[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        } 
  
    }
    
    public Pagereference saveQDSettlement(){
        
        nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             
             if(string.isEmpty(objAccount)){
            showms = true;
       
            return null;
        }else
        if(((QD1.Creditor_Values__c == 'Creditor/LF/Att Made Offer' || QD1.Creditor_Values__c == 'Negotiator Made Offer' || QD1.Creditor_Values__c == 'Emailed Creditor/LF/Att Offer') && (QD1.Offer_Amount__c == null || QD1.Payments_Terms__c == null || QD1.Settlement_Type__c == null )) ||
          ((QD1.Applicant_Values__c == 'Sent Email To Client - Offer' || QD1.Applicant_Values__c == 'Spoke To Client - Offer') && (QD1.Law_Firm_3rd_Party__c == null || QD1.Original_Creditor__c == null || QD1.Current_Balance__c == null || QD1.Account_Ending__c == null || QD1.Offer_Amount__c == null || QD1.Payments_Terms__c == null || QD1.Settlement_Type__c == null)) ||
          (QD1.Counter_Offer_Made__c && InputText == '')){
            showms = false;
       
            return null;
        }else{
         RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Negotiations'];
            if(showPanel){
             //   QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts3[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        }
    }
    
    public Pagereference saveQDCancelPayment(){
        
        nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             
             if(string.isEmpty(objAccount)){
            showms = true;
       
            return null;
        }else
        if((QD1.Client_Request_To_Cancel__c && CancelReason == '') ){
            showms = false;
       
            return null;
        }
        else{
         RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Pending Cancellation'];
            if(showPanel){
             //   QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts2[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            
           prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        }
    }
    
    public Pagereference saveQDDocuments(){
        nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             
             if(string.isEmpty(objAccount) && QD1.Caller_List__c == null){
              showms = true;
              showmsa = true;
              return null;
          }else
          if(string.isEmpty(objAccount) && QD1.Caller_List__c != null){
            showms = true;
             showmsa = false;
            return null;
        }else
          if(!string.isEmpty(objAccount) && QD1.Caller_List__c == null){
            showms = false;
             showmsa = true;
            return null;
        }else
        if((QD1.Caller_List__c == 'Send LOR/POA' && QD1.Send_LOR_POA__c && (CreditorName1 == '' || Last4Account1 == '')) ||
          (QD1.Caller_List__c == 'Litigation' && QD1.Client_Received_Summons__c && (CreditorName4 == '' || Last4Account =='')) ||
          (QD1.Caller_List__c == '1099C' && QD1.Client_received_1099C__c && CreditorName == '')){
            showms = false;
             showmsa = false;
            return null;
        }
        else{
         RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Documents'];
            if(showPanel){
             //   QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts2[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            system.debug('Kr@'+QD1.id);
            
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        }
    }
    
    public Pagereference saveQDMiscellaneous(){
        
        nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             
             if(string.isEmpty(objAccount) && QD1.Call_Type_Miscellaneous__c == null){
              showms = true;
              showmsa = true;
              return null;
          }else
          if(string.isEmpty(objAccount) && QD1.Call_Type_Miscellaneous__c != null){
            showms = true;
             showmsa = false;
            return null;
        }else
          if(!string.isEmpty(objAccount) && QD1.Call_Type_Miscellaneous__c == null){
            showms = false;
             showmsa = true;
            return null;
        }else
        if((QD1.Call_Type_Miscellaneous__c == 'FDCPA' && QD1.Receiving_3rd_Party_Calls__c && CreditorName1 == '') ||
          (QD1.Call_Type_Miscellaneous__c == 'FDCPA' && QD1.LOR_sent_to_3rd_Party_Collection_Notic__c && QD1.FDCPA_Date_Sent__c == null) ||
          (QD1.Call_Type_Miscellaneous__c == 'FDCPA Lead Post' && QD1.Create_Refferal_To_Client__c && CreditorNameLead == '') ||
          (QD1.Call_Type_Miscellaneous__c == 'Email Client' && QD1.Client_Requests_E_mail__c && EmailReason == '') ){
            showms = false;
             showmsa = false;
            return null;
        }
        else{
         RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Miscellaneous'];
            if(showPanel){
             //   QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts2[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        }
    }
    
    public Pagereference saveQDPayments(){
        /*if(QD1.Call_Type_Payments__c == null)
        showms = true;
        else
        showms = false;
       */ nu_dse__Program__c prog =Null;
             String objAccount = QD1.Account__c;
             
          if(string.isEmpty(objAccount) && QD1.Call_Type_Payments__c == null){
              showms = true;
              showmsa = true;
              return null;
          }else
          if(string.isEmpty(objAccount) && QD1.Call_Type_Payments__c != null){
            showms = true;
             showmsa = false;
            return null;
        }else
          if(!string.isEmpty(objAccount) && QD1.Call_Type_Payments__c == null){
            showms = false;
             showmsa = true;
            return null;
        }else
        if((QD1.Call_Type_Payments__c == 'NSF' && QD1.Able_To_Reschedule__c && QD1.Date_Requested_NSF__c == null) || 
            (QD1.Call_Type_Payments__c == 'Skip Draft' && QD1.Client_Requested_Skip__c && QD1.Date_Skipped__c == null) || 
            (QD1.Call_Type_Payments__c == 'Change Draft Date' && QD1.Change_Draft_Date_Just_1_Time__c && (QD1.Current_Date_Draft__c == null || QD1.Date_Requested_Draft__c == null)) ||
            (QD1.Call_Type_Payments__c == 'Change Draft Date' && QD1.Change_Draft_Day_s_All__c && (QD1.Current_Date_Draft1__c == null || QD1.Date_Requested_Draft1__c == null)) ||
            (QD1.Call_Type_Payments__c == 'Change Draft Amount' && (QD1.Change_Draft_Amount_All__c || QD1.Change_Draft_Amount_1_Time__c) && DraftAmount == '') ||
            (QD1.Call_Type_Payments__c == 'Refund Request' && QD1.Request_Refund__c && RefundReason == '') ||
            (QD1.Call_Type_Payments__c == 'Add/Remove debt' && (QD1.Remove_Debt__c || QD1.Add_Debt__c) && (CreditorName == '' || Last4Account == '' || AmountDebt == ''))||
            (QD1.Call_Type_Payments__c == 'Default on Active Settlement' && QD1.Default_On_Active_Settlement__c && (CreditorName11 == '' || Last4Account1 == '') ||
            (QD1.Call_Type_Payments__c == 'Estimate to Complete' && QD1.Provides_Additional_Funds__c && (AmountEstimate == '' || QD1.Draft_Date_Estimate__c == null)))){
            showms = false;
             showmsa = false;
            return null;
         }else{
         RecordType sRecordType1 = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'Payments'];
            if(showPanel){
             //   QD1.Description__c = quickDocScripts2[0].Description__c;
                QD1.Notes__c = quickDocScripts2[0].Notes__c;
            }
            
            QD1.recordtypeid = sRecordType1.id;
            insert QD1;
            
            prog = [select id, name, nu_dse__Account__c from nu_dse__Program__c where nu_dse__Account__c =: QD1.Account__c];
       
            PageReference redirectPage = new PageReference('/'+prog.Id);
             return redirectPage;
        }
    }
    
    public PageReference CancelQD(){
        PageReference redirectPage = new PageReference('/apex/QuickDoc');
        return redirectPage;
    }
    
    public void clearAll(){
        RecordType sRecordType = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Quick_Doc__c' and Name= 'OnBoarding Call'];
        QD = new Quick_Doc__c();
        QD1 = new Quick_Doc__c(RecordTypeId = sRecordType.id); 
        showPanel = FALSE;
        showmessage = false;
        showsave = true;
        showname = false;
        showphone = false;
        showemail = false;
        showfax = false;
        InputText = '';
        msgPanel = false;
        blnSendLOR = false;
        blnSummons = false;
        bln1099c = false;
        showAccountReview = false;
        quickDocScripts = new list<Quick_Doc_Scripts__c>();
        quickDocScripts1 = new list<Quick_Doc_Scripts__c>();
        quickDocScripts2 = new list<Quick_Doc_Scripts__c>();
        quickDocScripts3 = new list<Quick_Doc_Scripts__c>();
        DraftAmount = '';
        RefundReason = '';
        CreditorName = '';
        Last4Account = '';
        AmountDebt = '';
        CreditorName11 = '';
        Last4Account1 = '';
        AmountEstimate = '';
        CreditorName1 = '';
             Last4Account1 = '';
             CreditorName2 = '';
             Last4Account2 = '';
             CreditorName3 = '';
             Last4Account3 = '';
             CreditorName4 = '';
             Last4Account = '';
             CreditorName = '';
             CreditorName1 = '';
            CreditorNameLead = '';
            EmailReason = '';
           
    }
    
    public void DescriptionQD(){
      
       if(QD.Portfolio__c != null && QD.Portfolio__c != 'Contingency' && QD.MonthReview__c != null){
            showPanel = TRUE;
            showsave = false;
            ShowAccount = false;
            showms = false;
         
            showPanel = TRUE;
            String str = QD.Portfolio__c+'-'+QD.MonthReview__c;
            system.debug('@K'+str);
            quickDocScripts = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c Where Name =:str];
            //quickDocScripts[0].Description__c = 'This is a script for '+QD.MonthReview__c;
            //quickDocScripts[0].Notes__c = 'This is a note for '+QD.MonthReview__c;
            
            scriptpane = quickDocScripts[0].Description__c;
            notespane = quickDocScripts[0].Notes__c;
            
            
            String AditInfo = QD.Additional_Information__c;
            String strNotes = '';
            if(QD.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD.MonthReview__c != NULL)
                strNotes += notespane +'.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts[0].Notes__c = strNotes;
        }else        
          if(QD.Portfolio__c != null && QD.Portfolio__c == 'Contingency' && QD.MonthReview__c != null){
        
            showPanel = TRUE;
            showsave = true;
            ShowAccount = true;
            
            QD.Account__c = QD.Account__c;
         showPanel = TRUE;
            String str = QD.Portfolio__c+'-'+QD.MonthReview__c;
            quickDocScripts = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c Where Name =:str];
            //quickDocScripts[0].Description__c = 'This is a script for '+QD.MonthReview__c;
            //quickDocScripts[0].Notes__c = 'This is a note for '+QD.MonthReview__c;
            scriptpane = quickDocScripts[0].Description__c;
            notespane = quickDocScripts[0].Notes__c;
            
            String AditInfo = QD.Additional_Information__c;
            String strNotes = '';
            if(QD.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD.MonthReview__c != NULL)
                strNotes += notespane +'.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts[0].Notes__c = strNotes;  
        }else{
            showPanel = FALSE;    
        }
        
      /*
        system.debug('###QD.Portfolio__c::'+QD.Portfolio__c);
        if(QD.Conducted_Account_Review__c){
            if(QD.Portfolio__c == 'Attorney'){
                showsave = false;
             //   showmessage = true;
                system.debug('KKKK');
                
            }else{
                showsave = true;
            }
        if(QD.MonthReview__c=='--None--'){
          showPanel = FALSE;
        }
            showPanel = TRUE;
            String str = QD.Portfolio__c+'-'+QD.MonthReview__c;
            quickDocScripts = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c Where Name =:str];
            //quickDocScripts[0].Description__c = 'This is a script for '+QD.MonthReview__c;
            //quickDocScripts[0].Notes__c = 'This is a note for '+QD.MonthReview__c;
            scriptpane = quickDocScripts[0].Description__c;
            notespane = quickDocScripts[0].Notes__c;
            
            String AditInfo = QD.Additional_Information__c;
            String strNotes = '';
            if(QD.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD.MonthReview__c != NULL)
                strNotes += notespane +'.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts[0].Notes__c = strNotes;
        }else{
            showPanel = FALSE;    
        }  */
    
    }
    
    public void ContactPage(){

        if(QD1.Portfolio__c != null && QD1.Portfolio__c != 'Timberline'){
            showPanel = TRUE;
            showsave = false;
            ShowAccount = false;
            showname = true;
            showemail = true;
            showphone = true;
            showfax = true;
            showms = false;
            showmsa = false;
         //   String str = QD1.Portfolio__c+'-'+QD1.MonthReview__c;
            quickDocScripts1 = [Select Id,Name,Description__c,Notes__c, Name__c, Fax__c, Email__c, Phone__c  FROM Quick_Doc_Scripts__c Where Name =: QD1.Portfolio__c];
            
         //   scriptpane = quickDocScripts[0].Description__c;
            String AditInfo = QD1.Additional_Information__c;
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD1.Completed_On_Boarding_Call__c)
                strNotes += 'Notified client of FC transition & welcomed client to program. Verified number of accounts enrolled.  Reviewed Auto-Pay script. Reviewed Special Purpose Savings Account appearing on bank statement. Informed client to send in creditor correspondence & provided hardship script. Set expectations for negotiations timeframe & strategy call. Provided client with CS contact info.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            system.debug('Kranthi');
            quickDocScripts1[0].Notes__c = strNotes;
        }else        
          if(QD1.Portfolio__c != null && QD1.Portfolio__c == 'Timberline'){
        
            showPanel = TRUE;
            showsave = true;
            ShowAccount = true;
            showname = true;
            showemail = true;
            showphone = true;
            showfax = true;
            showmsa = false;
            QD1.Account__c = QD1.Account__c;
         //   String str = QD1.Portfolio__c+'-'+QD1.MonthReview__c;
            quickDocScripts1 = [Select Id,Name,Description__c,Notes__c, Name__c, Fax__c, Email__c, Phone__c  FROM Quick_Doc_Scripts__c Where Name =: QD1.Portfolio__c];
            
         //   scriptpane = quickDocScripts[0].Description__c;
            String AditInfo = QD1.Additional_Information__c;
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD1.Completed_On_Boarding_Call__c)
                strNotes += 'Notified client of FC transition & welcomed client to program. Verified number of accounts enrolled.  Reviewed Auto-Pay script. Reviewed Special Purpose Savings Account appearing on bank statement. Informed client to send in creditor correspondence & provided hardship script. Set expectations for negotiations timeframe & strategy call. Provided client with CS contact info.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            system.debug('Kranthi');
            quickDocScripts1[0].Notes__c = strNotes;  
        }else{
            showPanel = FALSE;    
        }
        
    }
    
    
    public void StrategyPage(){
    
        if(QD1.Portfolio__c != 'Timberline'){
            showPanel = TRUE;
            showsave = false;
            ShowAccount = false;
            showname = true;
            showemail = true;
            showphone = true;
            showfax = true;
            showms = false;
            String str = QD1.Portfolio__c+'-'+'Strategy';
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c, Name__c, Fax__c, Email__c, Phone__c  FROM Quick_Doc_Scripts__c Where Name =: Str];
            
         //   scriptpane = quickDocScripts[0].Description__c;
            String AditInfo = QD1.Additional_Information__c;
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD1.Completed_Strategy_Call__c && (QD1.Portfolio__c == 'Anchor' || QD1.Portfolio__c == 'Bedrock' || QD1.Portfolio__c == 'Boulder' || QD1.Portfolio__c == 'CA - Service' || QD1.Portfolio__c == 'Harbor' || QD1.Portfolio__c == 'Pioneer' || QD1.Portfolio__c == 'Royal'))
                strNotes += 'Conducted 3.5 month strategy call, reviewed 1st priority to settle as per the program strategy. Advised client to send in all collection notices and settlement offers. Educated on the length of the program and advised clients of NSF/Skip that has occurred on the account.\n';
            if(QD1.Completed_Strategy_Call__c && (QD1.Portfolio__c == 'Atlas' || QD1.Portfolio__c == 'Timberline'))
                strNotes += '75 Day call completed, reviewed 1st priority to settle as per the program strategy. Advised client to send in all collection notices and settlement offers. Educated on the length of the program and advised clients of NSF/Skip that has occurred on the account.\n';
            if(QD1.Completed_Strategy_Call__c && (QD1.Portfolio__c == 'Rockwell' || QD1.Portfolio__c == 'StonePoint'))
                strNotes += '';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
         //   if(!String.isEmpty(strNotes))
                quickDocScripts2[0].Notes__c = strNotes;
        }else        
          if(QD1.Portfolio__c != 'None' && QD1.Portfolio__c == 'Timberline'){
        
            showPanel = TRUE;
            showsave = true;
            ShowAccount = true;
            showname = true;
            showemail = true;
            showphone = true;
            showfax = true;
            String str = QD1.Portfolio__c+'-'+'Strategy';
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c, Name__c, Fax__c, Email__c, Phone__c  FROM Quick_Doc_Scripts__c Where Name =: Str];
            
         //   scriptpane = quickDocScripts[0].Description__c;
            String AditInfo = QD1.Additional_Information__c;
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified Last 4 SSN.\n';
            if(QD1.Completed_Strategy_Call__c && (QD1.Portfolio__c == 'Anchor' || QD1.Portfolio__c == 'Bedrock' || QD1.Portfolio__c == 'Boulder' || QD1.Portfolio__c == 'CA - Service' || QD1.Portfolio__c == 'Harbor' || QD1.Portfolio__c == 'Pioneer' || QD1.Portfolio__c == 'Royal'))
                strNotes += 'Conducted 3.5 month strategy call, reviewed 1st priority to settle as per the program strategy. Advised client to send in all collection notices and settlement offers. Educated on the length of the program and advised clients of NSF/Skip that has occurred on the account.\n';
            if(QD1.Completed_Strategy_Call__c && (QD1.Portfolio__c == 'Atlas' || QD1.Portfolio__c == 'Timberline'))
                strNotes += '75 Day call completed, reviewed 1st priority to settle as per the program strategy. Advised client to send in all collection notices and settlement offers. Educated on the length of the program and advised clients of NSF/Skip that has occurred on the account.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts2[0].Notes__c = strNotes;  
        }else{
            showPanel = FALSE;    
        }
        
    }
    
    public void CustomerServicePage_Payment(){
   
    
        String CallType = QD1.Call_Type_Payments__c;
        QD1 = new Quick_doc__c();
        QD1.Call_Type_Payments__c = CallType;
        showPanel = false;
        DraftAmount = '';
        RefundReason = '';
        CreditorName = '';
        Last4Account = '';
        AmountDebt = '';
        CreditorName11 = '';
        Last4Account1 = '';
        AmountEstimate = '';
         if(QD1.Remove_Debt__c ==true ||QD1.Request_Refund__c==true||QD1.Change_Draft_Amount_All__c==true||QD1.Change_Draft_Amount_1_Time__c==true||QD1.Default_On_Active_Settlement__c==true||QD1.Provides_Additional_Funds__c==true ||QD1.Add_Debt__c==true||QD1.Able_To_Reschedule__c==true||QD1.Client_Requested_Skip__c==true||QD1.Change_Draft_Date_Just_1_Time__c==true||QD1.Change_Draft_Day_s_All__c==true){
      msgPanel =true;
    }else{
       msgPanel =false;
    }
    }
    
    public void CustomerServicePage(){
    
    if(QD1.Remove_Debt__c ==true ||QD1.Request_Refund__c==true||QD1.Change_Draft_Amount_All__c==true||QD1.Change_Draft_Amount_1_Time__c==true||QD1.Default_On_Active_Settlement__c==true||QD1.Provides_Additional_Funds__c==true ||QD1.Add_Debt__c==true||QD1.Able_To_Reschedule__c==true||QD1.Client_Requested_Skip__c==true||QD1.Change_Draft_Date_Just_1_Time__c==true||QD1.Change_Draft_Day_s_All__c==true){
      msgPanel =true;
    }else{
       msgPanel =false;
    }
    
        String CallType = QD1.Call_Type_Payments__c;
    //    QD1 = new Quick_doc__c();
        QD1.Call_Type_Payments__c = CallType;
        showPanel = TRUE;
            
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c limit 1];
            
            String CreditorFDCPA = '';
            string DateFDCPA;
            string dateskip;
            datetime DateDraft = system.now();
            string DateRequested;
            String DateDraft1;
            string DateRequested1;
            string DateEst;
            String EstAmt = '';
            String ReasonEmail = '';
            String RsnRefd = '';
            String AmountDraft = '';
            string AmtDbt = '';
            string Last4 = '';
            string Last4A1 = '';
            string Cred = '';
            string dt;
            Integer Day;
            datetime dtt = system.now();
            datetime dtt1 = system.now();
            datetime dtt2 = system.now();
            datetime dtt3 = system.now();
            datetime dtt4 = system.now();
            datetime dtt5 = system.now();
            
            if(QD1.Call_Type_Payments__c != null)
                showmsa = false;

            String AditInfo = QD1.Additional_Information__c;
            
            if(QD1.Call_Type_Payments__c == 'NSF'){
                QD1.Client_Requested_Skip__c =  false;
            }
            
                        
            if(AmountDebt != null)
                AmtDbt = AmountDebt;
            else
                AmtDbt = '';
            if(CreditorName != null)
                CreditorFDCPA = CreditorName;
            else
                CreditorFDCPA = '';
                
            if(Last4Account != null)
                Last4 = '('+Last4Account+')';
            else
                Last4 = '';
            
            if(Last4Account1 != null)
                Last4A1 = '('+Last4Account1+')';
            else
                Last4A1 = '';
                
            if(RefundReason != null)
                RsnRefd = RefundReason;
            else
                RsnRefd = '';
            
            if(AmountEstimate != null)
                EstAmt = AmountEstimate;
            else
                EstAmt  = '';
                
            if(DraftAmount != null)
                AmountDraft = DraftAmount;
            else
                AmountDraft = '';
            
            if(QD1.Date_Requested_NSF__c != null){
                dtt1 = QD1.Date_Requested_NSF__c;
                DateFDCPA = dtt1.formatGMT('MM-dd-yyyy');
            }else
                DateFDCPA = dtt1.formatGMT('01-01-1900');
                
            if(QD1.Date_Skipped__c != null){
                dtt2 = QD1.Date_Skipped__c;
                DateSkip = dtt2.formatGMT('MM-dd-yyyy');
            }else
                DateSkip = dtt2.formatGMT('01-01-1900');
                
            if(QD1.Current_Date_Draft__c != null){
                DateDraft = QD1.Current_Date_Draft__c;
                dt = DateDraft.formatGMT('MM-dd-yyyy'); 
            }    
            else
                dt = DateDraft.formatGMT('01-01-1900');
            
            if(QD1.Date_Requested_Draft__c != null){
                dtt = QD1.Date_Requested_Draft__c;
                DateRequested = dtt.formatGMT('MM-dd-yyyy');
            }else
                DateRequested = dtt.formatGMT('01-01-1900');
            
            if(QD1.Current_Date_Draft1__c != null){
                dtt3 = QD1.Current_Date_Draft1__c;
             //   DateDraft1 = dtt3.dayGmt();
                Day = Dtt3.dayGmt();
                if(Day == 1 || Day == 21 || Day == 31){
                    DateDraft1 = String.valueOf(Day)+'st';
                }else
                if(Day == 2 || Day == 22){
                    DateDraft1 = String.valueOf(Day)+'nd';
                }else
                if(Day == 3 || Day == 23){
                    DateDraft1 = String.valueOf(Day)+'rd';
                }else{
                    DateDraft1 = String.valueOf(Day)+'th';
                }
            }
           else{
                DateDraft1 = '';
                }
            
            if(QD1.Date_Requested_Draft1__c != null){
                dtt4 = QD1.Date_Requested_Draft1__c;
                Day = Dtt4.dayGmt();
                if(Day == 1 || Day == 21 || Day == 31){
                    DateRequested1 = String.valueOf(Day)+'st';
                }else
                if(Day == 2 || Day == 22){
                    DateRequested1 = String.valueOf(Day)+'nd';
                }else
                if(Day == 3 || Day == 23){
                    DateRequested1 = String.valueOf(Day)+'rd';
                }else{
                    DateRequested1 = String.valueOf(Day)+'th';
                }
            }else
                DateRequested1 =  '';
            
            if(QD1.Draft_Date_Estimate__c != null){
                Dtt5 = QD1.Draft_Date_Estimate__c;
                DateEst = dtt5.formatGMT('MM-dd-yyyy');
            }else
                DateEst = dtt5.formatGMT('01-01-1900');
                
            if(CreditorName11 != null)
                cred = CreditorName11;
            else
                cred = '';       
         
    /*------------------------------------------*/
         if(QD1.Draft_Date__c !=Null){
           Integer count =0;
           Date drfDate = QD1.Draft_Date__c;
           Integer dtDay = drfDate.day();
            Integer dtMonth = drfDate.month();
            Integer dtYear = drfDate.year();
           DateTime fromDate = System.today();
            Datetime dtAdjustedDate = Null;
            DateTime draftDate = DateTime.newInstance(dtYear,dtMonth,dtDay+1);
            SYstem.debug('#draftDate '+draftDate );
            if(draftDate  !=Null){
            while(fromDate < draftDate ){
             
                if(fromDate.format('EEE')=='Sun' ||fromDate.format('EEE')=='Sat'){
               // continue;
                }else{
                  count++;
                }
                
               fromDate=fromDate.addDays(1);
            }
            if(count > 4){
              System.debug('#Count'+count);
              
              dtAdjustedDate = System.today()+2;
              if(dtAdjustedDate.format('EEE')=='Sun'){
              QD1.task_Date__c =date.valueOf(dtAdjustedDate+2);
              System.debug('#Sun--'+QD1.task_Date__c);
              }else If(dtAdjustedDate.format('EEE')=='Sat'){
              QD1.task_Date__c =date.valueOf(dtAdjustedDate+1);
             System.debug('#Sat--'+QD1.task_Date__c);
              }else{
              QD1.task_Date__c =System.today()+2;
              } 
            }Else{
            QD1.task_Date__c = System.today();
            }
            }else{
              QD1.task_Date__c =Null;            }
            }
            system.debug('@#@#'+ QD1.task_Date__c);
            system.debug('@#@#------'+ QD1.Draft_Date__c);
    /*------------------------------------------*/
           
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Other_Than_POA__c)
                strNotes += 'Spoke to other than POA.\n';
            if(QD1.Creditor__c)
                strNotes += 'Spoke to Creditor.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified last 4 of SSN.\n';
            if(QD1.Last_4_Digit_SSN__c == 'Did Not Verify Last 4 SSN')
                strNotes += 'Did not verify last 4 of SSN.\n';
            if(QD1.Read_Mini_Miranda__c)
                strNotes += 'Read Mini Miranda.\n';
            if(QD1.Verified_Mini_Miranda__c)
                strNotes += 'Verified Mini Miranda.\n';
            if(QD1.Did_Not_Verify_Mini_Miranda__c)
                strNotes += 'Did not verify Mini Miranda.\n';
            if(QD1.Account_NSF__c && QD1.Call_Type_Payments__c == 'NSF')
                strNotes += 'Account NSF-ed, informed client. \n';
            if(QD1.Able_To_Reschedule__c && QD1.Call_Type_Payments__c == 'NSF')
                strNotes += 'Was able to reschedule draft to '+DateFDCPA+'. \n';
            if(QD1.Recorded_Authorization_NSF__c && QD1.Call_Type_Payments__c == 'NSF')
                strNotes += 'Recorded authorization. \n';
            if(QD1.Uploaded_Authorization_NSF__c && QD1.Call_Type_Payments__c == 'NSF')
                strNotes += 'Uploaded to clients file.\n';
            if(QD1.Task_Set_For_Payments_NSF__c && QD1.Call_Type_Payments__c == 'NSF')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Client_Requested_Skip__c && QD1.Call_Type_Payments__c == 'Skip Draft')
                strNotes += 'Client requested to skip draft '+dateskip+'.\n';
            if(QD1.Recorded_Authorization_SKIP__c && QD1.Call_Type_Payments__c == 'Skip Draft')
                strNotes += 'Recorded authorization. \n';
            if(QD1.Uploaded_Authorization_SKIP__c && QD1.Call_Type_Payments__c == 'Skip Draft')
                strNotes += 'Uploaded to clients file.\n';
            if(QD1.Task_Set_For_Payments_SKIP__c && QD1.Call_Type_Payments__c == 'Skip Draft')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Change_Draft_Date_Just_1_Time__c && QD1.Call_Type_Payments__c == 'Change Draft Date')
                strNotes += 'Client requested to change draft date (one time) from '+dt+' to '+DateRequested+'.\n';
            if(QD1.Change_Draft_Day_s_All__c && QD1.Call_Type_Payments__c == 'Change Draft Date')
                strNotes += 'Client requested to change all future dates from the '+DateDraft1+'  to the '+DateRequested1+' of the month.\n';
            if(QD1.Recorded_Authorization_DRAFTDATE__c && QD1.Call_Type_Payments__c == 'Change Draft Date')
                strNotes += 'Recorded authorization. \n';
            if(QD1.Uploaded_Authorization_DRAFTDATE__c && QD1.Call_Type_Payments__c == 'Change Draft Date')
                strNotes += 'Uploaded to clients file.\n';
            if(QD1.Task_Set_For_Payments_DRAFTDATE__c && QD1.Call_Type_Payments__c == 'Change Draft Date')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Change_Draft_Amount_All__c && QD1.Call_Type_Payments__c == 'Change Draft Amount')
                strNotes += 'Client requesting to change draft amount to $'+AmountDraft+' for all future drafts.\n';
            if(QD1.Change_Draft_Amount_1_Time__c && QD1.Call_Type_Payments__c == 'Change Draft Amount')
                strNotes += 'Client requesting to change draft amount for next draft only to $'+AmountDraft+'.\n';
            if(QD1.Recorded_Authorization_DRAFTAMOUNT__c && QD1.Call_Type_Payments__c == 'Change Draft Amount')
                strNotes += 'Recorded authorization. \n';
            if(QD1.Uploaded_Authorization_DRAFTAMOUNT__c && QD1.Call_Type_Payments__c == 'Change Draft Amount')
                strNotes += 'Uploaded to clients file.\n';
            if(QD1.Task_Set_For_Payments_DRAFTAMOUNT__c && QD1.Call_Type_Payments__c == 'Change Draft Amount')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Changing_Bank_Info__c && QD1.Call_Type_Payments__c == 'Change Bank')
                strNotes += 'Client is changing banks.\n';
            if(QD1.Send_Voided_Check__c && QD1.Call_Type_Payments__c == 'Change Bank')
                strNotes += 'Advised client to send voided check, pre-printed check (not starters check) or document on the letterhead with name, address, routing & account#.\n';
            if(QD1.Task_For_ATD__c && QD1.Call_Type_Payments__c == 'Change Bank')
                strNotes += 'Task set to send ATD form.\n';
            if(QD1.Task_For_ACH__c && QD1.Call_Type_Payments__c == 'Change Bank')
                strNotes += 'Task set to send ACH form.\n';
            if(QD1.Request_Estimate__c && QD1.Call_Type_Payments__c == 'Estimate to Complete')
                strNotes += 'Client requested Estimate to Complete Program.\n';
            if(QD1.Task_Payments__c && QD1.Call_Type_Payments__c == 'Estimate to Complete')
                strNotes += 'Task set for Payments Dept. Advised estimate is good for 7 days.\n';
            if(QD1.Provided_Estimate__c && QD1.Call_Type_Payments__c == 'Estimate to Complete')
                strNotes += 'Informed client of estimate to complete program, and what was factored into it (remaining fees, remaining balancesof active settlements, unsettled debts, and balance in special purpose savings account).\n';
            if(QD1.Provides_Additional_Funds__c && QD1.Call_Type_Payments__c == 'Estimate to Complete')
                strNotes += 'Client provided additional funds: $'+EstAmt+' on '+DateEst+'. Set task for payments.\n';
            if(QD1.Request_Refund__c && QD1.Call_Type_Payments__c == 'Refund Request')
                strNotes += 'Client requested refund; '+RsnRefd+'.\n';
            if(QD1.Recorded_Authorization_REFUND__c && QD1.Call_Type_Payments__c == 'Refund Request')
                strNotes += 'Recorded request. \n';
            if(QD1.Uploaded_Authorization_REFUND__c && QD1.Call_Type_Payments__c == 'Refund Request')
                strNotes += 'Upload to file.\n';
            if(QD1.Task_Set_For_Payments_REFUND__c && QD1.Call_Type_Payments__c == 'Refund Request')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Remove_Debt__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Client requests to remove debt: '+CreditorFDCPA+' '+Last4+' $'+AmtDbt+'.\n';
            if(QD1.Add_Debt__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Client requests to add debt: '+CreditorFDCPA+' '+Last4+' $'+AmtDbt+'.\n';
            if(QD1.Recorded_Authorization_ADD__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Recorded authorization. \n';
            if(QD1.Uploaded_Authorization_ADD__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Uploaded to clients file.\n';
            if(QD1.Task_Set_For_Payments_ADD__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Task set for Payments Dept.\n';
            if(QD1.Request_Written_Confirmation__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'Request client sent in written confirmation.\n';
            if(QD1.Send_In_Statements__c && QD1.Call_Type_Payments__c == 'Add/Remove debt')
                strNotes += 'and send in most recent statements.\n';
            if(QD1.Default_On_Active_Settlement__c && QD1.Call_Type_Payments__c == 'Default on Active Settlement')
                strNotes += 'Client may default on active settlement: '+ cred +' '+Last4A1+'.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts2[0].Notes__c = strNotes;
            
            
    }
    
   
   
    public void PendingCancellation(){
    
        string cr = CancelReason;
        CancelReason = '';
        
        CancelReason = cr;
        if(QD1.Client_Request_To_Cancel__c==false){
            msgPanel =false;
            showAccountReview =false;
            CancelReason = '';
        }else{
            msgPanel =true;
            showAccountReview =true;
        }
  
            showPanel = TRUE;
            showAccount =true;
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c limit 1];
            
         //   scriptpane = quickDocScripts[0].Description__c;
            String AditInfo = QD1.Additional_Information__c;
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Other_Than_POA__c)
                strNotes += 'Spoke to other than POA.\n';
            if(QD1.Creditor__c)
                strNotes += 'Spoke to Creditor.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified last 4 of SSN.\n';
            if(QD1.Last_4_Digit_SSN__c == 'Did Not Verify Last 4 SSN')
                strNotes += 'Did not verify last 4 of SSN.\n';
            if(QD1.Read_Mini_Miranda__c)
                strNotes += 'Read Mini Miranda.\n';
            if(QD1.Verified_Mini_Miranda__c)
                strNotes += 'Verified Mini Miranda.\n';
            if(QD1.Did_Not_Verify_Mini_Miranda__c)
                strNotes += 'Did not verify Mini Miranda.\n';
            if(QD1.Client_Request_To_Cancel__c)
                strNotes += 'Client request to cancel.\n';
            if(!string.isEmpty(CancelReason))
                strNotes += CancelReason+'.\n';    
            if(QD1.To_Pending_Cancellation__c)
                strNotes += 'Placed account in Pending Cancellation.\n';
            if(QD1.Transfer_To_Retention__c)
                strNotes += 'Transfered to retention team.\n';
            if(QD1.Retention_Follow_up_Task__c)
                strNotes += 'Client following up on pending cancellation request, unable to contact Sr. Member of CS, set task for follow up.\n';
            if(QD1.Request_Bankruptcy_Referral__c)
                strNotes += 'Client requests bankruptcy referral.\n';
            if(QD1.X5_Questions_Asked__c)
                strNotes += 'Asked 5 questions per FSOP.\n';
            if(QD1.Task_Set_For_BK_Referral__c)
                strNotes += 'Set a task for BK Referral.\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts2[0].Notes__c = strNotes;
        }
        
        
        public void Documents_d(){
            STRING callt = QD1.Caller_List__c;
            QD1 = new Quick_doc__c();
            QD1.Caller_List__c = callt;
            
             showPanel = false;
             blnSendLOR = false;
             blnSummons = false;
             bln1099c = false;
             showPanel = TRUE;
             CreditorName1 = '';
             Last4Account1 = '';
             CreditorName2 = '';
             Last4Account2 = '';
             CreditorName3 = '';
             Last4Account3 = '';
             CreditorName4 = '';
             Last4Account = '';
             CreditorName = '';
             if(QD1.Send_LOR_POA__c ==true||QD1.Client_Received_Summons__c||QD1.Client_received_1099C__c==true){
               msgPanel  =true;
             }else{
               msgPanel =false;
             }
             quickDocScripts = new list<Quick_Doc_Scripts__c>();
        quickDocScripts1 = new list<Quick_Doc_Scripts__c>();
        quickDocScripts2 = new list<Quick_Doc_Scripts__c>();
        quickDocScripts3 = new list<Quick_Doc_Scripts__c>();
        }
        
        public void Documents(){
       //     QD1 = new Quick_doc__c();
             showPanel = TRUE;
             if(QD1.Send_LOR_POA__c ==true||QD1.Client_Received_Summons__c||QD1.Client_received_1099C__c==true){
               msgPanel  =true;
             }else{
               msgPanel =false;
             }
               
     if(QD1.Caller_List__c != null)
         showmsa = false;
     
     if(QD1.Caller_List__c == 'Send LOR/POA'){
         QD1.Client_Received_Summons__c = false;
     }   
            
  if(QD1.Send_LOR_POA__c==true && QD1.Caller_List__c == 'Send LOR/POA'){
    msgPanel = true;
     blnSendLOR  = true;
      blnSummons = false;
                     bln1099c = false;
     
  }else if(QD1.Client_Received_Summons__c==true && QD1.Caller_List__c == 'Litigation'){
  msgPanel = true;
   blnSummons =true;
 blnSendLOR  = false;
    bln1099c = false;
  }else if(QD1.Client_received_1099C__c && QD1.Caller_List__c == '1099C'){
  msgPanel = true;
   bln1099c = true;
blnSendLOR = false;
              blnSummons = false;
  }else{
  msgPanel = false;
       blnSendLOR = false;
              blnSummons = false;
                     bln1099c = false;
  }      
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c limit 1];
            
            String Creditor1099 = '';
            String CreditorLitigation = '';
            String AcctLitigation = '';
            String CreditorSend1;
            String CreditorSend2;
            String CreditorSend3;
            String AcctSend1 = '';
            String AcctSend3 = '';
            String AcctSend2 = '';

            String AditInfo = QD1.Additional_Information__c;
            
            if(QD1.Caller_List__c == '1099C'){
                QD1.Client_Received_Summons__c = false;
                QD1.Send_LOR_POA__c = false;
                CreditorName4 = '';
                system.debug('KRA####');
            }
            
            if(CreditorName != null)
                Creditor1099 = CreditorName;
            else
                Creditor1099 = '';
                
            if(CreditorName4 != null)
                CreditorLitigation = CreditorName4;
            else
                CreditorLitigation = '';
            
            if(Last4Account != null)
                AcctLitigation = '('+Last4Account+')';
            else
                AcctLitigation = '';
                
            if(CreditorName1 != null)
                CreditorSend1 = CreditorName1;
            else
                CreditorSend1 = '';
                
            if(CreditorName2 != null)
                CreditorSend2 = CreditorName2;
       //     else
         //       CreditorSend2 = '';
                
                system.debug('@@@@'+CreditorName2);
                system.debug('@@@@K'+CreditorName3);
                
            if(CreditorName3 != null)
                CreditorSend3 = CreditorName3;
     //       else
       //         CreditorSend3 = '';
                
            if(Last4Account1 != null)
                AcctSend1 = '('+Last4Account1+')';
            else
                AcctSend1 = '';
                
            if(Last4Account1 != null)
                AcctSend2 = '('+Last4Account2+')';
            else
                AcctSend2 = '';
                
            if(Last4Account1 != null)
                AcctSend3 = '('+Last4Account3+')';
            else
                AcctSend3 = '';
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Other_Than_POA__c)
                strNotes += 'Spoke to other than POA.\n';
            if(QD1.Creditor__c)
                strNotes += 'Spoke to Creditor.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified last 4 of SSN.\n';
            if(QD1.Last_4_Digit_SSN__c == 'Did Not Verify Last 4 SSN')
                strNotes += 'Did not verify last 4 of SSN.\n';
            if(QD1.Read_Mini_Miranda__c)
                strNotes += 'Read Mini Miranda.\n';
            if(QD1.Verified_Mini_Miranda__c)
                strNotes += 'Verified Mini Miranda.\n';
            if(QD1.Did_Not_Verify_Mini_Miranda__c)
                strNotes += 'Did not verify Mini Miranda.\n';
            if(QD1.Send_LOR_POA__c && QD1.Caller_List__c == 'Send LOR/POA' && CreditorName1 == '' && CreditorName2 == '' && CreditorName3 == '')
                strNotes += 'LOR/POA requested to be sent to.\n';
            else
            if(QD1.Send_LOR_POA__c && QD1.Caller_List__c == 'Send LOR/POA' && CreditorName1 != '' && CreditorName2 == '' && CreditorName3 == '')
                strNotes += 'LOR/POA requested to be sent to '+ CreditorSend1 +''+ AcctSend1 +'.\n';
            else
            if(QD1.Send_LOR_POA__c && QD1.Caller_List__c == 'Send LOR/POA' && CreditorName1 != '' && CreditorName2 != '' && CreditorName3 == '')
                strNotes += 'LOR/POA requested to be sent to '+ CreditorSend1 +''+ AcctSend1 +','+CreditorSend2+''+ AcctSend2 +'.\n';
            else
            if(QD1.Send_LOR_POA__c && QD1.Caller_List__c == 'Send LOR/POA' && CreditorName1 != '' && CreditorName2 != '' && CreditorName3 != '')
                strNotes += 'LOR/POA requested to be sent to Kra '+ CreditorSend1 +''+ AcctSend1 +','+CreditorSend2+''+ AcctSend2 +','+CreditorSend3+''+AcctSend3+'.\n';
             //   strNotes += 'LOR/POA requested to be sent to '+ CreditorSend1 +''+ AcctSend1 +','+CreditorSend2+''+ AcctSend2 +','+CreditorSend3+''+AcctSend3+'.\n';
            if(QD1.Task_Set_CS_Outbound_Fax__c && QD1.Caller_List__c == 'Send LOR/POA')
                strNotes += 'Set task for CS Outbound Fax.\n';
            if(QD1.Client_Received_Summons__c && QD1.Caller_List__c == 'Litigation')
                strNotes += 'Client received Summons from '+ CreditorLitigation +''+AcctLitigation+'.\n';
            if(QD1.On_File_Less_Than_48_Hours__c && QD1.Caller_List__c == 'Litigation')
                strNotes += 'Summons on file less than 48 hours, advised client s/he would get a call from our Litigation Dept within 48 hours.\n';
            if(QD1.On_File_Over_48_Hours__c && QD1.Caller_List__c == 'Litigation')
                strNotes += 'Summons on file over 48 hours, transfered client to Litigation Dept.\n';
            if(QD1.Not_On_File__c && QD1.Caller_List__c == 'Litigation')
                strNotes += 'Summons not on File.\n';
            if(QD1.Request_Copy_Via_E_mail_Fax__c && QD1.Caller_List__c == 'Litigation')
                strNotes += 'Advised client to send to us a copy via email or fax, it would be forwarded to our Litigation Dept, will follow up within 10 business days with best course of action.\n';
            if(QD1.Client_received_1099C__c && QD1.Caller_List__c == '1099C')
                strNotes += 'Client received 1099C form for '+ Creditor1099 +'.\n';
            if(QD1.X1099C_On_File__c && QD1.Caller_List__c == '1099C')
                strNotes += '1099C is on file. Advised client to consult a tax professional as we cannot legally provide tax advice. Advised client we will have the account marked as "settled".\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts2[0].Notes__c = strNotes;
        
        }
        
        public void Miscellaneous_M(){
            String CallM = QD1.Call_Type_Miscellaneous__c;
            QD1 = new Quick_Doc__c();
            QD1.Call_Type_Miscellaneous__c = CallM;
            showPanel = false;
            CreditorName1 = '';
            CreditorNameLead = '';
            EmailReason = '';
            
            if(QD1.Receiving_3rd_Party_Calls__c==true||QD1.LOR_sent_to_3rd_Party_Collection_Notic__c==true||QD1.Create_Refferal_To_Client__c==true){
             msgPanel=true;
           }else{
            msgPanel=false;
           }
           
        }
        
        public void Miscellaneous(){
           
           if(QD1.Receiving_3rd_Party_Calls__c==true||QD1.LOR_sent_to_3rd_Party_Collection_Notic__c==true||QD1.Create_Refferal_To_Client__c==true||QD1.Client_Requests_E_mail__c==true){
             msgPanel=true;
           }else{
            msgPanel=false;
           }
           
           if(QD1.Call_Type_Miscellaneous__c != null)
               showmsa = false;
           
            if(QD1.Receiving_3rd_Party_Calls__c == true || QD1.LOR_sent_to_3rd_Party_Collection_Notic__c== true||QD1.Client_Requests_E_mail__c==true){
            msgPanel =true;
            } else if(QD1.Create_Refferal_To_Client__c == true) {
              msgPanel =true;
            }else if(QD1.Client_Requests_E_mail__c == true){
            msgPanel =true;
            }
            else{
            msgPanel =false;
            }
            showPanel = TRUE;
            
            quickDocScripts2 = [Select Id,Name,Description__c,Notes__c  FROM Quick_Doc_Scripts__c limit 1];
            
            String CreditorFDCPA = '';
            string DateFDCPA;
            String CreditorLead = '';
            String ReasonEmail = '';
            String CreditorSend2 = '';
            String CreditorSend3 = '';
            datetime dtt = system.now();
            

            String AditInfo = QD1.Additional_Information__c;
            
                        
            if(CreditorName1 != null)
                CreditorFDCPA = CreditorName1;
            else
                CreditorFDCPA = '';
            
            if(CreditorNameLead != null)
                CreditorLead = CreditorNameLead;
            else
                CreditorLead  = '';
                
            if(EmailReason != null)
                ReasonEmail = EmailReason;
            else
                ReasonEmail = '';
            
             
             if(QD1.FDCPA_Date_Sent__c != null){
                Dtt = QD1.FDCPA_Date_Sent__c;
                DateFDCPA = dtt.formatGMT('MM-dd-yyyy');
            }else
                DateFDCPA = dtt.formatGMT('01-01-1900');
                
            
            
            string strNotes = '';
            if(QD1.Applicant__c)
                strNotes += 'Spoke to Applicant.\n';
            if(QD1.Co_Applicant__c)
                strNotes += 'Spoke to Co-Applicant.\n';
            if(QD1.Other_Than_POA__c)
                strNotes += 'Spoke to other than POA.\n';
            if(QD1.Creditor__c)
                strNotes += 'Spoke to Creditor.\n';
            if(QD1.Verified_Last_4_Digtit_SSN__c)
                strNotes += 'Verified last 4 of SSN.\n';
            if(QD1.Last_4_Digit_SSN__c == 'Did Not Verify Last 4 SSN')
                strNotes += 'Did not verify last 4 of SSN.\n';
            if(QD1.Read_Mini_Miranda__c)
                strNotes += 'Read Mini Miranda.\n';
            if(QD1.Verified_Mini_Miranda__c)
                strNotes += 'Verified Mini Miranda.\n';
            if(QD1.Did_Not_Verify_Mini_Miranda__c)
                strNotes += 'Did not verify Mini Miranda.\n';
            if(QD1.Client_receiving_creditor_calls__c && QD1.Call_Type_Miscellaneous__c == 'Creditor Calls')
                strNotes += 'Client is receiving creditor calls from \n';
            if(QD1.AMEX_BOA_Chase_Discover_Citibank_FNB__c && QD1.Call_Type_Miscellaneous__c == 'Creditor Calls')
                strNotes += 'AMEX/Chase/Discover/First National Bank. Advised client of 3 things to say to creditors when they call. "I have fallen into financial hardship. I am reviewing my payment options based on my budget and other obligations. Please contact me only in writing from now on". Client can refer to the scripts in their welcome package as well.\n';
            if(QD1.Other_Creditor_Gave_Hardship_Script__c && QD1.Call_Type_Miscellaneous__c == 'Creditor Calls')
                strNotes += 'other creditors. Advised client of hardship script. "I have fallen into financial hardship. I am reviewing my payment options based on my budget and other obligations. Please contact me only in writing from now on". Advised client of our strategy with Chase/Discover and the delay in sending the letters of Representation.\n';
            if(QD1.Receiving_3rd_Party_Calls__c && QD1.Call_Type_Miscellaneous__c == 'FDCPA')
                strNotes += 'Client receiving 3rd party calls from '+ CreditorFDCPA+'.\n';
            if(QD1.FDCPA_Guidelines_Discussed__c && QD1.Call_Type_Miscellaneous__c == 'FDCPA')
                strNotes += 'Advised of FDCPA guidelines.\n';
            if(QD1.LOR_sent_to_3rd_Party_Collection_Notic__c && QD1.Call_Type_Miscellaneous__c == 'FDCPA')
                strNotes += 'LOR was sent on '+ DateFDCPA+'. Advised client to send in the proof collector contacting them after the LOR was sent.\n';
            if(QD1.Create_Refferal_To_Client__c && QD1.Call_Type_Miscellaneous__c == 'FDCPA Lead Post')
                strNotes += 'Created FDCPA lead post to submit to Client First. Collector: '+CreditorLead  +'. Asked client to send in proof of violation: [collection notice, screen shot of the phone call on Caller ID, save voice mail message] Advised we submitted a complaint and client will be contacted by FDCPA attorney.\n';
            if(QD1.Client_Requests_E_mail__c && QD1.Call_Type_Miscellaneous__c == 'Email Client')
                strNotes += 'Client requests e-mail '+ReasonEmail +'.\n';
            if(QD1.Task_Set_for_Outbound_E_mail_to_Client__c && QD1.Call_Type_Miscellaneous__c == 'Email Client')
                strNotes += 'Task set for "Outbound E-mail to client".\n';
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            quickDocScripts2[0].Notes__c = strNotes;
        }
    
    public void SettlementSpreadPage(){
        
        if((QD1.Applicant_Values__c == Null && QD1.Creditor_Values__c==null)&&QD1.Counter_Offer_Made__c==false ){
        msgPanel =false;
        }
        else{
        msgPanel =true;
        }
        quickDocScripts3 = [Select Id,Notes__c FROM Quick_Doc_Scripts__c limit 1];
        String AditInfo = QD1.Additional_Information__c;
        string Creditor = '';
        string Payment = '';
        string Sattlementtype = '';
        string accend = '';
        string lawfirm = '';
        string orgcreditor = '';
        string counteroffer = '';
        string curofr = '';
        string phone = '';
        
        if(QD1.Offer_Amount__c != null)
            Creditor = QD1.Offer_Amount__c;
        else
            Creditor = '';
        
        if(QD1.Payments_Terms__c != null)
            payment = QD1.Payments_Terms__c;
        else
            payment = '';
            
         if(QD1.Settlement_Type__c != null)
             Sattlementtype = QD1.Settlement_Type__c;
         else
             Sattlementtype = '';
         
         if(QD1.Account_Ending__c != null)
             accend = QD1.Account_Ending__c;
         else
             accend = '';
         
         if(QD1.Law_Firm_3rd_Party__c != null)
             lawfirm = QD1.Law_Firm_3rd_Party__c;
         else
             lawfirm = '';
             
         if(QD1.Original_Creditor__c != null)
             orgcreditor = QD1.Original_Creditor__c;
         else
             orgcreditor = '';
             
         if(inputtext != null)
             counteroffer = inputtext;
         else
             counteroffer = '';
         
         if(QD1.Current_Balance__c != null)
             curofr = QD1.Current_Balance__c;
         else
             curofr = '';
          
         if(QD1.Phone__c != null)
             phone = QD1.Phone__c;
         else
             phone = '';
                 
            
            showPanel = true;
            string strNotes = '';
            if(QD1.Applicant_Values__c == 'Sent Email To Client - Offer')
                strNotes += 'Sent email to client regarding offer: '+ lawfirm +'/'+ orgcreditor +' ('+ accend +') $'+ Creditor +' over '+ payment +' payment(s). Current Balance: $'+ curofr +' - '+ Sattlementtype +'.\n';
            if(QD1.Applicant_Values__c == 'Spoke To Client - Offer')
                strNotes += 'Spoke regarding offer: '+ lawfirm +'/'+ orgcreditor +' ('+ accend +') $'+ Creditor +' over '+ payment +' payment(s). Current Balance: $'+ curofr +' - '+ Sattlementtype +'.\n';
            if(QD1.Recorded_Authorization__c)
                strNotes += 'Recorded authorization;.\n';
            if(QD1.Client_Direct__c)
                strNotes += 'Client will be making payments to the creditor.\n';
            if(QD1.SPSA__c)
                strNotes += 'Settlement will be paid from SPSA account.\n';
            if(QD1.Creditor_Values__c == 'Creditor/LF/Att Made Offer')
                strNotes += 'Creditor made an offer: $'+ Creditor +' over '+ payment +' payment(s) - '+ Sattlementtype +'.\n';
            if(QD1.Creditor_Values__c == 'Negotiator Made Offer')
                strnotes += 'Negotiator made an offer: $'+ Creditor +' over '+ payment +' payment(s) - '+ Sattlementtype +'.\n';
            if(QD1.Creditor_Values__c == 'Emailed Creditor/LF/Att Offer')
                strNotes += 'Emailed Creditor offer: $'+ Creditor +' over '+ payment +' payment(s) - '+ Sattlementtype +'.\n';    
            if(QD1.Waiting_For_Response__c)
                strNotes += 'Waiting to hear back regarding the offer.\n';
            if(QD1.Will_Follow_Up__c)
                strNotes += 'Will follow up.\n';    
            if(QD1.Waiting_For_Attorney_Approval__c)
                strNotes += 'Waiting for attorney approval.\n';
            if(QD1.Offer__c == 'Accepted')
                strNotes += 'Offer Accepted.\n';
            if(QD1.Offer__c == 'Declined')
                strNotes += 'Offer Declined.\n';
            if(QD1.Counter_Offer_Made__c)
                strNotes += 'Counter offer made: $'+ counteroffer +'.\n';  
            if(QD1.Phone__c != null)
                strNotes += 'Phone # ' +Phone+'.\n';  
            if(!string.isEmpty(AditInfo))
                strNotes += AditInfo;
            system.debug('Kranthi');
            quickDocScripts3[0].Notes__c = strNotes;
            notes = strnotes;
            noteslist.add(strnotes);
            
        
    }
    
    public void closePopup(){        
        displayPopup = false;    
    }     
    public void showPopup(){  
    system.debug('@@@@');      
        displayPopup = true;    
    }
    
    public void NotePanQD(){
        
    }
    public Pagereference getselection(){
        string s = ApexPages.currentPage().getParameters().get('selectid');
        system.debug('###s::'+s);    
        DescriptionQD();
        return null;
    }

}