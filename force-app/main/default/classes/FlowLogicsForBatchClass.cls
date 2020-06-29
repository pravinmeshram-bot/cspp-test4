public class FlowLogicsForBatchClass {
    
    public static List<Task> createTasks(nu_dse__Payment__c paymentInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Id taskOwnerId = taskOwnerIdMap.get('NSF Payment Task');
        
        //Task1..
        /*taskList.add(createTask(paymentInst, 'NSF Email 2.', paymentInst.NSF_Date__c + 4, 
                                      'NSFEMAIL20', taskCommTempIds.get('NSFEMAIL20')));  Removed that, since it was not added to the list in the Flow*/
        
        //Task2..
        taskList.addAll(createTask(paymentInst, 'NSF Call 1', getActivityDate(new List<Integer> {1,0,0,0,0,0,2}), 
                                        'NSF CALL 1', taskCommTempIds.get('NSF Call 1'), taskOwnerId));
        
        //Task3..
        taskList.addAll(createTask(paymentInst, 'NSF Call 2', getActivityDate(new List<Integer> {2,1,1,1,1,3,3}), 
                                        'NSF Call 2', taskCommTempIds.get('NSF Call 2'), taskOwnerId));
        
        //Task4..
        taskList.addAll(createTask(paymentInst, 'NSF Call 3', getActivityDate(new List<Integer> {3,2,2,2,4,4,4}), 
                                        'NSF Call 3', taskCommTempIds.get('NSF Call 3'), taskOwnerId));
        
        //Task5..
        taskList.addAll(createTask(paymentInst, 'NSF Call 4', getActivityDate(new List<Integer> {4,3,3,5,5,5,5}), 
                                        'NSF Call 4', taskCommTempIds.get('NSF Call 4'), taskOwnerId));
        
        //Task6..
        taskList.addAll(createTask(paymentInst, 'NSF Call 5', getActivityDate(new List<Integer> {5,4,6,6,6,6,6}), 
                                        'NSF Call 5', taskCommTempIds.get('NSF Call 5'), taskOwnerId));
        
        //Task7..
        taskList.addAll(createTask(paymentInst, 'NSF Call 6', getActivityDate(new List<Integer> {8,7,7,7,7,7,9}), 
                                        'NSF Call 6', taskCommTempIds.get('NSF Call 6'), taskOwnerId));
        
        //Task8..
        taskList.addAll(createTask(paymentInst, 'NSF Email 1', getActivityDate(new List<Integer> {1,0,0,0,0,0,2}), 
                                        'NSF Email 1', taskCommTempIds.get('NSF Email 1'), taskOwnerId));
        
        //Task9..
        taskList.addAll(createTask(paymentInst, 'NSF Email 2', getActivityDate(new List<Integer> {2,1,1,1,1,3,3}), 
                                        'NSF Email 2', taskCommTempIds.get('NSF Email 2'), taskOwnerId));
        
        //Task10..
        taskList.addAll(createTask(paymentInst, 'NSF Email 3', getActivityDate(new List<Integer> {3,2,2,2,4,4,4}), 
                                        'NSF Email 3', taskCommTempIds.get('NSF Email 3'), taskOwnerId));
        
        //Task11..
        taskList.addAll(createTask(paymentInst, 'NSF Email 4', getActivityDate(new List<Integer> {4,3,3,5,5,5,5}), 
                                        'NSF Email 4', taskCommTempIds.get('NSF Email 4'), taskOwnerId));
        
        //Task12..
        taskList.addAll(createTask(paymentInst, 'NSF Email 5', getActivityDate(new List<Integer> {5,4,6,6,6,6,6}), 
                                        'NSF Email 5', taskCommTempIds.get('NSF Email 5'), taskOwnerId));
        
        //Task13..
        taskList.addAll(createTask(paymentInst, 'NSF Email 6', getActivityDate(new List<Integer> {8,7,7,7,7,7,9}), 
                                        'NSF Email 6', taskCommTempIds.get('NSF Email 6'), taskOwnerId));
        
        //Task14..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Call 1', getActivityDate(new List<Integer> {30,30,30,30,32,31,30}), 
                                        'Unresponsive NSF Call 1', taskCommTempIds.get('Unresponsive NSF Call 1'), taskOwnerId));
        
        //Task15..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Email 1', getActivityDate(new List<Integer> {30,30,30,30,32,31,30}), 
                                        'Unresponsive NSF Email 1', taskCommTempIds.get('Unresponsive NSF Email 1'), taskOwnerId));
        
        //Task16..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Call 2', getActivityDate(new List<Integer> {31,31,31,33,33,32,31}), 
                                        'Unresponsive NSF Call 2', taskCommTempIds.get('Unresponsive NSF Call 2'), taskOwnerId));
        
        //Task17..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Email 2', getActivityDate(new List<Integer> {31,31,31,33,33,32,31}), 
                                        'Unresponsive NSF Email 2', taskCommTempIds.get('Unresponsive NSF Email 2'), taskOwnerId));
        
        //Task18..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Call 3', getActivityDate(new List<Integer> {32,32,34,34,34,33,32}), 
                                        'Unresponsive NSF Call 3', taskCommTempIds.get('Unresponsive NSF Call 3'), taskOwnerId));
        
        //Task19..
        taskList.addAll(createTask(paymentInst, 'Unresponsive NSF Email 3', getActivityDate(new List<Integer> {32,32,34,34,34,33,32}), 
                                        'Unresponsive NSF Email 3', taskCommTempIds.get('Unresponsive NSF Email 3'), taskOwnerId));
        
        Task taskInst20 = new Task();
        taskInst20.ActivityDate = system.today();
        taskInst20.Subject = 'NSF';
        taskInst20.Clients_task__c = True;
        taskInst20.Call_Type__c = 'NSF';
        taskInst20.Status = 'Not Started';
        taskInst20.NSF_Payment__c = paymentInst.Id;
        taskInst20.WhatId = paymentInst.nu_dse__Program__c;
        taskList.add(taskInst20);
        
        return taskList;
    }
    
    public static Date getActivityDate(List<Integer> activityDayCalcList) {
    
        if (activityDayCalcList.size() >= 7) {
            
            switch on math.mod(Date.newInstance(1900,1,7).daysBetween(System.today()),7) {
                    
                when 0{
                    
                    return System.today().addDays(activityDayCalcList[0]);
                }   
                when 1{
                    
                    return System.today().addDays(activityDayCalcList[1]);
                }
                when 2{
                    
                    return System.today().addDays(activityDayCalcList[2]);
                }
                when 3{
                    
                    return System.today().addDays(activityDayCalcList[3]);
                }
                when 4{
                    
                    return System.today().addDays(activityDayCalcList[4]);
                }
                when 5{
                    
                    return System.today().addDays(activityDayCalcList[5]);
                }
                when 6{
                    
                    return System.today().addDays(activityDayCalcList[6]);
                }
                when else {
                    
                    return System.today();
                }
            }
        } else {
            
            return null;
        }
    }
    
    public static List<Task> createARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        Boolean isAttorney = programInst.Attorney__c;
        Id taskOwnerId = taskOwnerIdMap.get('Account Review');
        
        if(!isAttorney){
            //Task30Day..
            taskList.addAll(createTask(programInst, '30 Day AR', activityDate.addDays(30), 
                                       '30 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
            //Task60Day..
            taskList.addAll(createTask(programInst, '60 Day AR', activityDate.addDays(60), 
                                       '60 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
            //Task90Day..
            taskList.addAll(createTask(programInst, '90 Day AR', activityDate.addDays(90), 
                                       '90 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        }
        
        //Task150Day..
        /*taskList.addAll(createTask(programInst, '150 Day AR', activityDate.addDays(150), 
                                      '150 Day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task180Day..
        taskList.addAll(createTask(programInst, '180 Day AR', activityDate.addDays(180), 
                                      '180 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task210Day..
        taskList.addAll(createTask(programInst, '210 Day AR', activityDate.addDays(210), 
                                      '210 Day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task240Day..
        taskList.addAll(createTask(programInst, '240 Day AR', activityDate.addDays(240), 
                                      '240 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task270Day..
        taskList.addAll(createTask(programInst, '270 Day AR', activityDate.addDays(270), 
                                      '270 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task300Day..
        taskList.addAll(createTask(programInst, '300 Day AR', activityDate.addDays(300), 
                                      '300 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task300Day..
        taskList.addAll(createTask(programInst, '330 Day AR', activityDate.addDays(330), 
                                      '330 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        //Task360Day..
        taskList.addAll(createTask(programInst, '360 Day AR', activityDate.addDays(360), 
                                      '360 day AR', taskCommTempIds.get('AR Flow'), taskOwnerId));
        */
        
        //Client Task for Agents
        if(isAttorney){
            //Task30Day..Account review one
            taskList.add(createClientTask(programInst.Id, 'Check In Call', activityDate.addDays(30)));
            //Task90Day..Account review three
            taskList.add(createClientTask(programInst.Id, 'Strategy Call', activityDate.addDays(90)));
            //Task180Day..Account review six
            taskList.add(createClientTask(programInst.Id, 'Program Review', activityDate.addDays(180)));
        }              
        
        //Task60Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Two', activityDate.addDays(60)));
        //Task150Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Five', activityDate.addDays(150)));
        
        //Task210Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Seven', activityDate.addDays(210)));
        //Task240Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Eight', activityDate.addDays(240)));
        //Task270Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Nine', activityDate.addDays(270)));
        //Task300Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Ten', activityDate.addDays(300)));
        //Task300Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Eleven', activityDate.addDays(330)));
        //Task360Day..
        //taskList.add(createClientTask(programInst.Id, 'Account Review Twelve', activityDate.addDays(360)));
        
        return taskList;
    }
    
    /*public static List<Task> createYear2ARFlow(nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        Id taskOwnerId = taskOwnerIdMap.get('Account Review');
        
        //Task455Day..
        taskList.addAll(createTask(programInst, 'AR Y2Q1', activityDate.addDays(455), 
                                      'AR Y2Q1', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task545Day..
        taskList.addAll(createTask(programInst, 'AR Y2Q2', activityDate.addDays(545), 
                                      'AR Y2Q2', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task635Day..
        taskList.addAll(createTask(programInst, 'AR Y2Q3', activityDate.addDays(635), 
                                      'AR Y2Q3', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task725Day..
        taskList.addAll(createTask(programInst, 'AR Y2Q4', activityDate.addDays(725), 
                                      'AR Y2Q4', taskCommTempIds.get('Account Review'), taskOwnerId));
        
        //Client Task for Agents                       
        //Task455Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Thirteen', activityDate.addDays(455)));
        //Task545Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Fourteen', activityDate.addDays(545)));
        //Task635Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Fifteen', activityDate.addDays(635)));
        //Task745Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Sixteen', activityDate.addDays(745)));
        
        return taskList;
    }*/
    
    public static List<Task> upsertARFlow(nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        List<Task> taskList = new List<Task>();
        Date activityDate = system.Today();
        holidayMap = Holidays.getHolidaysMap(); 
        Boolean isAttorney = programInst.Attorney__c;
        
        if(isAttorney){
            taskList.addAll(upsertTask(programInst, 'Check In Call', activityDate.addDays(30), 'Check In Call', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
            taskList.addAll(upsertTask(programInst, 'Strategy Call', activityDate.addDays(90), 'Strategy Call', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
            taskList.addAll(upsertTask(programInst, 'Program Review', activityDate.addDays(180), 'Program Review', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        }
        
        if(!isAttorney){
            taskList.addAll(upsertTask(programInst, '30 Day AR', activityDate.addDays(30), '30 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
            taskList.addAll(upsertTask(programInst, '60 Day AR', activityDate.addDays(60), '60 Day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
            taskList.addAll(upsertTask(programInst, '90 Day AR', activityDate.addDays(90), '90 Day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        }
        //Task30Day..
        /*taskList.addAll(upsertTask(programInst, '30 Day AR', activityDate.addDays(30), 
                                      '30 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task60Day..
        taskList.addAll(upsertTask(programInst, '60 Day AR', activityDate.addDays(60), 
                                      '60 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task90Day..
        taskList.addAll(upsertTask(programInst, '90 Day AR', activityDate.addDays(90), 
                                      '90 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task150Day..
        taskList.addAll(upsertTask(programInst, '150 Day AR', activityDate.addDays(150), 
                                      '150 Day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task180Day..
        taskList.addAll(upsertTask(programInst, '180 Day AR', activityDate.addDays(180), 
                                      '180 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task210Day..
        taskList.addAll(upsertTask(programInst, '210 Day AR', activityDate.addDays(210), 
                                      '210 Day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task240Day..
        taskList.addAll(upsertTask(programInst, '240 Day AR', activityDate.addDays(240), 
                                      '240 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task270Day..
        taskList.addAll(upsertTask(programInst, '270 Day AR', activityDate.addDays(270), 
                                      '270 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task300Day..
        taskList.addAll(upsertTask(programInst, '300 Day AR', activityDate.addDays(300), 
                                      '300 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task300Day..
        taskList.addAll(upsertTask(programInst, '330 Day AR', activityDate.addDays(330), 
                                      '330 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task360Day..
        taskList.addAll(upsertTask(programInst, '360 Day AR', activityDate.addDays(360), 
                                      '360 day AR', taskCommTempIds.get('Pause Account review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));*/
        return taskList;
    }
    
    /*public static List<Task> upsertYear2ARFlow(nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        List<Task> taskList = new List<Task>();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : Date.ValueOf(programInst.CreatedDate) ;
        holidayMap = Holidays.getHolidaysMap(); 
        
        //Task455Day..
        taskList.addAll(upsertTask(programInst, 'AR Y2Q1', activityDate.addDays(455), 
                                      'AR Y2Q1', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task545Day..
        taskList.addAll(upsertTask(programInst, 'AR Y2Q2', activityDate.addDays(545), 
                                      'AR Y2Q2', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task635Day..
        taskList.addAll(upsertTask(programInst, 'AR Y2Q3', activityDate.addDays(635), 
                                      'AR Y2Q3', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task725Day..
        taskList.addAll(upsertTask(programInst, 'AR Y2Q4', activityDate.addDays(725), 
                                      'AR Y2Q4', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
                                      
        return taskList ;
    }*/
    
    /*public static List<Task> createYear3ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        Id taskOwnerId = taskOwnerIdMap.get('Account Review');
        
        //Task820Day..
        taskList.addAll(createTask(programInst, 'AR Y3Q1', activityDate.addDays(820), 
                                      'AR Y3Q1', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task545Day..
        taskList.addAll(createTask(programInst, 'AR Y3Q2', activityDate.addDays(910), 
                                      'AR Y3Q2', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task635Day..
        taskList.addAll(createTask(programInst, 'AR Y3Q3', activityDate.addDays(1000), 
                                      'AR Y3Q3', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task725Day..
        taskList.addAll(createTask(programInst, 'AR Y3Q4', activityDate.addDays(1090), 
                                      'AR Y3Q4', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Client Task for Agents                       
        //Task455Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Seventeen', activityDate.addDays(820)));
        //Task545Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Eighteen', activityDate.addDays(910)));
        //Task635Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Nineteen', activityDate.addDays(1000)));
        //Task745Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty', activityDate.addDays(1090)));
        return taskList;
    }*/
    
    /*public static List<Task> upsertYear3ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        List<Task> taskList = new List<Task>();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        holidayMap = Holidays.getHolidaysMap(); 
        
        //Task820Day..
        taskList.addAll(upsertTask(programInst, 'AR Y3Q1', activityDate.addDays(820), 
                                      'AR Y3Q1', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task545Day..
        taskList.addAll(upsertTask(programInst, 'AR Y3Q2', activityDate.addDays(910), 
                                      'AR Y3Q2', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task635Day..
        taskList.addAll(upsertTask(programInst, 'AR Y3Q3', activityDate.addDays(1000), 
                                      'AR Y3Q3', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task725Day..
        taskList.addAll(upsertTask(programInst, 'AR Y3Q4', activityDate.addDays(1090), 
                                      'AR Y3Q4', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        return taskList;
    }*/
    
    /*public static List<Task> createYear4ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : Date.ValueOf(programInst.CreatedDate) ;
        Id taskOwnerId = taskOwnerIdMap.get('Account Review');
        
        //Task820Day..
        taskList.addAll(createTask(programInst, 'AR Y4Q1', activityDate.addDays(1185), 
                                      'AR Y4Q1', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task545Day..
        taskList.addAll(createTask(programInst, 'AR Y4Q2', activityDate.addDays(1275), 
                                      'AR Y4Q2', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task635Day..
        taskList.addAll(createTask(programInst, 'AR Y4Q3', activityDate.addDays(1365), 
                                      'AR Y4Q3', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task725Day..
        taskList.addAll(createTask(programInst, 'AR Y4Q4', activityDate.addDays(1455), 
                                      'AR Y4Q4', taskCommTempIds.get('Account Review'), taskOwnerId));
        
        //Client Task for Agents                       
        //Task455Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty One', activityDate.addDays(1185)));
        //Task545Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Two', activityDate.addDays(1275)));
        //Task635Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Three', activityDate.addDays(1365)));
        //Task745Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Four', activityDate.addDays(1455)));
        
        return taskList;
    }*/
    
    /*public static List<Task> upsertYear4ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        List<Task> taskList = new List<Task>();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        holidayMap = Holidays.getHolidaysMap(); 
              
        //Task820Day..
        taskList.addAll(upsertTask(programInst, 'AR Y4Q1', activityDate.addDays(1185), 
                                      'AR Y4Q1', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task545Day..
        taskList.addAll(upsertTask(programInst, 'AR Y4Q2', activityDate.addDays(1275), 
                                      'AR Y4Q2', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task635Day..
        taskList.addAll(upsertTask(programInst, 'AR Y4Q3', activityDate.addDays(1365), 
                                      'AR Y4Q3', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task725Day..
        taskList.addAll(upsertTask(programInst, 'AR Y4Q4', activityDate.addDays(1455), 
                                      'AR Y4Q4', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        
        return taskList;
    }*/
    
    /*public static List<Task> createYear5ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        Id taskOwnerId = taskOwnerIdMap.get('Account Review');
        
        //Task820Day..
        taskList.addAll(createTask(programInst, 'AR Y5Q1', activityDate.addDays(1550), 
                                      'AR Y5Q1', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task545Day..
        taskList.addAll(createTask(programInst, 'AR Y5Q2', activityDate.addDays(1640), 
                                      'AR Y5Q2', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task635Day..
        taskList.addAll(createTask(programInst, 'AR Y5Q3', activityDate.addDays(1730), 
                                      'AR Y5Q3', taskCommTempIds.get('Account Review'), taskOwnerId));
        //Task725Day..
        taskList.addAll(createTask(programInst, 'AR Y5Q4', activityDate.addDays(1820), 
                                      'AR Y5Q4', taskCommTempIds.get('Account Review'), taskOwnerId));
        
        //Client Task for Agents                       
        //Task455Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Five', activityDate.addDays(1550)));
        //Task545Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Six', activityDate.addDays(1640)));
        //Task635Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Seven', activityDate.addDays(1730)));
        //Task745Day..
        taskList.add(createClientTask(programInst.Id, 'Account Review Twenty Eight', activityDate.addDays(1820)));
        
        return taskList;
    }*/
    
    /*public static List<Task> upsertYear5ARFlow (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        List<Task> taskList = new List<Task>();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : system.Today();
        holidayMap = Holidays.getHolidaysMap(); 
        
        //Task1550Day..
        taskList.addAll(upsertTask(programInst, 'AR Y5Q1', activityDate.addDays(1550), 
                                      'AR Y5Q1', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task1640Day..
        taskList.addAll(upsertTask(programInst, 'AR Y5Q2', activityDate.addDays(1640), 
                                      'AR Y5Q2', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task1730Day..
        taskList.addAll(upsertTask(programInst, 'AR Y5Q3', activityDate.addDays(1730), 
                                      'AR Y5Q3', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
        //Task1820Day..
        taskList.addAll(upsertTask(programInst, 'AR Y5Q4', activityDate.addDays(1820), 
                                      'AR Y5Q4', taskCommTempIds.get('Account Review'), 'Completed', holidayMap, programIdWithUniqueIdSetMap));
                                      
        return taskList;
    }*/
    
    /*
    public static void AccountReview(List<nu_dse__Program__c> programList) {
    
        try {
            
            Id dataTempRecordTypeId = Schema.SObjectType.nu_dse__Program__c .getRecordTypeInfosByName().get('Data_Temp').getRecordTypeId();
            Map<String, Task> taskToUpsertMap = new Map<String, Task>();
            List<nu_dse__Program__c> programToUpdate = new List<nu_dse__Program__c>();
            Map<String, Id> taskCommTempIds = new Map<String, Id> ();
        
            for (Task_Communication_Template__mdt CommTempCMDT : [SELECT Id, Label, DeveloperName, Communication_Template_Id__c FROM Task_Communication_Template__mdt]) {
            
                taskCommTempIds.put(CommTempCMDT.Label, CommTempCMDT.Communication_Template_Id__c);
            }
            
            
            for (nu_dse__Program__c program : programList) {
                
                if (program.Pause_Account_Review__c == True && program.LastModifiedBy.Attorney_Admin__c == False && program.recordTypeId != dataTempRecordTypeId) {
                        
                    taskToUpsertMap.putAll(FlowLogicsForBatchClass.upsertARFlow(program, taskCommTempIds));
                    taskToUpsertMap.putAll(FlowLogicsForBatchClass.upsertYear2ARFlow(program, taskCommTempIds));
                    taskToUpsertMap.putAll(FlowLogicsForBatchClass.upsertYear3ARFlow(program, taskCommTempIds));
                    taskToUpsertMap.putAll(FlowLogicsForBatchClass.upsertYear4ARFlow(program, taskCommTempIds));
                    taskToUpsertMap.putAll(FlowLogicsForBatchClass.upsertYear5ARFlow(program, taskCommTempIds));
                }
            }
        } catch(Exception e) {
             
             nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'AccountReviewY5V2', nu_dse__User_Context__c = UserInfo.getUserId(),nu_dse__Message__c = e.getMessage());
             insert errorLog;
        }
    }
    
    
    */
    
    public static List<Task> upsertTask (nu_dse__Program__c programInstance, String subject, Date dueDate, String uniqueId, Id commTempId, String status, 
                                                                                Map<String, Holiday> holidayMap, Map<Id, Set<String>> programIdWithUniqueIdSetMap) {
        
        Date activityDate = dueDate; 
        activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        List<Task> taskList = new List<Task>();
        
        if (activityDate != null && activityDate >= system.Today() && (programIdWithUniqueIdSetMap.isEmpty() == True || (programIdWithUniqueIdSetMap.isEmpty() == False &&
                    programIdWithUniqueIdSetMap.get(programInstance.Id).Contains(programInstance.Id + uniqueId) == False))) { 
        
            Task taskInstance = new Task(); 
            taskInstance.subject = subject; 
            taskInstance.ActivityDate = activityDate; 
            taskInstance.Unique_Identifier__c = programInstance.Id + uniqueId;
            taskInstance.nu_dse__Communication_Template__c = commTempId;
            taskInstance.Status = status;
            taskInstance.WhatId = programInstance.Id;
            taskInstance.nu_dse__Is_System_Task__c = true; 
            taskList.add(taskInstance);
        }
        return taskList;
    }
    
    /*public static List<Task> createOption1Task (nu_dse__Program__c programInst, Map<String, Id> taskCommTempIds, Map<String, Id> taskOwnerIdMap) {
        
        List<Task> taskList = new List<Task>();
        Date activityDate = programInst.Attorney__c ? programInst.NDS_CREATED_DATE__c : date.newinstance(programInst.CreatedDate.year(), programInst.CreatedDate.month(), programInst.CreatedDate.day());
        Id taskOwnerId = taskOwnerIdMap.get('Option 1 Legal Task');
        
        //Day1 Email
        taskList.addAll(createTask(programInst, 'Electronic Welcome Package with 2PDFs WP & Contract', activityDate.addDays(0), 
                                      'Electronic Welcome Package', taskCommTempIds.get('Electronic Welcome Package with 2PDFs'), taskOwnerId));
        //Day10 Email
        taskList.addAll(createTask(programInst, 'Understand Your Program', activityDate.addDays(10), 
                                      'Understand Your Program', taskCommTempIds.get('Understand Your Program'), taskOwnerId));
        
        //Day17 Email
        taskList.addAll(createTask(programInst, 'Key To Success', activityDate.addDays(17), 
                                      'Key To Success', taskCommTempIds.get('Key To Success'), taskOwnerId));
        //Day27 Email
        taskList.addAll(createTask(programInst, 'Program Review Call Notification', activityDate.addDays(27), 
                                      'Program Review Call Notification', taskCommTempIds.get('Program Review Call Notification'), taskOwnerId));
        
        
        
        //Task Day37 Email
        taskList.addAll(createTask(programInst, 'Portal Engagement', activityDate.addDays(37), 
                                      'Portal Engagement', taskCommTempIds.get('Portal Engagement'), taskOwnerId));
        //Task Day45 Email
        taskList.addAll(createTask(programInst, 'Working Hard For You', activityDate.addDays(45), 
                                      'Working Hard For You', taskCommTempIds.get('Working Hard For You'), taskOwnerId));
        
        
        //Task Day53 Email
        taskList.addAll(createTask(programInst, 'Here To Help', activityDate.addDays(53), 
                                      'Here To Help', taskCommTempIds.get('Here To Help'), taskOwnerId));
        //Task Day60 Email
        taskList.addAll(createTask(programInst, 'Encouragement', activityDate.addDays(60), 
                                      'Encouragement', taskCommTempIds.get('Encouragement'), taskOwnerId));
                                      
        //Task Day68 Email
        taskList.addAll(createTask(programInst, 'NewsLetter', activityDate.addDays(68), 
                                      'NewsLetter', taskCommTempIds.get('NewsLetter'), taskOwnerId));
        //Task Day72 Email
        taskList.addAll(createTask(programInst, 'Strategy Call Notification', activityDate.addDays(72), 
                                      'Strategy Call Notification', taskCommTempIds.get('Strategy Call Notification'), taskOwnerId));
        
        
        //Task Day90 Email
        taskList.addAll(createTask(programInst, 'Stay on Course', activityDate.addDays(90), 
                                      'Stay on Course', taskCommTempIds.get('Stay on Course'), taskOwnerId));
        //Task Day100 Email
        taskList.addAll(createTask(programInst, 'Communication With Us', activityDate.addDays(100), 
                                      'Communication With Us', taskCommTempIds.get('Communication With Us'), taskOwnerId));
        
        //Task Day110 Email
        taskList.addAll(createTask(programInst, 'You Doing Great', activityDate.addDays(110), 
                                      'You Doing Great', taskCommTempIds.get('You Doing Great'), taskOwnerId));
        //Task Day27 Email
        taskList.addAll(createTask(programInst, 'Program Review Call Notification Text', activityDate.addDays(27), 
                                      'Program Review Call Notification Text', taskCommTempIds.get('Program Review Call Notification Text'), taskOwnerId));
        
        
        //Task Day72 Email
        taskList.addAll(createTask(programInst, 'CS Strategy Call Notification Text', activityDate.addDays(72), 
                                      'CS Strategy Call Notification Text', taskCommTempIds.get('CS Strategy Call Notification Text'), taskOwnerId));
        //Task Day28 Email
        taskList.addAll(createTask(programInst, 'Program Review Call Notification Robo Call', activityDate.addDays(28), 
                                      'Program Review Call Notification Robo Call', taskCommTempIds.get('Program Review Call Notification Robo Call'), taskOwnerId));
        
        //Task Day30 Email
        taskList.addAll(createTask(programInst, 'CS Month 1 Review Call', activityDate.addDays(30), 
                                      'CS Month 1 Review Call', taskCommTempIds.get('CS Month 1 Review Call'), taskOwnerId));
         
        
        //Task Day73 Email
        taskList.addAll(createTask(programInst, 'Strategy Call Notification Robo Call', activityDate.addDays(73), 
                                      'Strategy Call Notification Robo Call', taskCommTempIds.get('Strategy Call Notification Robo Call'), taskOwnerId));
        
        //Task Day75 Email
        taskList.addAll(createTask(programInst, 'CS Strategy Call', activityDate.addDays(75), 
                                      'CS Strategy Call', taskCommTempIds.get('CS Strategy Call'), taskOwnerId));
         
                                                                                               
        return taskList;
    }*/
    
    public static List<Task> createTask (nu_dse__Payment__c paymentInstance, String subject, Date activityDate, String uniqueId, Id commTempId, Id taskOwnerId) {
        
        List<Task> taskList = new List<Task>();
        
        Task taskInstance = new Task();
        taskInstance.WhatId = paymentInstance.Id;
        taskInstance.Subject = subject;
        taskInstance.ActivityDate = activityDate;
        taskInstance.Unique_Identifier__c = paymentInstance.Id + uniqueId;
        taskInstance.nu_dse__Is_System_Task__c = True;
        taskInstance.nu_dse__Communication_Template__c = commTempId;
        
        if (taskOwnerId != null) {
        
            taskInstance.OwnerId = taskOwnerId;
        }
        
        taskList.add(taskInstance);
        
        return taskList;
    }
    
    public static List<Task> createTask (nu_dse__Program__c programInstance, String subject, Date activityDate, String uniqueId, Id commTempId, Id taskOwnerId) {
        
        List<Task> taskList = new List<Task>();
        
        if (activityDate != null  && activityDate >= system.Today()) {
            
            Task taskInstance = new Task();
            taskInstance.WhatId = programInstance.Id;
            taskInstance.Subject = subject;
            taskInstance.ActivityDate = activityDate;
            taskInstance.Unique_Identifier__c = programInstance.Id + uniqueId;
            taskInstance.nu_dse__Is_System_Task__c = True;
            taskInstance.nu_dse__Communication_Template__c = commTempId;
            
            if (taskOwnerId != null) {
        
                taskInstance.OwnerId = taskOwnerId;
            }
            
            taskList.add(taskInstance);
        }
        
        return taskList;
    }
    
    public static Task createClientTask (Id relatedToId, String subject, Date activityDate) {
        
        Task taskInstance = new Task();
        
        if (activityDate != null) {
            
            taskInstance.WhatId = relatedToId;
            taskInstance.Subject = subject;
            taskInstance.ActivityDate = activityDate;
            taskInstance.Call_Type__c = 'Account Review Calls';
            taskInstance.Priority = 'High';
            taskInstance.Status = 'Not Started';
            taskInstance.Clients_task__c = True;
        }
        
        return taskInstance;   
    }
    
}