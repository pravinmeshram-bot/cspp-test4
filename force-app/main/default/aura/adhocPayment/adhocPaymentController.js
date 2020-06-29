({
    doInit : function(component, event, helper) {
        let domain = window.location.search;
        let parm = domain.split('=')
        if (parm != null && parm[1] != null){
            component.set("v.actionString","ReschedulePayments");
            component.set("v.recordId",parm[1]);
        } else {
            helper.defaultMethod(component, event, helper, true, component.get("v.filterMap"), false);
            component.set("v.isInit",true);
        }
    },
    ShowModal : function(component, event, helper) {
        let objectInfo = event.getSource().get("v.title");
        component.set("v.objectInfo",objectInfo);
        component.set("v.isModal",true);
        component.set("v.newGroupTaskInstance", {'sobjectType':'nu_dse__Group_Task__c'});
    },
    handleLazyLoadEvent : function(component,event,helper) {
        let action = event.getParam("action");
        if(action) {
            let filterMap = component.get("v.filterMap") || {};
            let adhocPaymentWrapper = component.get("v.adhocPaymentWrapper") || {};
            filterMap.offset = adhocPaymentWrapper[action].length.toString();
            helper.defaultMethod(component, event, helper, false, filterMap, false);
        }
    },
    toggleSection : function(component, event, helper) {
        let toggleMap = component.get("v.toggleMap");
        let sectionType = event.currentTarget.getAttribute("data-sectionName");
        toggleMap[sectionType] = !toggleMap[sectionType];
        component.set("v.toggleMap", toggleMap);
    },
})