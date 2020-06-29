({
    doInit : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "getCurrentUser",                                       
            {},  
            function(result) {
                if (result) {
                    if (result.userInstance) {
                        let userInstance = JSON.parse(JSON.stringify(result.userInstance));                    
                        userInstance.FirstName = userInstance.FirstName.charAt(0).toUpperCase() + userInstance.FirstName.slice(1).toLowerCase()
        				userInstance.LastName = userInstance.LastName.charAt(0).toUpperCase() + userInstance.LastName.slice(1).toLowerCase()
                        component.set("v.userInstance", userInstance);
                        component.set("v.newUserInstance", JSON.parse(JSON.stringify(result.userInstance)));
                    }
                    if (result.statePicklistValueList) {
                        component.set("v.statePickListValueList", result.statePicklistValueList);
                    }
                    if (result.phoneVerificationStatus) {
                        component.set("v.phoneVerificationStatus", result.phoneVerificationStatus);
                    }
                    if (result.emailVerificationStatus) {
                        component.set("v.emailVerificationStatus", result.emailVerificationStatus);
                    }
                }
            }, null
        ); 
    },
    editUser : function (component, event) {
        component.set("v.isEdit", true);
    },
    cancelModal : function(component, event, helper) {
        component.set("v.newUserInstance", JSON.parse(JSON.stringify(component.get("v.userInstance"))));
        component.set("v.isEdit", false);
    },
    updateModal : function(component, event, helper) {
        let newUserInstance = component.get("v.newUserInstance");
        let userInstance = component.get("v.userInstance");
        var phoneRegEx = /^(?:(\+))?(?:[0-9]{0,3}[\s-\/-]?)(?:(?:\((?=\d{3}\)))?(\d{3})(?:(?!\(\d{3})\))?[\s-\/-]?)(?:(?:\((?=\d{3}\)))?(\d{3})(?:(?!\(\d{3})\))?[\s-\/-]?)(?:(?:\((?=\d{4}\)))?(\d{4})(?:(?!\(\d{4})\))?[\s-\/-]?)?$/;
        if(!newUserInstance.MobilePhone || (newUserInstance.MobilePhone).match(phoneRegEx) ) {
            var inputs = component.find("validation");
            var isFormValid = true;
            for (var i = 0; i < inputs.length; i++) {
                if((inputs[i].get("v.validity") && !inputs[i].get("v.validity").valid)) {
                    $A.util.addClass(inputs[i], 'slds-has-error');
                    isFormValid = false;
                } else{
                    $A.util.removeClass(inputs[i], 'slds-has-error');
                }
            }            
            if(isFormValid) {
                helper.callServerMethod(
                    component,
                    helper,
                    "updateUser",                                       
                    { 
                        userInstance : component.get("v.userInstance"),
                        newUserInstance : component.get("v.newUserInstance")
                    },  
                    function(result) {
                        if (result) { 
                            if (result.userInstance) { 
                                component.set("v.userInstance", JSON.parse(JSON.stringify(result.userInstance)));
                                component.set("v.newUserInstance", JSON.parse(JSON.stringify(result.userInstance)));
                            }
                            if (result.phoneVerificationStatus) {
                                component.set("v.phoneVerificationStatus", result.phoneVerificationStatus);
                            }
                            if (result.emailVerificationStatus) {
                                component.set("v.emailVerificationStatus", result.emailVerificationStatus);
                            }
                            component.set("v.isEdit", false);
                            let toastMessage = '';
                            if ( userInstance.LastName != newUserInstance.LastName || userInstance.FirstName != newUserInstance.FirstName 
                                || userInstance.Street != newUserInstance.Street || userInstance.City != newUserInstance.City 
                                || userInstance.State != newUserInstance.State || userInstance.PostalCode != newUserInstance.PostalCode 
                                || userInstance.State__c != newUserInstance.State__c) {
                                toastMessage += 'User details updated successfully';
                            }
                            if (newUserInstance.Email != userInstance.Email) {
                                if(toastMessage) {
                                    toastMessage += ', Please check Email to verify'
                                } else {
                                    toastMessage += 'Please check Email to verify'
                                }
                            }
                            if (newUserInstance.MobilePhone != userInstance.MobilePhone && 
                                (newUserInstance.MobilePhone).match(phoneRegEx)) {
                                if(toastMessage) {
                                    toastMessage += ', Please check SMS for verification code.'
                                } else {
                                    toastMessage += 'Please check SMS for verification code.'
                                }
                                component.set("v.changedPhoneNumber", newUserInstance.MobilePhone);
                                var modalContent = component.find("triggerTheFlow");
                                modalContent.initiateFlow(newUserInstance.MobilePhone);
                            }
                            if(toastMessage) {
                                var toRenderModal = component.get("v.toRenderModal");
                                toRenderModal.isModal = true;
                                toRenderModal.Message = toastMessage;
                                toRenderModal.Name = 'Your request has been received.';
                                component.set("v.toRenderModal",toRenderModal);
                            } 
                        } 
                    }, null
                );
            } 
        }
    },
    updatePhone : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "updatePhoneNumber",                                       
            {
                phoneNumber : component.get("v.changedPhoneNumber"),
                userInstance : component.get("v.userInstance")
            },  
            function(result) {
                if (result) {
                    if (result.userInstance) {
                        component.set("v.userInstance", JSON.parse(JSON.stringify(result.userInstance)));
                        component.set("v.newUserInstance", JSON.parse(JSON.stringify(result.userInstance)));
                    }
                    if (result.phoneVerificationStatus) {
                        component.set("v.phoneVerificationStatus", result.phoneVerificationStatus);
                    }
                    if (result.emailVerificationStatus) {
                        component.set("v.emailVerificationStatus", result.emailVerificationStatus);
                    }
                    component.set("v.changedPhoneNumber","")
                    if (newUserInstance.MobilePhone != userInstance.MobilePhone) {
                        var toRenderModal = component.get("v.toRenderModal");
                        toRenderModal.isModal = true;
                        toRenderModal.Message = "Mobile Number verified successfully.";
                        toRenderModal.Name = 'Your request has been received.';
                        component.set("v.toRenderModal",toRenderModal);
                    }
                }                
            }, null
        );
    },
    resetPassword : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "resetpassword",                                       
            {
                userInstance : component.get("v.userInstance")
            },  
            function(result) {
                if (result) {
                    var toRenderModal = component.get("v.toRenderModal");
                    toRenderModal.isModal = true;
                    toRenderModal.Name = 'Your request has been received.';
                    toRenderModal.Message = "Reset password link has been sent to your email";
                    component.set("v.toRenderModal",toRenderModal);
                } 
            }, null
        );
    },
    cancelConfirmationModal : function(component, event, helper) {
        component.set("v.toRenderModal.isModal",false);
    }
})