public class StatusMappingStaticSetClass_nds {
    
    public static Set<Id> processedPaymentIdSet = new Set<Id>();
    public static Set<Id> processedOfferIdSet = new Set<Id>();
    public static Set<Id> processedtradelineIdSet = new Set<Id>();
    
    public static Boolean isUserQueried = False;
    public static User userInstance = new User();
    
    public static Map<String, Map<String, String>> staticDataMap = new Map<String, Map<String, String>>();
    public static Boolean staticDataMapInitialized = False;
    public static Boolean tradelinestaticDataMapInitialized = False;
    
    public static Boolean isPaymentTriggerFired = False;
    
    public static User getUser() {
    
        if (isUserQueried == False) {
        
            List<User> userList = [SELECT Id, Attorney_Admin__c FROM User WHERE Id = :UserInfo.getUserId()];
            isUserQueried = True;
            
            if (userList.isEmpty() == False) {
                
                userInstance = userList[0];
                return userInstance;
            }
            return userInstance;
        }
        return userInstance;
    }
}