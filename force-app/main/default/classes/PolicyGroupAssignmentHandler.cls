public class PolicyGroupAssignmentHandler {
    
    public static boolean QueueableMethodCalled = false;
    
    
        public static void filterProgList(Map<Id,nu_dse__Program__c> ProgramOldMap, Map<Id,nu_dse__Program__c> ProgramNewMap,List<nu_dse__Program__c> NewprogramList,Boolean isInsert) {
            List<nu_dse__Program__c> filteredprogramList = new List<nu_dse__Program__c>();
            List<String> StatusList=new List<String>{'Active Client','Pending Cancellation','Client Cancelled'};
            Set<Id> processedProgramIdSet = new Set<Id>();
            
            for(nu_dse__Program__c program: NewprogramList){
                if( isInsert ||
                    (StatusList.contains(program.nu_dse__Program_Status__c) && program.nu_dse__Program_Status__c != ProgramOldMap.get(program.id).nu_dse__Program_Status__c) ||
                   (Program.DNL_Status__c != null && (Program.nu_dse__Program_Status__c == 'Graduated Program' || Program.nu_dse__Program_Status__c == 'Graduated') && (isInsert || Program.nu_dse__Program_Status__c != ProgramOldMap.get(Program.Id).nu_dse__Program_Status__c || Program.Total_Fees__c != ProgramOldMap.get(Program.Id).Total_Fees__c)) ||
                   ((program.Estimated_Settlement__c != null && program.Estimated_Settlement__c != ProgramOldMap.get(program.Id).Estimated_Settlement__c) ||
                    (program.Settlement_Fee__c != null && program.Settlement_Fee__c != ProgramOldMap.get(program.Id).Settlement_Fee__c) ||
                    (program.nu_dse__Total_Debt_Included__c != null && program.nu_dse__Total_Debt_Included__c != ProgramOldMap.get(program.Id).nu_dse__Total_Debt_Included__c) ||
                    (program.GCS_Policy_Group__c != null && program.GCS_Policy_Group__c != ProgramOldMap.get(program.Id).GCS_Policy_Group__c)
                    ) ||
                   (!isInsert &&((processedProgramIdSet.contains(program.Id) == False && (program.DNL_Status__c != ProgramOldMap.get(program.Id).DNL_Status__c)
                    && program.DNL_Status__c == 'Pre-TILA Signed' && (ProgramOldMap.get(program.Id).DNL_Status__c=='Lead Active' || ProgramOldMap.get(program.Id).DNL_Status__c=='Converted')
                    && program.nu_dse__Fee_Template__c != null && program.nu_dse__Processor__c != null)))
                  )
                {
                    processedProgramIdSet.add(program.nu_dse__Processor__c);
                    filteredprogramList.add(program) ;
                }
            }
            //return filteredprogramList ;
            if(!filteredprogramList.isEmpty()) {
                System.enqueueJob(new QueueableMethod(ProgramOldMap, ProgramNewMap , filteredprogramList , isInsert));
            }
        }
        
    
    public class QueueableMethod implements Queueable,Database.AllowsCallouts{
        
        Map<Id,nu_dse__Program__c> ProgramOldMap = new Map<Id,nu_dse__Program__c>();
        Map<Id,nu_dse__Program__c> ProgramNewMap = new Map<Id,nu_dse__Program__c>();
        List<nu_dse__Program__c> NewprogramList = new List<nu_dse__Program__c>();
        Boolean isInsert;
        
        public QueueableMethod(Map<Id,nu_dse__Program__c> ProgramOldMap, Map<Id,nu_dse__Program__c> ProgramNewMap,List<nu_dse__Program__c> NewprogramList,Boolean isInsert)
        {
            this.NewprogramList = NewprogramList; 
            this.ProgramNewMap = ProgramNewMap;
            this.ProgramOldMap = ProgramOldMap;
            this.isInsert = IsInsert;
        }
        
        public void execute(QueueableContext context) {
            System.debug('Isinsert->'+IsInsert) ;
            //Calling ProgramFeeTemplateMappingTriggerHandler for DNL status
            if(!isInsert)
            {
                
             ProgramFeeTemplateMappingTriggerHandler.ProgramFeeTemplateMapping( ProgramOldMap, NewprogramList) ;
            }
           // if(!isInsert)
           
                programPolicyGroupMapping(ProgramOldMap,NewprogramList);
            Prizm_ProgramHandler.TotalFeesUpdate(ProgramOldMap, NewProgramList, isInsert);
           /*if(!Velocify_ProgramHandler.VelocifyExecuted){    
        
                VelocifyTriggerActive__mdt VelocifyTrigger = [Select Id,isActive__c from VelocifyTriggerActive__mdt where DeveloperName ='ProgramTriggerActive'];
                system.debug('VelocifyTrigger --->'+VelocifyTrigger);
        
                If(VelocifyTrigger.IsActive__c)  {
                    if(!isInsert && !Attorney_staticVariableUtility.VelocifyAdmin){
                        Velocify_ProgramHandler.UpdateLeadStatus(NewprogramList, ProgramOldMap, ProgramNewMap);
                    }
                }
            }*/
            
            PolicyGroupAssignmentHandler.QueueableMethodCalled = true;
        }
    
    }
    
     public static void invokeFeeTemplateAssignment(){
         Map<Id, nu_dse__Program__c> ProgramOldMap = (Map<Id,nu_dse__Program__c>)Trigger.OldMap;
         List<nu_dse__Program__c> ProgramList = new List<nu_dse__Program__c>();
         for(nu_dse__Program__c Program: (List<nu_dse__Program__c>)Trigger.new){
             if(Trigger.isInsert || (Trigger.isUpdate && Program.nu_dse__Total_Debt_Included__c != ProgramOldMap.get(Program.Id).nu_dse__Total_Debt_Included__c)){
                 ProgramList.add(Program);
             }
         }
         
        if(!ProgramList.isEMpty()){
          // System.enqueueJob(new FeeTemplateAssingment(ProgramOldMap , ProgramList));
         }
     }
    
    /* public class FeeTemplateAssingment implements Queueable,Database.AllowsCallouts
     {
         Map<Id, nu_dse__Program__c> programOldMap;
         List<nu_dse__Program__c> programList;
         
         
         public FeeTemplateAssingment(Map<Id, nu_dse__Program__c> programOldMap,List<nu_dse__Program__c> programList )
        {
            this.programList = programList;
            this.programOldMap = programOldMap;
            //this.OpportunityList = OpprtunityList; 
        }
         
         
         public void execute(QueueableContext context) {
              List<nu_dse__Program__c> filteredProgramList = new List<nu_dse__Program__c> ();
        
        Map<Id, String> programWithCategoryMap = new Map<Id, String>();
        
        Map<Id, String> programWithProgramTypeMap = new Map<Id, String>();
        
        Map<String, Integer> ndsSettlementFeeMap = 
            new Map<String, Integer>{'LDP' => 9, 'Under 30000' => 17, 'Over 30000' => 17, 'Over 35000' => 17};
            
        Map<String, Map<String, Map<Decimal, nu_dse__Field_mapping__c>>> portfolioWithFieldMapping = 
            new Map<String, Map<String, Map<Decimal, nu_dse__Field_mapping__c>>>();
            
        Set<String> portfolioSet = new Set<String>();
        
        Map<Id, String> programWithTargetPolicyGrp = new Map<Id, String>();
        
        Map<String, Id> targetKeyWithFeeTempIdMap = new Map<String, Id>();
        
        Map<String, String> programTypeWithPortfolioMap = new Map<String, String>();
        
        Set<Id> processorIdSet = new Set<Id>();
        
        Set<Id> feeTemplateIdSet = new Set<Id>();
        
        Set<String> programTypeSet = new Set<String>();
                
        for (nu_dse__Program__c programInst : programList) {
        
            if (programInst.nu_dse__Total_Debt_Included__c != NULL
                && programInst.nu_dse__Total_Debt_Included__c != programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c
                && (programInst.DNL_Status__c != 'Pre-TILA Signed' && programInst.DNL_Status__c != 'Graduated DRP' 
                    && programInst.Program_Type__c != NULL && programInst.Program_Type__c.contains('Versara') == False)
                && programInst.Portfolio__c != NULL) {
                
                filteredProgramList.add(programInst);
                portfolioSet.add(programInst.Portfolio_Name__c);
                
                if (programInst.nu_dse__Fee_Template__c != NULL) {
                    feeTemplateIdSet.add(programInst.nu_dse__Fee_Template__c);
                }
                    
                if (programInst.Program_Type__c != NULL) {
                    programTypeSet.add(programInst.Program_Type__c);
                }
                
                if (programInst.nu_dse__Processor__c != NULL) {
                    processorIdSet.add(programInst.nu_dse__Processor__c);
                }
            }
        }
        System.debug('filteredProgramList-1->'+filteredProgramList);
        System.debug('feeTemplateIdSet --->'+feeTemplateIdSet);
        System.debug('portfolioSet--->'+portfolioSet);
        System.debug('processorIdSet--->'+processorIdSet);
        
        if (filteredProgramList != NULL && filteredProgramList.isEmpty() == False) {
        
            for (nu_dse__Field_mapping__c fieldMappingInst : 
            [
                SELECT Id, Program_Portfolio__c, LDP__c, Over_30000__c, Over_35000__c, Under_30000__c, Trust_Account_Provider__c, 
                Priority_Sequence_Number__c, Policy_Type__c, Program_Type_30K__c, Program_Type_35K__c, Populate_Program_Type__c 
                FROM nu_dse__Field_mapping__c 
                WHERE nu_dse__Data_Mapping__r.Name = 'PolicyGroupAssignment' AND Program_Portfolio__c IN :portfolioSet
            ]) {
                
                if (String.isNotBlank(fieldMappingInst.Program_Portfolio__c) && String.isNotBlank(fieldMappingInst.Policy_Type__c) 
                    && fieldMappingInst.Priority_Sequence_Number__c != NULL) {
                     
                    if (portfolioWithFieldMapping.containsKey(fieldMappingInst.Program_Portfolio__c) == False) { 
                    
                        portfolioWithFieldMapping.put(fieldMappingInst.Program_Portfolio__c, 
                                    new Map<String, Map<Decimal, nu_dse__Field_mapping__c>>());                    
                    }
                        
                    if (portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c)
                            .containsKey(fieldMappingInst.Policy_Type__c) == False) {
                        
                        portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c)
                            .put(fieldMappingInst.Policy_Type__c, new Map<Decimal, nu_dse__Field_mapping__c>());                     
                    }
                    
                    portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c).get(fieldMappingInst.Policy_Type__c)
                        .put(fieldMappingInst.Priority_Sequence_Number__c, fieldMappingInst);                                                                                                                            
                }
            }
            
            if (portfolioWithFieldMapping.isEmpty() == False) {
                
                System.debug('portfolioWithFieldMapping--->'+portfolioWithFieldMapping);
                
                for (nu_dse__Program__c programInst : filteredProgramList) {
                
                    if (portfolioWithFieldMapping.containsKey(programInst.Portfolio_Name__c) 
                        && portfolioWithFieldMapping.get(programInst.Portfolio_Name__c).isEmpty() == False) {
                        
                        String oldCategory, newCategory;
                        
                        if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c != NULL) {
                    
                            if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 15000) {
                            
                                oldCategory = 'LDP__c';
                                
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 15000 
                                       && programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 30000) {
                                       
                                oldCategory = 'Under_30000__c';     
                                      
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 30000 
                                       && programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 35000) {
                                       
                                oldCategory = 'Over_30000__c';         
                                  
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 35000) {
                            
                                oldCategory = 'Over_35000__c';
                            }
                        }
                        System.debug('oldCategory---->'+oldCategory);
                            
                        if (programInst.nu_dse__Total_Debt_Included__c >= 35000) {
                        
                            newCategory = 'Over_35000__c';
                            
                        } else if (programInst.nu_dse__Total_Debt_Included__c >= 30000 
                                       && programInst.nu_dse__Total_Debt_Included__c < 35000) {
                                   
                            newCategory = 'Over_30000__c';         
                              
                        } else if ((programInst.nu_dse__Total_Debt_Included__c >= 15000 
                                        && programInst.nu_dse__Total_Debt_Included__c < 30000)
                                   || (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 15000
                                       && programInst.nu_dse__Total_Debt_Included__c < 15000)) {
                                   
                            newCategory = 'Under_30000__c';     
                                  
                        } else if (programInst.nu_dse__Total_Debt_Included__c < 15000) {
                    
                            newCategory = 'LDP__c';
                        }
                        System.debug('newCategory ---->'+newCategory);
                        
                        if (oldCategory != newCategory) {
                            
                            String newCategoryLabel = Schema.getGlobalDescribe().get('nu_dse__Field_mapping__c').getDescribe().fields
                                                        .getMap().get(newCategory).getDescribe().getLabel();
                                                        
                            programWithCategoryMap.put(programInst.Id, newCategoryLabel);
                            
                            if (portfolioWithFieldMapping.get(programInst.Portfolio_Name__c).get('Debt Settlement').isEmpty() == False) {
                                
                                String targetPolicyGroup;
                            
                                for (Integer ctr = 1; ctr <= portfolioWithFieldMapping.get(programInst.Portfolio_Name__c)
                                                                .get('Debt Settlement').size(); ctr++) {
                                    
                                    nu_dse__Field_mapping__c fmd = portfolioWithFieldMapping.get(programInst.Portfolio_Name__c)
                                                                    .get('Debt Settlement').get(ctr);
                                    System.debug('Field Mapping --->'+fmd);
                                    
                                    if (fmd != NULL) {
                                    
                                        if (fmd.Populate_Program_Type__c == True) {
                                            
                                            if(newCategoryLabel == 'Under 30000' || newCategoryLabel == 'Over 30000') {
                                                
                                                programWithProgramTypeMap.put(programInst.Id, fmd.Program_Type_30K__c);
                                                
                                            } else if (newCategoryLabel == 'Over 35000') {
                                                
                                                programWithProgramTypeMap.put(programInst.Id, fmd.Program_Type_35K__c);
                                            }
                                        }
                                    
                                        Set<String> policyGroupSet = new Set<String>{fmd.LDP__c, fmd.Under_30000__c, fmd.Over_30000__c, fmd.Over_35000__c};
                                    
                                        if (ctr == 1) {
                                            
                                            targetPolicyGroup = (String)fmd.get(newCategory);
                                        }
                                        
                                        if (String.isNotBlank(programInst.GCS_Policy_Group__c) 
                                            && policyGroupSet.contains(programInst.GCS_Policy_Group__c)) {
                                            
                                            targetPolicyGroup = (String)fmd.get(newCategory);
                                            break;
                                        }
                                    }
                                }
                                                        
                                if (String.isNotBlank(targetPolicyGroup)) {
                                    
                                    programWithTargetPolicyGrp.put(programInst.Id, targetPolicyGroup);
                                }
                            }
                        }
                    }
                }
                System.debug('programWithTargetPolicyGrp--->'+programWithTargetPolicyGrp);
                System.debug('programWithCategoryMap------->'+programWithCategoryMap);
                System.debug('programWithProgramTypeMap------->'+programWithProgramTypeMap); 
                System.debug('filteredProgramList--2->'+filteredProgramList);
                
                if (programWithCategoryMap.isEmpty() == False) {
                
                    Map<Id, nu_dse__Processor__c>  processorMap = 
                        new Map<Id, nu_dse__Processor__c>([SELECT Id, nu_dse__Type__c FROM nu_dse__Processor__c 
                                                           WHERE Id IN :processorIdSet]);
                
                    Map<Id, nu_dse__Fee_Template__c> feeTemplateMap = new Map<Id, nu_dse__Fee_Template__c>(
                    [
                        SELECT Id, Portfolio_Name__c, Program_Type__c, nu_dse__Settlement_Pct__c, Debt_Amount__c,
                        Service_Fee_Percentage__c, nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c 
                        FROM nu_dse__Fee_Template__c
                        WHERE (Id IN :feeTemplateIdSet  
                        OR nu_dse__GCS_Fee_Group_Id__c IN :programWithTargetPolicyGrp.values() 
                        OR nu_dse__RAMS_Fee_Group_Id__c IN :programWithTargetPolicyGrp.values())
                        AND Portfolio_Name__c IN :portfolioWithFieldMapping .keySet() 
                        AND Debt_Amount__c != NULL AND Program_Type__c != NULL 
                        AND nu_dse__Settlement_Pct__c != NULL AND Service_Fee_Percentage__c != NULL
                    ]);
                    
                    System.debug('feeTemplateMap----->'+feeTemplateMap);
                    System.debug('processorMap----->'+processorMap);
                    
                    for(nu_dse__Fee_Template__c ft : feeTemplateMap.values()) {
                         
                         String existingKey = ft.Portfolio_Name__c + '-' + Integer.valueOf(ft.nu_dse__Settlement_Pct__c) + '-' 
                                              + Integer.valueOf(ft.Service_Fee_Percentage__c) + '-' + ft.Program_Type__c + '-' 
                                              + ft.Debt_Amount__c + '-';
                          
                         System.debug('existingKey--->'+existingKey);                    
                         if (ft.nu_dse__GCS_Fee_Group_Id__c != NULL) {
                         
                             System.debug('GCS');
                             targetKeyWithFeeTempIdMap.put(existingKey + 'GCS-' + ft.nu_dse__GCS_Fee_Group_Id__c, ft.Id);
                         }
                         
                         if (ft.nu_dse__RAMS_Fee_Group_Id__c != NULL) {
                             
                             System.debug('RAMS');
                             targetKeyWithFeeTempIdMap.put(existingKey + 'RAMS-' + ft.nu_dse__RAMS_Fee_Group_Id__c, ft.Id);
                         }                                             
                    }
                    System.debug('targetKeyWithFeeTempIdMap--->'+targetKeyWithFeeTempIdMap);
                    
                    if (programWithProgramTypeMap.isEmpty() == False) {
                        
                        programTypeSet.addAll(programWithProgramTypeMap.values());
                    }
                    System.debug('programTypeSet---->'+programTypeSet);
                    
                    if (programTypeSet.isEmpty() == False) {
                        
                        for (LeadTracProgramType__mdt programType : [Select Label,Portfolio_name__c FROM LeadTracProgramType__mdt 
                                                                             WHERE Label IN: programTypeSet]) {
                                                                             
                            programTypeWithPortfolioMap.put(programType.Label, programType.Portfolio_name__c);
                        }
                    }
                    System.debug('programTypeWithPortfolioMap--->'+programTypeWithPortfolioMap);
                            
                    for (nu_dse__Program__c programInst : filteredProgramList) {
                    
                        System.debug('programInst--->'+programInst);
                
                        if (programWithCategoryMap.get(programInst.Id) != NULL 
                            && programWithTargetPolicyGrp.isEmpty() == False && programWithTargetPolicyGrp.get(programInst.Id) != NULL) {
                            
                            //programInst.Settlement_Fee__c = ndsSettlementFeeMap.get(programWithCategoryMap.get(programInst.Id));
                        
                            programInst.GCS_Policy_Group__c = programWithTargetPolicyGrp.get(programInst.Id);
                            
                            if (programWithProgramTypeMap.isEmpty() == False && programWithProgramTypeMap.get(programInst.Id) != NULL) {
                                
                                programInst.Program_Type__c = programWithProgramTypeMap.get(programInst.Id);
                            }
                        
                            //nu_dse__Fee_Template__c ft = feeTemplateMap.get(programInst.nu_dse__Fee_Template__c);
                            
                            nu_dse__Processor__c proc = processorMap.get(programInst.nu_dse__Processor__c);
                                                                
                            String amountCategory = 
                                programWithCategoryMap.get(programInst.Id) == 'LDP' ? 'Under 30000' : 
                                    (programWithCategoryMap.get(programInst.Id) == 'Over 35000' ? 'Over 30000' : 
                                        programWithCategoryMap.get(programInst.Id));
                                        
                            //System.debug('ft---->'+ft);
                            System.debug('proc--->'+proc);
                            
                            String keyToUpdate;
                            
                            if (proc != NULL && programTypeWithPortfolioMap.isEmpty() == False 
                                && programTypeWithPortfolioMap.get(programInst.Program_Type__c) != NULL) {
                            
                                keyToUpdate =  programTypeWithPortfolioMap.get(programInst.Program_Type__c) + '-' 
                                               + Integer.valueOf(programInst.Estimated_Settlement__c) + '-' 
                                               + Integer.valueOf(programInst.Settlement_Fee__c)+ '-' 
                                               + programInst.Program_Type__c + '-' 
                                               + amountCategory + '-' 
                                               + proc.nu_dse__Type__c + '-'
                                               + programWithTargetPolicyGrp.get(programInst.Id); 
                            }                       
                            System.debug('keyToUpdate --->'+keyToUpdate );    
                             
                            if (String.isNotBlank(keyToUpdate) && targetKeyWithFeeTempIdMap.isEmpty() == False 
                                && targetKeyWithFeeTempIdMap.get(keyToUpdate) != NULL) {
                                
                                programInst.nu_dse__Fee_Template__c = targetKeyWithFeeTempIdMap.get(keyToUpdate);
                                    System.debug('checking feetemplate on program --->'+programInst.nu_dse__Fee_Template__c );
                            } else {
                                
                                programInst.nu_dse__Fee_Template__c = NULL;
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                                String[] toAddresses = new String[] {Label.Fee_Template_Missing_Email};
                                mail.setToAddresses(toAddresses);
                        
                                mail.setSubject('Fee Template missing : ' + programInst.Name);
                        
                                mail.setHtmlBody('Hi, <br/><p>The Fee Template is missing for the Program : <b>'
                                + programInst.Name + ' - ' + programInst.Client_Full_Name__c 
                                + '</b>.</p><p>Policy Group : '+programWithTargetPolicyGrp.get(programInst.Id)
                                +'</p><p>Portfolio : ' +programInst.Portfolio_Name__c
                                + '</p><p>Program Type : ' +programInst.Program_Type__c
                                + '</p><p>Debt Category : ' +amountCategory
                                + '</p><p>Estimated Settlement % : ' +programInst.Estimated_Settlement__c
                                + '</p><p>Service Fee Percentage : ' +programInst.Settlement_Fee__c+ '</p>');
                        
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            }                            
                        }  
                    }
                    System.debug('filteredProgramList--3->'+filteredProgramList);
                    update filteredProgramList;
                }
            }
        }
             
         }
         
         
     }*/
    
      
    //S20-154 ****Starts****
    public static void programPolicyGroupMapping(Map<Id, nu_dse__Program__c> programOldMap, List<nu_dse__Program__c> programList) {
        
        List<nu_dse__Program__c> filteredProgramList = new List<nu_dse__Program__c> ();
        
        Map<Id, String> programWithCategoryMap = new Map<Id, String>();
        
        Map<Id, String> programWithProgramTypeMap = new Map<Id, String>();
        
        Map<String, Integer> ndsSettlementFeeMap = 
            new Map<String, Integer>{'LDP' => 9, 'Under 30000' => 17, 'Over 30000' => 17, 'Over 35000' => 17};
            
        Map<String, Map<String, Map<Decimal, nu_dse__Field_mapping__c>>> portfolioWithFieldMapping = 
            new Map<String, Map<String, Map<Decimal, nu_dse__Field_mapping__c>>>();
            
        Set<String> portfolioSet = new Set<String>();
        
        Map<Id, String> programWithTargetPolicyGrp = new Map<Id, String>();
        
        Map<String, Id> targetKeyWithFeeTempIdMap = new Map<String, Id>();
        
        Map<String, String> programTypeWithPortfolioMap = new Map<String, String>();
        
        Set<Id> processorIdSet = new Set<Id>();
        
        Set<Id> feeTemplateIdSet = new Set<Id>();
        
        Set<String> programTypeSet = new Set<String>();
        
        List<nu_dse__Program__c> ProgramsToBeUpdated = new List<nu_dse__Program__c>();
                
        for (nu_dse__Program__c programInst : programList) {
           
            if (programOldMap != null && programOldMap.get(programInst.Id)!= null
                && programInst.nu_dse__Total_Debt_Included__c != NULL
                && programInst.nu_dse__Total_Debt_Included__c != programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c
                && (programInst.DNL_Status__c != 'Pre-TILA Signed' && programInst.DNL_Status__c != 'Graduated DRP' 
                    && programInst.Program_Type__c != NULL && programInst.Program_Type__c.contains('Versara') == False)
                && programInst.Portfolio__c != NULL) {
                
                filteredProgramList.add(programInst);
                portfolioSet.add(programInst.Portfolio_Name__c);
                
                if (programInst.nu_dse__Fee_Template__c != NULL) {
                    feeTemplateIdSet.add(programInst.nu_dse__Fee_Template__c);
                }
                    
                if (programInst.Program_Type__c != NULL) {
                    programTypeSet.add(programInst.Program_Type__c);
                }
                
                if (programInst.nu_dse__Processor__c != NULL) {
                    processorIdSet.add(programInst.nu_dse__Processor__c);
                }
            }
        }
        System.debug('filteredProgramList-1->'+filteredProgramList);
        System.debug('feeTemplateIdSet --->'+feeTemplateIdSet);
        System.debug('portfolioSet--->'+portfolioSet);
        System.debug('processorIdSet--->'+processorIdSet);
        
        if (filteredProgramList != NULL && filteredProgramList.isEmpty() == False) {
        
            for (nu_dse__Field_mapping__c fieldMappingInst : 
            [
                SELECT Id, Program_Portfolio__c, LDP__c, Over_30000__c, Over_35000__c, Under_30000__c, Trust_Account_Provider__c, 
                Priority_Sequence_Number__c, Policy_Type__c, Program_Type_30K__c, Program_Type_35K__c, Populate_Program_Type__c 
                FROM nu_dse__Field_mapping__c 
                WHERE nu_dse__Data_Mapping__r.Name = 'PolicyGroupAssignment' AND Program_Portfolio__c IN :portfolioSet
            ]) {
                
                if (String.isNotBlank(fieldMappingInst.Program_Portfolio__c) && String.isNotBlank(fieldMappingInst.Policy_Type__c) 
                    && fieldMappingInst.Priority_Sequence_Number__c != NULL) {
                     
                    if (portfolioWithFieldMapping.containsKey(fieldMappingInst.Program_Portfolio__c) == False) { 
                    
                        portfolioWithFieldMapping.put(fieldMappingInst.Program_Portfolio__c, 
                                    new Map<String, Map<Decimal, nu_dse__Field_mapping__c>>());                    
                    }
                        
                    if (portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c)
                            .containsKey(fieldMappingInst.Policy_Type__c) == False) {
                        
                        portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c)
                            .put(fieldMappingInst.Policy_Type__c, new Map<Decimal, nu_dse__Field_mapping__c>());                     
                    }
                    
                    portfolioWithFieldMapping.get(fieldMappingInst.Program_Portfolio__c).get(fieldMappingInst.Policy_Type__c)
                        .put(fieldMappingInst.Priority_Sequence_Number__c, fieldMappingInst);                                                                                                                            
                }
            }
            
            if (portfolioWithFieldMapping.isEmpty() == False) {
                
                System.debug('portfolioWithFieldMapping--->'+portfolioWithFieldMapping);
                
                for (nu_dse__Program__c programInst : filteredProgramList) {
                
                    if (portfolioWithFieldMapping.containsKey(programInst.Portfolio_Name__c) 
                        && portfolioWithFieldMapping.get(programInst.Portfolio_Name__c).isEmpty() == False) {
                        
                        String oldCategory, newCategory;
                        
                        if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c != NULL) {
                    
                            if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 15000) {
                            
                                oldCategory = 'LDP__c';
                                
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 15000 
                                       && programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 30000) {
                                       
                                oldCategory = 'Under_30000__c';     
                                      
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 30000 
                                       && programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c < 35000) {
                                       
                                oldCategory = 'Over_30000__c';         
                                  
                            } else if (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 35000) {
                            
                                oldCategory = 'Over_35000__c';
                            }
                        }
                        System.debug('oldCategory---->'+oldCategory);
                            
                        if (programInst.nu_dse__Total_Debt_Included__c >= 35000) {
                        
                            newCategory = 'Over_35000__c';
                            
                        } else if (programInst.nu_dse__Total_Debt_Included__c >= 30000 
                                       && programInst.nu_dse__Total_Debt_Included__c < 35000) {
                                   
                            newCategory = 'Over_30000__c';         
                              
                        } else if ((programInst.nu_dse__Total_Debt_Included__c >= 15000 
                                        && programInst.nu_dse__Total_Debt_Included__c < 30000)
                                   || (programOldMap.get(programInst.Id).nu_dse__Total_Debt_Included__c >= 15000
                                       && programInst.nu_dse__Total_Debt_Included__c < 15000)) {
                                   
                            newCategory = 'Under_30000__c';     
                                  
                        } else if (programInst.nu_dse__Total_Debt_Included__c < 15000) {
                    
                            newCategory = 'LDP__c';
                        }
                        System.debug('newCategory ---->'+newCategory);
                        
                        if (oldCategory != newCategory) {
                            
                            String newCategoryLabel = Schema.getGlobalDescribe().get('nu_dse__Field_mapping__c').getDescribe().fields
                                                        .getMap().get(newCategory).getDescribe().getLabel();
                                                        
                            programWithCategoryMap.put(programInst.Id, newCategoryLabel);
                            
                            if (portfolioWithFieldMapping.get(programInst.Portfolio_Name__c).get('Debt Settlement').isEmpty() == False) {
                                
                                String targetPolicyGroup;
                            
                                for (Integer ctr = 1; ctr <= portfolioWithFieldMapping.get(programInst.Portfolio_Name__c)
                                                                .get('Debt Settlement').size(); ctr++) {
                                    
                                    nu_dse__Field_mapping__c fmd = portfolioWithFieldMapping.get(programInst.Portfolio_Name__c)
                                                                    .get('Debt Settlement').get(ctr);
                                    System.debug('Field Mapping --->'+fmd);
                                    
                                    if (fmd != NULL) {
                                    
                                        if (fmd.Populate_Program_Type__c == True) {
                                            
                                            if(newCategoryLabel == 'Under 30000' || newCategoryLabel == 'Over 30000') {
                                                
                                                programWithProgramTypeMap.put(programInst.Id, fmd.Program_Type_30K__c);
                                                
                                            } else if (newCategoryLabel == 'Over 35000') {
                                                
                                                programWithProgramTypeMap.put(programInst.Id, fmd.Program_Type_35K__c);
                                            }
                                        }
                                    
                                        Set<String> policyGroupSet = new Set<String>{fmd.LDP__c, fmd.Under_30000__c, fmd.Over_30000__c, fmd.Over_35000__c};
                                    
                                        if (ctr == 1) {
                                            
                                            targetPolicyGroup = (String)fmd.get(newCategory);
                                        }
                                        
                                        if (String.isNotBlank(programInst.GCS_Policy_Group__c) 
                                            && policyGroupSet.contains(programInst.GCS_Policy_Group__c)) {
                                            
                                            targetPolicyGroup = (String)fmd.get(newCategory);
                                            break;
                                        }
                                    }
                                }
                                                        
                                if (String.isNotBlank(targetPolicyGroup)) {
                                    
                                    programWithTargetPolicyGrp.put(programInst.Id, targetPolicyGroup);
                                }
                            }
                        }
                    }
                }
                System.debug('programWithTargetPolicyGrp--->'+programWithTargetPolicyGrp);
                System.debug('programWithCategoryMap------->'+programWithCategoryMap);
                System.debug('programWithProgramTypeMap------->'+programWithProgramTypeMap); 
                System.debug('filteredProgramList--2->'+filteredProgramList);
                
                if (programWithCategoryMap.isEmpty() == False) {
                
                    Map<Id, nu_dse__Processor__c>  processorMap = 
                        new Map<Id, nu_dse__Processor__c>([SELECT Id, nu_dse__Type__c FROM nu_dse__Processor__c 
                                                           WHERE Id IN :processorIdSet]);
                
                    Map<Id, nu_dse__Fee_Template__c> feeTemplateMap = new Map<Id, nu_dse__Fee_Template__c>(
                    [
                        SELECT Id, Portfolio_Name__c, Program_Type__c, nu_dse__Settlement_Pct__c, Debt_Amount__c,
                        Service_Fee_Percentage__c, nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c 
                        FROM nu_dse__Fee_Template__c
                        WHERE (Id IN :feeTemplateIdSet  
                        OR nu_dse__GCS_Fee_Group_Id__c IN :programWithTargetPolicyGrp.values() 
                        OR nu_dse__RAMS_Fee_Group_Id__c IN :programWithTargetPolicyGrp.values())
                        AND Portfolio_Name__c IN :portfolioWithFieldMapping .keySet() 
                        AND Debt_Amount__c != NULL AND Program_Type__c != NULL 
                        AND nu_dse__Settlement_Pct__c != NULL AND Service_Fee_Percentage__c != NULL
                    ]);
                    
                    System.debug('feeTemplateMap----->'+feeTemplateMap);
                    System.debug('processorMap----->'+processorMap);
                    
                    for(nu_dse__Fee_Template__c ft : feeTemplateMap.values()) {
                         
                         String existingKey = ft.Portfolio_Name__c + '-' + Integer.valueOf(ft.nu_dse__Settlement_Pct__c) + '-' 
                                              + Integer.valueOf(ft.Service_Fee_Percentage__c) + '-' + ft.Program_Type__c + '-' 
                                              + ft.Debt_Amount__c + '-';
                          
                         System.debug('existingKey--->'+existingKey);                    
                         if (ft.nu_dse__GCS_Fee_Group_Id__c != NULL) {
                         
                             System.debug('GCS');
                             targetKeyWithFeeTempIdMap.put(existingKey + 'GCS-' + ft.nu_dse__GCS_Fee_Group_Id__c, ft.Id);
                             System.debug(existingKey + 'GCS-' + ft.nu_dse__GCS_Fee_Group_Id__c+'---key---'+ft.Id);
                         }
                         
                         if (ft.nu_dse__RAMS_Fee_Group_Id__c != NULL) {
                             
                             System.debug('RAMS');
                             targetKeyWithFeeTempIdMap.put(existingKey + 'RAMS-' + ft.nu_dse__RAMS_Fee_Group_Id__c, ft.Id);
                         }                                             
                    }
                    System.debug('targetKeyWithFeeTempIdMap--->'+targetKeyWithFeeTempIdMap);
                    
                    if (programWithProgramTypeMap.isEmpty() == False) {
                        
                        programTypeSet.addAll(programWithProgramTypeMap.values());
                    }
                    System.debug('programTypeSet---->'+programTypeSet);
                    
                    if (programTypeSet.isEmpty() == False) {
                        
                        for (LeadTracProgramType__mdt programType : [Select Label,Portfolio_name__c FROM LeadTracProgramType__mdt 
                                                                             WHERE Label IN: programTypeSet]) {
                                                                             
                            programTypeWithPortfolioMap.put(programType.Label, programType.Portfolio_name__c);
                        }
                    }
                    System.debug('programTypeWithPortfolioMap--->'+programTypeWithPortfolioMap);
                            
                    for (nu_dse__Program__c programInst : filteredProgramList) {
                    
                        nu_dse__Program__c Program = new nu_dse__Program__c();
                        Program.Id = ProgramInst.Id;
                        
                        System.debug('programInst--->'+programInst);
                
                        if (programWithCategoryMap.get(programInst.Id) != NULL 
                            && programWithTargetPolicyGrp.isEmpty() == False && programWithTargetPolicyGrp.get(programInst.Id) != NULL) {
                            
                           // programInst.Settlement_Fee__c = ndsSettlementFeeMap.get(programWithCategoryMap.get(programInst.Id));
                        
                           program.GCS_Policy_Group__c = programWithTargetPolicyGrp.get(programInst.Id);
                            
                            if (programWithProgramTypeMap.isEmpty() == False && programWithProgramTypeMap.get(programInst.Id) != NULL) {
                                
                                program.Program_Type__c = programWithProgramTypeMap.get(programInst.Id);
                            }
                        
                            //nu_dse__Fee_Template__c ft = feeTemplateMap.get(programInst.nu_dse__Fee_Template__c);
                            
                            nu_dse__Processor__c proc = processorMap.get(programInst.nu_dse__Processor__c);
                                                                
                            String amountCategory = 
                                programWithCategoryMap.get(programInst.Id) == 'LDP' ? 'Under 30000' : 
                                    (programWithCategoryMap.get(programInst.Id) == 'Over 35000' ? 'Over 30000' : 
                                        programWithCategoryMap.get(programInst.Id));
                                        
                            //System.debug('ft---->'+ft);
                            System.debug('proc--->'+proc);
                            
                            String keyToUpdate;
                            
                            if (proc != NULL && programTypeWithPortfolioMap.isEmpty() == False 
                                && programTypeWithPortfolioMap.get(programInst.Program_Type__c) != NULL) {
                            
                                keyToUpdate =  programTypeWithPortfolioMap.get(programInst.Program_Type__c) + '-' 
                                               + Integer.valueOf(programInst.Estimated_Settlement__c) + '-' 
                                               + Integer.valueOf(programInst.Settlement_Fee__c)+ '-' 
                                               + programInst.Program_Type__c + '-' 
                                               + amountCategory + '-' 
                                               + proc.nu_dse__Type__c + '-'
                                               + programWithTargetPolicyGrp.get(programInst.Id); 
                            }                       
                            System.debug('keyToUpdate --->'+keyToUpdate );    
                             
                            if (String.isNotBlank(keyToUpdate) && targetKeyWithFeeTempIdMap.isEmpty() == False 
                                && targetKeyWithFeeTempIdMap.get(keyToUpdate) != NULL) {
                                 System.debug('check condition --->'+targetKeyWithFeeTempIdMap.get(keyToUpdate) ); 

                                program.nu_dse__Fee_Template__c = targetKeyWithFeeTempIdMap.get(keyToUpdate);
                                System.debug('updated fee template --->'+programInst.nu_dse__Fee_Template__c ); 
                            
                            } else {
                                
                                program.nu_dse__Fee_Template__c = NULL;
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                                String[] toAddresses = new String[] {Label.Fee_Template_Missing_Email};
                                mail.setToAddresses(toAddresses);
                        
                                mail.setSubject('Fee Template missing : ' + programInst.Name);
                        
                                mail.setHtmlBody('Hi, <br/><p>The Fee Template is missing for the Program : <b>'
                                + programInst.Name + ' - ' + programInst.Client_Full_Name__c 
                                + '</b>.</p><p>Policy Group : '+programWithTargetPolicyGrp.get(programInst.Id)
                                +'</p><p>Portfolio : ' +programInst.Portfolio_Name__c
                                + '</p><p>Program Type : ' +programInst.Program_Type__c
                                + '</p><p>Debt Category : ' +amountCategory
                                + '</p><p>Estimated Settlement % : ' +programInst.Estimated_Settlement__c
                                + '</p><p>Service Fee Percentage : ' +programInst.Settlement_Fee__c+ '</p>');
                        
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            }                            
                        }
                        
                        ProgramsToBeUpdated.add(Program);  
                    }
                    System.debug('filteredProgramList--3->'+filteredProgramList);
                }
            }
        }
        if(!ProgramsToBeUpdated.isEMpty()){
            Update ProgramsToBeUpdated;
        }
    }
    //S20-154 ****Ends****
    
    //S20-209 **** Starts****
    public static void populatingEnrollmentDateAndStrategyCallDate(Map<Id, nu_dse__Program__c> programOldMap, List<nu_dse__Program__c> programList) {
        
        Date attorneyStrategyDate;
        Date nonAttorneyStrategyDate;
        Boolean attorneyStrategyDateCalculated = False;
        Boolean nonAttorstrategyDateCalculated = False;
        
        Map<String, Holiday> holidayMap = Holidays.getHolidaysMap();
        
        for (nu_dse__Program__c programInstance : programList) {
            
            if (programInstance.nu_dse__Program_Status__c == 'Active Client' 
                && (Trigger.isInsert || (Trigger.isUpdate && programInstance.Enrollment_Date__c == null
                                        && programOldMap.get(programInstance.Id).nu_dse__Program_Status__c != 'Active Client')) ) {
                
                programInstance.Enrollment_Date__c = System.today();
                
                //if(!Attorney_StaticVariableUtility.apiUser){
                //For Attorney programs add 8 months else add 6months..
                if (programInstance.Attorney__c == True) {
                    
                    if (attorneyStrategyDateCalculated == False) {
                        
                        attorneyStrategyDate = getPreviousWorkingDay(holidayMap, System.today().addMonths(8), True, True);
                        programInstance.Expected_Strategy_Call_Date__c = attorneyStrategyDate;
                        attorneyStrategyDateCalculated = True;
                        
                    } else {
                        
                        programInstance.Expected_Strategy_Call_Date__c = attorneyStrategyDate;
                    }
                
                } else {
                
                    if (nonAttorstrategyDateCalculated == False) {
                        
                        nonAttorneyStrategyDate = getPreviousWorkingDay(holidayMap, System.today().addMonths(6), True, True);
                        programInstance.Expected_Strategy_Call_Date__c = nonAttorneyStrategyDate;
                        nonAttorstrategyDateCalculated = True;
                        
                    } else {
                        
                        programInstance.Expected_Strategy_Call_Date__c = nonAttorneyStrategyDate;
                    }
                }
                //}
            }
        }
    }
    
    public static Date getPreviousWorkingDay(Map<String, Holiday> holidayMap, Date currentDate, Boolean considerWeekEnd, Boolean considerHolidays) {
        
        System.debug(HolidayMap);
        System.debug(currentDate);
        
        Boolean daysIncremented;
        
        do {
            
            daysIncremented = False;
            
            if (considerHolidays == True && holidayMap.containsKey(currentDate.day() + '-' + currentDate.month())) {
            
                Holiday holidayRec = holidayMap.get(currentDate.day() + '-' + currentDate.month());
            
                if ((holidayRec.IsRecurrence && (holidayRec.RecurrenceStartDate != null && holidayRec.RecurrenceStartDate <= currentDate)
                        && (holidayRec.recurrenceEndDateOnly == null || holidayRec.recurrenceEndDateOnly >= currentDate))
                        || (holidayRec.IsRecurrence == False && holidayRec.ActivityDate.isSameDay(currentDate))) {
                
                    currentDate = currentDate.addDays(-1);
                    daysIncremented = True;
                }
            } 
    
            if (considerWeekEnd == True) {
                
                Date weekStart  = currentDate.toStartofWeek();
                Integer numofDayToAdd = weekStart.daysBetween(currentDate) == 6 ? -1 : weekStart.daysBetween(currentDate) == 0 ? -2 : 0;
                currentDate = currentDate.addDays(numofDayToAdd);
                daysIncremented = numofDayToAdd == 0?False:True;
            }
            
        } while(daysIncremented == True? holidayMap.containsKey(currentDate.day() + '-' + currentDate.month()) : False);
        return currentDate;
    }
    //S20-209 **** Ends****
    
}