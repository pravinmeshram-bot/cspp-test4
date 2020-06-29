({
    doInit : function(component, event, helper) {
        helper.buildData(component, helper);
    },
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
        var faqEvent = component.getEvent("faqEvent");
        console.log('fire place::',component.get("v.data"));
        faqEvent.setParams(
            {
                "selectedRecord" : component.get("v.data")
            }
        );
        faqEvent.fire();
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
        var faqEvent = component.getEvent("faqEvent");
        faqEvent.setParams(
            {
                "selectedRecord" : component.get("v.data")
            }
        );
        faqEvent.fire();
    }
})