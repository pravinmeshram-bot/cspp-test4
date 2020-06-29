({
	closeNotifierToast : function(component) {
        console.log('***** callled');
        let notificationMap = {'isRender' : 'false'};
        component.set("v.notificationMap", notificationMap);
        console.log('***** value set', notificationMap);
    },
})