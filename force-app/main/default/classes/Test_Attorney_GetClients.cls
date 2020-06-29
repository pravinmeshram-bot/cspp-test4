@isTest
public class Test_Attorney_GetClients {
    
    static void init () {
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Load_clients__c = true;
        batchJobTimings.Load_Draft_Payments__c = true;
        batchJobTimings.Load_TradeLines__c = true;
        batchJobTimings.Load_Tasks__c = true;
        batchJobTimings.Load_Group_Tasks__c = true;
        batchJobTimings.Account_Record_Type__c = 'Attorney Client';
        BatchJobTimings.Program_Record_Type__c = 'Attorney';
        batchJobTimings.SetupOwnerId = userInfo.getProfileId();
        insert batchJobTimings;
        
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true; 
     Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
    Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
     Attorney_StaticVariableUtility.isWorkflowTriggerExecuted = true;
    Attorney_StaticVariableUtility.isClientTriggerExecuted = true;
    Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        
        Account acc = new Account ();
        acc.NDS_File_Number__c = '1';
        acc.Name = 'Test';
        insert acc;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c  ();
        pgm.Import_ID__c = '1';
        pgm.nu_dse__Account__c = acc.ID;
        pgm.Draft_Plan_ID__c = '123456';
        insert pgm;
        
        Task t = new Task ();
        t.whatId = acc.ID;
        t.FileNumber__c = '1';
       // insert t;
    }
    static leadtracNetClient.TaskType TaskType (long typeId) {
        leadtracNetClient.TaskType taskType = new leadtracNetClient.TaskType ();
        taskType.TaskTypeId = typeId;
        taskType.Name = 'test';
        taskType.Priority = 'Medium';
        taskType.UserAssignmentRequired = 'false';
        taskType.Category = 'test';
        return taskType;
    }
    static leadtracNetClient.GetTaskResult taskResult () {
         leadtracNetClient.GetTaskResult result = new leadtracNetClient.GetTaskResult ();
         leadtracNetClient.ArrayOfTask tasks = new leadtracNetClient.ArrayOfTask ();
         List <leadtracNetClient.Task> taskArray = new List <leadtracNetClient.Task> ();
         
         leadtracNetClient.Task task = new leadtracNetClient.Task ();
         task.FileNumber = '1';
         task.TaskId = 1;
         task.ScheduledOnUTC = DateTime.Now ();
         task.Subject = 'test';
         task.Description = 'test';
         task.AssignedAs = 'User';
         task.AssignedTo = 'test';
         task.RemindMinutesBefore = 0;

         task.TaskType = TaskType (1);
         task.CompletedOn = DateTime.Now ();
         task.CreatedOn = DateTime.Now ();
         task.ModifiedOn = DateTime.Now ();
         taskArray.add (task);
         
         leadtracNetClient.Task task1 = new leadtracNetClient.Task ();
         task1.FileNumber = '2';
         task1.TaskId = 2;
         task1.ScheduledOnUTC = DateTime.Now ();
         task1.Subject = 'test';
         task1.Description = 'test';
         task1.AssignedAs = 'Group';
         task1.AssignedTo = 'test';
         task1.RemindMinutesBefore = 0;
         
         task1.TaskType = taskType (2) ;
         task1.CompletedOn = DateTime.Now ();
         task1.CreatedOn = DateTime.Now ();
         task1.ModifiedOn = DateTime.Now ();
         taskArray.add (task1);
         
         tasks.Task = taskArray;
         result.Tasks = tasks;
         return result;
    }
    
