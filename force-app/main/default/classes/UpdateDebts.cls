@RestResource(urlMapping='/DebtService/UpdateDebts/*')
global class UpdateDebts {

    @HTTPPOST
    global static void doPost(list<nu_dse__TradeLine__c> debts){
        
        List<nu_dse__TradeLine__c> updateDebts = new List<nu_dse__TradeLine__c>();
        
        try{
            
            upsert debts ; 
            
        }catch(Exception e){
            
        }
    }
}