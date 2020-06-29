({
    renderToastMessage : function(component, event, helper) {
        let toastParam = event.getParam("toastParam");
        console.log('**** toast param', toastParam);
        component.set("v.notificationMap", toastParam);
        console.log('after toast -->');
      /*  window.setTimeout($A.getCallback(function() {
            helper.closeNotifierToast(component);
        }), 10000);*/
        console.log('after toast sent-->');
    },
    closeNotifierAction : function(component, event, helper) {
        helper.closeNotifierToast(component);
    },
    doInit : function(component, event, helper) {
        
        let domain = window.location.origin;
        console.log('domain--->1',domain);
        /*
        let pathName = window.location.pathname.split('/');
        console.log('pathName--->',pathName);
        if (pathName.length > 1) {
            domain = domain + '/' + pathName[1];
        }
        */
        console.log('domain--->2',domain);
        console.log('**** verifying *****');
        helper.callServerMethod( 
            component,
            helper,
            "validateLogin",                                       
            {},  
            function(result) {
                console.log('result--->',result);
                if (result) {         
                    /*var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "https://community-pioneerdev.cs68.force.com/Dashboard/secur/logout.jsp";//domain+"/secur/logout.jsp"
                    });
                    urlEvent.fire();   */
                    let atag = document.createElement('a');
                    atag.href = domain+"/secur/logout.jsp";
                    atag.target="_self";
                    atag.click();
                    console.log('**** logout called');
                }
            },null
        ); 
    }
})