({
	leaveHandler: function(event) {
        event.returnValue = "Are you sure you want to leave? All changes will be lost!";
    },
    preventLeaving: function(component, helper) {
        window.addEventListener("beforeunload", this.leaveHandler);
    },
    setProfileMenu : function (component, event, helper){
       component.set("v.isProfileMenu",true);
        let currentTabName = event.detail.menuItem.get("v.value");
        if (currentTabName == "myprofile") {
            currentTabName = 'detail/'+component.get("v.uiwrapperMap.userInstance.Id");
        }
        component.set("v.currentTabName", currentTabName);
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domain + '/s/' + currentTabName
        });
        urlEvent.fire();
        let isSectionExpanded = component.get("v.isSectionExpanded");
        if (isSectionExpanded) {
            component.set("v.isSectionExpanded", false);
        }
        let isExpandedProfile = component.get("v.isExpandedProfile");
        if (isExpandedProfile) {
            component.set("v.isExpandedProfile", false);
        }
    },
    setCurrentmenu : function (component, event, helper){
        let currentTabName = event.currentTarget.getAttribute("data-tabName");
        if (currentTabName == "myprofile") {
            currentTabName = 'detail/'+component.get("v.uiwrapperMap.userInstance.Id");
        }
        component.set("v.currentTabName", currentTabName);
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domain + '/s/' + currentTabName
        });
        urlEvent.fire();
        let isSectionExpanded = component.get("v.isSectionExpanded");
        if (isSectionExpanded) {
            component.set("v.isSectionExpanded", false);
        }
        let isExpandedProfile = component.get("v.isExpandedProfile");
        if (isExpandedProfile) {
            component.set("v.isExpandedProfile", false);
        }
        component.set("v.showProfileFlag",true);
    },
    handleApplicationEvent : function(component, event, helper){
        var tabName = event.getParam("tabName");
        component.set("v.currentTabName", tabName);
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+ tabName
        });
        urlEvent.fire();
    },
    handleSmoothScrollEvent: function(target, duration, num) {
        if (target != null) {
                 var target = document.querySelector(target);
                 var targetPosition = target.offsetTop - num;
             }
             else {
                 var targetPosition = 0
             }
        	var startPosition = window.pageYOffset;
            var distance = targetPosition - startPosition;
            var startTime = null;
            
            function animation(currentTime) {
                if(startTime === null) startTime = currentTime;
                var timeElapsed = currentTime - startTime;
                var run = ease(timeElapsed, startPosition, distance, duration);
                window.scrollTo(0, run)
                if(timeElapsed < duration) requestAnimationFrame(animation)
            }
            
            function ease(t, b, c, d) {
                t /= d / 2;
                if (t < 1) return c / 2 * t * t + b;
                t--;
                return -c / 2 * (t * (t - 2) - 1) + b
            }
            
            requestAnimationFrame(animation)
     }
})