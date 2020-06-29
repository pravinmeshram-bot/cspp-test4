({
	onToggleRoundRobinFlag : function(component, event, helper) {
        var userRecord = component.get("v.user");
        
        var action = component.get('c.toggleRoundRobinStatus');
        action.setParams({
            "pUserId" : userRecord.Id
        });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var retMsgJSON = response.getReturnValue();
                var retMsg = JSON.parse(retMsgJSON);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": (retMsg.isSuccess ? "success" : "error"), "message": retMsg.message
                });
                toastEvent.fire();
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
	}
})