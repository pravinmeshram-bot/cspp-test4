/******************************************
Modified By: Mayur Agarwal
Modified Date - 3/16/2020
Description of Modification - Populating Tradeline Name on Program and Moving DML of Program after Tradeline.
******************************************/


@RestResource(urlMapping='/UploadSettlementLetter/*')
global class UploadSettlementLetter {
    
    @HTTPPOST
    global static String getSettlementLetters(String clientNumber, String arrayStatus, String offerId,String tradelineName, String letterUploaded, 
                                                String excelaDocumentName, String ndsCurrentCreditor, String currentBalance,
                                                String litigationStage, String responseDate, String ExelaOfferAmount, String ExelaCurrentBalance) {
    
        List<nu_dse__Offer__c> offers = new List<nu_dse__Offer__c>();
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>();
        String message = ''; // changes by Mayur to Support Error Message
        
        try {
        system.debug('mayur1'+clientNumber);
        system.debug('mayur2'+arrayStatus);
           
            if (String.isNotBlank(clientNumber) && String.isNotBlank(arrayStatus)) {
                
                for (nu_dse__Program__c programInstance : [SELECT Id, Array_Status__c, excela_tradeline__c //added by Mayur
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__r.Box_Folder_Name__c = :clientNumber LIMIT 1]) {
                    
                    programInstance.Array_Status__c = arrayStatus;
                    programInstance.Excela_Document_Name__c = excelaDocumentName;
                    //Below line added by Mayur to Trigger Group Task Creation
                    programInstance.excela_tradeline__c = tradelineName;
                    programs.add(programInstance);
                }
                
                if (programs != null && programs.size() > 0) {
                    
                    System.debug('programs---->' + programs);
                    
                    //Below 2 lines commented by Mayur and moved this logic after Tradeline DML
                    
                //    update programs;
               //     message = 'Array Status Updated Successfully.';
                    
                    if (String.isNotBlank(offerId) && letterUploaded != null) {
                       
                       for (nu_dse__Offer__c offer : [SELECT Id, Letter_Uploaded__c, Excela_Document_Name__c, nu_dse__Tradeline__c, Letter_Received_Date__c
                                                       FROM nu_dse__Offer__c WHERE Id = :offerId ]) {
                           
                            offer.Letter_Uploaded__c = Boolean.valueOf(letterUploaded);
                            
                            if (Boolean.valueOf(letterUploaded) == True && offer.Letter_Received_Date__c == null) {
                                
                                offer.Letter_Received_Date__c = System.today();
                            }
                            
                            if (String.isNotBlank(excelaDocumentName) == True) {
                                
                                offer.Excela_Document_Name__c = excelaDocumentName;
                            }
                            offers.add(offer);  
                                                    
                        }
                        
                        if (offers != null && offers.size() > 0) {
                            
                            System.debug('offers---->' + offers);
                            update offers;
                            
                            message = 'Array Status and Letter Uploaded were Updated Successfully.';
                            /*
                            if (Boolean.valueOf(letterUploaded) == True) {

                                List<Task> taskList = new List<Task> ();
                                
                                for (Task taskInstance : [SELECT Id FROM TASK WHERE WhatId = :offerId AND Status != 'Completed' AND Subject = 'Obtain Creditor Auth']) {
                                    
                                    taskInstance.Status = 'Completed';
                                    taskList.add(taskInstance);
                                }
                                update taskList;
                            }*/
                        }
                    }
                    
                    if (String.isNotBlank(tradelineName) == True) {
                        
                        List<nu_dse__Tradeline__c> tradelineList = new List<nu_dse__Tradeline__c> ();
                        
                        for (nu_dse__Tradeline__c tradelineInst : [SELECT Id FROM nu_dse__Tradeline__c WHERE Name = :tradelineName]) {
                                
                            nu_dse__Tradeline__c tradelineInstance = new nu_dse__Tradeline__c();
                            tradelineInstance.Id = tradelineInst.Id;
                            
                            if (String.isNotBlank(ndsCurrentCreditor) == True) {
                                
                                tradelineInstance.nds_Current_Creditor_Name__c = ndsCurrentCreditor;
                            }
                            
                            if (String.isNotBlank(currentBalance) == True) {
                                
                                tradelineInstance.SFS_Current_Balance__c = Decimal.valueOf(currentBalance);
                            }
                            
                            if (String.isNotBlank(litigationStage) == True) {
                                
                                tradelineInstance.Litigation_Stage__c = litigationStage;
                            }
                            
                            if (String.isNotBlank(responseDate) == True) {
                                
                                tradelineInstance.Excela_Response_Date__c = Date.parse(responseDate);
                            }
                            
                            if (String.isNotBlank(ExelaOfferAmount ) == True) {
                                
                                tradelineInstance.Exela_Offer_Amount__c = Decimal.valueOf(ExelaOfferAmount );
                            }
                            
                            if (String.isNotBlank(currentBalance) == True) {
                                
                                tradelineInstance.Exela_Current_Balance__c = Decimal.valueOf(currentBalance);
                            }
                            
                            System.debug('tradelineInstance-->'+tradelineInstance);
                            tradelineList.add(tradelineInstance);
                        }
                        
                        if (tradelineList != null && tradelineList.size() > 0) {
                                
                            update tradelineList;
                            message += ' And Tradeline Updated Successfully.';
                        }
                        
                    }
                    
                    //Below 2 added by Mayur
                  update programs;
                  message += 'Array Status Updated Successfully.';
                } else {
                    
                    message = 'Client does not exist with ' + clientNumber + ' !!!';
                }
            
            } else {
                
                message = 'Client number or array status cannot be empty!!!';
            }
        
        } catch (Exception e) {
            
            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'UploadSettlementLetter.getSettlementLetters', 
                                                                     nu_dse__Message__c = '{' + clientNumber + ',' + arrayStatus + ',' 
                                                                     + offerId + ',' + letterUploaded + '}-'  + e.getMessage(), 
                                                                     nu_dse__Stack_Trace__c  = e.getStackTraceString(), 
                                                                     nu_dse__User_Context__c = userInfo.getName());
            insert errorLog;
            
            Task_Owner_Id_Mapping__mdt taskOwnerId = [SELECT Owner_Id__c FROM Task_Owner_Id_Mapping__mdt WHERE MasterLabel = 'SFS Case'];
            
            Summon__c summon = new Summon__c(Error_Log__c = errorLog.Id);
            
            if (String.isNotBlank(taskOwnerId.Owner_Id__c)) {
                
                summon.OwnerId = taskOwnerId.Owner_Id__c;
            }
            
            insert summon;
            
            message = 'Letter Upload Failed !!!';            
            return message;
        } 
                
        return message;
    }
    
    @HTTPGET
    global static List<Tradeline> getLatestOffers(){
        
        List<Tradeline> tradelines = new List<Tradeline>(); 
        Map<Id,Id> tradelineIdOfferId = new Map<Id,Id>();
        
        for (nu_dse__Offer__c off : [SELECT Id, nu_dse__TradeLine__c, Latest_Offer__c FROM nu_dse__Offer__c WHERE Latest_Offer__c = TRUE]) {
            
            if (off.nu_dse__TradeLine__c != null && String.isNotBlank(off.nu_dse__TradeLine__c)) {
            
                tradelineIdOfferId.put(off.nu_dse__TradeLine__c, off.Id);
            }
        }
        
        List<nu_dse__TradeLine__c> tradelineList = 
            [
                SELECT Id,Name,nu_dse__New_Creditor__r.name,nu_dse__Original_Creditor__r.name,nds_Original_Creditor_Name__c,
                nds_Current_Creditor_Name__c,nu_dse__New_Account_Number__c,nu_dse__Original_Account_Number__c,
                nu_dse__Program__r.nu_dse__Program_Status__c,nu_dse__Program__r.Name,nu_dse__Program__r.nu_dse__Account__r.Box_Folder_Name__c,
                nu_dse__Program__r.nu_dse__Account__r.BoxFolderId__c,nu_dse__Program__r.nu_dse__Account__r.nu_dse__RAMS_Payee_Id__c,
                nu_dse__Program__r.nu_dse__Account__r.FirstName,nu_dse__Program__r.nu_dse__Account__r.LastName,
                nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_First_Name__c,nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_Last_Name__c,
                nu_dse__Program__r.nu_dse__Account__r.PersonMailingStreet,nu_dse__Program__r.nu_dse__Account__r.PersonMailingCity,
                nu_dse__Program__r.nu_dse__Account__r.PersonMailingState,nu_dse__Program__r.nu_dse__Account__r.PersonMailingPostalCode,
                nu_dse__Program__r.nu_dse__Account__r.PersonMailingCountry,nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone,
                nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone,nu_dse__Program__r.nu_dse__Account__r.CreatedDate,
                nu_dse__Program__r.Portfolio__c,nu_dse__Program__r.Attorney__c,nu_dse__Program__r.Portfolio__r.Name 
                FROM nu_dse__TradeLine__c
            ];
            
        System.debug(tradelineList.size() + ' <------tradelineList------> ' + tradelineList );
       
        for (nu_dse__TradeLine__c tl : tradelineList) {
            
            Tradeline t = new Tradeline();
            
            t.tradelineName = tl.Name;
            t.newCreditorName = tl.nu_dse__New_Creditor__r.name;
            t.originalCreditorName = tl.nu_dse__Original_Creditor__r.name;
            t.ndsOriginalCreditorName = tl.nds_Original_Creditor_Name__c;
            t.ndsCurrentCreditorName = tl.nds_Current_Creditor_Name__c;
            t.newAccountNumber = tl.nu_dse__New_Account_Number__c;
            t.originalAccountNumber = tl.nu_dse__Original_Account_Number__c;
            t.programStatus = tl.nu_dse__Program__r.nu_dse__Program_Status__c;
            t.programName = tl.nu_dse__Program__r.Name;
            t.boxFolderName = tl.nu_dse__Program__r.nu_dse__Account__r.Box_Folder_Name__c;
            t.boxFolderId = tl.nu_dse__Program__r.nu_dse__Account__r.BoxFolderId__c;
            t.ramsPayeeId = tl.nu_dse__Program__r.nu_dse__Account__r.nu_dse__RAMS_Payee_Id__c;
            t.firstName = tl.nu_dse__Program__r.nu_dse__Account__r.FirstName;
            t.lastName = tl.nu_dse__Program__r.nu_dse__Account__r.LastName;
            t.coFirstName = tl.nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_First_Name__c;
            t.coLastName = tl.nu_dse__Program__r.nu_dse__Account__r.nu_dse__Co_Last_Name__c;
            t.personMailingStreet = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMailingStreet;
            t.personMailingCity = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMailingCity;
            t.personMailingState = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMailingState;
            t.personMailingPostalCode = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMailingPostalCode;
            t.personMailingCountry = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMailingCountry;
            t.personHomePhone = tl.nu_dse__Program__r.nu_dse__Account__r.PersonHomePhone;
            t.personMobilePhone = tl.nu_dse__Program__r.nu_dse__Account__r.PersonMobilePhone;
            t.createdDate = tl.nu_dse__Program__r.nu_dse__Account__r.CreatedDate;
            t.portfolioId = tl.nu_dse__Program__r.Portfolio__c;
            t.attorney = tl.nu_dse__Program__r.Attorney__c;
            t.portfolioName = tl.nu_dse__Program__r.Portfolio__r.Name;
            
            if (tradelineIdOfferId != null && tradelineIdOfferId.size() > 0 && tradelineIdOfferId.containskey(tl.Id) 
                && tradelineIdOfferId.get(tl.Id) != null) {
                
                t.offerId = tradelineIdOfferId.get(tl.Id);
                
            }            
            
            tradelines.add(t);
        }
        System.debug(tradelines.size() + ' <-----tradelines:Size----> ' + tradelines);
        return tradelines;        
    }
    
    global class Tradeline{
    
        global String tradelineName;
        global String newCreditorName;
        global String originalCreditorName;
        global String ndsOriginalCreditorName;
        global String ndsCurrentCreditorName;
        global String newAccountNumber;
        global String originalAccountNumber;
        global String programStatus;
        global String programName;
        global String boxFolderName;
        global String boxFolderId;
        global String ramsPayeeId;
        global String firstName;
        global String lastName;
        global String coFirstName;
        global String coLastName;
        global String personMailingStreet;
        global String personMailingCity;
        global String personMailingState;
        global String personMailingPostalCode;
        global String personMailingCountry;
        global String personHomePhone;
        global String personMobilePhone;
        global DateTime createdDate;
        global String portfolioId;
        global Boolean attorney;
        global String portfolioName;
        global String offerId;
        
    }
}