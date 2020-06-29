({
    init : function (component) {
        var flow = component.find("flowData");       
        var inputVariables = [
            { name : "Mobile", type : "String", value: '6038585178' } 
        ];
        flow.startFlow("MobileNumberVerification", inputVariables);
    },
    flowInitiate : function (component, event, helper) {
        
        console.log('~~~~~~');
        var flow = component.find("flowData");
        var params = event.getParam("arguments");
        if (params) {
            var phone = params.userPhone;
            console.log('phone--->',phone);
            var inputVariables = [
                { name : "Mobile", type : "String", value: phone } 
            ];
            console.log('inputVariables--->',inputVariables);
            flow.startFlow("MobileNumberVerification", inputVariables);
        }
    },
    handleStatusChange : function (component, event) {
        console.log('-------flow status~~~~~~~',event.getParams());
        if(event.getParam("status") === "FINISHED") {
            
            console.log('-------status~~~~~~~',event.getParam("status"));
            var compEvent = component.getEvent("handleFlow");
             compEvent.setParams({
                "isSuccess": "true"
            });
            compEvent.fire();
        }
    }
})