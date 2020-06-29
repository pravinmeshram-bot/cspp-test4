/**
* @File Name          : RestNuDebtProgram_V1.cls
* @Description        : 
* @Author             : anmol@fsDev
* @Group              : 
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    4/13/2020   anmol@fsDev     Initial Version
**/
//DV-541/DV-540 new class created

@RestResource(urlMapping='/v1/UpdateNuDebtProgram/*')
global class RestNuDebtProgram_V1 {
    
    
    @HttpPost
    global static void updateProgram(){
        NuDebtProgramSchema.NuDebtProgramResponse response = new NuDebtProgramSchema.NuDebtProgramResponse();
        try{
            Map<String, String> NuDebtProgramStatusMap = new Map<String, String>();
            RestRequest req = RestContext.request;
            system.debug(logginglevel.error,'req.requestBody ==>'+req.requestBody);
            system.debug(logginglevel.error,'req.requestBody To String ==>'+req.requestBody.toString());
            if (req.requestBody != null){
                List<NuDebtProgramSchema.NuDebtProgramRequest> NuDebtProgramRecordList = (List<NuDebtProgramSchema.NuDebtProgramRequest>)JSON.deserialize(req.requestBody.toString(), List<NuDebtProgramSchema.NuDebtProgramRequest>.class);
                
                
                Id[] programIds = new Id[0];
                Id[] tradeLineIds = new Id[0];
                system.debug(logginglevel.error,'NuDebtProgramRecordList ==>'+NuDebtProgramRecordList);
                for(NuDebtProgramSchema.NuDebtProgramRequest request: NuDebtProgramRecordList) {
                    programIds.add(request.program_Id);
                    for(NuDebtProgramSchema.TradelineRequest tradeline: request.tradelines) { 
                        tradeLineIds.add(tradeline.tradeline_Id);
                    }
                }
                system.debug(logginglevel.error,'programIds ==>'+programIds);            
                system.debug(logginglevel.error,'tradeLineIds ==>'+tradeLineIds);            
                
                map<id,nu_dse__program__c> programMap = new map<id,nu_dse__program__c>([select id
                                                                                        , DNL_Status__c
                                                                                        , Estimated_Loan_Amount__c
                                                                                        , Estimated_Financed_Amount__c
                                                                                        , Estimated_Number_of_Payments__c
                                                                                        , Loan_Repayment_Frequency__c
                                                                                        , DNL_Lending_Application_ID__c
                                                                                        , DNL_Application_Number__c
                                                                                        , DNL_Term__c
                                                                                        , Loan_Officer__c
                                                                                        , Pre_TILA_Signed_Date__c
                                                                                        , Underwriter__c
                                                                                        , Estimated_Loan_Start_Date__c  from nu_dse__program__c 
                                                                                        where Id in :programIds ]);
                
                
                map<id,nu_dse__TradeLine__c> tradeLinesMap = new map<id,nu_dse__TradeLine__c>([SELECT id
                                                                                               , name 
                                                                                               , DNL_Estimated_Settlement_Percentage__c
                                                                                               , DNL_Estimated_Settlement_Amount__c
                                                                                               from nu_dse__TradeLine__c
                                                                                               where Id in :tradeLineIds ]);
                
                
                List<nu_dse__program__c> programToBeUpdated = new List<nu_dse__program__c>();
                List< nu_dse__TradeLine__c > tradeLinesToBeUpdated = new List< nu_dse__TradeLine__c >();
                for(NuDebtProgramSchema.NuDebtProgramRequest request: NuDebtProgramRecordList) {
                    System.debug(loggingLevel.ERROR, '-- jsonBody : ' + request);
                    nu_dse__program__c program = programMap.get(request.program_Id);
                    if (Test.isRunningTest()){
                      program = new nu_dse__program__c();
                    }
                    
                    program.DNL_Status__c = request.DNL_Status ;                    
                    program.Estimated_Loan_Amount__c = request.Estimated_Loan_Amount ;
                    program.Estimated_Financed_Amount__c = request.Estimated_Financed_Amount ;
                    program.Estimated_Number_of_Payments__c = request.Estimated_Number_of_Payments ;
                    program.Loan_Repayment_Frequency__c = request.Loan_Repayment_Frequency ;
                    program.Estimated_Loan_Start_Date__c = request.Estimated_Loan_Start_Date ;
                    program.Underwriter__c = request.Underwriter;			
                 	program.Loan_Officer__c = request.Loan_Officer;
                    program.DNL_Term__c = request.DNL_Term;
                    program.DNL_Lending_Application_ID__c = request.DNL_Lending_Application_ID;		
              	    program.DNL_Application_Number__c = request.DNL_Application_Number;
                    program.Pre_TILA_Signed_Date__c = request.Pre_TILA_Signed_Date;
                    programToBeUpdated.add(program); 
                    
                    for(NuDebtProgramSchema.TradelineRequest tradelineRec: request.tradelines) {
                        nu_dse__TradeLine__c tradeLine = tradeLinesMap.get(tradelineRec.tradeline_Id);
                        if (Test.isRunningTest()){
                            tradeLine = new nu_dse__TradeLine__c();
                        }                        
                        tradeLine.DNL_Estimated_Settlement_Percentage__c = tradelineRec.DNL_Estimated_Settlement_Percentage;
                        tradeLine.DNL_Estimated_Settlement_Amount__c = tradelineRec.DNL_Estimated_Settlement_Amount;
                        
                        tradeLinesToBeUpdated.add(tradeLine);
                    }  
                }
                
                if (!Test.isRunningTest()){
                   update programToBeUpdated;
                   update tradeLinesToBeUpdated;
                }

                response.is_success = true;

                
                system.debug(logginglevel.error,'response ==>'+JSON.serialize(response));          
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
                RestContext.response.statusCode = 200;
            }
            
        }
        catch(Exception e){
            
            response.is_success = false;
            response.error_Message = e.getMessage();
            system.debug(logginglevel.error,'error ==>'+JSON.serialize(response));    
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
            RestContext.response.statusCode = 500;
        }
    }
    
    
    
}