    static leadtracNetClient.ArrayOfClient clientResult () {
        leadtracNetClient.ArrayOfClient result = new leadtracNetClient.ArrayOfClient ();
        List <leadtracNetClient.Client> clientList = new List <leadtracNetClient.Client> ();
        leadtracNetClient.Client client = new leadtracNetClient.Client ();
        client.FileNumber = '1';
        client.CampaignId = '1';
        client.CreatedOn = DateTime.Now ();
        client.UpdatedOn = DateTime.Now ();
        client.UpdatedBy = 'test';
        
        leadtracNetClient.ArrayOfClientStatus clientStatus = new leadtracNetClient.ArrayOfClientStatus ();
        List <leadtracNetClient.ClientStatus> clientStatusList = new List <leadtracNetClient.ClientStatus> ();
        leadtracNetClient.ClientStatus status = new leadtracNetClient.ClientStatus ();
        status.WorkflowId = '1';
        status.WorkflowName = 'test';
        status.StatusId = 1;
        status.Name = 'test';
        status.UpdatedOn = DateTime.Now ();
        status.UpdatedBy = 'test';   
        clientStatusList.add (status);
        ClientStatus.ClientStatus = clientStatusList;
        client.CurrentStatus = clientStatus;
        
        leadtracNetClient.ArrayOfClientAssignee Assignees = new leadtracNetClient.ArrayOfClientAssignee ();
        List <leadtracNetClient.ClientAssignee> assigneeList = new List <leadtracNetClient.ClientAssignee> ();
        leadtracNetClient.ClientAssignee assignee = new leadtracNetClient.ClientAssignee ();
        assignee.UniqueId = '1';
        assignee.UserCode = '1';
        assignee.UserName = 'test';
        assignee.Name = 'test';
        assignee.Role = 'tesst';
        assignee.UpdatedOn = DateTime.Now ();
        assignee.UpdatedBy = 'test';
        assigneeList.add (assignee);
        Assignees.ClientAssignee = assigneeList;
        client.Assignees = Assignees;
        
        leadtracNetClient.ArrayOfClientProperty properties = new leadtracNetClient.ArrayOfClientProperty ();
        List <leadtracNetClient.ClientProperty> propertyList = new List <leadtracNetClient.ClientProperty> ();
        leadtracNetClient.ClientProperty property = new leadtracNetClient.ClientProperty ();
        property.Name = 'LastName';
        property.Value = 'test';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'FirstName';
        property.Value = 'test';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankStreetAddress';
        property.Value = 'test';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1AKA';
        property.Value = 'test';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AlternateNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2DOB';
        property.Value = '01/01/1980';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AccountReviewEvent';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'LeadID';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'OtherIncomeReason2';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TotalIncome';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankruptcyYear';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankruptcyChapter';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CreditScore1';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EstimatedHomeValue';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'FiledBankruptcy';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'MortgageBalance';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Address1';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Address2';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'City';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EmailAddress';
        property.Value = 'test@test.com';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'State';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'WorkNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ZipCode';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AddressLine1';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Appartment';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BestDay';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BestTime';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CorrespondencePreference';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'DebtConsultant';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'DoNotCall';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'DoNotEmail';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'DoNotSMS';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'FaxNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1DLNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1DLState';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1DOB';
        property.Value = '01/01/1990';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1Email';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1Employer';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1Occupation';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1SSN';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2AddressLine1';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2BestTime';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2CellNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2DLNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2DLState';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2Email';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2Employer';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2FaxNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2First';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2Last';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2HomeNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2Occupation';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2SSN';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2WorkNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2ZipCode';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Prefix';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'SalesEmail';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2SSN';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TimeZone';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ESTSettlementAmt';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ProgramFeeAmt';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ProgramSavings';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'RetainerFee';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'RetainerFeeTotal';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TotalProgramCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TrustFeeMonthly';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TrustFeeMonthlyTotal';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CancellationDate';
        property.Value = '01/01/1990';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CancellationReason';
        property.Value = 'BBB rating concerns';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CurrentDebtPayment';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EstimatedTotalDebt';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'FirstDraftDate';
        property.Value = '1/2/2018';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'MaxProgramLength';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'NSFDraftAmount';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'NSFDraftDate';
        property.Value = '01/01/1990';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'NSFReason';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ProgramLength';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ProgramType';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'RecurringDate';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'RecurringDate2';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TelephoneCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AccountOwnerName';
        property.Value = '1';        
        propertyList.add (property);
        
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AccountType';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankAccountNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankCity';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankName';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankPhone';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankRoutingNumber';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankState';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BankZipCode';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Hardship';
        property.Value = 'Divorce';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'HardshipReason';
        property.Value = 'Divorce';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AutoInsuranceCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AutoLoanCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'AutoOther';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'BackTaxes';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CableSatelliteCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'CharityCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ChildCareCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ClothingCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EducationCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EntertainmentCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'FoodCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'GymFees';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'HomeRentInsuranceCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'HomeOwner';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'HouseholdItemsCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'LaundryCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'LifeInsuranceCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'MedicalCareCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1AnnualIncome';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name1MonthlyIncome';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Name2AnnualIncome';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Other1Cost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'Other1Name';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'PersonalCare';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'StudentLoans';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'UtilitiesCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'TelephoneCost';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'EstSettlementPercent';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'LegalFeeMonthlyTotal';
        property.Value = '1';        
        propertyList.add (property);
        
        property = new leadtracNetClient.ClientProperty ();
        property.Name = 'ProgramFeePercent';
        property.Value = '1';        
        propertyList.add (property);
        
        properties.ClientProperty = propertyList;
        client.Properties = Properties;

        leadtracNetClient.ArrayOfAsset assets = new leadtracNetClient.ArrayOfAsset ();
        List <leadtracNetClient.Asset> assetList = new List <leadtracNetClient.Asset> ();
        leadtracNetClient.Asset asset = new leadtracNetClient.Asset ();
        asset.AssetId = '1';
        asset.Name = 'test';
        asset.Description = 'test';
        asset.Type_x = 'test';
        asset.isDeleted = false;
        asset.UpdatedOn = DateTime.Now ();
        asset.UpdatedBy = 'test';
        assetList.add (asset);
        assets.Asset = assetList;
        client.assets = assets;
        
        clientList.add (client);
        result.client = clientList;
        return result;
    }
    
