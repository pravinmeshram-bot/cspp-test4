({
    doInit : function(component, event, helper) {
        
        let tradelineRecId;
        var domain = window.location.search;
        if(domain) {
            var parm = domain.split('=');
            if(parm && parm.length && parm.length > 1) {
                var id = parm[1].split('&');
                tradelineRecId = id[0];
            }
        }
        helper.callServerMethod(
            component,
            helper,
            "getDefault",
            {
                tradelineId : tradelineRecId,
                isDoInit : true
            },
            function(response) {
                
                if (response) {
                    
                    for (let i = 0; i < response.tradeLineWrapList.length; i++) {
                        
                        response.tradeLineWrapList[i].expanded = false;
                        response.tradeLineWrapList[i].expandInMobile = false;
                        response.tradeLineWrapList[i].tradeLineHistoryWrapList.sort( function (tradeLine1, tradeLine2) {
                            if (tradeLine1.accountHistoryDate > tradeLine2.accountHistoryDate) {
                                return -1;
                            }
                            if (tradeLine1.accountHistoryDate < tradeLine2.accountHistoryDate) {
                                return 1;
                            }
                            return 0;
                        });
                        if (response.tradeLineWrapList[i].tradelineId === tradelineRecId) {
                            response.tradeLineWrapList[i].expanded = true;
                            response.tradeLineWrapList[i].expandInMobile = false;
                            component.set("v.currentTradeline",response.tradeLineWrapList[i]);
                            response.tradeLineWrapList[i].isAcccountHistory = false;
                            response.tradeLineWrapList[i].isStatusExpand = false;
                            component.set("v.currentTradelineInMobileView",response.tradeLineWrapList[i]);
                        }
                    }
                    if (!tradelineRecId) {
                        response.tradeLineWrapList[0].expanded = true
                        component.set("v.currentTradeline",response.tradeLineWrapList[0]);
                    }
                    component.set("v.columnHeaderMap",response);
                }
            }
        );
    },
    cancelModal : function(component, event, helper) {
        
        let columnHeader = component.get("v.columnHeaderMap") || {};
        for(let i = 0; i < columnHeader.tradeLineWrapList.length; i++) {
            
            if (columnHeader.tradeLineWrapList[i].expanded == true 
                || columnHeader.tradeLineWrapList[i].expandInMobile == true) {
                
                columnHeader.tradeLineWrapList[i].expanded = false;
                columnHeader.tradeLineWrapList[i].isStatusExpand = false;
                columnHeader.tradeLineWrapList[i].expandInMobile = false;
                columnHeader.tradeLineWrapList[i].isAcccountHistory = false;
            }
        }
        component.set("v.columnHeaderMap", columnHeader);
        component.set("v.currentTradelineInMobileView",{});
        /*var appEvent = $A.get("e.c:SetHeaderValue");
        appEvent.setParams({
            "tabName" : ""});
        appEvent.fire();   */
    },
    closeModel: function(component, event, helper) {
        
        var value = event.getSource().get('v.value');
        var currentindex = event.getSource().get('v.name');
        let columnHeader = component.get("v.columnHeaderMap") || {};
        
        if (columnHeader.tradeLineWrapList[currentindex].expanded == false
            || columnHeader.tradeLineWrapList[currentindex].expandInMobile == false) {
            
            for(let i = 0; i < columnHeader.tradeLineWrapList.length; i++) {
                
                if (columnHeader.tradeLineWrapList[i].expanded == true
                    || columnHeader.tradeLineWrapList[i].expandInMobile == true) {
                    
                    columnHeader.tradeLineWrapList[i].expanded = false;
                    columnHeader.tradeLineWrapList[i].isAcccountHistory = false;
                    columnHeader.tradeLineWrapList[i].isStatusExpand = false;
                    columnHeader.tradeLineWrapList[i].expandInMobile = false;
                }
            }
            component.set("v.currentTradeline", columnHeader.tradeLineWrapList[currentindex]);
            component.set("v.currentTradelineInMobileView", columnHeader.tradeLineWrapList[currentindex]);
            columnHeader.tradeLineWrapList[currentindex].expanded = true;
            columnHeader.tradeLineWrapList[currentindex].expandInMobile = true;
        }
        component.set("v.columnHeaderMap", columnHeader)
    },
    navigatetoFAQ :function(component, event, helper) {
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domain + '/s/FAQ'
        });
        urlEvent.fire();
    },
    handleClick :function(component, event, helper) {
        var currentTradeline = component.get("v.currentTradelineInMobileView");
        currentTradeline.isStatusExpand = !currentTradeline.isStatusExpand;
        component.set("v.currentTradelineInMobileView", currentTradeline)
    },
    handleAccountHistoryClick :function(component, event, helper) {
        var currentTradeline = component.get("v.currentTradelineInMobileView");
        currentTradeline.isAcccountHistory = !currentTradeline.isAcccountHistory;
        component.set("v.currentTradelineInMobileView", currentTradeline)
    },
})