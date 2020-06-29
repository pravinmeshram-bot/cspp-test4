({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helper) {
        
        var password = component.find("password_selfRegister").get("v.value");
        var confirmPassword = component.find("confirmPassword_selfRegister").get("v.value");
        var username = component.find("username_selfRegister").get("v.value");
        var startUrl = component.get("v.startUrl");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        
        console.log("password::::", password);
        console.log("confirmPassword::::", confirmPassword);
        console.log("username::::", username);
        console.log("startUrl::::", startUrl);
        console.log("regConfirmUrl::::", regConfirmUrl);
        console.log('**** test wrapper-->', JSON.stringify(component.get("v.accountWrapper")));
        
        var usernameRegEx = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log('**** ==>', username.match(usernameRegEx));
                                                        
        if(username.match(usernameRegEx)) {
            
            let accountWrapper = component.get("v.accountWrapper") || {};
            accountWrapper.sourceType = component.get("v.sourceType");
            if (component.get("v.campaignId")) {
                accountWrapper.campaignId = component.get("v.campaignId");
            }
            helper.callServerMethod(
                component,
                helper,
                "selfRegister",
                {
                    password:password, 
                    confirmPassword:confirmPassword, 
                    username:username, 
                    accountWrapper: JSON.stringify(accountWrapper),
                    startUrl : startUrl,
                    regConfirmUrl : regConfirmUrl
                },
                function(response){
                    component.set("v.showError", false); 
                    component.set("v.errorMessage", '');  
                    console.log("response::::", response);
                },
                function(error){
                    component.set("v.showError", true); 
                    component.set("v.errorMessage", error); 
                }
            ); 
        } else {
            component.set("v.showError", true); 
            component.set("v.errorMessage", "Username should have below format username@youremail.com"); 
        }
        /*let domain = window.location.origin;
        console.log('domain--->',domain);
        let pathName = window.location.pathname.split('/');
        console.log('pathName--->',pathName);
        if (pathName.length > 1) {
            domain = domain + '/' + pathName[1];
        }
        console.log('domain--->',domain);
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = '';
        var lastname = '';
        var email = component.find("email").get("v.value");
        var dob = component.find("dob").get("v.value");
        var ssn = component.find("ssn").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({firstname:firstname, lastname:lastname, email:email, dob:dob, ssn:ssn, domain:domain,
                password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
          action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
          }
       });
    $A.enqueueAction(action);*/
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }    
})