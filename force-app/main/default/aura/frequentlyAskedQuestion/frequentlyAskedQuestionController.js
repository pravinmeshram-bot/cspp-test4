({
    doInit : function(component, event, helper) {
        helper.callServerMethod(
            component,
            helper,
            "getAllFrequentQuestions",
            {},
            function(response){
                
                console.log("responseFAQ::",response);
                if(response && response.length > 0) {
                    let innerWidth = window.innerWidth;
                    if(innerWidth >= 767){
                        response[0].expanded = true;
                        component.set("v.currentQuestion", response[0]);
                    } else {
                        response[0].expanded = false;
                    }
                    
                    component.set("v.faqList",response);
                    component.set("v.faqListOriginal", response);
                    component.set("v.isDoInitFired", true);
                }
            }
        );
    },
    
    onExpand : function(component, event, helper) {
        let index = parseInt(event.currentTarget.getAttribute("data-index"));       
        console.log('index--->',index);
        let faqList = component.get("v.faqListToDisplay");
        
        
        if (faqList != null && faqList.length > index && faqList[index] != null ) {
            
            for(var ind = 0; ind < faqList.length;ind++) {
                
                faqList[ind].expanded = false;
            }
            faqList[index].expanded = true;
        }
        console.log('**** faqList-->', faqList);
        component.set("v.faqListToDisplay",faqList);
        component.set("v.currentQuestion", faqList[index]);
    },
    
    onSearch : function(component, event, helper) {
        
        let searchTerm = component.get("v.searchInput");
        console.log('searchTerm:::',searchTerm);
        let faqList = component.get("v.faqListOriginal") || [];
        console.log('***** faqList-->', faqList);
        let filteredFaqList = faqList.filter(function(questionInstance) {
            if(questionInstance.Question__c.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1) {
                questionInstance.expanded = false;
                return true;
            }
            return false;
        });
        if(filteredFaqList.length) {
            filteredFaqList[0].expanded = true;
            component.set("v.currentQuestion", filteredFaqList[0]);
        }
        
        component.set("v.faqList", filteredFaqList);
        component.set("v.isDoInitFired", false);
        component.set("v.isDoInitFired", true);
        console.log('***** filteredFaqList-->', filteredFaqList);
        
        //helper.getFrequentlyAskedQuestion(component, event, helper,searchTerm);
        
    },
    
    onReset : function(component, event, helper) {
        component.set("v.searchInput", "");
        let faqListOriginal = component.get("v.faqListOriginal");
        for(let i = 0; i < faqListOriginal.length; i++) {
            faqListOriginal[i].expanded = (i === 0) ? true : false;
            if(i === 0) {
                component.set("v.currentQuestion", faqListOriginal[i]);
            }
        }
        component.set("v.faqList", component.get("v.faqListOriginal"));
        component.set("v.isDoInitFired", false);
        component.set("v.isDoInitFired", true);
    },
    
    defaultRecord : function(component, event, helper) {
        let faqList = event.getParam("selectedRecord");
        
        if(faqList != null && faqList.length > 0) {
            
            for(var ind = 0; ind < faqList.length;ind++) {
                
                faqList[ind].expanded = false;
            }
        }
        
        if($A.get("$Browser.isPhone")) {
            
            faqList[0].expanded = false;
        } else {
            faqList[0].expanded = true;
            component.set("v.currentQuestion", faqList[0]);
        }
        console.log('FAQ event fire:::',faqList);
        component.set("v.faqListToDisplay",faqList);
    },
    toggleSection : function(component, event, helper) {
        let isExpanded = component.get("v.isExpanded");
        let index = parseInt(event.currentTarget.getAttribute("data-index"));  
        console.log('**** index-->', index);
        let faqList = component.get("v.faqListToDisplay") || [];
        console.log('**** faqList-->', faqList);
        if(!isExpanded) {
            component.set("v.currentQuestion", faqList[index]);
            component.set("v.isExpanded", !isExpanded);
        }
        component.set("v.isExpanded", !isExpanded);
    },
    hideExpandedSection : function(component, event, helper) {
        component.set("v.isExpanded", !component.get("v.isExpanded"));
    }
})