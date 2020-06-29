({
    doInit : function(component, event, helper) {
        
        let domain = window.location.search;
        console.log('domain--->',domain);
        let parm = domain.split('=')
        console.log('parm--->',parm);
        
        if (parm) {
            component.set("v.offerId", parm[1]);
            helper.callServerMethod(
                component,
                helper,
                "getOfferInfo",
                {
                    offerId : parm[1]
                },
                function(result){
                    if (result) {
                        console.log("result::::", result);
                        component.set("v.offerInfo", JSON.parse(JSON.stringify(result)));
                        console.log("offerInfo---->", component.get("v.offerInfo"));
                    }
                },
                null 
            );
        }
    },
    updateStatus : function(component,event,helper) {
        
        let offerStatus = component.get("v.status");
        let offer = component.get("v.offerInfo.offerList[0]");
        let offerInstance = { 'sobjectType':'nu_dse__Offer__c'};
        offerInstance.Id = offer.Id;
        offerInstance.Is_Terms_Conditions_Checked__c = offer.Is_Terms_Conditions_Checked__c;
        if (offerStatus == 'Accept') {
            offerInstance.nu_dse__Status__c = 'Client Approved';
        } else if (offerStatus == 'Decline') {
            offerInstance.nu_dse__Status__c = 'Client Declined';
        }
        helper.callServerMethod(
            component,
            helper,
            "updateOfferStatus",
            {
                "offerInstance" : offerInstance
            },
            function(response) {
                component.set("v.toRenderModal","");
                component.set("v.isModalOpen1",true);
                if (offerStatus == 'Accept') {
                    component.set("v.successMessageString","You\'ve approved your settlement offer! Congratulations! The offer will go through a final review and then sent to our Payments Department to execute payments to your creditor. We\'ll reach out to you should additional information be needed to process your settlement offer.");
                } else if (offerStatus == 'Decline') {
                    component.set("v.successMessageString","You've decline your settlement offer. Please contact us to discuss next steps.");
                }
            },
            null 
        );
    },
    showToast :  function(component,event,helper) {
        let status = event.getSource().get("v.title");
        component.set("v.toRenderModal","Alert");
        component.set("v.status",status);
    },
    closeModel :  function(component,event,helper) {
        component.set("v.toRenderModal","");
    },
    closeModel1 :  function(component,event,helper) {
        component.set("v.isModalOpen1",false);
    },
    cancelModel : function(component,event,helper) {
        component.set("v.isModalOpen1",false);
        component.set("v.toRenderModal","");
        var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            "tabName" : ""});
        appEvent.fire();        
    }
})