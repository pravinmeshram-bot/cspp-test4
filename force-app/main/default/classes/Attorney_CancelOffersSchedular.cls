public class Attorney_CancelOffersSchedular implements System.schedulable{

    public void execute(System.SchedulableContext sc){
    
        Database.executebatch(new Attorney_CancelOffersBatch(),1);
    }

}