({
    selectRecord : function(component, event, helper) {    
        var getSelectRecord = component.get("v.oRecord");
        var compEvent = component.getEvent("oSelectedRecordEvent");
        var recordToSend = {
            'Id' : getSelectRecord.recordId, 
            'Name' : getSelectRecord.label,
            'fieldsToDisplayList' : getSelectRecord.fieldsToDisplayList 
        };
        compEvent.setParams({
            "recordByEvent" : recordToSend 
        });  
        compEvent.fire();
    }
})