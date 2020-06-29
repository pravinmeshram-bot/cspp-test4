({
	loadUserList : function(component, event, helper) {
        //loan the list of users for the profile
        var profileName = component.get("v.profileName");
        
        var action = component.get('c.getUsers');
        action.setParams({
            "pProfileName" : profileName
        });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userList = response.getReturnValue();
                component.set("v.users", userList);
                
                var listTitle = profileName + " Users " + "(" + userList.length + ")";
                component.set("v.listTitle", listTitle);

                component.set("v.isDisplayList", true);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
	}
})