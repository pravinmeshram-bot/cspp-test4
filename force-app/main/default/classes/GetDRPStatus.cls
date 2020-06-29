/* Financial Spectra */

@RestResource(urlMapping='/v1/GetDRPStatus/*')
global class GetDRPStatus {

    public class NuDebtProgramRecordRequest {
        public String ProgramId;
    }
    
    public class NuDebtProgramRecordResponse {
        public String ProgramId;
        public String ProgramStatus;        
    }

    @HttpPost
    global static void getProgramStatus(){
        Map<String, String> NuDebtProgramStatusMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        system.debug(logginglevel.error,'req.requestBody ==>'+req.requestBody);
        system.debug(logginglevel.error,'req.requestBody To String ==>'+req.requestBody.toString());
        List<NuDebtProgramRecordResponse> responseList = new List<NuDebtProgramRecordResponse>();
        if (req.requestBody != null){
            List<NuDebtProgramRecordRequest> NuDebtProgramRecordList = (List<NuDebtProgramRecordRequest>)JSON.deserialize(req.requestBody.toString(), List<NuDebtProgramRecordRequest>.class);
            
            Id[] programIds = new Id[0];
            system.debug(logginglevel.error,'NuDebtProgramRecordList ==>'+NuDebtProgramRecordList);
            for(NuDebtProgramRecordRequest program: NuDebtProgramRecordList) {
                programIds.add(program.ProgramId);
            }
            system.debug(logginglevel.error,'programIds ==>'+programIds);            

            for(nu_dse__program__c cl: [select id, nu_dse__Program_Status__c from nu_dse__program__c where Id in :programIds ]){
                NuDebtProgramRecordResponse resp = new NuDebtProgramRecordResponse();
                resp.ProgramId = cl.id;
                resp.ProgramStatus = cl.nu_dse__Program_Status__c;                
                responseList.add(resp);
            }
        
            system.debug(logginglevel.error,'responseList ==>'+JSON.serialize(responseList));          
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseList));
            RestContext.response.statusCode = 200;   
        }
        
        
    }
    
  
}