public class Holidays {
    
    static Map<String, Holiday> staticHolidayMap = new Map<String, Holiday>();
    static Boolean mapContructed = False;
    
    public static String dayOftheWeek(Date day) {
        
        DateTime dayTime = DateTime.newInstance(day.year(), day.month(), day.day());
        String dayOfweek = dayTime.format('EEEE');
        return dayOfweek;
    }
    
    public static String dayOfTheWeek(DateTime day) {
        
        String dayOfweek = day.format('EEEE');
        return dayOfweek; 
    }
    
    public Static List<Holiday> getHolidays() {
        
        List<Holiday> holidayList = [SELECT Id, Name, Description, EndTimeInMinutes, IsAllDay, ActivityDate, 
                                        RecurrenceEndDateOnly, IsRecurrence, RecurrenceMonthOfYear, RecurrenceStartDate,
                                        RecurrenceInstance,RecurrenceDayOfMonth FROM Holiday];
        return holidayList;
    }
    
    public static Map<String, Holiday> getHolidaysMap() {
    
        if (mapContructed == False) {
            
            for (Holiday holiday : [SELECT Id, Name, Description, EndTimeInMinutes, IsAllDay, ActivityDate, 
                                            RecurrenceEndDateOnly, IsRecurrence, RecurrenceMonthOfYear, RecurrenceStartDate,
                                            RecurrenceInstance,RecurrenceDayOfMonth FROM Holiday]) {
            
                if (holiday.IsRecurrence) {
                
                    staticHolidayMap.put(holiday.RecurrenceDayOfMonth + '-' + monthOfTheYear(holiday.RecurrenceMonthOfYear), holiday);
               
                } else {  //if(holiday.ActivityDate > System.today())
                
                    staticHolidayMap.put(holiday.ActivityDate.day() + '-' + holiday.ActivityDate.month(), holiday);
                }
            }
            mapContructed = True;
        }
        return staticHolidayMap;
    }
    
    public static boolean isHolidayOrWeekend(List<Holiday> holidays, Date activityDate) {
        
        Boolean isweekEnd = isWeekEnd(dayOfTheWeek(activityDate));
        
        if(isweekEnd == False) {
            
            for(Holiday h: Holidays) {
                
                if(!h.IsRecurrence) {
                    
                    // if not recurrence then activityDate should match exact holiday date. 
                    if(h.ActivityDate.isSameDay(activityDate)) {
                        
                        return true; 
                    }
                    
                } else{
                    
                    /*
                    System.debug('start date GT activity?: ' + (h.RecurrenceStartDate <= activityDate )); 
                    
                    System.debug('end date LT activity?: '+ (h.recurrenceEndDateOnly <= activityDate)); 
                    
                    System.debug('day matches?: '+ (h.RecurrenceDayOfMonth == activityDate.day()) );
                    
                    System.debug('Month matches' + (monthOfTheYear(h.RecurrenceMonthOfYear) == activityDate.month()) );
                      
                    */
                    
                    // if reOccuring then activityDate should match reoccuring date, consturcted. 
                    
                    if( (h.RecurrenceStartDate !=null && h.RecurrenceStartDate<=activityDate ) && (h.recurrenceEndDateOnly==null || h.recurrenceEndDateOnly >= activityDate )){
                        
                        if((h.RecurrenceDayOfMonth == activityDate.day()) && ( monthOfTheYear(h.RecurrenceMonthOfYear) == activityDate.month()) ){
                            
                           return true; 
                        }
                    }
                }
            }
            
        } else{
            
            return true; 
        }
        
        return false; 
    }
    
   public static integer dayOfTheWeekmask(string day) {
   
       if(day.equalsIgnoreCase('Sunday'))
           return 1;
       else if(day.equalsIgnoreCase('Monday'))
           return 0;
       else if(day.equalsIgnoreCase('Tuesday'))
           return 0;       
       else if(day.equalsIgnoreCase('Wednesday'))
           return 0;       
       else if(day.equalsIgnoreCase('Thursday'))
           return 0;
       else if(day.equalsIgnoreCase('Friday'))
           return 0;
       else if(day.equalsIgnoreCase('Saturday'))   
           return 2;
       return null;
   }  
   
   public static integer holidaysInWeekDays(String day) {
   
       if(day.equalsIgnoreCase('Sunday'))
           return 1;
       else if(day.equalsIgnoreCase('Monday'))
           return 1;
       else if(day.equalsIgnoreCase('Tuesday'))
           return 1;       
       else if(day.equalsIgnoreCase('Wednesday'))
           return 1;       
       else if(day.equalsIgnoreCase('Thursday'))
           return 1;
       else if(day.equalsIgnoreCase('Friday'))
           return 3;
       else if(day.equalsIgnoreCase('Saturday'))   
           return 2;
       return null;
   }
    
