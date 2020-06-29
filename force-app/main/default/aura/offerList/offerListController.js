({
    doInit : function(component, event, helper) {        
        helper.callServerMethod(
            component,
            helper,
            "getOfferList",
            {
                isDefault : true
            },
            function(response) {
                
                console.log("response::::", response);
                console.log('details::::',JSON.parse(JSON.stringify(response.detailFields)));
                console.log('isOfferListVisible::::',response.isOfferListVisible);
                component.set("v.isOfferDecision", response.isOfferDecision);
                if (response.isOfferListVisible) {
                    
                    let offerList = JSON.parse(JSON.stringify(response.offerList || []));
                
                    for(let i = 0; i < offerList.length; i++) {
                        
                        if(offerList[i].Available_for_Client_Review__c && offerList[i].Source_of_Payment__c == 'PSA'
                                    && offerList[i].Tradeline_Litigation_Status__c == 'Non Lit') {
                            
                            offerList[i].offerCriteriaMet = true;
                            /*let todayDate = new Date();
                            todayDate.setTime(todayDate.getTime() + todayDate.getTimezoneOffset() * 60 * 1000);
                            
                            let firstPaymentDate = new Date(offerList[i].nu_dse__First_Payment_Date__c);
                            firstPaymentDate.setTime(firstPaymentDate.getTime() + firstPaymentDate.getTimezoneOffset() * 60 * 1000);
                            
                            if(firstPaymentDate > todayDate) {
                                
                                let diff = helper.getDiff(todayDate, firstPaymentDate);
                                console.log('**** diff-->', diff);
                                if(diff > 5) {
                                    offerList[i].offerCriteriaMet = true;
                                }  else {
                                    
                                    offerList[i].offerMoreInfo = true;
                                }
                            }*/
                        } else if (offerList[i].Source_of_Payment__c != 'PSA' 
                                   && offerList[i].Tradeline_Litigation_Status__c != 'Non Lit') {
                            
                            offerList[i].offerMoreInfo = true;
                        } else if (offerList[i].Available_for_Client_Review__c == false && 
                                   (offerList[i].Source_of_Payment__c == 'PSA' 
                                   || offerList[i].Tradeline_Litigation_Status__c == 'Non Lit') ) {
                            
                            offerList[i].offerMoreInfo = true;
                        }
                    }
                    console.log('**** offerListofferList-->', offerList);
                    component.set("v.offerList", offerList);
                    component.set("v.offerFieldsetFields", JSON.parse(JSON.stringify(response.detailFields)));
                    component.set("v.offerListViewFieldset", JSON.parse(JSON.stringify(response.listFields )));
                    component.set("v.program", JSON.parse(JSON.stringify(response.program )));
                    component.set("v.isInit", true);
                    console.log('******response.program-->', response.program);
                    console.log('******response.offerList-->', response.offerList);
                    console.log('******response.detailFields-->', response.detailFields);
                    console.log('******response.listFields-->', response.listFields);
                }
            },
            null 
        );
    },
    updateStatus : function(component,event,helper) {
        let status = event.getSource().get("v.title");
        console.log('status---->',status);
        if (status) {
            component.set("v.toRenderModal","Alert");
            component.set("v.status",status);
        } else {
            let offerStatus = component.get("v.status");
            component.set("v.isInit", false);
            helper.callServerMethod(
                component,
                helper,
                "updateOfferStatus",
                {
                    "offerId" : component.get("v.offerInstance").Id,
                    "status" : offerStatus
                },
                function(response) {
                    if (response) {
                        console.log("response::::",response);
                        component.set("v.offerList", response.offerList);
                        component.set("v.offerFieldsetFields", response.detailFields);
                        component.set("v.offerListViewFieldset", response.listFields);
                        component.set("v.offerInstance","");
                        component.set("v.status","");
                        component.set("v.toRenderModal","");
                        component.set("v.isInit", true);
                        helper.notifierTost(component,{
                            "variant" : "Success",
                            "message" : "Your Response Sent Successfully "
                        });
                    }
                },
                null 
            );
        }
    },
    cancelModel  : function(component,event,helper) {
        component.set("v.offerInstance",{'sobjectType': 'nu_dse__Offer__c'});
        //component.set("v.status","");
        component.set("v.toRenderModal","");
    },
    handleAction : function(component,event,helper) {
        var selectedRecord = event.getParam("selectedRecord");   
        console.log('select Record::::',JSON.stringify(selectedRecord));
        component.set("v.offerInstance",selectedRecord);
        var action = event.getParam("action");
        console.log('res info --->',action);
        
        if(action === 'Review') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/approvals?id="+selectedRecord.Id
            });
            urlEvent.fire();            
            //component.set("v.toRenderModal",event.getParam("selectedRecord").Name);
            
        } else if (action === 'View Info') {
            console.log('selectedRecordId-->',selectedRecord.Id);
            component.set("v.toRenderModal","View Info");
        }
    },
    reviewForApproval : function(component, event, helper) {
        console.log('***** get source', event.getSource());
        let indexPos = event.getSource().get("v.name");
        console.log('**** indexPos-->', indexPos);
        let offerListToDisplay = component.get("v.offerListToDisplay") || [];
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/approvals?id="+offerListToDisplay[indexPos].Id
        });
        urlEvent.fire(); 
        
    },
    viewInfo : function(component, event, helper) {
        let indexPos = event.getSource().get("v.name");
        let offerListToDisplay = component.get("v.offerListToDisplay") || [];
        component.set("v.offerInstance",offerListToDisplay[indexPos]);
        component.set("v.toRenderModal","View Info");
    }
})