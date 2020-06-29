global class OfferStatusComponentController {
    @RemoteAction
    global static List<Offer> getOffer(Id recordId) {
            List<nu_dse__Offer__c> records = [SELECT Id, Name, nu_dse__Status__c, NDS_Creditor_Info__c FROM nu_dse__Offer__c WHERE nu_dse__Program__c = :recordId AND nu_dse__Status__c = 'Pending Client Approval'];

            List<Offer> offerList = new List<Offer>();

            if(records.size() > 0){
               for(nu_dse__Offer__c offer : records) {
                    offerList.add(new Offer(offer));
               }
               return offerList;
            }
            else{
               return offerList;
            }
        }
       global class Offer {
       public String name;
       public Id recordId;
       public Boolean accepted;
       
       global Offer(nu_dse__Offer__c offer) {
           this.name = offer.Name;
           this.recordId = offer.Id;
           this.accepted = offer.nu_dse__Status__c == 'Pending Client Approval';
       }
    }
}