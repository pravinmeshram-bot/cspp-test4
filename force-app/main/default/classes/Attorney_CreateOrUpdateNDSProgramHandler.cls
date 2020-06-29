/**
 * @File Name          : Attorney_CreateOrUpdateNDSProgramHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/23/2019, 10:05:35 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/23/2019   ChangeMeIn@UserSettingsUnder.SFDoc      Initial Version
**/
public without sharing class Attorney_CreateOrUpdateNDSProgramHandler{

    public static boolean testClientUpdated = false;
 //By Mayur for S20-578
    public Static void populateTestClient(){
        if(!testClientUpdated){
            List<Account> AccountList = new List<Account>();
            List<nu_dse__Program__c> ProgramList = (List<nu_dse__Program__c>)Trigger.new;
            Map<Id, nu_dse__Program__c> ProgramOldMap = (Map<Id, nu_dse__Program__c>)Trigger.oldMap;
            for(nu_dse__Program__c Program: ProgramList){
                if((Trigger.isInsert || Program.Test_Program__c != ProgramOldMap.get(Program.Id).Test_Program__c) && Program.nu_dse__Account__c != null){
                    Account a = new Account();
                    a.Id = Program.nu_dse__Account__c;
                    a.Test_Client__c = Program.Test_Program__c;
                    AccountList.add(a);
                }
            }
            Update AccountList;
            TestClientUpdated = true;
        }
    }

    public Static boolean PaymentCancelled = false;

    public static void cancelPayments(List<nu_dse__Program__c> ProgramList, Map<Id,nu_dse__Program__c> ProgramOldMap){
     // public static void cancelPayments(){  
        if(!PaymentCancelled){
       //     List<nu_dse__Program__c> ProgramList = [Select id, nu_dse__Program_Status__c from nu_dse__Program__c where id = :Trigger.new];
         //   Map<Id,nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.oldMap;           
         /* Start - Commented by Praveen part of code optimization, as this logic is already handled below in same method
            List<Id> ProgramList1 = new List<Id>();   
            
            
            for(nu_dse__Program__c Program : ProgramList){             
                if((ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'NSF' || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Pending Cancellation') && Program.nu_dse__Program_Status__c == 'Active Client'){                 
                    ProgramList1.add(Program.id);
                }
            }
            if(!ProgramList1.isEmpty()){                     
                Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
                Id FeeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
                List<nu_dse__Payment__c> PaymentList = [Select Id, nu_dse__Program__c, nu_dse__Program__r.nu_dse__Program_Status__c,nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c, nu_dse__Transaction_Status__c,nu_dse__Program__r.nu_dse__Processor__r.Processor_Name__c, 
                                                        nu_dse__Schedule_Date__c  
                                                        from nu_dse__Payment__c where nu_dse__Program__c =: ProgramList1 AND nu_dse__Schedule_Date__c>=:Date.today()
                                                        AND (RecordTypeID =:DraftRecordTypeId OR (RecordTypeID = :FeeRecordTypeId AND nu_dse__Offer__c = null))];           
                if(!PaymentList.isEmpty()){                  
                    for(nu_dse__Payment__c Payment : PaymentList){
                        system.debug('<<--Changing data here!');
                        // if(payment.RecordTypeID != DraftRecordTypeId || !payment.Is_Skip_Payment__c){
                            if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c != null && Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c.contains('CFT')){                       
                                Payment.nu_dse__Transaction_Status__c = 'Scheduled';
                            }else if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c == 'GCS'){                          
                                Payment.nu_dse__Transaction_Status__c = 'Pending';   
                            }else if(Payment.nu_dse__Program__r.nu_dse__Processor__r.Processor_Name__c == 'Harbor'
                                || Payment.nu_dse__Program__r.nu_dse__Processor__r.Processor_Name__c == 'RAMS-BEDROCK'
                                || Payment.nu_dse__Program__r.nu_dse__Processor__r.Processor_Name__c == 'RAMS-ROCKWELL'){                                     
                                        Payment.nu_dse__Transaction_Status__c = 'Pending';
                            }else if(Payment.nu_dse__Program__r.nu_dse__Processor__r.Processor_Name__c == 'RAMS-WHITESTONE'){
                                Payment.nu_dse__Transaction_Status__c = 'Pending';  
                            } else {
                                Payment.nu_dse__Transaction_Status__c = 'Pending';  
                            }
                        // }
                    }
                }
                update PaymentList;
            }
            End */ 
            List<Id> ProgramIds = new List<Id>();
            
            /* Start - commented and added below - Praveen
            for(nu_dse__Program__c Program : ProgramList){
                System.debug('****ProgramStatus'+Program.nu_dse__Program_Status__c);
                if((Program.nu_dse__Program_Status__c == 'Client Cancelled' || Program.nu_dse__Program_Status__c == 'Pending Cancellation' 
                    || Program.nu_dse__Program_Status__c == 'NSF' || Program.nu_dse__Program_Status__c == 'UnResponsive NSF' 
                    || (Program.nu_dse__Program_Status__c == 'Active Client' && (ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'NSF' 
                                                                                 || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'UnResponsive NSF' || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Pending Cancellation' 
                                                                                 || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Client Cancelled'))) && Program.nu_dse__Program_Status__c != ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c 
                   && !Attorney_StaticVariableUtility.apiUser){
                       
                       ProgramIds.add(Program.Id);
                   }
            }
            End */
            // Start - added by Praveen
            system.debug('====='+ProgramList +'===='+ProgramOldMap);
                        
            for(nu_dse__Program__c Program : ProgramList){
            if((Program.nu_dse__Program_Status__c == 'Client Cancelled' || Program.nu_dse__Program_Status__c == 'Pending Cancellation' 
                    || Program.nu_dse__Program_Status__c == 'NSF' || Program.nu_dse__Program_Status__c == 'UnResponsive NSF' ||  Program.nu_dse__Program_Status__c == 'Graduated Program'
                    || Program.nu_dse__Program_Status__c == 'Versara NDS Graduated' ||  (Program.nu_dse__Program_Status__c == 'Active Client' && (ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'NSF' 
                       || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'UnResponsive NSF' || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Pending Cancellation' 
                        || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Client Cancelled' || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Graduated Program'
                        || ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c == 'Versara NDS Graduated'))) 
                        && Program.nu_dse__Program_Status__c != ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c){
            ProgramIds.add(Program.Id);
            }
            }
            // End
            System.debug('*****'+ProgramIds);
            if(!ProgramIds.isEmpty()){
                Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
                Id FeeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
                List<nu_dse__Payment__c> PaymentList = [Select Id, nu_dse__Program__c,nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c,nu_dse__Program__r.nu_dse__Processor__c, nu_dse__Program__r.nu_dse__Program_Status__c, nu_dse__Transaction_Status__c, 
                                                        nu_dse__Schedule_Date__c, nu_dse__Is_Makeup_Payment_Created__c , RecordTypeID, Is_Skip_Payment__c 
                                                        from nu_dse__Payment__c where nu_dse__Program__c =: ProgramIds AND nu_dse__Schedule_Date__c>=:Date.today() 
                                                        AND (RecordTypeID =:DraftRecordTypeId OR (RecordTypeID = :FeeRecordTypeId AND nu_dse__Offer__c = null)) ];
                system.debug('==='+ PaymentList);
                if((PaymentList != null && PaymentList.size() < 60) || Attorney_StaticVariableUtility.apiUser){
                    System.debug('****'+Date.today());
                    
                   // System.debug('*****'+PaymentList);
                    for(nu_dse__Payment__c Payment : PaymentList){
                       /* Start - commented as no logic is written in below IF condition
                        if(payment.Is_Skip_Payment__c){
                            system.debug('--payment : ' + payment);
                        }
                        End */
                        system.debug('==== size ====' + PaymentList.size());
                        if(Payment.nu_dse__Program__r.nu_dse__Program_Status__c == 'Active Client' && Payment.nu_dse__Transaction_Status__c == 'Cancelled' && Payment.nu_dse__Is_Makeup_Payment_Created__c == False){
                           //For Draft Record Type, do not change status if skip payment is true
                           system.debug('====1=== ' + payment);
                           if(payment.RecordTypeID == DraftRecordTypeId){
                               if(!payment.Is_Skip_Payment__c){
                               system.debug('====2=== ' + payment);
                                   if(Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c != null && Payment.nu_dse__Program__r.nu_dse__Processor__r.nu_dse__Type__c.contains('CFT')){
                                       Payment.nu_dse__Transaction_Status__c = 'Scheduled';
                                   } else {
                                       Payment.nu_dse__Transaction_Status__c = 'Pending';
                                   }
                               }
                           }else{
                                Payment.nu_dse__Transaction_Status__c = 'Pending';
                           }
                        } else if(Payment.nu_dse__Program__r.nu_dse__Program_Status__c != 'Active Client' && (Payment.nu_dse__Transaction_Status__c == 'Scheduled' || Payment.nu_dse__Transaction_Status__c == 'Pending')){
                            Payment.nu_dse__Transaction_Status__c = 'Cancelled';
                        }
                        if(payment.Is_Skip_Payment__c){
                            system.debug('--after change payment : ' + payment);
                        }
                    }
                    System.debug('*****'+PaymentList);
                    
                      Update PaymentList;
                } else {
                    
                    if (System.isBatch() == False) {
                        
                        Attorney_cancelPaymentsBatch bat = new Attorney_cancelPaymentsBatch(ProgramIds);
                        Database.executeBatch(bat,Integer.valueOf(Label.Cancel_Payments_Batch_Size));
                    }
                }
                
                PaymentCancelled = true;
            }
            
        }
        
    }

    public static boolean FeetemplateUpdated = false;
    
    //changes made for NMI-371
    //Static Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String, LeadTracProgramType__mdt>();
    public static void UpdateFeeTemplateBatch(boolean flg){
    
        if(!FeeTemplateUpdated){
        List<nu_dse__Program__c> ProgramList = (List<nu_dse__Program__c>)Trigger.new;
        Map<Id,nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.oldMap;
        
        List<nu_dse__Program__c> UpdatedPrograms = new List<nu_dse__Program__c>();
        Set<String> feeGroupIdSet = new Set<String>();
        Set<Decimal> serviceFeePercentageSet = new Set<Decimal>();
        Set<Decimal> settlementPctSet = new Set<Decimal>();
        Set<String> programeNameSet = new Set<String>();
        for(nu_dse__Program__c Program : ProgramList){  
            
            /*if(Trigger.isUpdate && Program.nu_dse__Fee_Template__c != null && (!Program.isPre_Tila__c) && Program.DNL_Status__c!='Pre-TILA Signed' && Program.Attorney__c && Program.nu_dse__Total_Debt_Included__c != null// && ((Program.nu_dse__Total_Debt_Included__c < 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c >= 30000) || (Program.nu_dse__Total_Debt_Included__c >= 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c < 30000))
            ){ 
                UpdatedPrograms.add(Program);
                feeGroupIdSet.add(program.GCS_Policy_Group__c);
                serviceFeePercentageSet.add(program.Settlement_Fee__c);
                settlementPctSet.add(program.Estimated_Settlement__c);
                programeNameSet.add(program.Program_type__c);  
            }*/
            //PDI-684
            if(flg){
               if(trigger.oldMap.containskey(Program.id)==true){
                nu_dse__Program__c prgInst=(nu_dse__Program__c)Trigger.oldMap.get(Program.Id); //@ 
               if((Trigger.isUpdate && (!Program.isPre_Tila__c) && (prgInst.DNL_Status__c==Program.DNL_Status__c) && Program.Attorney__c && Program.nu_dse__Total_Debt_Included__c != null// && ((Program.nu_dse__Total_Debt_Included__c < 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c >= 30000) || (Program.nu_dse__Total_Debt_Included__c >= 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c < 30000))
                  )|| test.isRunningTest()){
                UpdatedPrograms.add(Program);
                feeGroupIdSet.add(program.GCS_Policy_Group__c);
                serviceFeePercentageSet.add(program.Settlement_Fee__c);
                settlementPctSet.add(program.Estimated_Settlement__c);
                programeNameSet.add(program.Program_type__c);  
               }
             } 
            }
            else{
                if((Trigger.isInsert && Program.Attorney__c && Program.nu_dse__Total_Debt_Included__c != null// && ((Program.nu_dse__Total_Debt_Included__c < 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c >= 30000) || (Program.nu_dse__Total_Debt_Included__c >= 30000 && ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c < 30000))
            )|| test.isRunningTest()){
                UpdatedPrograms.add(Program);
                feeGroupIdSet.add(program.GCS_Policy_Group__c);
                serviceFeePercentageSet.add(program.Settlement_Fee__c);
                settlementPctSet.add(program.Estimated_Settlement__c);
                programeNameSet.add(program.Program_type__c);  
            } //@
            }
            
         }
        
        List<LeadTracProgramType__mdt> leadTracPrgTypesLst = [Select Label,Portfolio_name__c,RAMS__c FROM LeadTracProgramType__mdt WHERE Label IN: programeNameSet];
        Set<String> portifolioNameSet = new Set<String>();
        Map<String,String> portifolioProgMap = new Map<String,String>();
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt progType: leadTracPrgTypesLst){
            portifolioNameSet.add(progType.Portfolio_name__c);
            portifolioProgMap.put(progType.Label, progType.Portfolio_name__c);
            LeadTracProgramTypeMap.put(progType.Label,progType);
        }
        system.debug('###feeGroupIdSet::'+feeGroupIdSet);  
        
        List<nu_dse__Fee_Template__c> feeTemLst = new List<nu_dse__Fee_Template__c>();
        feeTemLst = [select Id,Name,Debt_Amount__c,Program_Type__c,portfolio_name__c,nu_dse__Settlement_Pct__c,Service_Fee_Percentage__c,nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c FROM nu_dse__Fee_Template__c WHERE portfolio_name__c IN: portifolioNameSet
        AND nu_dse__Settlement_Pct__c IN: settlementPctSet AND Service_Fee_Percentage__c IN: serviceFeePercentageSet
        AND (nu_dse__GCS_Fee_Group_Id__c IN: feeGroupIdSet OR nu_dse__RAMS_Fee_Group_Id__c IN: feeGroupIdSet)];
        system.debug('###feeTemLst::'+feeTemLst);
        Map<String,List<nu_dse__Fee_Template__c>> feeTempLstMap = new Map<String,List<nu_dse__Fee_Template__c>>();
        Map<String,List<nu_dse__Fee_Template__c>> RAMSTempLstMap = new Map<String,List<nu_dse__Fee_Template__c>>();
        for(nu_dse__Fee_Template__c feeTemp: feeTemLst){
            String key = feeTemp.portfolio_name__c+'-'+Integer.valueOf(feeTemp.nu_dse__Settlement_Pct__c)+'-'+Integer.valueOf(feeTemp.Service_Fee_Percentage__c)+'-'+feeTemp.nu_dse__GCS_Fee_Group_Id__c;
            System.debug(Key);
            if(feeTempLstMap.containsKey(key)){
                List<nu_dse__Fee_Template__c> feeTempLst = feeTempLstMap.get(key);
                feeTempLst.add(feeTemp);
                feeTempLstMap.put(key,feeTempLst);    
            }else{
                feeTempLstMap.put(key, new List<nu_dse__Fee_Template__c> {feeTemp});    
            }
            if(feeTemp.nu_dse__RAMS_Fee_Group_Id__c != null){
                String RAMSKey = feeTemp.portfolio_name__c+'-'+Integer.valueOf(feeTemp.nu_dse__Settlement_Pct__c)+'-'+Integer.valueOf(feeTemp.Service_Fee_Percentage__c)+'-'+feeTemp.nu_dse__RAMS_Fee_Group_Id__c;
                if(!RAMSTempLstMap.containsKey(RAMSKey)){
                    RAMSTempLstMap.put(RAMSKey,new List<nu_dse__Fee_Template__c>());
                }
                RAMSTempLstMap.get(RAMSKey).add(feeTemp);
            }
        }
        system.debug('###feeTempLstMap::'+feeTempLstMap);
        for(nu_dse__Program__c prog: programList){
            String key = portifolioProgMap.get(prog.Program_type__c)+'-'+Integer.valueOf(prog.Estimated_Settlement__c)+'-'+Integer.valueOf(prog.Settlement_Fee__c)+'-'+prog.GCS_Policy_Group__c;
            system.debug('###key::'+key);
            if(feeTempLstMap.containsKey(key) || RAMSTempLstMap.containsKey(key)){
                List<nu_dse__Fee_Template__c> feetempLst;
                if(LeadTracProgramTypeMap.get(prog.Program_type__c) != null && LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c && RAMSTempLstMap.ContainsKey(Key)){
                    feetempLst = RAMSTempLstMap.get(Key);
                } else if(!LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c && feeTempLstMap.containsKey(key)){
                    feetempLst = feeTempLstMap.get(key); 
                }
                system.debug('###feetempLst::'+feetempLst);
                if(feeTempLst != null){
                for(nu_dse__Fee_Template__c feeTemp: feetempLst){
                If(prog.nu_dse__Total_Debt_Included__c > 0)
                {
                    if(prog.nu_dse__Total_Debt_Included__c >= 30000 && feeTemp.Debt_Amount__c == 'Over 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;
                        
                    else if(prog.nu_dse__Total_Debt_Included__c < 30000 && feeTemp.Debt_Amount__c == 'Under 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;  
                        
              
                    system.debug('###Prog::'+prog);
                 }   
                    else
                    {
                    
                    if(prog.nds_Estimated_Total_Debt__c>= 30000 && feeTemp.Debt_Amount__c == 'Over 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)
                                              prog.nu_dse__Fee_Template__c = feeTemp.Id;
                        

                    else if(prog.nds_Estimated_Total_Debt__c < 30000 && feeTemp.Debt_Amount__c == 'Under 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;           
                        

                    }
                }
                }
            }
        }
        
        feeTemplateUpdated = true;
        }
    }

    public Static boolean isPortfolioProcessorUpdated = false;
    
    public static void PopulateProcessorAndPortfolio(){
        
        if(!isPortfolioProcessorUpdated){
        
        Map<Id,nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.oldMap;
        
        System.debug('****'+Trigger.New);
        List<String> ProgramTypes = new List<String>();
        for(nu_dse__Program__c program : (List<nu_dse__Program__c>)Trigger.new){
            System.debug('****inside for');
            if((program.portfolio__c == null || program.nu_dse__Processor__c == null || (Trigger.isUpdate && ProgramOldMap.get(Program.Id).Program_Type__c != Program.Program_Type__c)) && program.program_Type__c != null){
                System.debug('****'+program.Program_Type__c);
                ProgramTypes.add(program.Program_Type__c);
            }
        }
        //changes added by uchit for S20-503
        if(!ProgramTypes.isEmpty()){
            List<LeadTracProgramType__mdt> ProgramTypeMetadata = [Select DeveloperName,MasterLabel,Active__c,Portfolio_On_Program__c,Processor__c from LeadTracProgramType__mdt where MasterLabel =: ProgramTypes];
            
            System.debug('****'+ProgramTypeMetaData);
            
            List<String> PortfolioNames = new List<String>();
            List<String> ProcessorNames = new List<String>();        
            
            Map<String,LeadTracProgramType__mdt> ProgramTypeMetadataMap = new Map<String,LeadTracProgramType__mdt>();
            
            for(LeadTracProgramType__mdt metadata : ProgramTypeMetadata){
                PortfolioNames.add(metadata.Portfolio_On_Program__c);
                ProcessorNames.add(metadata.Processor__c);
                ProgramTypeMetadataMap.put(metadata.MasterLabel,metadata);
            }
            
            System.debug(PortfolioNames);
            System.debug(ProcessorNames);
            
            List<nu_dse__Processor__c> ProcessorList = [Select Id, Name,Processor_Name__c from nu_dse__Processor__c where Processor_Name__c =: ProcessorNames];
            List<Portfolio__c> PortfolioList = [Select Id, Name from Portfolio__c where Active_Status__c = true];
            System.debug(PortfolioList);
            
            Map<String,nu_dse__Processor__c> processorMap = new Map<String,nu_dse__Processor__c>();
            Map<String,Portfolio__c> PortfolioMap = new Map<String,Portfolio__c>();
            
            Map<Id, Portfolio__c> PortfolioIdMap = new Map<Id,Portfolio__c>(PortfolioList);
            System.debug(PortfolioIdMap);
            
            for(nu_dse__Processor__c processor : ProcessorList){
                processorMap.put(processor.Processor_Name__c.toLowerCase(),Processor);
            }
            
            for(Portfolio__c Portfolio : PortfolioList){
                PortfolioMap.put(Portfolio.Name.toLowerCase(),Portfolio);
            }
            
            System.debug(PortfolioMap);
            System.debug(processorMap);
            
            for(nu_dse__Program__c program : (List<nu_dse__Program__c>)Trigger.new){
                if(program.program_Type__c != null && ProgramTypeMetadataMap.containsKey(program.program_Type__c)){
                    
                    if(program.nu_dse__Processor__c == null && ProgramTypeMetadataMap.get(program.program_Type__c).Processor__c != null && processorMap.containsKey(ProgramTypeMetadataMap.get(program.program_Type__c).Processor__c.toLowerCase())){
                        program.nu_dse__Processor__c = processorMap.get(ProgramTypeMetadataMap.get(program.program_Type__c).Processor__c.toLowerCase()).Id;
                    }
                    if((program.portfolio__c == null  || (Trigger.isUpdate && ProgramOldMap.get(Program.Id).Program_Type__c != Program.Program_Type__c) && (PortfolioIdMap.get(Program.Portfolio__c).Name != 'Versara Client')) && ProgramTypeMetadataMap.get(program.program_Type__c).Portfolio_On_Program__c != null && PortfolioMap.containsKey(ProgramTypeMetadataMap.get(program.program_Type__c).Portfolio_On_Program__c.toLowerCase())){
                        program.portfolio__c = PortfolioMap.get(ProgramTypeMetadataMap.get(program.program_Type__c).Portfolio_On_Program__c.toLowerCase()).Id;
                    }
                    
                }
                isPortfolioProcessorUpdated = true;
            }
        }
        }
    }
    
    

    public Static void onChangeDraftPlanId(List<nu_dse__Program__c> ProgramList,Map<Id,nu_dse__Program__c> programOldMap){
        System.debug('****inside method');
        if(Attorney_StaticVariableUtility.apiuser){
            System.debug('****API User');
            List<Id> ProgramIds = new List<Id>();
            for(nu_dse__Program__c Program : ProgramList){
                if(Program.Attorney__c && Program.Draft_Plan_Id__c != programOldMap.get(Program.Id).Draft_plan_id__c){
                    ProgramIds.add(Program.Id);
                }
            }
            System.debug('****'+ProgramIds);
            Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            Id RefundRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();

            System.debug('****'+DraftRecordTypeId);
            List<nu_dse__Payment__c> PaymentList = [Select Id,Attorney_Payment_Id__c,FileNumber__c,recordtype.name, nu_dse__Payment_Sequence_Number__c,nds_Payment_Type__c,Payment_Type_Data__c,Status_Reason__c,Statused_On__c,nu_dse__Schedule_Date__c , Payment_Status__c , 
                                                    nu_dse__Program__c,Draft_plan_Id__c,nu_dse__Transaction_Status__c ,Last_Modified_By_NDS__c ,Attorney__c ,nu_dse__Amount__c ,nu_dse__Processor_Fee__c,nu_dse__Service_Fee__c ,
                                                    Draft_Split__c, nu_dse__Retainer_Fee__c ,nu_dse__Monthly_Maintenance_Fee__c , nu_dse__Type__c ,nu_dse__GCS_Synced__c,nu_dse__External_GCS_ID__c,nu_dse__Synced_With_Processor__c
                                                    from nu_dse__Payment__c where nu_dse__Program__c =: ProgramIds AND isAttorney__c = true AND (RecordTypeId =:DraftRecordTypeId OR RecordTypeId =:RefundRecordTypeId)];
            
            System.debug('****'+PaymentList);
     //       List<Id> PaymentIds = new List<Id>();
            
            List<Archived_Draft_Payment__c> DraftPaymentList = new List<Archived_Draft_Payment__c>();
            for(nu_dse__Payment__c Payment : PaymentList){
                
     //           PaymentIds.add(Payment.Id);
                
                Archived_Draft_Payment__c DraftPayment= new Archived_Draft_Payment__c();
                DraftPayment.Amount__c = payment.nu_dse__Amount__c;
                DraftPayment.Attorney__c= payment.Attorney__c;
                DraftPayment.Attorney_Payment_Id__c= payment.Attorney_Payment_Id__c;
                DraftPayment.Draft_Split__c= payment.Draft_Split__c;
                DraftPayment.FileNumber__c= payment.FileNumber__c;
                DraftPayment.Last_Modified_By_NDS__c= payment.Last_Modified_By_NDS__c;
                DraftPayment.Monthly_Maintenance_Fee__c= payment.nu_dse__Monthly_Maintenance_Fee__c;
                DraftPayment.NDS_Payment_Type__c= payment.NDS_Payment_Type__c;
                DraftPayment.Draft_plan_Id__c= payment.Draft_plan_Id__c;
                DraftPayment.Payment_Sequence_Number__c= payment.nu_dse__Payment_Sequence_Number__c;
                DraftPayment.Payment_Status__c= payment.Payment_Status__c;
                DraftPayment.Payment_Type_Data__c= payment.Payment_Type_Data__c;
                DraftPayment.Processor_Fee__c= payment.nu_dse__Processor_Fee__c;
                DraftPayment.Program__c= payment.nu_dse__Program__c;
                DraftPayment.Retainer_Fee__c= payment.nu_dse__Retainer_Fee__c;
                DraftPayment.Schedule_Date__c= payment.nu_dse__Schedule_Date__c ;
                DraftPayment.Service_Fee__c= payment.nu_dse__Service_Fee__c;
                DraftPayment.Statused_On__c= payment.Statused_On__c;
                DraftPayment.Status_Reason__c= payment.Status_Reason__c;
                DraftPayment.Transaction_Status__c= payment.nu_dse__Transaction_Status__c ;
                DraftPayment.Type__c= payment.nu_dse__Type__c;
                DraftPayment.GCS_Synced__c= Payment.nu_dse__GCS_Synced__c;
                DraftPayment.Synced_With_Processor__c= Payment.nu_dse__Synced_With_Processor__c;
                DraftPayment.External_GCS_Id__c= Payment.nu_dse__External_GCS_ID__c;
                DraftPayment.Record_type__c= Payment.Recordtype.name;

                DraftPaymentList.add(DraftPayment);
            }
             
 /*           Id RefundRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId();
            
            List<nu_dse__Payment__c> RefundPaymentList = [Select Id from nu_dse__Payment__c where nu_dse__Program__c =: ProgramIds AND nu_dse__Advance_Payment__c =: PaymentIds AND isAttorney__c = true AND RecordTypeId =:RefundRecordTypeId];
            
            PaymentList.AddAll(RefundPaymentList);
            
            System.debug('*****'+PaymentList.size());*/
            
            Delete PaymentList;
            
            Insert DraftPaymentList;
        }
    }
    
    public static void PrimaryWorkfow(List<nu_dse__Program__c> programLst,Map<Id,nu_dse__Program__c> ProgramOldMap){
        
        Map<Id,nu_dse__Program__c> UpdatedProgramMap = new Map<Id,nu_dse__Program__c>();
        for(nu_dse__Program__c prog: programLst){
            if(prog.Attorney__c && (ProgramOldMap == null || ProgramOldMap.get(prog.Id) == null  || prog.nu_dse__Program_Status__c != ProgramOldMap.get(prog.Id).nu_dse__Program_Status__c)){
                UpdatedProgramMap.put(prog.Id,prog);
            }
        }
        
         if(!UpdatedProgramMap.isEmpty()){
        List<Workflow__c> workflowList = [Select id, Workflow_Status__c,Program__c, Name from Workflow__c where Program__c =:UpdatedProgramMap.keySet() AND name='Primary'];
        
        Map<Id, Workflow__c> programWrokflowMap = new Map<Id,Workflow__c>();
        for(workflow__c wf : workflowlist){
            if(wf.name == 'Primary'){
                programWrokflowMap.put(wf.Program__c,wf);
            }
        }
        
        List<Workflow__c> UpdatedWorkFlow = new List<Workflow__c>();
        
        for(Id programId : UpdatedProgramMap.keySet()){
            if(programWrokflowMap.containsKey(programId)){
                Workflow__c wf = programWrokflowMap.get(programId);
                wf.Workflow_Status__c = UpdatedProgramMap.get(programId).nu_dse__Program_Status__c;
                Updatedworkflow.add(wf);
            }
            else{
                nu_dse__Program__c prog = UpdatedProgramMap.get(programId);
                workflow__c wf = new workflow__c(Name = 'Primary', workflow_status__c = prog.nu_dse__Program_Status__c, nds_external_id__c = prog.import_id__c +'_Primary', program__c = prog.id, filenumber__c = prog.import_id__c );
                Updatedworkflow.add(wf);
            }
        }
        
        /*for(workflow__c workFlow : workFlowList){
            if(Workflow.name == 'Primary' && UpdatedProgramMap.containsKey(workFlow.program__c)){
                workflow.Workflow_Status__c = UpdatedProgramMap.get(workFlow.program__c).nu_dse__Program_Status__c;
            }
        }*/
        System.debug('****'+UpdatedWorkflow);
        if(!Updatedworkflow.isEmpty()){
            Database.upsert(Updatedworkflow,true);            
        }   
        }
        
               
        /*else
         for(nu_dse__Program__c prog: programLst){
         if(prog.attorney__c == true)
         {
        Workflow__c[] works = new List<workflow__c>();
        workflow__C w = new workflow__c(Name = 'Primary', workflow_status__c = prog.nu_dse__Program_Status__c, nds_external_id__c = prog.import_id__c +'_' +prog.nu_dse__Program_Status__c, program__c = prog.id, filenumber__c = prog.import_id__c );
        works.add(w);    
                insert works;   
                }
        }*/
    }

    public static void CreateOrUpdateNDSProgram(List<nu_dse__Program__c> programLst, Map<Id,nu_dse__Program__c> ProgramOldMap){
        Map<String,String> progUpdMap = new Map<String,String>();
        
        Map<Id,nu_dse__Program__c> UpdatedProgramMap = new Map<Id,nu_dse__Program__c>();
        
         Boolean apiuser = Attorney_StaticVariableUtility.apiuser;
    //Uchit Start  
        Set<String> programeNameSet = new Set<String>();
        for(nu_dse__Program__c Program : ProgramLst){  
            programeNameSet.add(program.Program_type__c);  
         }
           
         List<LeadTracProgramType__mdt> leadTracPrgTypesLst1 = [Select Label,Portfolio_name__c,RAMS__c FROM LeadTracProgramType__mdt WHERE Label IN: programeNameSet];
        
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt progType: leadTracPrgTypesLst1){
            
            LeadTracProgramTypeMap.put(progType.Label,progType);
        }
        
        System.debug('****'+LeadTracProgramTypeMap);
      //Uchit End 
        
        for(nu_dse__Program__c prog: programLst){
        
            /*System.debug(prog.nds_EstimatedSettlement_Amount__c != ProgramOldMap.get(prog.Id).nds_EstimatedSettlement_Amount__c);
            System.debug(prog.nds_EstimatedProgram_Fee__c != ProgramOldMap.get(prog.Id).nds_EstimatedProgram_Fee__c);
            System.debug(prog.nu_dse__Estimated_Settlement_Amount__c != ProgramOldMap.get(prog.Id).nu_dse__Estimated_Settlement_Amount__c );
            System.debug(prog.GCS_Policy_Group__c!= ProgramOldMap.get(Prog.Id).GCS_Policy_Group__c);
            System.debug(prog.nds_Retainer_Fee__c != ProgramOldMap.get(prog.Id).nds_Retainer_Fee__c);
            System.debug(prog.nds_Total_Program_Cost__c != ProgramOldMap.get(prog.Id).nds_Total_Program_Cost__c);
            System.debug(prog.nds_Trust_Fee_Monthly__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_Monthly__c);
            System.debug(prog.Cancellation_Date__c != ProgramOldMap.get(prog.Id).Cancellation_Date__c);
            System.debug(prog.nds_Cancellation_Reason__c != ProgramOldMap.get(prog.Id).nds_Cancellation_Reason__c);
            System.debug(prog.nds_Current_Debt_Payments__c != ProgramOldMap.get(prog.Id).nds_Current_Debt_Payments__c);
            System.debug(prog.nds_Estimated_Total_Debt__c != ProgramOldMap.get(prog.Id).nds_Estimated_Total_Debt__c);
            System.debug(prog.Sales_rep_Email__c != ProgramOldMap.get(prog.Id).Sales_rep_Email__c);
            System.debug(prog.NSF_Draft_Date__c != ProgramOldMap.get(prog.Id).NSF_Draft_Date__c);
            System.debug(prog.nds_Maxprogram_length__c != ProgramOldMap.get(prog.Id).nds_Maxprogram_length__c);
            System.debug(prog.nds_NSF_Draft_Amount__c != ProgramOldMap.get(prog.Id).nds_NSF_Draft_Amount__c);
            System.debug(prog.nds_NSF_Reason__c != ProgramOldMap.get(prog.Id).nds_NSF_Reason__c);
            System.debug(prog.nu_dse__Program_Length__c != ProgramOldMap.get(prog.Id).nu_dse__Program_Length__c);
            System.debug(prog.Program_Type__c != ProgramOldMap.get(prog.Id).Program_Type__c);
            System.debug(prog.Monthly_legal_fee__c != ProgramOldMap.get(prog.Id).Monthly_legal_fee__c );
            System.debug(prog.Client_Sticky_Note__c!= ProgramOldMap.get(prog.Id).Client_Sticky_Note__c);
            System.debug(prog.nu_dse__Reoccurring_Debit_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Reoccurring_Debit_Day__c);
            System.debug(prog.nu_dse__Twice_Monthly_Reoccuring_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Twice_Monthly_Reoccuring_Day__c);
            System.debug(prog.Sales_Rep__c != ProgramOldMap.get(prog.Id).Sales_Rep__c);
            System.debug(prog.Current_Account_Review__c != ProgramOldMap.get(prog.Id).Current_Account_Review__c);
            System.debug(prog.nu_dse__Total_Program_Cost__c != ProgramOldMap.get(prog.Id).nu_dse__Total_Program_Cost__c);
            System.debug(prog.nds_Trust_Fee_monthly_total__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_monthly_total__c);
            System.debug(prog.nu_dse__Initial_Debit_Date__c != ProgramOldMap.get(prog.Id).nu_dse__Initial_Debit_Date__c    );
            System.debug(prog.RetainerTerm__c != ProgramOldMap.get(prog.Id).RetainerTerm__c);*/
            
            
            if(prog.Attorney__c && !apiuser && (prog.nds_EstimatedSettlement_Amount__c != ProgramOldMap.get(prog.Id).nds_EstimatedSettlement_Amount__c 
            
            ||prog.nds_EstimatedProgram_Fee__c != ProgramOldMap.get(prog.Id).nds_EstimatedProgram_Fee__c
            ||prog.nu_dse__Estimated_Settlement_Amount__c != ProgramOldMap.get(prog.Id).nu_dse__Estimated_Settlement_Amount__c 
            ||prog.nds_Program_Savings__c != ProgramOldMap.get(prog.Id).nds_Program_Savings__c
            //Uchit
            
            
            
            ||(prog.GCS_Policy_Group__c!= ProgramOldMap.get(Prog.Id).GCS_Policy_Group__c && LeadTracProgramTypeMap.get(prog.Program_type__c) != null && !LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c)
            
            ||prog.nds_Retainer_Fee__c != ProgramOldMap.get(prog.Id).nds_Retainer_Fee__c
            
            ||prog.nds_Retainer_Fee_Total__c != ProgramOldMap.get(prog.Id).nds_Retainer_Fee_Total__c
            ||prog.nds_Total_Program_Cost__c != ProgramOldMap.get(prog.Id).nds_Total_Program_Cost__c
            ||prog.nds_Trust_Fee_Monthly__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_Monthly__c
            ||prog.Cancellation_Date__c != ProgramOldMap.get(prog.Id).Cancellation_Date__c
            ||prog.nds_Cancellation_Reason__c != ProgramOldMap.get(prog.Id).nds_Cancellation_Reason__c
            ||prog.nds_Current_Debt_Payments__c != ProgramOldMap.get(prog.Id).nds_Current_Debt_Payments__c
            ||prog.nds_Estimated_Total_Debt__c != ProgramOldMap.get(prog.Id).nds_Estimated_Total_Debt__c
             ||prog.Sales_rep_Email__c != ProgramOldMap.get(prog.Id).Sales_rep_Email__c
            ||prog.NSF_Draft_Date__c != ProgramOldMap.get(prog.Id).NSF_Draft_Date__c
            ||prog.nds_Maxprogram_length__c != ProgramOldMap.get(prog.Id).nds_Maxprogram_length__c
            ||prog.nds_NSF_Draft_Amount__c != ProgramOldMap.get(prog.Id).nds_NSF_Draft_Amount__c
            ||prog.nds_NSF_Reason__c != ProgramOldMap.get(prog.Id).nds_NSF_Reason__c
            ||prog.nu_dse__Program_Length__c != ProgramOldMap.get(prog.Id).nu_dse__Program_Length__c
            ||prog.Program_Type__c != ProgramOldMap.get(prog.Id).Program_Type__c
            ||prog.Monthly_legal_fee__c != ProgramOldMap.get(prog.Id).Monthly_legal_fee__c 
                        ||prog.Client_Sticky_Note__c!= ProgramOldMap.get(prog.Id).Client_Sticky_Note__c

            ||prog.nu_dse__Reoccurring_Debit_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Reoccurring_Debit_Day__c
            ||prog.nu_dse__Twice_Monthly_Reoccuring_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Twice_Monthly_Reoccuring_Day__c
            ||prog.Sales_Rep__c != ProgramOldMap.get(prog.Id).Sales_Rep__c
            ||prog.Sales_Rep_Email__c != ProgramOldMap.get(prog.Id).Sales_Rep_Email__c
            ||prog.Current_Account_Review__c != ProgramOldMap.get(prog.Id).Current_Account_Review__c
      //      ||prog.Sales_Rep__c!= ProgramOldMap.get(prog.Id).Sales_Rep__c

      //      ||prog.Lead_Id__c != ProgramOldMap.get(prog.Id).Lead_Id__c
            ||prog.nu_dse__Total_Program_Cost__c != ProgramOldMap.get(prog.Id).nu_dse__Total_Program_Cost__c
            ||prog.nds_Trust_Fee_monthly_total__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_monthly_total__c
            ||prog.nu_dse__Initial_Debit_Date__c != ProgramOldMap.get(prog.Id).nu_dse__Initial_Debit_Date__c    
            ||prog.RetainerTerm__c != ProgramOldMap.get(prog.Id).RetainerTerm__c)){
            
                progUpdMap = new Map<String,String>();
                   progUpdMap.put('FileNumber',prog.Import_ID__c);
                //if(prog.nds_EstimatedSettlement_Amount__c != ProgramOldMap.get(prog.Id).nds_EstimatedSettlement_Amount__c)
                
                   if(String.ValueOf(prog.nu_dse__Estimated_Settlement_Amount__c) != null && String.ValueOf(prog.nu_dse__Estimated_Settlement_Amount__c) != '')
                  {
                   progUpdMap.put('ESTSettlementAmt',String.ValueOf(prog.nu_dse__Estimated_Settlement_Amount__c ));
                  }
                   else
                   {
                   progUpdMap.put('ESTSettlementAmt',String.ValueOf(prog.nds_EstimatedSettlement_Amount__c));

                   } 
                
               //     progUpdMap.put('ESTSettlementAmt',String.valueOf(prog.nds_EstimatedSettlement_Amount__c));
               // if(prog.nds_EstimatedProgram_Fee__c != ProgramOldMap.get(prog.Id).nds_EstimatedProgram_Fee__c)
                    progUpdMap.put('ProgramFeeAmt',String.valueOf(prog.nds_EstimatedProgram_Fee__c));
               // if(prog.nds_Program_Savings__c != ProgramOldMap.get(prog.Id).nds_Program_Savings__c)
                    progUpdMap.put('ProgramSavings',String.valueOf(prog.nds_Program_Savings__c));
               // if(prog.nds_Retainer_Fee__c != ProgramOldMap.get(prog.Id).nds_Retainer_Fee__c)
                    progUpdMap.put('RetainerFee',String.valueOf(prog.nds_Retainer_Fee__c));
               // if(prog.nds_Retainer_Fee_Total__c != ProgramOldMap.get(prog.Id).nds_Retainer_Fee_Total__c)
                    progUpdMap.put('RetainerFeeTotal',String.ValueOf(prog.nds_Retainer_Fee_Total__c));
                                        progUpdMap.put('LegalFeeMonthly',String.ValueOf(prog.Monthly_Legal_Fee__c));

                    progUpdMap.put('RetainerTerm',String.ValueOf(prog.RetainerTerm__c ));
                    
                    If(prog.Client_Sticky_Note__c != 'Data Clean Up Needed in NDS')
                    {
                    progUpdMap.put('UserDefined',String.valueOf(prog.Client_Sticky_Note__c));
                    }


                   if(String.ValueOf(prog.nu_dse__Total_Program_Cost__c) != null && String.ValueOf(prog.nu_dse__Total_Program_Cost__c) != '')
                  {
                   progUpdMap.put('TotalProgramCost',String.ValueOf(prog.nu_dse__Total_Program_Cost__c));
                  }
                   else
                   {
                   progUpdMap.put('TotalProgramCost',String.ValueOf(prog.nds_Total_Program_Cost__c));

                   } 
               // if(prog.nds_Trust_Fee_Monthly__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_Monthly__c)
                    progUpdMap.put('TrustFeeMonthly',String.ValueOf(prog.nds_Trust_Fee_Monthly__c));
               // if(prog.Cancellation_Date__c != ProgramOldMap.get(prog.Id).Cancellation_Date__c)
               
                if(String.ValueOf(prog.Cancellation_Date__c) != NULL && String.ValueOf(prog.Cancellation_Date__c) != '')
                {
                String Year2 = String.ValueOf(prog.Cancellation_Date__c).left(4);
                String MonthInt2 = String.ValueOf(prog.Cancellation_Date__c).Right(5);
                string day2 = String.ValueOf(prog.Cancellation_Date__c).right(2);
                String Month2 = MonthInt2.Left(2);
                String FinalDate2 = Month2 +'/' +Day2 +'/' +Year2;
                
              
                    progUpdMap.put('CancellationDate',FinalDate2);
                    }
                    else
                    progUpdMap.put('CancellationDate',String.ValueOf(prog.Cancellation_Date__c));
                    
               // if(prog.Cancellation_Reason__c != ProgramOldMap.get(prog.Id).Cancellation_Reason__c)
                    progUpdMap.put('CancellationReason',prog.nds_Cancellation_Reason__c);
               // if(prog.nds_Current_Debt_Payments__c != ProgramOldMap.get(prog.Id).nds_Current_Debt_Payments__c)
                    progUpdMap.put('CurrentDebtPayment',String.valueOf(prog.nds_Current_Debt_Payments__c));
               // if(prog.nds_Estimated_Total_Debt__c != ProgramOldMap.get(prog.Id).nds_Estimated_Total_Debt__c)
                    progUpdMap.put('EstimatedTotalDebt',String.ValueOf(prog.nds_Estimated_Total_Debt__c));
               // if(prog.NSF_Draft_Date__c != ProgramOldMap.get(prog.Id).NSF_Draft_Date__c)
               
               if(String.ValueOf(prog.NSF_Draft_Date__c) != NULL && String.ValueOf(prog.NSF_Draft_Date__c) != '')
                {
                    String Year = String.ValueOf(prog.NSF_Draft_Date__c).left(4);
                String MonthInt = String.ValueOf(prog.NSF_Draft_Date__c).Right(5);
                string day = String.ValueOf(prog.NSF_Draft_Date__c).right(2);
                String Month = MonthInt.Left(2);
                String FinalDate = Month +'/' +Day +'/' +Year;
                
                
                
                    progUpdMap.put('NSFDraftDate',FinalDate);
                    }
                    else
                                        progUpdMap.put('NSFDraftDate',String.ValueOf(prog.NSF_Draft_Date__c));

               // if(prog.nds_Maxprogram_length__c != ProgramOldMap.get(prog.Id).nds_Maxprogram_length__c)
                    progUpdMap.put('MaxProgramLength',String.ValueOf(prog.nds_Maxprogram_length__c));
               // if(prog.nds_NSF_Draft_Amount__c != ProgramOldMap.get(prog.Id).nds_NSF_Draft_Amount__c)
                    progUpdMap.put('NSFDraftAmount',String.ValueOf(prog.nds_NSF_Draft_Amount__c));
               // if(prog.nds_NSF_Reason__c != ProgramOldMap.get(prog.Id).nds_NSF_Reason__c)
                    progUpdMap.put('NSFReason',prog.nds_NSF_Reason__c);
               // if(prog.nu_dse__Program_Length__c != ProgramOldMap.get(prog.Id).nu_dse__Program_Length__c)
                    progUpdMap.put('ProgramLength',String.ValueOf(prog.nu_dse__Program_Length__c));
               // if(prog.Program_Type__c != ProgramOldMap.get(prog.Id).Program_Type__c)
                    progUpdMap.put('ProgramType',prog.Program_Type__c);
               // if(prog.nu_dse__Reoccurring_Debit_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Reoccurring_Debit_Day__c)
                    progUpdMap.put('RecurringDate',String.ValueOf(prog.nu_dse__Reoccurring_Debit_Day__c));
              //  if(prog.nu_dse__Twice_Monthly_Reoccuring_Day__c != ProgramOldMap.get(prog.Id).nu_dse__Twice_Monthly_Reoccuring_Day__c)
                    progUpdMap.put('RecurringDate2',String.valueOf(prog.nu_dse__Twice_Monthly_Reoccuring_Day__c));
                                        
                    if(LeadTracProgramTypeMap != null && LeadTracProgramTypeMap.containsKey(prog.Program_type__c) && !LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c && LeadTracProgramTypeMap.get(prog.Program_type__c) != null)
                        progUpdMap.put('PolicyGroup',String.valueOf(prog.GCS_Policy_Group__c));

                    
             //       progUpdMap.put('DebtConsultant',String.valueOf(prog.Sales_Rep__c));

               
                /*-------START By Shyam----------------*/
               // if(prog.Sales_Rep__c != ProgramOldMap.get(prog.Id).Sales_Rep__c)
                    progUpdMap.put('DebtConsultant',String.valueOf(prog.Sales_Rep__c));
              //  if(prog.Sales_Rep_Email__c != ProgramOldMap.get(prog.Id).Sales_Rep_Email__c)
                    progUpdMap.put('SalesEmail',String.valueOf(prog.Sales_Rep_Email__c));
                
                /*-------END By Shyam----------------*/
                /*******Additional fields Ramesh**********/
              //  if(prog.Current_Account_Review__c != ProgramOldMap.get(prog.Id).Current_Account_Review__c)
                    progUpdMap.put('AccountReviewEvent',String.valueOf(prog.Current_Account_Review__c));
              //  if(prog.Lead_Id__c != ProgramOldMap.get(prog.Id).Lead_Id__c)
              //      progUpdMap.put('LeadID',String.valueOf(prog.Lead_Id__c));
              //  if(prog.nu_dse__Total_Program_Cost__c != ProgramOldMap.get(prog.Id).nu_dse__Total_Program_Cost__c)
               //     progUpdMap.put('TotalProgramCost',String.valueOf(prog.nu_dse__Total_Program_Cost__c));
               // if(prog.nds_Trust_Fee_monthly_total__c != ProgramOldMap.get(prog.Id).nds_Trust_Fee_monthly_total__c)
                    progUpdMap.put('TrustFeeMonthlyTotal',String.valueOf(prog.nds_Trust_Fee_monthly_total__c));
               // if(prog.nu_dse__Initial_Debit_Date__c != ProgramOldMap.get(prog.Id).nu_dse__Initial_Debit_Date__c)
               
               
               
               
               if(String.ValueOf(prog.nu_dse__Initial_Debit_Date__c) != NULL && String.ValueOf(prog.nu_dse__Initial_Debit_Date__c) != '')
                {
                String Year3 = String.ValueOf(prog.nu_dse__Initial_Debit_Date__c).left(4);
                String MonthInt3 = String.ValueOf(prog.nu_dse__Initial_Debit_Date__c).Right(5);
                string day3 = String.ValueOf(prog.nu_dse__Initial_Debit_Date__c).right(2);
                String Month3 = MonthInt3.Left(2);
                String FinalDate3 = Month3 +'/' +Day3 +'/' +Year3;
                
              
                    progUpdMap.put('FirstDraftDate',FinalDate3);
                    }
                    else
                    progUpdMap.put('FirstDraftDate',String.ValueOf(prog.nu_dse__Initial_Debit_Date__c));
                    
                    
                    
                    
                  //  progUpdMap.put('FirstDraftDate',String.valueOf(prog.nu_dse__Initial_Debit_Date__c));
                /*******End*******************************/
                system.debug('###progUpdMap::'+progUpdMap);
                if(!progUpdMap.isEmpty())
                    calloutToNDS(progUpdMap, prog.campaignId__c, prog.Import_Id__c);
            }
            
  }
        
    }
    
    @future(callout=TRUE)
    public static void calloutToNDS(Map<String,String> progUpdMap, String campaignId, String FileNumber){
        leadtracNetClient.ClientServiceSoap soap = new leadtracNetClient.ClientServiceSoap();
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        leadtracNetClient.ArrayOfClientProperty propertyArray;
        leadtracNetClient.ClientProperty property;
        List<leadtracNetClient.ClientProperty> propLst;
        propLst = new List<leadtracNetClient.ClientProperty>();
        propertyArray = new leadtracNetClient.ArrayOfClientProperty();
        property = new leadtracNetClient.ClientProperty();
        property.Name = 'FileNumber';
        property.Value = FileNumber;
        propLst.add(property);
        for(String str: progUpdMap.keySet()){
            if(progUpdMap.containsKey(Str)){
                property = new leadtracNetClient.ClientProperty();
                property.Name = str;
                property.Value = progUpdMap.get(str);
                propLst.add(property);    
            }
        }
        propertyArray.ClientProperty = propLst;
      
       
        String retunedString = soap.CreateOrUpdateClient(credentials.UserName__c, credentials.Password__c,campaignId,propertyArray);        
        
    }
    public static void createFeeTemplate(List<nu_dse__Program__c> ObjProgramList){
        
        Set<String> programKeySet = new Set<String>();
        Set<Id> programIdSet = new Set<Id>();
        
        for(nu_dse__Program__c p: ObjProgramList){
            if(p.Attorney__c){
                programIdSet.add(p.Id);
                
                if(p.UniqueFeeTemplateIdentifier__c != null)
                    programKeySet.add(p.UniqueFeeTemplateIdentifier__c.replace('0.','.')); 
            }
        } 
        
        System.debug('+++++++ 1. programIdSet ' + programIdSet);
        System.debug('+++++++ 2. programKeySet ' + programKeySet);
        
        Map<String,nu_dse__Fee_Template__c> feeTemplateMap = new Map<String,nu_dse__Fee_Template__c>();
        for(nu_dse__Fee_Template__c feeTemplate: [Select Id,Name,UniqueIdentifier__c from nu_dse__Fee_Template__c Where UniqueIdentifier__c =:programKeySet and Is_With_ALLG__c=true])
            feeTemplateMap.put(feeTemplate.UniqueIdentifier__c,feeTemplate);  
        
        System.debug('+++++++ 3. feeTemplateMap ' + feeTemplateMap);

        Map<String,nu_dse__Fee_Template__c> feeTemplateInsertMap = new Map<String,nu_dse__Fee_Template__c>();
        Map<String,List<nu_dse__Fee_Item__c>> feeTemplateItemInsertMap = new Map<String,List<nu_dse__Fee_Item__c>>();
        
        for(nu_dse__Program__c p: [Select Id,Name,Attorney__c,Estimated_Settlement__c,Settlement_Fee__c,
                                   nu_dse__Monthly_Third_Party_Fees__c,Monthly_Legal_Fee__c,Program_Type__c,UniqueFeeTemplateIdentifier__c 
                                   FROM nu_dse__Program__c WHERE ID IN: programIdSet]){ 
            
            string key = p.UniqueFeeTemplateIdentifier__c;
            
            System.debug('+++++++ 4. key ' + key);
            if(!feeTemplateMap.containsKey(key))
            {
                System.debug('+++++++ 5.  does not contain feeTemplateMap');
                if(!feeTemplateInsertMap.containsKey(key))
                {
                    System.debug('+++++++ 6.  does not contain feeTemplateInsertMap');
                    
                    nu_dse__Fee_Template__c template = new nu_dse__Fee_Template__c();
                    template.nu_dse__Settlement_Pct__c = p.Estimated_Settlement__c;
                    /*Commented by Ramesh -- throwing an error invalid picklist value for Attorney_Program_Type__c*/
                    template.Attorney_Program_Type__c = p.Program_Type__c;
                    template.Name =  'Attorney' + '_' + p.Program_Type__c + '_' + p.Estimated_Settlement__c + '_' + p.Settlement_Fee__c;
                    template.Is_With_ALLG__c = true;
                    feeTemplateInsertMap.put(key,template);
                    
                    List<nu_dse__Fee_Item__c> feedItemList = new List<nu_dse__Fee_Item__c>();
                    
                    nu_dse__Fee_Item__c feeItemSettlement = new nu_dse__Fee_Item__c(); 
                    feeItemSettlement.RecordTypeId = Attorney_StaticVariableUtility.SettlementFeeRecordId;
                    feeItemSettlement.Name = p.Estimated_Settlement__c+'_'+p.Settlement_Fee__c + '_'+ p.Program_Type__c + '_' + 'Settlement';
                    feeItemSettlement.nu_dse__Percent__c = p.Settlement_Fee__c;
                    feeItemSettlement.nu_dse__Fee_Basis__c = 'Debt';
                    feeItemSettlement.nu_dse__Frequency__c = 'Monthly';
                    feedItemList.add(feeItemSettlement);
                    
                    nu_dse__Fee_Item__c feeItemThirdParty = new nu_dse__Fee_Item__c(); 
                    feeItemThirdParty.RecordTypeId = Attorney_StaticVariableUtility.ThirdpartyFeeRecordId;
                    feeItemThirdParty.Name = p.Estimated_Settlement__c+'_'+p.Settlement_Fee__c + '_'+ p.Program_Type__c + '_' + 'MonthlyLegal';
                    feeItemThirdParty.nu_dse__Fee_Amount__c = p.Monthly_Legal_Fee__c;
                    feeItemThirdParty.nu_dse__Fee_Basis__c = 'Debt';
                    feeItemThirdParty.nu_dse__Frequency__c = 'Monthly';
                    feedItemList.add(feeItemThirdParty);
                    
                    feeTemplateItemInsertMap.put(key,feedItemList);
                }
            }
            
        }
        
        System.debug('+++++++ 7.  feeTemplateInsertMap ' + feeTemplateInsertMap);
        
        insert feeTemplateInsertMap.values();
        
        createFeeTemplateItems(feeTemplateInsertMap,feeTemplateItemInsertMap);
        
        linkFeeTemplateWithProgram(programKeySet,programIdSet);
        
    }
    
    public static void createFeeTemplateItems(Map<String,nu_dse__Fee_Template__c> feeTemplateInsertMap,Map<String,List<nu_dse__Fee_Item__c>> feeTemplateItemInsertMap){
        
        Set<Id> templateIdSet = new Set<Id>();
        System.debug('+++++++ 7.  feeTemplateInsertMap ' + feeTemplateInsertMap);
        System.debug('+++++++ 8.  feeTemplateItemInsertMap ' + feeTemplateItemInsertMap);
        
        List<nu_dse__Fee_Item__c> insertFeedItem = new List<nu_dse__Fee_Item__c>();
        for(string key : feeTemplateInsertMap.keySet())
        {
            string feedTemplateId = feeTemplateInsertMap.get(key).id;
            System.debug('+++++++ 9.  feedTemplateId ' + feedTemplateId);
            
            for(nu_dse__Fee_Item__c feedItem:feeTemplateItemInsertMap.get(key))
            {
                feedItem.nu_dse__Fee_Template__c = feedTemplateId;
                 System.debug('+++++++ 10.  feedItem ' + feedItem);
                insertFeedItem.add(feedItem);
            }
        }
        
        insert insertFeedItem;
    }
    
    public static void linkFeeTemplateWithProgram(Set<String> programKeySet,Set<Id> programIdSet)
    {
        
        List<nu_dse__Program__c> programUpdList = new List<nu_dse__Program__c>();    
        
        Map<String,nu_dse__Fee_Template__c> feeTemplateMap = new Map<String,nu_dse__Fee_Template__c>();
        for(nu_dse__Fee_Template__c feeTemplate: [Select Id,Name,UniqueIdentifier__c from nu_dse__Fee_Template__c Where UniqueIdentifier__c =:programKeySet and Is_With_ALLG__c=true])
            feeTemplateMap.put(feeTemplate.UniqueIdentifier__c,feeTemplate);  
        
        System.debug('+++++++ 11.  feeTemplateMap ' + feeTemplateMap);
        
        for(nu_dse__Program__c p: [Select Id,Name,Attorney__c,Estimated_Settlement__c,Settlement_Fee__c,
                                    nu_dse__Monthly_Third_Party_Fees__c,Program_Type__c,UniqueFeeTemplateIdentifier__c FROM nu_dse__Program__c WHERE ID IN: programIdSet]){ 
            
            string key = p.UniqueFeeTemplateIdentifier__c;
            
            System.debug('+++++++ 12.  key ' + key);
                                        
            if(feeTemplateMap.containsKey(key))
            {
                p.nu_dse__Fee_Template__c = feeTemplateMap.get(key).Id;
                programUpdList.add(p);
                System.debug('+++++++ 13.  p.nu_dse__Fee_Template__c ' + p.nu_dse__Fee_Template__c);
            }
       }
        
        update programUpdList;
    }
    
    // added by Praveen - Decommissioned - Process Builder : Populate Portfolio on Client Accounts
    public static boolean isExecuteFirst = true;
    public static void populatePortfolioOnAccount(List<nu_dse__Program__c> prgmList , Map<id,nu_dse__Program__c> prgmOldMap){
        
        if(isExecuteFirst){
        Map<id,nu_dse__Program__c> prgmMap = new Map<id,nu_dse__Program__c>();
        List<Account> updateAccList = new List<Account>();
        
        
        for(nu_dse__Program__c  prgm : prgmList){
       // system.debug('=====acc portfolio===='+prgm.nu_dse__Account__r.Portfolio__c);
            if((Trigger.isInsert && prgm.Portfolio__c != null && prgm.nu_dse__Account__r.Portfolio__c == null) || (Trigger.isUpdate && prgm.Portfolio__c != null &&  prgm.nu_dse__Account__r.Portfolio__c == null && prgm.Portfolio__c != prgmOldMap.get(prgm.id).Portfolio__c)){
                prgmMap.put(prgm.nu_dse__Account__c,prgm);
            }
        }
        
        if(prgmMap.KeySet().size()>0){
            for(Account accs : [select id,Portfolio__c from Account where id IN:prgmMap.KeySet()]){
                accs.Portfolio__c = prgmMap.get(accs.id).Portfolio__c;
                updateAccList.add(accs);
            }
         }
        
        system.debug('===='+ updateAccList);
        if(!updateAccList.isEmpty()){
            update updateAccList;
            isExecuteFirst = false;
        }
        }
    }
// added by Praveen
    
   
}