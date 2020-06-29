public class ResubmitApprovalController{
  public string ApprovalName{get;set;}
  public string FinalString{get;set;}
  Public string ApprovalProcessName{get;set;}
  public string selectedVal{get;set;}
  public boolean buttonFlag{get;set;}
  
  Public static  Boolean showPanelFlag{get;set;}
  /* Constructor getting called*/
    public ResubmitApprovalController(ApexPages.StandardController controller) {
     list<nu_dse__Offer__c> lstOfOfferRecord= new list<nu_dse__Offer__c>();
     string currentID=apexpages.currentpage().getparameters().get('id');
     if(currentID !=null && currentID !=''){
     // Getting the  Offer  records details using the AId param*/
      lstOfOfferRecord=[select id,Timberline_Settlement_Approval_Status__c,Attorney_Settlement_Approval_Status__c,
                          IsAttorney__c from nu_dse__Offer__c where id=:currentID and nu_dse__Status__c  !='Canceled' and nu_dse__Status__c  !='Accepted' ]; 
     
     }
     // checking if the soql returning any row.
     if(lstOfOfferRecord !=null && lstOfOfferRecord.size()>0 ){
     // byfurcating the current approval process on the offer record
       if(lstOfOfferRecord[0].IsAttorney__c ==true && lstOfOfferRecord[0].Attorney_Settlement_Approval_Status__c !=null && lstOfOfferRecord[0].Attorney_Settlement_Approval_Status__c!='None' ){  Attorney_Settlement_Workflow ('Approval1', lstOfOfferRecord[0].Attorney_Settlement_Approval_Status__c);                                                                   ApprovalProcessName ='Attorney Settlement Workflow (New) V3_Up';
        //system.debug('line 13'+lstOfOfferRecord[0].IsAttorney__c  );
        // if the current approval process is Attorney Settlement Workflow (New) V3_Up sending "Approval1" as its value to the below function 
        // Also sending the curent value of Attorney_Settlement_Approval_Status__c status 
       
        
        }
        else if(lstOfOfferRecord[0].IsAttorney__c ==False && lstOfOfferRecord[0].Timberline_Settlement_Approval_Status__c !=null && lstOfOfferRecord[0].Timberline_Settlement_Approval_Status__c!='None'){  ApprovalProcessName ='Timberline Settlement Workflow (New)';                              Attorney_Settlement_Workflow ('Approval2', lstOfOfferRecord[0].Timberline_Settlement_Approval_Status__c );
           // if the current approval process is Timberline Settlement Workflow (New) sending "Approval2" as its value to the below function 
        // Also sending the curent value of Attorney_Settlement_Approval_Status__c status 
            
             
        }
     }

    }
    /* Below method is used for getting the dynamic value from metadata based on the rejection reason which approval options need to be populated*/
    public void Attorney_Settlement_Workflow (String ApprovalName,String LastApprovalStep ){
      list<Approval_Steps_Mapping__mdt> ApprovalSteps = new  list<Approval_Steps_Mapping__mdt> ();
    system.debug('line 34'+ LastApprovalStep );
    // getting the custom metadata value for the mating  rejection status value we have used the approval status to be shown  from Mapped_approval_steps_to_be_shown__c values
    // we will be configuring the approval status which needs to be shown in Mapped_approval_steps_to_be_shown__c field in semicolon separated way.
     ApprovalSteps= [SELECT MasterLabel, Approval_Step_Name__c, Mapped_approval_steps_to_be_shown__c,Approval_Process_Name__c  
                                                 FROM Approval_Steps_Mapping__mdt  where Approval_Step_Name__c=: LastApprovalStep and Approval_Process_Name__c = :ApprovalName
                                                  ];
      if(ApprovalSteps !=null &&ApprovalSteps .size()>0 &&  ApprovalSteps[0].Mapped_approval_steps_to_be_shown__c !=null){
      
       system.debug('Line 24'+ApprovalSteps[0].Mapped_approval_steps_to_be_shown__c);
       FinalString=ApprovalSteps[0].Mapped_approval_steps_to_be_shown__c;
       system.debug('line 50'+ FinalString);
       getApprovalStepsNames();
      
      }
    
    }
    /* creating the final Picklist Values which will be displayed in the VF Pgae*/
    public List<SelectOption> getApprovalStepsNames( )
    {
       //string CommaseperatedValue=FinalString;
       list<String> finalList= new list<String>();
        system.debug('line 37'+ finalList);
       
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
       
        if(FinalString!=null && String.isNotBlank(FinalString) )
        {
        showPanelFlag=true;
        
        for(String strFinal: FinalString.split(';')){
           
                 //strFinal= strFinal.replaceAll( '\\s+', '');
                system.debug('Line 24'+strFinal);
               
               // finalList.add(strFinal);
               options.add(new SelectOption(strFinal,strFinal));
            }
            //for(String strFinal1 : finalList){
             //options.add(new SelectOption(strFinal1,strFinal1));
            
            //}
        }
       system.debug('Line 24'+options);
    
       return options;
    }
 
  
 /* below method is used to update the offer record when the approval step is selected by the user*/
 public  void UpdateApproval(){
  List<nu_dse__Offer__c > listOfOfferRecords= new list<nu_dse__Offer__c >();
  List<nu_dse__Offer__c > listOfOfferRecordsToBeUpdated= new list<nu_dse__Offer__c >();
  
  selectedVal =selectedVal.trim();
  system.debug('line 77'+selectedVal +'ApprovalName'+ApprovalProcessName);
  string currentPageID=apexpages.currentpage().getparameters().get('id');
  // Getting the record details through the id passed through Url
  if(currentPageID !=null){
  
      listOfOfferRecords=[select id,nu_dse__Status__c,Attorney_Settlement_Approval_Status__c,Portfolio_Name__c,Timberline_Settlement_Approval_Status__c from nu_dse__Offer__c 
                          where id=:currentPageID and nu_dse__Status__c !='Canceled' limit 100];
  
  }
  system.debug('line 92'+currentPageID); 
  nu_dse__Offer__c tempOffer= new nu_dse__Offer__c();
 if(listOfOfferRecords !=null && listOfOfferRecords.size()>0){
 // Checking for which work flow the approval conditions should be met
  if(ApprovalProcessName=='Attorney Settlement Workflow (New) V3_Up'){
      // checking the approval step selected by the end user in the VF Page
     if( selectedVal =='In-House Attorney'){
             tempOffer.id=currentPageID;
             // checking if the field value already satisfy the approval condition or not if not providing the fields with such values
             if(listOfOfferRecords[0].nu_dse__Status__c !='In-House Attorney Review'){
                 tempOffer.nu_dse__Status__c='In-House Attorney Review';
             }
             if(listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c!='None' || listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c  !='In-House Attorney Review Rejected'){
            
                 tempOffer.Attorney_Settlement_Approval_Status__c='None';
             }
            tempOffer.Resubmit_Approval__c = true;
             system.debug('line 100'+ tempOffer);
            listOfOfferRecordsToBeUpdated.add(tempOffer);
   
     }
    else if(selectedVal =='Obtain Authorization'){
     
         tempOffer.id=currentPageID;
          if(listOfOfferRecords[0].nu_dse__Status__c !='Pending Client Approval'|| listOfOfferRecords[0].nu_dse__Status__c !='Pending Creditor Approval'  || listOfOfferRecords[0].nu_dse__Status__c !='In-House Attorney Approved'  ){
                 tempOffer.nu_dse__Status__c='Pending Client Approval';
             }
              if(listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c!='In-House Attorney Review Approved' || listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c   !='Obtain Authorization Rejected'){
                 tempOffer.Attorney_Settlement_Approval_Status__c='None';
             }
         tempOffer.Resubmit_Approval__c = true;
              listOfOfferRecordsToBeUpdated.add(tempOffer);
             system.debug('line 100'+ tempOffer);
     }
      else if(selectedVal =='Negotiations Associate Review'){
     
            tempOffer.id=currentPageID;
            if(listOfOfferRecords[0].nu_dse__Status__c !='Authorization and Letter Received' ){
         
             tempOffer.nu_dse__Status__c='Authorization and Letter Received';
           }
           if(listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c!='Obtain Authorization Approved' || listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c !='Negotiations Associate Review Rejected'){
             tempOffer.Attorney_Settlement_Approval_Status__c='Negotiations Associate Review Rejected';
        
          }
          tempOffer.Resubmit_Approval__c = true;
            listOfOfferRecordsToBeUpdated.add(tempOffer);
           system.debug('line 100'+ tempOffer);
     }
     else if(selectedVal =='Payment Processing'){   
         tempOffer.id=currentPageID;
          if(listOfOfferRecords[0].nu_dse__Status__c !='To Payment Processing' ){
             tempOffer.nu_dse__Status__c='To Payment Processing';
           }
          if(listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c!='Negotiations Associate Review Approved' || listOfOfferRecords[0].Attorney_Settlement_Approval_Status__c 
          !='Payment Processing Rejected'){
             tempOffer.Attorney_Settlement_Approval_Status__c='Negotiations Associate Review Approved';
        
          }
         tempOffer.Resubmit_Approval__c = true;
          listOfOfferRecordsToBeUpdated.add(tempOffer);
     }
       
     system.debug('line 131'+ tempOffer);
  
    }
    else if(ApprovalProcessName=='Timberline Settlement Workflow (New)'){
    
      if( selectedVal =='Management Review'){
         
              tempOffer.id=currentPageID;
              if(listOfOfferRecords[0].nu_dse__Status__c !='Management Review' ){
                 tempOffer.nu_dse__Status__c='Management Review';
               }
              if(listOfOfferRecords[0]. Timberline_Settlement_Approval_Status__c !='None' || listOfOfferRecords[0].Timberline_Settlement_Approval_Status__c
              !='Management Review Rejected'){
                 tempOffer.Timberline_Settlement_Approval_Status__c='None';
            
              }
          //tempOffer.Resubmit_Approval__c = true;
               system.debug('line 100'+ tempOffer);
           listOfOfferRecordsToBeUpdated.add(tempOffer);
       }
      else if( selectedVal =='Obtain Authorization'){
         
              tempOffer.id=currentPageID;
              if(listOfOfferRecords[0].nu_dse__Status__c !='Pending Client Approval' || listOfOfferRecords[0].nu_dse__Status__c !='Pending Creditor Approval'  || listOfOfferRecords[0].nu_dse__Status__c !='Management Approved' ){
                 tempOffer.nu_dse__Status__c='Management Approved';
               }
              if(listOfOfferRecords[0]. Timberline_Settlement_Approval_Status__c !='Management Review Approved' || listOfOfferRecords[0].Timberline_Settlement_Approval_Status__c !='Obtain Authorization Rejected'){
                 tempOffer.Timberline_Settlement_Approval_Status__c='Obtain Authorization Rejected';
            
              }
          tempOffer.Resubmit_Approval__c = true;
               system.debug('line 100'+ tempOffer);
           listOfOfferRecordsToBeUpdated.add(tempOffer);
       }
        else if( selectedVal =='Negotiations Associate Review'){
         
              tempOffer.id=currentPageID;
              if(listOfOfferRecords[0].nu_dse__Status__c !='Authorization and Letter Received' ){
                 tempOffer.nu_dse__Status__c='Authorization and Letter Received';
               }
              if(listOfOfferRecords[0]. Timberline_Settlement_Approval_Status__c !='Obtain Authorization Approved' || listOfOfferRecords[0].Timberline_Settlement_Approval_Status__c !='Negotiations Associate Review Rejected'){
                 tempOffer.Timberline_Settlement_Approval_Status__c='Negotiations Associate Review Rejected';
            
              }
            tempOffer.Resubmit_Approval__c = true;
               system.debug('line 100'+ tempOffer);
           listOfOfferRecordsToBeUpdated.add(tempOffer);
       }
       else if( selectedVal =='Payment Processing'){
         
              tempOffer.id=currentPageID;
              if(listOfOfferRecords[0].nu_dse__Status__c !='To Payment Processing' ){
                 tempOffer.nu_dse__Status__c='To Payment Processing';
               }
              if(listOfOfferRecords[0]. Timberline_Settlement_Approval_Status__c !='Negotiations Associate Review Approved' || listOfOfferRecords[0].Timberline_Settlement_Approval_Status__c !='Payment Processing Rejected'){
                 tempOffer.Timberline_Settlement_Approval_Status__c='Payment Processing Rejected';
            
              }
           tempOffer.Resubmit_Approval__c = true;
                listOfOfferRecordsToBeUpdated.add(tempOffer);
          system.debug('line 100'+ tempOffer);
       }
   
    
    }
  }
  if(  listOfOfferRecordsToBeUpdated !=null &&   listOfOfferRecordsToBeUpdated.size()>0){
       try{
       system.debug('line 225'+ listOfOfferRecordsToBeUpdated);
           // performing DML updating the record with satisfied condition so that it Satisfy the entry criteria of approval step.
            update listOfOfferRecordsToBeUpdated;
           
            buttonFlag=true;
           system.debug('line 240 testing button'+ buttonFlag);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Resubmit_Confirmation));
           
       }catch(Exception e){
       
       
       }
   }
 }

}