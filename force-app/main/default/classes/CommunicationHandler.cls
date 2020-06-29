public with sharing class CommunicationHandler {

    public void sendSMS(List<Task> taskList) {
        
        Map<Id, String> whatIdPhoneMap = new Map<Id, String>();
        List<Task> taskToUpdateList = new List<Task>();
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> paymentIdSet = new Set<Id>();
        Set<Id> prospectIdSet = new Set<Id>();
        Set<Id> offerIdSet = new Set<Id>();
        
        Set<String> prospectFieldsToQueryStringSet = new Set<String>{'Id', 'Name', 'nu_dse__Work_Phone__c', 'nu_dse__Cell_Phone__c', 'nu_dse__Home_Phone__c'};
        Set<String> programFieldsToQueryStringSet = new Set<String>{'Id', 'Name', 'nu_dse__Account__r.Phone', 'nu_dse__Account__r.PersonHomePhone', 'nu_dse__Account__r.PersonMobilePhone', 'Portfolio_Phone__c'};
        Set<String> paymentFieldsToQueryStringSet = new Set<String>{'Id', 'Name', 'nu_dse__Program__r.nu_dse__Account__r.Phone', 'nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone', 'nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone', 'nu_dse__Program__r.Portfolio_Phone__c'};
        Set<String> offerFieldsToQueryStringSet = new Set<String>{'Id', 'Name', 'nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone', 'nu_dse__Program__r.Portfolio_Phone__c'};
        
        Map<Id, SObject> sobjectMap = new Map<Id, SObject>();
        Map<Id, Set<String>> tasksIdMergeFieldssetMap = new Map<Id, Set<String>>();
        
        TwilioMessage message;
        
        List<String> programStatusList = new List<String>();
        Set<String> communicationPortfolioNameSet = new Set<String>();
        Boolean containsProgTasks = False;
        List<Portfolio__c> communicationPortfolioList = new List<Portfolio__c>();
        
        if (taskList != null && taskList.isEmpty() == False) {
        
            String programPrefix = nu_dse__Program__c.SObjecttype.getDescribe().getKeyPrefix();
            String paymentPrefix = nu_dse__Payment__c.SObjecttype.getDescribe().getKeyPrefix();
            String prospectPrefix = nu_dse__Prospect__c.SObjecttype.getDescribe().getKeyPrefix();
            String offerPrefix = nu_dse__offer__c.SObjecttype.getDescribe().getKeyPrefix();
            
            for (Task taskRec : taskList) {
            
                if (taskRec.nu_dse__Communication_Template__c != null) {
                
                    if (taskRec.nu_dse__Phone__c == null && taskRec.whatId != null) {
                    
                        Set<String> fieldsStringSet = CustomMergeFields.getFieldsFromTheTextBody(taskRec.nu_dse__Communication_Template__r.nu_dse__SMS_Body__c);
                        
                        if (fieldsStringSet != null && fieldsStringSet.isEmpty() == False) {
                        
                            tasksIdMergeFieldssetMap.put(taskRec.Id, fieldsStringSet);
                        }
                        
                        if (String.valueOf(taskRec.whatId).startsWith(programPrefix)) {
                    
                            programIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                            
                            if (fieldsStringSet != null && fieldsStringSet.isEmpty() == False) {
                            
                                programFieldsToQueryStringSet.addAll(fieldsStringSet);
                            }
                        
                        } else if (String.valueOf(taskRec.whatId).startsWith(paymentPrefix)) {
                        
                            paymentIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                            
                            if (fieldsStringSet != null && fieldsStringSet.isEmpty() == False) {
                            
                                paymentFieldsToQueryStringSet.addAll(fieldsStringSet);
                            }
                            
                        } else if (String.valueOf(taskRec.whatId).startsWith(prospectPrefix)) {
                        
                            prospectIdSet.add(taskRec.whatId);
                            
                            if (fieldsStringSet != null && fieldsStringSet.isEmpty() == False) {
                            
                                prospectFieldsToQueryStringSet.addAll(fieldsStringSet); //programFieldsToQueryStringSet.addAll(fieldsStringSet);
                            }
                        
                        } else if (String.valueOf(taskRec.whatId).startsWith(offerPrefix)) {
                            
                            offerIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                            
                            if (fieldsStringSet != null && fieldsStringSet.isEmpty() == False) {
                            
                                offerFieldsToQueryStringSet.addAll(fieldsStringSet);
                            }
                        }
                    }
                }
            }
            system.debug('tasksIdMergeFieldssetMap-->'+tasksIdMergeFieldssetMap);
            
            if (containsProgTasks == True) {
                
                for (Program_Status_Mapping__mdt CommTempForPrgmStatus : [SELECT Id, Label FROM Program_Status_Mapping__mdt]) {
                
                     programStatusList.add(CommTempForPrgmStatus.Label);
                }
                
                for (Process_For_Portfolio__mdt commPortfolioName : [SELECT Id, Label FROM Process_For_Portfolio__mdt WHERE Send_Notification__c = True]) {
                    
                    communicationPortfolioNameSet.add(commPortfolioName.Label);
                }
                
                System.debug('communicationPortfolioNameSet-->'+communicationPortfolioNameSet);
                
                communicationPortfolioList = [SELECT Id FROM Portfolio__c WHERE Name IN :communicationPortfolioNameSet];
            }
            
            if (programIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
            
                String programQuery = 'SELECT ';
                
                for (String prgmField : programFieldsToQueryStringSet) {
                
                    programQuery += prgmField + ', ';
                }
                programQuery = programQuery.removeEnd(', ');
                
                programQuery += ' FROM nu_dse__Program__c WHERE Id IN :programIdSet AND Portfolio__c IN :communicationPortfolioList AND nu_dse__Program_Status__c IN :programStatusList AND (nu_dse__Account__r.Phone != null ' +
                                ' OR nu_dse__Account__r.PersonHomePhone != null OR nu_dse__Account__r.PersonMobilePhone != null)';
                
                system.debug('programQuery-->'+programQuery);
                
                for (nu_dse__Program__c prgm : Database.query(programQuery)) {
                    
                    sobjectMap.put(prgm.Id, prgm);
                    
                    if (prgm.nu_dse__Account__r.Phone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.Phone);
                        
                    } else if (prgm.nu_dse__Account__r.PersonHomePhone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.PersonHomePhone);
                        
                    } else if (prgm.nu_dse__Account__r.PersonMobilePhone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.PersonMobilePhone);
                    }
                }
            }
            
            if (paymentIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
            
                String paymentQuery = 'SELECT ';
                
                for (String paymentField : paymentFieldsToQueryStringSet) {
                
                    paymentQuery += paymentField + ', ';
                }
                paymentQuery = paymentQuery.removeEnd(', ');
                
                paymentQuery += ' FROM nu_dse__Payment__c WHERE Id IN :paymentIdSet AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList AND (nu_dse__Program__r.nu_dse__Account__r.Phone != null ' +
                                ' OR nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null OR nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null) ';
                
                system.debug('paymentQuery-->'+paymentQuery);
                
                for (nu_dse__Payment__c payment : Database.Query(paymentQuery)) {
                
                    sobjectMap.put(payment.Id, payment);
                    
                    if (payment.nu_dse__Program__r.nu_dse__Account__r.Phone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.Phone);
                        
                    } else if (payment.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone);
                        
                    }  else if (payment.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone);
                    }
                }
            }
            
            if (prospectIdSet.isEmpty() == False) {
            
                String prospectQuery = 'SELECT ';
                
                for (String prospectField : prospectFieldsToQueryStringSet) {
                
                    prospectQuery += prospectField + ', ';
                }
                prospectQuery = prospectQuery.removeEnd(', ');
                
                prospectQuery += ' FROM nu_dse__Prospect__c WHERE Id IN :prospectIdSet AND (nu_dse__Work_Phone__c != null OR nu_dse__Cell_Phone__c != null ' +
                                 ' OR nu_dse__Home_Phone__c != null)';
                
                system.debug('prospectQuery--->'+prospectQuery);
                for (nu_dse__Prospect__c prospectRec : Database.Query(prospectQuery)) {
                
                    sobjectMap.put(prospectRec.Id, prospectRec);
                    
                    if (prospectRec.nu_dse__Work_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Work_Phone__c);
                        
                    } else if (prospectRec.nu_dse__Home_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Home_Phone__c);
                        
                    }  else if (prospectRec.nu_dse__Cell_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Cell_Phone__c);
                    }
                }
            }
            
            if (offerIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
                
                String offerQuery = 'SELECT ';
                
                for (String offerField : offerFieldsToQueryStringSet) {
                
                    offerQuery += offerField + ', ';
                }
                
                offerQuery = offerQuery.removeEnd(', ');
                
                offerQuery += ' FROM nu_dse__Offer__c WHERE Id IN :offerIdSet AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList AND (nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null)';
                
                System.debug('offerQuery-->'+offerQuery);
                
                for (nu_dse__offer__c offerRec : Database.Query(offerQuery)) {
                    
                    sobjectMap.put(offerRec.Id, offerRec);
                    whatIdPhoneMap.put(offerRec.Id, offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone);
                }
            }
            
            for (Task taskRec : taskList) {
            
                if (taskRec.nu_dse__Communication_Template__r.nu_dse__SMS_Body__c != null
                        && (taskRec.nu_dse__Phone__c != null || whatIdPhoneMap.containsKey(taskRec.whatId))) {
                
                    try {
                    
                        String phone;
                        String fromPhoneNumber;
                        
                        if (taskRec.nu_dse__Phone__c != null) {
                        
                            phone = taskRec.nu_dse__Phone__c;
                            
                        } else if (whatIdPhoneMap.containsKey(taskRec.whatId)) {
                        
                            phone = whatIdPhoneMap.get(taskRec.whatId);
                        }
                        
                        SObject sobjInstance;
                        
                        if (sobjectMap.containsKey(taskRec.whatId)) {
                        
                            sobjInstance = sobjectMap.get(taskRec.whatId);
                            
                            if (sobjInstance.Id != null && String.valueOf(sobjInstance.Id).startsWith(programPrefix)) {
                                
                                if (sobjInstance.get('Portfolio_Phone__c') != null) {
                                    
                                    fromPhoneNumber = String.valueOf(sobjInstance.get('Portfolio_Phone__c'));
                                }
                            
                            } else if (String.valueOf(sobjInstance.Id).startsWith(paymentPrefix)) {
                                
                                if (sobjInstance.getSObject('nu_dse__Program__r') != null && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c') != null) {
                                    
                                    fromPhoneNumber = String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c'));
                                }
                            
                            } else if (String.valueOf(sobjInstance.Id).startsWith(offerPrefix)) {
                                
                                if (sobjInstance.getSObject('nu_dse__Program__r') != null && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c') != null) {
                                    
                                    fromPhoneNumber = String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c'));
                                }
                            
                            }
                            
                            
                        }
                        System.debug('fromPhoneNumber->'+fromPhoneNumber);
                        
                        Set<String> fieldsSet = new Set<String>();
                        
                        if (tasksIdMergeFieldssetMap.containsKey(taskRec.Id)) {
                            
                            fieldsSet = tasksIdMergeFieldssetMap.get(taskRec.Id);
                        }
                        
                        String textBody = CustomMergeFields.mergeFields(taskRec.nu_dse__Communication_Template__r.nu_dse__SMS_Body__c, fieldsSet, sobjInstance);
                        system.debug('textBody--->'+textBody);
                        system.debug('fromPhoneNumber--->'+fromPhoneNumber);
                        system.debug('phone--->'+phone);
                        message = TwilioCommunications.sendSMS(fromPhoneNumber, phone, textBody);
                    
                        if (message.getErrorMessage() == null) {
                        
                            Task taskRecToupdate = new Task(Id = taskRec.Id, Status = 'Completed', nu_dse__Communication_Sent__c = True);
                            taskToUpdateList.add(taskRecToupdate);
                        
                        } else {
                        
                            if (message.getBody() != null) {
                            
                                nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotifyBySMS',
                                        nu_dse__Message__c = message.getBody(), nu_dse__User_Context__c = UserInfo.getName());
                                errorLogList.add(errLog);
                            }
                        }
                    
                    } catch(Exception e) {
                    
                        throw e;
                    }
                }
            }
            
            if (taskToUpdateList.isEmpty() == False) {
            
                update taskToUpdateList;
            }
            
            if (errorLogList.isEmpty() == False) {
            
                insert errorLogList;
            }
        }
    }
    
    public void sendVoiceBroadcasts(List<Task> taskList) {
        
        Map<Id, nu_dse__Communication_Template__c> taskIdCommunicationTemplateMap = new Map<Id, nu_dse__Communication_Template__c>();
        Map<Id, String> whatIdPhoneMap = new Map<Id, String>();
        Map<Id, Sobject> whatIdSobjectMap = new Map<Id, Sobject>();
        List<Task> taskToUpdateList = new List<Task>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> paymentIdSet = new Set<Id>();
        Set<Id> prospectIdSet = new Set<Id>();
        Set<Id> offerIdSet = new Set<Id>();
        
        Set<Id> communicationTemplateId = new Set<Id>();
        
        if (taskList.isEmpty() == False) {
        
            String programPrefix = nu_dse__Program__c.SObjecttype.getDescribe().getKeyPrefix();
            String paymentPrefix = nu_dse__Payment__c.SObjecttype.getDescribe().getKeyPrefix();
            String prospectPrefix = nu_dse__Prospect__c.SObjecttype.getDescribe().getKeyPrefix();
            String offerPrefix = nu_dse__Offer__c.SObjecttype.getDescribe().getKeyPrefix();
            
            List<String> programStatusList = new List<String>();
            Set<String> communicationPortfolioNameSet = new Set<String>();
            Boolean containsProgTasks = False;
            List<Portfolio__c> communicationPortfolioList = new List<Portfolio__c>();
            
            for (Task taskRec : taskList) {
            
                if (taskRec.nu_dse__Communication_Template__c != null) {
                
                    nu_dse__Communication_Template__c communicationTemp = new nu_dse__Communication_Template__c(Id = taskRec.nu_dse__Communication_Template__c,
                                nu_dse__From__c = taskRec.nu_dse__Communication_Template__r.nu_dse__From__c, nu_dse__TwiML__c = taskRec.nu_dse__Communication_Template__r.nu_dse__TwiML__c);
                
                    taskIdCommunicationTemplateMap.put(taskRec.Id, communicationTemp);
                    communicationTemplateId.add(communicationTemp.Id);
                    
                    if (taskRec.nu_dse__Phone__c == null && taskRec.whatId != null) {
                    
                        if (String.valueOf(taskRec.whatId).startsWith(programPrefix)) {
                    
                            programIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                            
                        } else if (String.valueOf(taskRec.whatId).startsWith(paymentPrefix)) {
                        
                            paymentIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                            
                        } else if (String.valueOf(taskRec.whatId).startsWith(prospectPrefix)) {
                        
                            prospectIdSet.add(taskRec.whatId);
                        
                        } else if (String.valueOf(taskRec.whatId).startsWith(offerPrefix)) {
                            
                            offerIdSet.add(taskRec.whatId);
                            containsProgTasks = True;
                        }
                    }
                }
            }
            
            System.debug('offerIdSet'+offerIdSet);
            
             if (containsProgTasks == True) {
                
                for (Program_Status_Mapping__mdt CommTempForPrgmStatus : [SELECT Id, Label FROM Program_Status_Mapping__mdt]) {
                
                     programStatusList.add(CommTempForPrgmStatus.Label);
                }
                
                for (Process_For_Portfolio__mdt commPortfolioName : [SELECT Id, Label FROM Process_For_Portfolio__mdt WHERE Send_Notification__c = True]) {
                    
                    communicationPortfolioNameSet.add(commPortfolioName.Label);
                }
                
                System.debug('communicationPortfolioNameSet-->'+communicationPortfolioNameSet);
                
                communicationPortfolioList = [SELECT Id FROM Portfolio__c WHERE Name IN :communicationPortfolioNameSet];
            }
            
            if (programIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
            
                for (nu_dse__Program__c prgm : [SELECT Id, Name, nu_dse__Account__r.Phone, nu_dse__Account__r.PersonHomePhone,
                                            nu_dse__Account__r.PersonMobilePhone, Portfolio_Phone__c, Portfolio__c, Portfolio__r.Name
                                            FROM nu_dse__Program__c 
                                            WHERE Id IN :programIdSet AND Portfolio__c IN :communicationPortfolioList 
                                            AND nu_dse__Program_Status__c IN :programStatusList AND (nu_dse__Account__r.Phone != null
                                            OR nu_dse__Account__r.PersonHomePhone != null 
                                            OR nu_dse__Account__r.PersonMobilePhone != null)]) {
                    
                    whatIdSobjectMap.put(prgm.Id, prgm);
                    
                    if (prgm.nu_dse__Account__r.Phone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.Phone);
                        
                    } else if (prgm.nu_dse__Account__r.PersonHomePhone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.PersonHomePhone);
                        
                    } else if (prgm.nu_dse__Account__r.PersonMobilePhone != null) {
                    
                        whatIdPhoneMap.put(prgm.Id, prgm.nu_dse__Account__r.PersonMobilePhone);
                    }
                    
                }
            }
            
            if (paymentIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
            
                for (nu_dse__Payment__c payment : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.Phone, nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone, 
                                                   nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone, nu_dse__Program__r.Portfolio__c, 
                                                   nu_dse__Program__r.Portfolio__r.Name, nu_dse__Program__r.Portfolio_Phone__c
                                                   FROM nu_dse__Payment__c 
                                                   WHERE Id IN :paymentIdSet AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList 
                                                   AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList 
                                                   AND (nu_dse__Program__r.nu_dse__Account__r.Phone != null
                                                   OR nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null
                                                   OR nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null)]) {
                    
                    whatIdSobjectMap.put(payment.Id, payment);
                    
                    if (payment.nu_dse__Program__r.nu_dse__Account__r.Phone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.Phone);
                        
                    } else if (payment.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone);
                        
                    }  else if (payment.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null) {
                    
                        whatIdPhoneMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone);
                    }
                }
            }
            
            if (prospectIdSet.isEmpty() == False) {
            
                for (nu_dse__Prospect__c prospectRec : [SELECT Id, Name, nu_dse__Work_Phone__c, nu_dse__Cell_Phone__c, nu_dse__Home_Phone__c FROM nu_dse__Prospect__c
                                                    WHERE Id IN :prospectIdSet AND (nu_dse__Work_Phone__c != null OR nu_dse__Cell_Phone__c != null
                                                    OR nu_dse__Home_Phone__c != null)]) {
                
                    if (prospectRec.nu_dse__Work_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Work_Phone__c);
                        
                    } else if (prospectRec.nu_dse__Home_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Home_Phone__c);
                        
                    }  else if (prospectRec.nu_dse__Cell_Phone__c != null) {
                    
                        whatIdPhoneMap.put(prospectRec.Id, prospectRec.nu_dse__Cell_Phone__c);
                    }
                }
            }
            System.debug('offerIdSet-->'+offerIdSet);
            
            if (offerIdSet.isEmpty() == False && communicationPortfolioList.isEmpty() == False) {
                
                for (nu_dse__Offer__c offerRec : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.Phone, nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone, 
                                               nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone, nu_dse__Program__r.Portfolio_Phone__c,
                                               nu_dse__Program__r.Portfolio__c, nu_dse__Program__r.Portfolio__r.Name 
                                               FROM nu_dse__Offer__c 
                                               WHERE Id IN :offerIdSet AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList
                                               AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList 
                                               AND (nu_dse__Program__r.nu_dse__Account__r.Phone != null
                                               OR nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null
                                               OR nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null)]) {
                   
                    whatIdSobjectMap.put(offerRec.Id, offerRec);
                   
                    if (offerRec.nu_dse__Program__r.nu_dse__Account__r.Phone != null) {
                    
                        whatIdPhoneMap.put(offerRec.Id, offerRec.nu_dse__Program__r.nu_dse__Account__r.Phone);
                        
                    } else if (offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone != null) {
                    
                        whatIdPhoneMap.put(offerRec.Id, offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone);
                        
                    }  else if (offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone != null) {
                    
                        whatIdPhoneMap.put(offerRec.Id, offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone);
                    }                                
                }
            }
            
            System.debug('whatIdPhoneMap-->'+whatIdPhoneMap);
            if (whatIdPhoneMap.isEmpty() == False) {
            
                Map<String, Set<String>> communicationTempAndItsPortfolioMap = new Map<String, Set<String>>();
                Set<String> answerTypeSet = new Set<String>{'human', 'machine'};
                Map<Id, Set<String>> communicationTempWithValidPorfolioMap = new Map<Id, Set<String>>();
                
                for (Voice_Recordings__c vrInst : [SELECT Id, twilio_answer_type__c, Communication_Template__c, Portfolio__c, Portfolio__r.Name FROM Voice_Recordings__c WHERE Communication_Template__c IN :communicationTemplateId]) {
                    
                    if (communicationTempAndItsPortfolioMap.containsKey(vrInst.Communication_Template__c + '-' +vrInst.Portfolio__c) == False) {
                        
                        communicationTempAndItsPortfolioMap.put(vrInst.Communication_Template__c + '-' +vrInst.Portfolio__c, new Set<String>());
                    }
                    communicationTempAndItsPortfolioMap.get(vrInst.Communication_Template__c + '-' +vrInst.Portfolio__c).add(vrInst.twilio_answer_type__c);
                }
                
                System.debug('vrMap-->'+communicationTempAndItsPortfolioMap);
                
                for (String communicationIdWithPortfolio : communicationTempAndItsPortfolioMap.keyset()) {
                    
                    if (communicationTempAndItsPortfolioMap.get(communicationIdWithPortfolio).containsAll(answerTypeSet) == True) {
                        
                        List<String> communicationTempAndItsPortfolioNameList = communicationIdWithPortfolio.split('-');
                        System.debug('communicationTempAndItsPortfolioNameList-->'+communicationTempAndItsPortfolioNameList);
                        
                        if (communicationTempAndItsPortfolioNameList.size() == 2) {
    
                            if (communicationTempWithValidPorfolioMap.containsKey(communicationTempAndItsPortfolioNameList[0]) == False) {
                                
                                communicationTempWithValidPorfolioMap.put(Id.valueOf(communicationTempAndItsPortfolioNameList[0]), new Set<String>());
                            }
                            communicationTempWithValidPorfolioMap.get(communicationTempAndItsPortfolioNameList[0]).add(communicationTempAndItsPortfolioNameList[1]);
                        }
                    }
                }
                
                System.debug('final-->'+communicationTempWithValidPorfolioMap);
                
                for (Task taskRec : taskList) {
                
                    if (taskIdCommunicationTemplateMap.containsKey(taskRec.Id)
                            && taskIdCommunicationTemplateMap.get(taskRec.Id).nu_dse__TwiML__c != null
                            && (taskRec.nu_dse__Phone__c != null || whatIdPhoneMap.containsKey(taskRec.whatId))) {
                    
                        try {
                        
                            String phone;
                            String fromPhoneNumber;
                            Set<String> portfolioSet = new Set<String>();
                            Boolean hasChildRecordings = False;
                            
                            if (communicationTempWithValidPorfolioMap.containsKey(taskIdCommunicationTemplateMap.get(taskRec.Id).Id)) {
                                
                                portfolioSet.addAll(communicationTempWithValidPorfolioMap.get(taskIdCommunicationTemplateMap.get(taskRec.Id).Id));
                            }
                            
                            if (taskRec.nu_dse__Phone__c != null) {
                            
                                phone = taskRec.nu_dse__Phone__c;
                                
                            } else if (whatIdPhoneMap.containsKey(taskRec.whatId)) {
                            
                                phone = whatIdPhoneMap.get(taskRec.whatId);
                            }
                            
                            if (whatIdSobjectMap.containsKey(taskRec.whatId)) {
                            
                                Sobject sobjInstance = whatIdSobjectMap.get(taskRec.whatId);
                                
                                System.debug('sobjInstance-->'+sobjInstance);
                                
                                if (sobjInstance.Id != null && String.valueOf(sobjInstance.Id).startsWith(programPrefix)) {
                                    
                                    if (sobjInstance.get('Portfolio_Phone__c') != null) {
                                        
                                        fromPhoneNumber = String.valueOf(sobjInstance.get('Portfolio_Phone__c'));
                                    }
                                    
                                    if (sobjInstance.get('Portfolio__c') != null && portfolioSet.contains(String.valueOf(sobjInstance.get('Portfolio__c')))) {
                                        
                                        hasChildRecordings = True;
                                        System.debug('sobjInstance-->'+String.valueOf(sobjInstance.get('Portfolio__c')));
                                    }
                                
                                } else if (String.valueOf(sobjInstance.Id).startsWith(paymentPrefix)) {
                                    
                                    if (sobjInstance.getSObject('nu_dse__Program__r') != null 
                                        && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c') != null) {
                                        
                                        fromPhoneNumber = String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c'));
                                    }
                                    
                                    if (sobjInstance.getSObject('nu_dse__Program__r') != null && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c') != null 
                                        && portfolioSet.contains(String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c')))) {
                                        
                                        hasChildRecordings = True;
                                        System.debug('sobjInstance-Payment-->'+String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c')));
                                    }
                                    
                                } else if (String.valueOf(sobjInstance.Id).startsWith(offerPrefix)) {
                                    
                                    if (sobjInstance.getSObject('nu_dse__Program__r') != null && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c') != null) {
                                        
                                        fromPhoneNumber = String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio_Phone__c'));
                                    }
                                    
                                    if (sobjInstance.getSObject('nu_dse__Program__r') != null && sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c') != null 
                                        && portfolioSet.contains(String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c')))) {
                                        
                                        hasChildRecordings = True;
                                        System.debug('sobjInstance-Offer-->'+String.valueOf(sobjInstance.getSObject('nu_dse__Program__r').get('Portfolio__c')));
                                    }
                                }
                            }
                            
                            if (String.valueOf(taskRec.whatId).startsWith(prospectPrefix)) {
                                
                                hasChildRecordings = True;
                            }
                            
                            if (string.isNotBlank(fromPhoneNumber) && taskIdCommunicationTemplateMap.containsKey(taskRec.Id) && taskIdCommunicationTemplateMap.get(taskRec.Id).nu_dse__From__c != null) {
                                    
                                fromPhoneNumber = taskRec.nu_dse__Communication_Template__r.nu_dse__From__c;
                            }
                            
                            System.debug('portfolioSet-->'+portfolioSet);
                            System.debug('HasChildRecordings-->'+hasChildRecordings);
                            
                            System.debug('**whatIdSobjectMap-->'+whatIdSobjectMap);
                            System.debug('**taskIdCommunicationTemplateMap-->'+taskIdCommunicationTemplateMap);
                            System.debug('**FromPhoneNumber-CH-->'+fromPhoneNumber);
                            System.debug('**TOPhoneNumber-CH-->'+phone);
                            
                            if (String.isNotBlank(fromPhoneNumber) && hasChildRecordings == True) {
                                
                                TwilioCommunications.sendVoiceBroadCast(fromPhoneNumber, phone, taskIdCommunicationTemplateMap.get(taskRec.Id).nu_dse__TwiML__c + '?taskId=' + taskRec.Id);
                                
                                Task taskRecToupdate = new Task(Id = taskRec.Id, Status = 'Completed', nu_dse__Communication_Sent__c = True);
                                taskToUpdateList.add(taskRecToupdate);
                                System.debug('Callout Performed');
                            }
                            
                        } catch(Exception e) {
                        
                            throw e;
                        }
                    }
                }
                
                if (taskToUpdateList.isEmpty() == False) {
                
                    update taskToUpdateList;
                }
            }
        }
    }
    
    public void sendEmailAlerts(List<Task> taskList) {
    
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Map<String, Id> emailTemplateMap = new Map<String, Id>();
        Map<Id, Id> whatIdEmailIdMap = new Map<Id, Id>();
        Map<Id, Id> taskIdCommunicationEmailTempIdMap = new Map<Id, Id>();
        Map<Id, String> prospectEmailMap = new Map<Id, String>();
        List<Task> taskToUpdateList = new List<Task>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> paymentIdSet = new Set<Id>();
        Set<Id> prospectIdSet = new Set<Id>();
        Set<Id> offerIdSet = new Set<Id>();
        
        Map<Id, String> taskIdAndItsFromAddress = new Map<Id, String> ();
        
        if (taskList != null && taskList.isEmpty() == False) {
        
            String programPrefix = nu_dse__Program__c.SObjecttype.getDescribe().getKeyPrefix();
            String prospectPrefix = nu_dse__Prospect__c.SObjecttype.getDescribe().getKeyPrefix();
            String paymentPrefix = nu_dse__Payment__c.SObjecttype.getDescribe().getKeyPrefix();
            String contactPrefix = Contact.SObjecttype.getDescribe().getKeyPrefix();
            String offerPrefix = nu_dse__Offer__c.SObjecttype.getDescribe().getKeyPrefix();
            
            List<String> programStatusList = new List<String>();
            Set<String> communicationPortfolioNameSet = new Set<String>();
            Boolean containsProgTasks = False;
            List<Portfolio__c> communicationPortfolioList = new List<Portfolio__c>();
            
            nu_dse__Communication_Notification_Settings__c communicationSetting = nu_dse__Communication_Notification_Settings__c.getInstance();
            String defaultprospectContactId = communicationSetting.nu_dse__Default_Prospect_Contact_Id__c;
            system.debug('defaultprospectContactId--->'+defaultprospectContactId);
            
            Map<String, Id> orgWideEmailAddressMap = new Map<String, Id>();
            
            for (OrgWideEmailAddress orgEmailAddressInst : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                
                orgWideEmailAddressMap.put(orgEmailAddressInst.Address, orgEmailAddressInst.Id);
            }
            
            for (Task taskRec : taskList) {
            
                system.debug('taskRec-->'+taskRec);
                
                if (taskRec.nu_dse__Communication_Template__c != null 
                        && taskRec.nu_dse__Communication_Template__r.nu_dse__Email_Template_Id__c != null) {
                
                    taskIdCommunicationEmailTempIdMap.put(taskRec.Id, taskRec.nu_dse__Communication_Template__r.nu_dse__Email_Template_Id__c);
                }
                
                if ((taskRec.whoId == null || (taskRec.whoId != null && String.valueOf(taskRec.whoId).startsWith(contactPrefix) == False))
                        && taskRec.whatId != null) {
                
                    if (String.valueOf(taskRec.whatId).startsWith(programPrefix)) {
                    
                        programIdSet.add(taskRec.whatId);
                        containsProgTasks = True;
                        
                    } else if (String.valueOf(taskRec.whatId).startsWith(paymentPrefix)) {
                    
                        paymentIdSet.add(taskRec.whatId);
                        containsProgTasks = True;
                        
                    } else if (String.valueOf(taskRec.whatId).startsWith(prospectPrefix) && defaultprospectContactId != null) {
                    
                        prospectIdSet.add(taskRec.whatId);
                        whatIdEmailIdMap.put(taskRec.whatId, defaultprospectContactId);
                    
                    } else if (String.valueOf(taskRec.whatId).startsWith(offerPrefix)) {
                        
                        offerIdSet.add(taskRec.whatId);
                        containsProgTasks = True;
                    }
                    
                }
            }
            system.debug('prospectIdSet-->'+prospectIdSet);
            system.debug('whatIdEmailIdMap-->'+whatIdEmailIdMap);
            
            if (containsProgTasks == True) {
                
                for (Program_Status_Mapping__mdt CommTempForPrgmStatus : [SELECT Id, Label FROM Program_Status_Mapping__mdt]) {
                
                    programStatusList.add(CommTempForPrgmStatus.Label);
                }
                
                for (Process_For_Portfolio__mdt commPortfolioName : [SELECT Id, Label FROM Process_For_Portfolio__mdt WHERE Send_Notification__c = True]) {
                    
                    communicationPortfolioNameSet.add(commPortfolioName.Label);
                }
                
                System.debug('communicationPortfolioNameSet-->'+communicationPortfolioNameSet);
                
                communicationPortfolioList = [SELECT Id FROM Portfolio__c WHERE Name IN :communicationPortfolioNameSet];
            }
            
            if (programIdSet.isEmpty() == False) {
            
                for (nu_dse__Program__c prgm : [SELECT Id, Name, nu_dse__Account__r.PersonEmail, nu_dse__Account__r.PersonContactId, 
                                                Portfolio__r.Communication_Template_Email__c 
                                                FROM nu_dse__Program__c
                                                WHERE Id IN :programIdSet AND Portfolio__c IN :communicationPortfolioList 
                                                AND nu_dse__Program_Status__c IN :programStatusList
                                                AND nu_dse__Account__r.PersonEmail != null]) {
                    
                    whatIdEmailIdMap.put(prgm.Id, prgm.nu_dse__Account__r.PersonContactId);
                    
                    if (prgm.portfolio__c != null && prgm.Portfolio__r.Communication_Template_Email__c != null) {
                        
                        taskIdAndItsFromAddress.put(prgm.Id, prgm.Portfolio__r.Communication_Template_Email__c);
                    }
                }
            }
            
            if (paymentIdSet.isEmpty() == False) {
            
                for (nu_dse__Payment__c payment : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.PersonEmail, 
                                                    nu_dse__Program__r.nu_dse__Account__r.PersonContactId, 
                                                    nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c
                                                    FROM nu_dse__Payment__c
                                                    WHERE Id IN :paymentIdSet AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList 
                                                    AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList
                                                    AND nu_dse__Program__r.nu_dse__Account__r.PersonEmail != null]) {
                
                    whatIdEmailIdMap.put(payment.Id, payment.nu_dse__Program__r.nu_dse__Account__r.PersonContactId);
                    
                    if (payment.nu_dse__Program__r.portfolio__c != null && payment.nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c != null) {
                        
                        taskIdAndItsFromAddress.put(payment.Id, payment.nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c);
                    }
                }
            }
            
            if (prospectIdSet.isEmpty() == False) {
            
                for (nu_dse__Prospect__c prospectRec : [SELECT Id, Name, nu_dse__Email_Address__c FROM nu_dse__Prospect__c WHERE Id IN :prospectIdSet]) {
                
                    prospectEmailMap.put(prospectRec.Id, prospectRec.nu_dse__Email_Address__c);
                }
            }
            system.debug('prospectEmailMap-->'+prospectEmailMap);
            
            if (offerIdSet.isEmpty() == False) {
                
                for (nu_dse__Offer__c offerRec : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.PersonContactId, 
                                                    nu_dse__Program__r.nu_dse__Account__r.PersonEmail,
                                                    nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c
                                                    FROM nu_dse__Offer__c 
                                                    WHERE Id IN :offerIdSet 
                                                    AND nu_dse__Program__r.Portfolio__c IN :communicationPortfolioList
                                                    AND nu_dse__Program__r.nu_dse__Program_Status__c IN :programStatusList
                                                    AND nu_dse__Program__r.nu_dse__Account__r.PersonEmail != null]) {
                
                    whatIdEmailIdMap.put(offerRec.Id, offerRec.nu_dse__Program__r.nu_dse__Account__r.PersonContactId);
                    
                    if (offerRec.nu_dse__Program__r.portfolio__c != null && offerRec.nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c != null) {
                        
                        taskIdAndItsFromAddress.put(offerRec.Id, offerRec.nu_dse__Program__r.Portfolio__r.Communication_Template_Email__c);
                    }
                }
            }
            system.debug('whatIdEmailIdMap-->'+whatIdEmailIdMap);
            for (Task taskRec : taskList) {
            
                if (taskIdCommunicationEmailTempIdMap.containsKey(taskRec.Id) && taskRec.whatId != null
                        && ((taskRec.whoId != null && String.valueOf(taskRec.whoId).startsWith(contactPrefix)) 
                                || whatIdEmailIdMap.containsKey(taskRec.whatId))) {
                    
                    Id whoId;
                    
                    if (taskRec.whoId != null && String.valueOf(taskRec.whoId).startsWith(contactPrefix)) {
                    
                        whoId = taskRec.whoId;
                        
                    } else if (whatIdEmailIdMap.containsKey(taskRec.whatId)) {
                    
                        whoId = whatIdEmailIdMap.get(taskRec.whatId);
                    }
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
                    if (taskIdAndItsFromAddress.containsKey(taskRec.whatId) && orgWideEmailAddressMap.containskey(taskIdAndItsFromAddress.get(taskRec.whatId))) {
                        
                        message.setOrgWideEmailAddressId(orgWideEmailAddressMap.get(taskIdAndItsFromAddress.get(taskRec.whatId)));
                    }
                    
                    message.setTemplateId(taskIdCommunicationEmailTempIdMap.get(taskRec.Id));
                    message.setWhatId(taskRec.whatId);
                    message.setTargetObjectId(whoId);
                    if (String.valueOf(taskRec.whatId).startsWith(prospectPrefix) && prospectEmailMap.containsKey(taskRec.whatId)) {
                        message.setToAddresses(new List<String>{prospectEmailMap.get(taskRec.whatId)});
                    }
                    message.setSaveAsActivity(false);
                    emailMessages.add(message);
                    
                    Task taskRecToupdate = new Task(Id = taskRec.Id, Status = 'Completed', nu_dse__Communication_Sent__c = True);
                    taskToUpdateList.add(taskRecToupdate);
                }
            }
            system.debug('emailMessages-->'+emailMessages);
            if (emailMessages.isEmpty() == False) {
            
                Messaging.SendEmailResult[] results;
                
                try {
                
                    results = Messaging.sendEmail(emailMessages);
                    system.debug('results-->'+results);
                    
                } catch(Exception e) {
                
                    throw e;
                }
                
                if (results[0].success && taskToUpdateList.isEmpty() == False) {
                
                    update taskToUpdateList;
                }
            }
        }
    }    
}