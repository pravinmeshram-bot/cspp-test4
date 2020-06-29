({
    doInit : function(component, event, helper) {
        
        helper.callServerMethod(
            component,
            helper,
            "getDefaultValues",
            {},
            function(response){
                if (response) {
                    component.set("v.columnHeaderMap",response);
                }
            }
        );
    },
    ShowNewDeptModal : function(component, event, helper) {
        
        helper.callServerMethod(
            component,
            helper,
            "getGroupTaskInstance",
            {},
            function (response) {
                if (response) {
                    var navigatePage = $A.get("e.force:navigateToURL");
                    navigatePage.setParams({
                        "url": '/add-new-debt?id='+response.Id
                    });
                    navigatePage.fire();
                }
            }
        );
        var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            "tabName" : "add-new-debt"
        });
        appEvent.fire();    
    },
    openModel: function(component, event, helper) {
        let currentdebtId = event.currentTarget.getAttribute("data-debtId");
        let currentindex = event.currentTarget.getAttribute("data-index");
        let columnHeader = component.get("v.columnHeaderMap") || {};
        
        if (currentdebtId) {
            var appEvent = $A.get("e.c:SetHeaderValue");
            appEvent.setParams({
                "tabName" : "enrolled-debt"
            });
            appEvent.fire();  
            var navigatePage = $A.get("e.force:navigateToURL");
            navigatePage.setParams({
                "url": '/enrolled-debt?id='+currentdebtId
            });
            navigatePage.fire();
        }
    }
})