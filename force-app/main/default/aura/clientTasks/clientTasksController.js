({
    doInit : function(component, event, helper) {        
        helper.callServerMethod(
            component,
            helper,
            "getTaskList",
            {},
            function(response) {
                
                if (response) { 
                    
                    component.set("v.isOfferDecision", response.isOfferDecision);
                    response.sObjectList = [];
                    if (response.isOfferListVisible) {
                        
                        let offerList = JSON.parse(JSON.stringify(response.offerList || [])); 
                        for (let i = 0; i < offerList.length; i++) {
                            
                            if (offerList[i].Available_for_Client_Review__c 
                                && offerList[i].Source_of_Payment__c == 'PSA'
                                && offerList[i].Tradeline_Litigation_Status__c == 'Non Lit') {
                                
                                offerList[i].offerCriteriaMet = true;  
                            } else if (offerList[i].Source_of_Payment__c != 'PSA' 
                                       && offerList[i].Tradeline_Litigation_Status__c != 'Non Lit') {
                                
                                offerList[i].offerMoreInfo = true;
                            } else if (offerList[i].Available_for_Client_Review__c == false 
                                       && (offerList[i].Source_of_Payment__c == 'PSA' 
                                           || offerList[i].Tradeline_Litigation_Status__c == 'Non Lit')) {
                                
                                offerList[i].offerMoreInfo = true;
                            }
                            offerList[i].isOffer = true;
                            response.sObjectList.push(offerList[i]);
                        }
                        if(response.taskList.length > 0 || offerList.length > 0) {
                            
                            var appEvent = $A.get("e.c:displayTaskAlert");
                            appEvent.setParam("isDisplayTaskAlert", "true");
                            appEvent.fire();
                        }
                        for (let j = 0; j < response.taskList.length; j++) {
                            
                            response.sObjectList.push(response.taskList[j]);
                        }
                        component.set("v.clientTaskWrapper", JSON.parse(JSON.stringify(response)));
                        component.set("v.offerList", offerList);
                        component.set("v.offerFieldsetFields", JSON.parse(JSON.stringify(response.detailFields)));
                        component.set("v.offerListViewFieldset", JSON.parse(JSON.stringify(response.listFields)));
                        component.set("v.program", JSON.parse(JSON.stringify(response.program )));
                        component.set("v.isInit", true);
                    }
                }
            }, null 
        );
    },
    reviewForApproval : function(component, event, helper) {
        
        let indexPos = event.getSource().get("v.name");
        let offerListToDisplay = component.get("v.tasksToDisplay") || [];
        var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            
            "tabName" : "approvals"
        });
        appEvent.fire();  
        
        var navigatePage = $A.get("e.force:navigateToURL");
        navigatePage.setParams({
            
            "url": '/approvals?id='+offerListToDisplay[indexPos].Id
        });
        navigatePage.fire();
    },
    rescheduleNow : function(component, event, helper) {
        let indexPos = event.getSource().get("v.name");
        let tasksToDisplay = component.get("v.tasksToDisplay") || [];
        var paymentId = tasksToDisplay[indexPos].NSF_payment_18_Digit__c;   
        
        if (paymentId) {
            
            var appEvent = $A.get("e.c:SetHeaderValue");
            appEvent.setParams({
                
                "tabName" : "payments"
            });
            appEvent.fire();  
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                
                "url": "/payments?id="+paymentId
            });
            urlEvent.fire();     
        } else {
            
            helper.notifierTost(component, {
                "variant" : "error",
                "message" : "You can't reschedule this task. Please contact system admin."
            });
        }
    },
    viewInfo : function(component, event, helper) {
        
        let indexPos = event.getSource().get("v.name");
        let offerListToDisplay = component.get("v.tasksToDisplay") || [];
        component.set("v.offerInstance",offerListToDisplay[indexPos]);
        component.set("v.toRenderModal","View Info");
    },
    taskAction : function(component, event, helper) { 
        
        var action = event.getParam("action");
        var selectedRecordId = event.getParam("selectedRecord").Id;
        
        if(action === 'View Info') {
            
            helper.callServerMethod(
                component,
                helper,
                "getViewInfo",
                {
                    taskId : selectedRecordId
                },
                function(response) {
                    
                    if (response) {
                        
                        component.set("v.taskInfo", response);
                        component.set("v.isModalOpen", true);
                    }
                }, null 
            );
        } else {
            
            var paymentId = event.getParam("selectedRecord").NSF_payment_18_Digit__c;  
            
            if (paymentId) {
                
                var appEvent = $A.get("e.c:SetHeaderValue");
                appEvent.setParams({
                    
                    "tabName" : "payments"
                });
                appEvent.fire();  
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/payments?id="+paymentId
                });
                urlEvent.fire();     
            } else {
                
                helper.notifierTost(component,{
                    "variant" : "error",
                    "message" : "Necessary information is not available to reschedule."
                });
            }
        }
    },
    
    getMoreInfo : function(component, event, helper) {
        let indexPos = event.getSource().get("v.name");
        let tasksToDisplay = component.get("v.tasksToDisplay") || [];
        helper.callServerMethod(
            component,
            helper,
            "getViewInfo",
            {
                taskId : tasksToDisplay[indexPos].Id,
                callType : tasksToDisplay[indexPos].Call_Type__c
            },
            function (response) {
                
                if (response) {
                    
                    response.taskInstance = tasksToDisplay[indexPos];
                    component.set("v.taskInfo", response);
                    component.set("v.isModalOpen", true);
                }
            }, null 
        );
    },
    cancelModel : function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
        component.set("v.offerInstance",{'sobjectType' : 'nu_dse__Offer__c'});
        component.set("v.toRenderModal","");
    }
})