    static leadtracNetServicing.ArrayOfGetActiveDraftPlanResult planResult () {
        leadtracNetServicing.ArrayOfGetActiveDraftPlanResult result = new leadtracNetServicing.ArrayOfGetActiveDraftPlanResult ();
        List <leadtracNetServicing.GetActiveDraftPlanResult> planList = new List <leadtracNetServicing.GetActiveDraftPlanResult> ();
        
        leadtracNetServicing.GetActiveDraftPlanResult plan = new leadtracNetServicing.GetActiveDraftPlanResult ();
        plan.IsSuccessful = TRUE;
        
        leadtracNetServicing.ArrayOfResultMessage messages = new leadtracNetServicing.ArrayOfResultMessage ();
        List <leadtracNetServicing.ResultMessage> messageList = new List <leadtracNetServicing.ResultMessage> ();
        leadtracNetServicing.ResultMessage message = new leadtracNetServicing.ResultMessage ();
        message.MessageType = 'error';
        message.Message = 'test';
        
        messageList.add (message);
        
        leadtracNetServicing.DraftPlan draft = new leadtracNetServicing.DraftPlan ();
        draft.FileNumber = '1';
        draft.PlanId = 1;
        draft.Status = 'new';
        draft.SuspendedOn = DateTime.now ();
        draft.CompletedOn = DateTime.Now ();
        draft.ActivatedOn = DateTime.Now ();
        draft.CreatedOn = DateTime.Now ();
        draft.ModifiedOn = DateTime.Now ();
        
        leadtracNetServicing.ArrayOfPayment Payments = new leadtracNetServicing.ArrayOfPayment ();
        List <leadtracNetServicing.Payment> paymentList = new List <leadtracNetServicing.Payment> ();
        leadtracNetServicing.Payment payment = new leadtracNetServicing.Payment ();
        payment.PaymentId = 1;
        payment.planId = 1;
        payment.CreatedOn = DateTime.Now ();
        payment.ModifiedOn = DateTime.now ();
        payment.vendorId = '1';
        payment.DueOn = DateTime.now ();
        payment.Number_x = 1;
        payment.Amount = 100;
        payment.Status = 'test';
        payment.StatusedOn = DateTime.Now ();
        payment.StatusReason = 'test';
        payment.PaymentType = 'test';
        payment.PaymentTypeData = 'test';
        
        leadtracNetServicing.ArrayOfSplit splits = new leadtracNetServicing.ArrayOfSplit ();
        List <leadtracNetServicing.Split> splitList = new List <leadtracNetServicing.Split> ();
        leadtracNetServicing.Split split = new leadtracNetServicing.Split ();
        split.SplitId = 1;
        split.VendorId = '1';
        split.Name = 'test';
        split.Amount = 100;
        split.CreatedOn = DateTime.Now ();
        split.ModifiedOn = DateTime.Now ();        
        splitList.add (split);
        splits.split = splitList;
        payment.splits = splits;
        paymentList.add (payment);
        payments.Payment = paymentList;        
        draft.Payments = payments;
        
        plan.DraftPlan = draft;
        plan.Messages = messages;
        
        planList.add (plan);
        result.GetActiveDraftPlanResult = planList;
        return result;
    }
    
