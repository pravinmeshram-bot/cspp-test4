({
    clearValue: function(component) {
        component.set("v.value", "");
    },
    
    doInit: function(component, event, helper) {
        helper.init(component);
    },
    
    handleDateChange: function(component, event, helper) {
        helper.doUpdate(component, event);
    },
    onblurHandled : function(component, event, helper) {
        console.log('***** on blur called');
    },
    handleFocus: function(component, event, helper) {
        console.log('**** onfocus fired');
        var onFocusEvent = component.getEvent("onFocus");
        onFocusEvent.fire();
        
        event.cancelBubble = true;
        event.stopPropagation();
        event.preventDefault();
    },
    handleOnClick: function(component, event, helper) {
        var onFocusEvent = component.getEvent("onFocus");
        onFocusEvent.fire();
        
        event.cancelBubble = true;
        event.stopPropagation();
        event.preventDefault();
    }
    
})