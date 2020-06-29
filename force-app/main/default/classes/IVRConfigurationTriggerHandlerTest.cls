@isTest
public class IVRConfigurationTriggerHandlerTest {
    
    static testMethod void inserIVRConfig_OneColumn_Error()
    {
        try
        {
            IVR_Configuration__c ivrConfig = new IVR_Configuration__c();
            ivrConfig.Description__c ='Test';
            ivrConfig.Is_Active__c =true;
            ivrConfig.IVR_Scoring_Table_Field__c ='Settlement_Auth_Score__c';
            ivrConfig.Logic_Definition__c ='Test';
            ivrConfig.Point_Value__c =50;
            ivrConfig.Technical_Definition__c ='Select Id,Test from nu_dse__Program__c';
            insert ivrConfig;
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains('Only one column permitted'));
        }
    }
    
    static testMethod void inserIVRConfig_InvalidColumn_Error()
    {
        try
        {
            IVR_Configuration__c ivrConfig = new IVR_Configuration__c();
            ivrConfig.Description__c ='Test';
            ivrConfig.Is_Active__c =true;
            ivrConfig.IVR_Scoring_Table_Field__c ='Settlement_Auth_Score';
            ivrConfig.Logic_Definition__c ='Test';
            ivrConfig.Point_Value__c =50;
            ivrConfig.Technical_Definition__c ='Select Id from nu_dse__Program__c';
            insert ivrConfig;
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains('not found in the IVR_Scoring__c object'));
        }
    }
    
    static testMethod void inserIVRConfig_Query_Error()
    {
        try
        {
            IVR_Configuration__c ivrConfig = new IVR_Configuration__c();
            ivrConfig.Description__c ='Test';
            ivrConfig.Is_Active__c =true;
            ivrConfig.IVR_Scoring_Table_Field__c ='Settlement_auth_score__c';
            ivrConfig.Logic_Definition__c ='Test';
            ivrConfig.Point_Value__c =50;
            ivrConfig.Technical_Definition__c ='Select Id from nu_dse__Program__';
            insert ivrConfig;
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains('nu_dse__Program__'));
        }
    }
}