({
    doInit : function(component, event, helper) {
        
        helper.callServerMethod(
            component,
            helper,
            "getDashboardMetrcis",
            {},
            function(result) {
                if (result) {
                    component.set("v.showDashboard", true);
                    component.set("v.dashboardMetricsMap", result);
                    component.set("v.adhocPaymentWrapper", result.adhocPaymentObj);
                    var amountOfYourDebtSettled = {
                        totalProgress: result.accountOverviewWrapper.adjustedDebt,
                        actualProgress : result.accountOverviewWrapper.resolvedDebt
                    };
                    component.set("v.dashBoardMetricData1", amountOfYourDebtSettled);
                    var percentOfCreditorsResolved = {
                        totalProgress : result.accountOverviewWrapper.enrolledCreditors,
                        actualProgress : result.accountOverviewWrapper.resolvedCreditors
                    };
                    component.set("v.dashBoardMetricData2", percentOfCreditorsResolved);
                }
            },
            null
        );
    },
    closeCongratsModel : function(component, event, helper) {
        component.set("v.dashboardMetricsMap.accountOverviewWrapper.congratsMessage", false);
    },
    ShowModal : function(component, event, helper) {
        let objectInfo = event.getSource().get("v.title");
        component.set("v.objectInfo",objectInfo);
        component.set("v.isModal",true);
        component.set("v.newGroupTaskInstance", {'sobjectType':'nu_dse__Group_Task__c'});
    },
    cancelModal : function(component, event, helper) {
        component.set("v.isModal",false); 
    },
    handleShowPopOver: function(component, evt, helper) {
        
        component.find('overlayLib').showCustomModal({
            header: "Get out of debt faster by adding extra funds.",
            body: "We recommend that whenever you are able to do so, you make an additional payment into program. All of the additional funds go directly towards building up your Program Savings Account, and will allow us to negotiate agreements more quickly on your behalf. There are no pre-payment penalties",
            showCloseButton: true,
            cssClass: "mypopover",
            closeCallback: function() {
            }
        });      
    },
    redirectToPayments: function(component, event, helper) {
        var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            "tabName" : "payments"});
        appEvent.fire();        
    },
    navigatetoFAQ: function(component, event, helper) {
        var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            "tabName" : "FAQ"
        });
        appEvent.fire();  
    }
})