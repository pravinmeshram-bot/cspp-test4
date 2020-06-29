/* Date : 12-10-2018
 * Author : Team IDev
 * Description : Handler for Admin Settings Controller
 */
public class AdminSettingsController {

    public  List<nu_dse__Program__c> programList { get; set; }
    public Id programId{get;set;}
    public nu_dse__Program__c programInstance {get; set;}
    public AdminSettingsController() {       
   programId = ApexPages.currentPage().getParameters().get('pid');
        if(programId != null) {
            programList = [SELECT Id, Name, Invite_Client__c, Invite_Co_Client__c, Client_Portal_User_Id__c, Co_Client_Portal_User_Id__c
                                                     FROM nu_dse__Program__c WHERE Id =: programId];
        }
    }

    
    /* Date : 05-10-2018
     * Description : Method to update the Client invitation and co-client invitation
     * Invoked From : Admin_Settings Controller
     */
    public void inviteClientAndCoClient() {
    
        update programList[0];
    
    }
    
}