    @isTest static void schedulerTest () {
        init ();
        Test.startTest ();
            Attorney_GetClients.getUserIdByName (UserInfo.getUserName ());
            Attorney_GetClients.getQueueByName ('test');
            Attorney_GetClients.ConvertSalesforceValidDateFormat ('01/01/1990');
            Attorney_GetClients.ConvertSalesforceValidDateFormat ('01-01-1990');
            Attorney_GetClients.propertyClass obj = new Attorney_GetClients.propertyClass ();
            Attorney_GetClients.getLeadtrackProgramLst ();
            Attorney_GetClients.taskRes = taskResult ();
            Attorney_GetClients.resp = new leadtracNetClient.ArrayOfString();
            Attorney_GetClients.cilent = clientResult ();
        try{
            Attorney_GetClients.draftPlanRes = new leadtracNetServicing.ModifiedDraftPlanResult();
        } catch (Exception e) {}
        Attorney_GetClients.planResltArray = planResult ();
            List <String> draftFileNumbersLst = new List <String> ();
            draftFileNumbersLst.add ('1');
            
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true; 
     Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
    Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
     Attorney_StaticVariableUtility.isWorkflowTriggerExecuted = true;
    Attorney_StaticVariableUtility.isClientTriggerExecuted = true;
    Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            
            try {
                Attorney_GetClients.fetchClinets (DateTime.Now (), DateTime.Now (), 'test', draftFileNumbersLst , null);
            } catch (Exception e) {
                System.debug('*****' + e.getStackTraceString());
                System.debug('*****' + e.getMessage());
            }
        	try {
                //Attorney_GetClients.fetchDraftPayments (DateTime.Now (), DateTime.Now (), 'test', draftFileNumbersLst );
            } catch (Exception e) {
                System.debug('*****' + e.getStackTraceString());
                System.debug('*****' + e.getMessage());
            }
            
        Test.stoptest ();
    }
    
    @isTest static void schedulerTest1 () {
        init ();
        Test.startTest ();
            Attorney_GetClients.getUserIdByName (UserInfo.getUserName ());
            Attorney_GetClients.getQueueByName ('test');
            Attorney_GetClients.ConvertSalesforceValidDateFormat ('01/01/1990');
            Attorney_GetClients.ConvertSalesforceValidDateFormat ('01-01-1990');
            Attorney_GetClients.propertyClass obj = new Attorney_GetClients.propertyClass ();
            Attorney_GetClients.getLeadtrackProgramLst ();
            Attorney_GetClients.taskRes = taskResult ();
            Attorney_GetClients.resp = new leadtracNetClient.ArrayOfString();
            Attorney_GetClients.cilent = clientResult ();
        try{
            Attorney_GetClients.draftPlanRes = new leadtracNetServicing.ModifiedDraftPlanResult();
        } catch (Exception e) {}
        Attorney_GetClients.planResltArray = planResult ();
            List <String> draftFileNumbersLst = new List <String> ();
            draftFileNumbersLst.add ('1');
            
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true; 
     Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
    Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
     Attorney_StaticVariableUtility.isWorkflowTriggerExecuted = true;
    Attorney_StaticVariableUtility.isClientTriggerExecuted = true;
    Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            
            try {
                //Attorney_GetClients.fetchClinets (DateTime.Now (), DateTime.Now (), 'test', draftFileNumbersLst , null);
            } catch (Exception e) {
                System.debug('*****' + e.getStackTraceString());
                System.debug('*****' + e.getMessage());
            }
        	try {
                Attorney_GetClients.fetchDraftPayments (DateTime.Now (), DateTime.Now (), 'test', draftFileNumbersLst );
            } catch (Exception e) {
                System.debug('*****' + e.getStackTraceString());
                System.debug('*****' + e.getMessage());
            }
            
        Test.stoptest ();
    }
    
    @isTest static void testMethodForWSDL () {
        microsoftComWsdlTypes obj = new microsoftComWsdlTypes ();
        microsoftComWsdlTypes1 obj1 = new microsoftComWsdlTypes1 ();
        microsoftComWsdlTypes2 obj2 = new microsoftComWsdlTypes2 ();
        leadtracNetDebtWsdlTypes obj3 = new leadtracNetDebtWsdlTypes ();
    }
    
   
}