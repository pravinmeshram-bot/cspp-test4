({
    notifierTost : function(component, param) {
        
        let notificationMap = {
            'isRender' : 'true',
            'message' : param.message,
            'iconName' : 'utility:' + param.variant.toLowerCase(),
            'type' : param.variant.toLowerCase()
        };
        var appEvent = $A.get("e.c:showToastMessageEvt");
        appEvent.setParams({
            "toastParam" : notificationMap
        });
        appEvent.fire();
    },
    
    notifierModal : function(component, param) {
        
        let notificationMap = {
            'isModal' : true,
            'message' : param.message,
            'iconName' : 'utility:' + param.variant.toLowerCase(),
            'name' : param.name
        };
        var appEvent = $A.get("e.c:showToastMessageEvt");
        appEvent.setParams({
            "toastParam" : notificationMap
        });
        appEvent.fire();
    },
    
    buildOffLineMsg : function(cmp, helper){
        var errorMsg = "No response from server or client is offline.";
        helper.notifierTost(cmp, {
            "variant" : "error",
            "message" : errorMsg
        });
    },
    showHideSpinner : function(cmp, showSpinner) {
        cmp.set("v.showSpinner", showSpinner);
    },
    callServerMethod: function(component, helper, apexMethodName, apexParams, successCallBack, errorCallBack) {
        helper.showHideSpinner(component, true);
        var action = component.get("c."+apexMethodName);
        if (apexParams){
            action.setParams(apexParams);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('****** state', state);
            if (component.isValid() && state === "SUCCESS") {
                helper.showHideSpinner(component, false);
                if(successCallBack){
                    successCallBack(response.getReturnValue());
                }
            } else if(state === "ERROR") {
                helper.showHideSpinner(component, false);
                let errorMessage = helper.handleError(response.getError());
                if(errorCallBack){
                    errorCallBack(errorMessage);
                } else {
                    helper.notifierTost(component, {
                        "variant" : "error",
                        "message" : errorMessage
                    });
                }
            } else if(state === "INCOMPLETE") {
                helper.showHideSpinner(component, false);
                if(errorCallBack){
                    errorCallBack(helper.handleError(response.getError()));
                } else {
                    helper.buildOffLineMsg(component, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleError : function(errors) {        
        let errorMessage = '';
        if(errors && Array.isArray(errors) && errors.length > 0) {
            errors.forEach(error => {
                if(error.message && errorMessage.includes(error.message) == false) {
                	errorMessage += error.message + "\n";
            	}
                if (error.pageErrors && error.pageErrors.length > 0) {
                	error.pageErrors.forEach(pageError=>{
                        if(errorMessage.includes(error.message) == false)
                    		errorMessage += pageError.message + "\n";
                	}); 
                } else if (error.fieldErrors) {
                    let fields = Object.keys(error.fieldErrors);
                    fields.forEach(fieldError=> {
                        if(Array.isArray(fieldError)) {
                            fieldError.forEach(err=>{
                            	if(errorMessage.includes(error.message) == false)
                        		errorMessage += err.message; 
                    		});
                    	}
                    });
                }
           });
		} else {
            errorMessage = errors;
        }       
        if(errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') !== -1) {
            let errorMessageList = errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            if(errorMessageList.length > 1) {
                let finalErroList = errorMessageList[1].split(': []');
                if(finalErroList.length) {
                    errorMessage = finalErroList[0];
                }
            }
        }
        if(errorMessage.indexOf('REQUIRED_FIELD_MISSING') !== -1) {
            let errorMessageList = errorMessage.split('REQUIRED_FIELD_MISSING,');
            if(errorMessageList.length > 1) {
                errorMessage = errorMessageList[1];
            }
        }
		if(errorMessage.indexOf('STRING_TOO_LONG') !== -1) {
            let errorMessageList = errorMessage.split('first error:,');
            if(errorMessageList.length > 1) {
                errorMessage = errorMessageList[1];
            } else {
                let errorMsgList = errorMessage.split('first error: STRING_TOO_LONG,');
                if(errorMsgList.length > 1) {
                    errorMessage = errorMsgList[1];
                }
            }
        } 
		if(errorMessage.indexOf('first error: NUMBER_OUTSIDE_VALID_RANGE,') !== -1) {
            let errorMessageList = errorMessage.split('first error: NUMBER_OUTSIDE_VALID_RANGE,');
            if(errorMessageList.length > 1) {
                errorMessage = errorMessageList[1].split(':')[0] || '';
            }
            errorMessage += ': Value entered is too large.';
        }
		if(errorMessage.indexOf('first error: UNABLE_TO_LOCK_ROW,') !== -1) {
            errorMessage = 'System error occurred. Please try again';
        }
        return errorMessage;
	},
    fieldValidationHelper : function(component,event, fieldSetList, inputs) {
        var returnValue = {'isFormValid' : true, 'errorMessage' : ''};
        if(!Array.isArray(inputs)) {
            inputs = [inputs];
        }
        for (var i = 0; i < inputs.length; i++) {
            if (fieldSetList[i] && fieldSetList[i].isRequired == true) {
                if(!inputs[i].get("v.value") || (inputs[i].get("v.validity") && !inputs[i].get("v.validity").valid) 
                   || ((fieldSetList[i].fieldType === 'currency' || fieldSetList[i].fieldType === 'double') 
                   && (parseInt(inputs[i].get("v.value")) <= 0) )) {
                    $A.util.addClass(inputs[i], 'slds-has-error');
                    returnValue.isFormValid = false;
                    if (returnValue.errorMessage) {
                        returnValue.errorMessage += ', ';
                    }
                    returnValue.errorMessage += fieldSetList[i].fieldLabel;
                } else{
                    $A.util.removeClass(inputs[i], 'slds-has-error');
                }
            }            
        }
        if (returnValue.errorMessage) {
            if (returnValue.errorMessage.includes(',')) {
                var getLastIndex = returnValue.errorMessage.lastIndexOf(', ');
                returnValue.errorMessage = returnValue.errorMessage.slice(0, getLastIndex) + returnValue.errorMessage.slice(getLastIndex).replace(', ', ' and ');
                returnValue.errorMessage += ' are required fields.' 
            } else {
                returnValue.errorMessage += ' is required field.' 
            }
        }
        return returnValue;
    }  
})