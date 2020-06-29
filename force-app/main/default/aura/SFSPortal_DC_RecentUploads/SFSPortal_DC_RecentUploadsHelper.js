({
	//used this generic function to create a server side request 
    sendRequest : function(cmp, methodName, params){
        return new Promise($A.getCallback(function(resolve, reject) {
            cmp.set("v.spinner", true);  //displaying loading spinner
            var action = cmp.get(methodName);
            if(params){
            	action.setParams(params);
            }
            action.setCallback(self, function(res) {
                var state = res.getState();
                if(state === 'SUCCESS') {
                    console.log('InsideSuccess---');
                    resolve(res.getReturnValue());
                } else if(state === 'ERROR') {
                    console.log('InsideERROR---');
                    reject(action.getError())
                }
                cmp.set("v.spinner", false);  //hide loading spinner
            });
            $A.enqueueAction(action);
        }));
    }
})