   public static boolean isWeekEnd(String day) {
         
        if(dayOfTheWeekmask(day)==1|| dayOfTheWeekmask(day)==2) {
            
            return true;
            
        } else{
            
            return false; 
        }
    }
    
    public Static integer monthOfTheYear(String month) {
        
        if(month.equalsIgnoreCase('January')) return 01; 
         if(month.equalsIgnoreCase('February')) return 02; 
         if(month.equalsIgnoreCase('March')) return 03; 
         if(month.equalsIgnoreCase('April')) return 04; 
         if(month.equalsIgnoreCase('May')) return 05; 
         if(month.equalsIgnoreCase('June')) return 06; 
         if(month.equalsIgnoreCase('July')) return 07; 
         if(month.equalsIgnoreCase('August')) return 08; 
         if(month.equalsIgnoreCase('September')) return 09; 
         if(month.equalsIgnoreCase('October')) return 10; 
         if(month.equalsIgnoreCase('November')) return 11; 
         if(month.equalsIgnoreCase('December')) return 12; 
        
        return null; 
    }

    
    public static Date getNextWorkingDay(List<Holiday> holidays, Date activityDate) {
        
        return null; 
    }
    
    public static Date getNextWorkingDay(Map<String, Holiday> holidayMap, Date currentDate) {
        
        Boolean daysIncremented = True;
        
        do {
            
            daysIncremented = False;
            
            if (holidayMap.containsKey(currentDate.day() + '-' + currentDate.month())) {
            
                Holiday holidayRec = holidayMap.get(currentDate.day() + '-' + currentDate.month());
            
                if ((holidayRec.IsRecurrence && (holidayRec.RecurrenceStartDate != null && holidayRec.RecurrenceStartDate <= currentDate)
                        && (holidayRec.recurrenceEndDateOnly == null || holidayRec.recurrenceEndDateOnly >= currentDate))
                        || (holidayRec.IsRecurrence == False && holidayRec.ActivityDate.isSameDay(currentDate))) {
                
                    currentDate = currentDate.addDays(1);
                    daysIncremented = True;
                }
            } 
    
            Date weekStart  = currentDate.toStartofWeek();
            Integer numofDayToAdd = weekStart.daysBetween(currentDate) == 6 ? 2 : weekStart.daysBetween(currentDate) == 0 ? 1 : 0;
            currentDate = currentDate.addDays(numofDayToAdd);
            daysIncremented = numofDayToAdd == 0?False:True;
            
        } while(daysIncremented == True? holidayMap.containsKey(currentDate.day() + '-' + currentDate.month()) : False);
        return currentDate;
    }
    
    //Changed when communication handler uses phone number from program
    public Date getNextWorkingDay(Map<String, Holiday> holidayMap, Date currentDate, Boolean considerWeekEnd, Boolean considerHolidays) {
        
        Boolean daysIncremented;
        
        do {
            
            daysIncremented = False;
            
            if (considerHolidays == True && holidayMap.containsKey(currentDate.day() + '-' + currentDate.month())) {
            
                Holiday holidayRec = holidayMap.get(currentDate.day() + '-' + currentDate.month());
            
                if ((holidayRec.IsRecurrence && (holidayRec.RecurrenceStartDate != null && holidayRec.RecurrenceStartDate <= currentDate)
                        && (holidayRec.recurrenceEndDateOnly == null || holidayRec.recurrenceEndDateOnly >= currentDate))
                        || (holidayRec.IsRecurrence == False && holidayRec.ActivityDate.isSameDay(currentDate))) {
                
                    currentDate = currentDate.addDays(1);
                    daysIncremented = True;
                }
            } 
    
            if (considerWeekEnd == True) {
                
                Date weekStart  = currentDate.toStartofWeek();
                Integer numofDayToAdd = weekStart.daysBetween(currentDate) == 6 ? 2 : weekStart.daysBetween(currentDate) == 0 ? 1 : 0;
                currentDate = currentDate.addDays(numofDayToAdd);
                daysIncremented = numofDayToAdd == 0?False:True;
            }
            
        } while(daysIncremented == True? holidayMap.containsKey(currentDate.day() + '-' + currentDate.month()) : False);
        return currentDate;
    }
}