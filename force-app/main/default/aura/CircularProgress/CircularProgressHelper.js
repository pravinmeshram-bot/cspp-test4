({
	doInit : function(component, event, helper) {
        console.log('doInit Called');
        var actualData = component.get("v.actualData");
        if(actualData != null && actualData != undefined){
            component.set("v.totalProgress",actualData.totalProgress);
            component.set("v.actualProgress",actualData.actualProgress);
            helper.drawChart(component, actualData.actualProgress,actualData.totalProgress);
        }
        helper.computeProgress(component, event, helper);
	},
    computeProgress : function(component, event, helper) {
        var totalVal = component.get("v.totalProgress");
        var actualVal = component.get("v.actualProgress");
        
        console.log('totalVal--> ' , totalVal);
        console.log('actualVal--> ' , actualVal);

        if(totalVal && actualVal && !isNaN(parseInt(totalVal)) && isFinite(totalVal) && !isNaN(parseInt(actualVal)) && isFinite(actualVal)){
           //parameter is number
           if(totalVal > 0){
            var percVal = parseInt(actualVal) / parseInt(totalVal) ;
           }
           else{
            var percVal = 0;
           }

            var progressVal = parseInt(percVal * 360) ;
            
            component.set("v.cirDeg" , progressVal );
            component.set("v.perText" , Math.round(parseInt(percVal * 100))+'%' );

            //helper.drawChart(component, progressVal);

        }else if(actualVal){
            //helper.callApexMethod(component, event, helper, totalVal, actualVal);
        }
    },
    callApexMethod : function(component, event, helper, txt_totalVal, txt_actualVal)  {
        
        var action = component.get('c.computePercentage');
        var txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordId : txt_recordId,
            sObjectName : txt_sObjectName,
            totalValueFieldName : txt_totalVal,
            actualValueFieldName : txt_actualVal
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === 'SUCCESS') {
                var percVal = a.getReturnValue() ; 
                var progressVal = parseInt( (percVal/100) * 360  ) ; 
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , Math.round(parseInt(percVal))  +'%' );              
                //helper.drawChart(component, progressVal);
            }  
        });
        $A.enqueueAction(action);  
    },

    drawChart : function(component, progressVal, totalProgress) {
        console.log('progressVal-> ' , progressVal);
         console.log('totalProgress-> ' , totalProgress);
         if(totalProgress == 0){
            totalProgress = 5;
         }
        var sectionCount = totalProgress/5;
        
        let ctx = component.find('chart').getElement();
        var opts = {
            angle: 0.15, // The span of the gauge arc
            lineWidth: 0.44, // The line thickness
            radiusScale: 1, // Relative radius
            pointer: {
                length: 0.6, // // Relative to gauge radius
                strokeWidth: 0.082, // The thickness
                color: '#000000' // Fill color
            },
            staticZones: [
                {strokeStyle: "#cbebfb", min: 0, max: sectionCount}, // Red from 100 to 130
               {strokeStyle: "#86c3e3", min: sectionCount, max: sectionCount*2}, // Yellow
               {strokeStyle: "#50a6d3", min: sectionCount*2, max: sectionCount*3}, // Green
               {strokeStyle: "#2090c8", min: sectionCount*3, max: sectionCount*4}, // Yellow
               {strokeStyle: "#1889ca", min: sectionCount*4, max: sectionCount*5}  // Red
            ],
            limitMax: false,// If false, max value increases automatically if value > maxValue
            limitMin: false,// If true, the min value of the gauge will be fixed
            //percentColors: [[0.0, "#a9d70b" ], [0.50, "#3366ff"], [1.0, "#0099ff"]], // !!!!
            strokeColor: '#E0E0E0',// to see which ones work best for you
            generateGradient: true,
            highDpiSupport: true,// High resolution support
        };
        var target = ctx; // your canvas element
        var gauge = new Gauge(ctx).setOptions(opts); // create sexy gauge!
        gauge.maxValue = totalProgress; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(progressVal); // set actual value
        }

})