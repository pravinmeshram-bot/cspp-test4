@isTest
public class UserTriggerTest {
    @testSetup
    static void setupTestData(){
    	list<User> users = [Select Id, Name From User Where UserPermissionsKnowledgeUser=true limit 1];
        if(users != null && users.size()>0){
            //try{
                System.runAs(users[0]){
                    Id clientServices_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Client Services').getRecordTypeId();
                    Id controls_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Controls').getRecordTypeId();
                    
                    list<SOP__kav> sopList = new list<SOP__kav>();
                    sopList.add(new SOP__kav(RecordTypeId=clientServices_RTId,UrlName='testurl1', Title='Test Client Services'));
                    sopList.add(new SOP__kav(RecordTypeId=controls_RTId,UrlName='testurl2', Title='Test Controls'));
                    insert sopList;
                    
                    //String articleId = sopList[0].KnowledgeArticleId;
                    //KbManagement.PublishingService.publishArticle(articleId, true);
                    
                    //articleId = sopList[1].KnowledgeArticleId;
                    //KbManagement.PublishingService.publishArticle(articleId, true);
                }
            //}catch(Exception e){
            //    system.debug('### Exception: '+e.getMessage());
            //}
        }
    }
    
    public static testmethod void testUserInsertion(){
        list<Profile> pfList= [Select Id, Name from profile where Name='System Administrator' OR Name='Client Services Manager'];
        String sysAdminProfileId=null;
        String clientServiceProfileId=null;
        if(pfList != null && pfList.size()>0){
            for(Profile pf: pfList){
                if(pf.Name=='System Administrator'){
                    sysAdminProfileId=pf.Id;
                }else{
                    clientServiceProfileId=pf.Id;
                }
            }
        }
        list<User> sysAdminUser = [Select Id, Name From User Where ProfileId=:sysAdminProfileId AND isActive=true];
        System.runAs(sysAdminUser[0]){
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            User uu=new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = clientServiceProfileId
                            ); 
            
            Test.startTest();
            insert uu;
            Test.stopTest();
        }
    }
    
    public static testmethod void testUserUpdation(){
    	list<Profile> pfList= [Select Id, Name from profile where Name='System Administrator' OR Name='Client Services Manager' OR Name='Controls Assistant'];
        String sysAdminProfileId=null;
        String clientServiceProfileId=null;
        String controlsAssistantProfileId=null;
        if(pfList != null && pfList.size()>0){
            for(Profile pf: pfList){
                if(pf.Name=='System Administrator'){
                    sysAdminProfileId=pf.Id;
                }else if(pf.Name=='Client Services Manager'){
                    clientServiceProfileId=pf.Id;
                }else{
                    controlsAssistantProfileId=pf.Id;
                }
            }
        }
        list<User> sysAdminUser = [Select Id, Name From User Where ProfileId=:sysAdminProfileId AND isActive=true];
        System.runAs(sysAdminUser[0]){
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            User uu=new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = clientServiceProfileId
                            ); 
            insert uu;
            Test.startTest();
            	uu.email=uniqueName + '@test1' + orgId + '.org';
            	uu.ProfileId=controlsAssistantProfileId;
            	update uu;
            Test.stopTest();
        }
    }
    
    public static testmethod void testUserUpdation1(){
    	list<Profile> pfList= [Select Id, Name from profile where Name='System Administrator' OR Name='Client Services Manager' OR Name='Controls Assistant'];
        String sysAdminProfileId=null;
        String clientServiceProfileId=null;
        String controlsAssistantProfileId=null;
        if(pfList != null && pfList.size()>0){
            for(Profile pf: pfList){
                if(pf.Name=='System Administrator'){
                    sysAdminProfileId=pf.Id;
                }else if(pf.Name=='Client Services Manager'){
                    clientServiceProfileId=pf.Id;
                }else{
                    controlsAssistantProfileId=pf.Id;
                }
            }
        }
        list<User> sysAdminUser = [Select Id, Name From User Where ProfileId=:sysAdminProfileId AND isActive=true];
        System.runAs(sysAdminUser[0]){
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            User uu=new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = clientServiceProfileId
                            ); 
            insert uu;
            Test.startTest();
            	uu.isActive=false;
            	update uu;
            Test.stopTest();
        }
    }
}