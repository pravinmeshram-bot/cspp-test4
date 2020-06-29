({
    doInit : function(component, event, helper) {
        console.log('**** helper called');
        let domain = window.location.search;
        console.log('domain--->',domain);
        let parm = domain.split('=')
        console.log('parm--->',parm);
        if (parm != null && parm[1] != null) {
            
            console.log('parm[1]--->',parm[1]);
            component.set("v.paymentId",parm[1]);
            
            helper.callServerMethod
            (
                component,
                helper,
                "getReschedulePayment",
                { 
                    paymentId : component.get("v.paymentId") 
                },
                function(response){
                    console.log('**** response-->', response);
                    if(response){
                        component.set("v.showError", false); 
                        component.set("v.errorMessage", '');
                        component.set("v.currentClickedPayment",response);
                        component.find("dateval_reschedule").set("v.value", response.minDate);
                    }
                },
                function(error){
                    component.set("v.showError", true); 
                    component.set("v.errorMessage", error);  
                }
            );
        }
    },
    cancelReschedule : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    toOpenModal  : function(component, event, helper) {
		var input = component.find("dateval_reschedule");
        var isFormValid = true;
		if(!input.get("v.value") || (input.get("v.validity") && !input.get("v.validity").valid)) {
            helper.notifierTost(component,{
                "variant" : "error",
                "message" : "Rescheduled Date is Required."
            });
            $A.util.addClass(input, 'slds-has-error');
            isFormValid = false;
        } else {
            component.set("v.isModalOpen", true); 
        }    
    },
    tocloseModal  : function(component, event, helper) {
        component.set("v.isModalOpen", false); 
    },
    createNewNSFPayment : function(component, event, helper) {
        var selectedDate = component.find("dateval_reschedule").get("v.value");
        component.set("v.isModalOpen", false); 
        console.log('***',selectedDate);
        helper.callServerMethod (
            component,
            helper,
            "createMakeupPaymentForFailurePayment",
            {
                selectedDate:selectedDate,
                paymentId : component.get("v.paymentId")
            },
            function(response) {
                console.log('**** response-->', response);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/"
                });
                urlEvent.fire();
            },
            function(error){
                console.log('**** error-->', error);
                    helper.notifierTost(component,{
                    "variant" : "error",
                    "message" : error
                });
            }
        );
    }
})