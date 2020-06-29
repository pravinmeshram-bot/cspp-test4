@RestResource(urlMapping='/pullProgramFees/*')
global class Prizm_PullProgramFeesService {

    @HttpPost
    global static String pullProgramFees() {
      String JsonResponse = '';
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String inputString = RestContext.request.requestBody.toString();
        if(inputString != NULL){
          List<Id> ProgramIds = (List<Id>)JSON.deserialize(inputString, List<Id>.class);
            JsonResponse = ProgramFees(ProgramIds);
        }
        System.debug(JsonResponse);
        return JsonResponse;
    }
    
    public static String ProgramFees(List<Id> ProgramIds){
        
        List<nu_dse__Program__c> ProgramList = [Select Id,Current_Accumulation__c,Current_Admin_Fee__c,Paid_Creditor_Payments__c,Expected_Accumulation__c,Expected_Admin_Fee__c,Total_Creditor_Payments__c,Remaining_Accumulation__c,Remaining_Admin_Fee__c,Remaining_Creditor_Payments__c,Current_Maintenance_Fee__c,nu_dse__Expected_Maintenance_Fees__c,Remaining_Maintenance_Fee__c,Current_Processor_Fee__c,Remaining_Processor_Fee__c,Expected_Processor_Fee__c,Current_Program_Fee__c,Expected_Program_Fee__c,Remaining_Program_Fee__c,Current_Retainer_Fee__c,Remaining_Retainer_Fee__c,Expected_Retainer_Fee__c,Current_Service_Fee__c,Remaining_Service_Fee__c,Expected_Service_Fee__c,Current_Third_Party_Fee__c,Remaining_Third_Party_Fee__c,Expected_Third_Party_Fee__c from nu_dse__Program__c where Id=:ProgramIds];
        
        List<DraftFees> DraftFeesList= new List<DraftFees>();
        
        for(nu_dse__Program__c Program : ProgramList){
            DraftFees df = new DraftFees();
            
            df.PaidAccumulation = String.valueOf(Program.Current_Accumulation__c);
            df.PaidAdminFee = String.valueOf(Program.Current_Admin_Fee__c );
            df.PaidCreditorPayments = String.valueOf(Program.Paid_Creditor_Payments__c);
            df.PaidMaintenanceFee = String.valueOf(Program.Current_Maintenance_Fee__c);
            df.PaidProcessorFee = String.valueOf(Program.Current_Processor_Fee__c);
            df.PaidProgramFee = String.valueOf(Program.Current_Program_Fee__c);
            df.PaidRetainerFee = String.valueOf(Program.Current_Retainer_Fee__c);
            df.PaidServiceFee= String.valueOf(Program.Current_Service_Fee__c);
            df.PaidThirdPartyFee = String.valueOf(Program.Current_Third_Party_Fee__c);
            df.TotalAccumulation = String.valueOf(Program.Expected_Accumulation__c);
            df.TotalAdminFee = String.valueOf(Program.Expected_Admin_Fee__c);
            df.TotalCreditorPayments = String.valueOf(Program.Total_Creditor_Payments__c);
            df.TotalMaintenanceFee = String.valueOf(Program.nu_dse__Expected_Maintenance_Fees__c);
            df.TotalProcessorFee= String.valueOf(Program.Expected_Processor_Fee__c);
            df.TotalProgramFee = String.valueOf(Program.Expected_Program_Fee__c);
            df.TotalRetainerFee = String.valueOf(Program.Expected_Retainer_Fee__c);
            df.TotalServiceFee = String.valueOf(Program.Expected_Service_Fee__c);
            df.TotalThirdPartyFee = String.valueOf(Program.Expected_Third_Party_Fee__c);
            df.RemainingAccumulation = String.valueOf(Program.Remaining_Accumulation__c);
            df.RemainingAdminFee = String.valueOf(Program.Remaining_Admin_Fee__c);
            df.RemainingCreditorPayments = String.valueOf(Program.Remaining_Creditor_Payments__c);
            df.RemainingMaintenanceFee = String.valueOf(Program.Remaining_Maintenance_Fee__c);
            df.RemainingProcessorFee = String.valueOf(Program.Remaining_Processor_Fee__c);
            df.RemainingProgramFee = String.valueOf(Program.Remaining_Program_Fee__c);
            df.RemainingRetainerFee = String.valueOf(Program.Remaining_Retainer_Fee__c);
            df.RemainingServiceFee = String.valueOf(Program.Remaining_Service_Fee__c);
            df.RemainingThirdPartyFee = String.valueOf(Program.Remaining_Third_Party_Fee__c);
            df.ProgramId = Program.Id;
            DraftFeesList.add(df);
        }
        
        return JSON.serialize(DraftFeesList);
        
    }
    
    public class DraftFees{
        
        public String ProgramId;
        public String PaidAccumulation;
        public String PaidAdminFee;
        public String PaidCreditorPayments;
        public String PaidMaintenanceFee;
        public String PaidProcessorFee;
        public String PaidProgramFee;
        public String PaidRetainerFee;
        public String PaidServiceFee;
        public String PaidThirdPartyFee;
        public String TotalAccumulation;
        public String TotalAdminFee;
        public String TotalCreditorPayments;
        public String TotalMaintenanceFee;
        public String TotalProcessorFee;
        public String TotalProgramFee;
        public String TotalRetainerFee;
        public String TotalServiceFee;
        public String TotalThirdPartyFee;
        public String RemainingAccumulation;
        public String RemainingAdminFee;
        public String RemainingCreditorPayments;
        public String RemainingMaintenanceFee;
        public String RemainingProcessorFee;
        public String RemainingProgramFee;
        public String RemainingRetainerFee;
        public String RemainingServiceFee;
        public String RemainingThirdPartyFee;
        
        
        public DraftFees(){
            
            ProgramId = '';
            PaidAccumulation = '';
            PaidAdminFee = '';
            PaidCreditorPayments = '';
            PaidMaintenanceFee = '';
            PaidProcessorFee = '';
            PaidProgramFee = '';
            PaidRetainerFee = '';
            PaidServiceFee= '';
            PaidThirdPartyFee = '';
            TotalAccumulation = '';
            TotalAdminFee = '';
            TotalCreditorPayments = '';
            TotalMaintenanceFee = '';
            TotalProcessorFee='';
            TotalProgramFee = '';
            TotalRetainerFee = '';
            TotalServiceFee = '';
            TotalThirdPartyFee = '';
            RemainingAccumulation = '';
            RemainingAdminFee = '';
            RemainingCreditorPayments = '';
            RemainingMaintenanceFee = '';
            RemainingProcessorFee = '';
            RemainingProgramFee ='';
            RemainingRetainerFee = '';
            RemainingServiceFee = '';
            RemainingThirdPartyFee = '';
            
            
        }
        
    }
}