({
    iconAction : function(component, event, helper) {
        console.log('****** icon action fired');
        let action = event.currentTarget.getAttribute("data-action");            
        console.log('res action--->',action);
        var actionEvent = component.getEvent("actionEvent");
        actionEvent.setParams({
            'selectedRecord': component.get("v.dataRowMap"),
            'selectedIndexPostion': component.get("v.indexPosition"),
            'action':action
        });
        actionEvent.fire();
    },
    taskAction : function(component, event, helper) {
        console.log('****** icon taskAction fired');
        let action = event.getSource().get("v.title");
        console.log('res action--->',action);
        console.log('res action--->',component.get("v.dataRowMap"));
        var actionEvent = component.getEvent("actionEvent");
        actionEvent.setParams({
            'selectedRecord': component.get("v.dataRowMap"),
            'selectedIndexPostion': component.get("v.indexPosition"),
            'action':action
        });
        actionEvent.fire();
    }
})