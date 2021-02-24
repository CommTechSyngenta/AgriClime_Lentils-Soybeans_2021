/*********************************************************************************************
* Apex Class Name    :     WebsiteAccountHandler
* Version            :     1.0
* Created Date       :     06-Jan-2020
* Function           :     This is class is used to deserialize the JSON data coming into website account object on agriclime registration to send out an auto responder through pardot.
* Modification Log
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Aakash                    06-Jan-2020            Created
***********************************************************************************************/
 public with sharing class WebsiteAccountHandler {
    /********************************************************************************************
* Method   : farmWrapperCalling
* Description: Method to call farm wrapper class to deserialize the JSON data coming into webstie account   
* ------------------------------------------------------------------------------------------
* Date          Name                    Modification Description
* ------------------------------------------------------------------------------------------
* 06-Jan-2020 Aakash                          Created  
********************************************************************************************/
    
    public static void farmWrapperCalling(Set<id> triggernew, Map<Id, wint__Website_Account__c> weboldMap){
        FarmWrapper farmtest;
        Map<Id,Contact> conList = new Map<Id,Contact>();
        Map<Id, Programs__c> ProgramMap = new Map<Id, Programs__c>();
        List<wint__Website_Account__c> tempwebAcc = [SELECT id,wint__Contact__c,wint__Campaign__c, wint__Contact2__c, wint__Email__c, wint__Lead__c,wint__Any__c,wint__ReferenceNo__c,wint__FirstName__c,wint__LastName__c,wint__Company__c, wint__Street__c,wint__City__c, wint__Street2__c,wint__PostalCode__c, wint__State__c, wint__FarmName__c  FROM wint__Website_Account__c WHERE id IN :triggernew];      
        system.debug('Testing if it is taking contact data');
        Set<Id> setOfContactIds = new Set<Id>();
        Double totalCommittedArea;
        for(wint__Website_Account__c w : tempwebAcc){        
            if(w.wint__Contact__c != null || w.wint__Lead__c != null ){
                System.debug('Testing if it is entering into tempwebAcc');
                List <Contact> listofContacts = [SELECT id, AgriclimeProgramDetails__c,AgriclimeLentilsProgramDetails__c, Account.Id, Account.BillingState, (SELECT id, Vibrance_Maxx_RFC_Committed__c,Soybean_Variety_1_Committed__c, Soybean_Variety_2_Committed__c, Soybean_Variety_3_Committed__c, Soybean_Variety_4_Committed__c, Soybean_Variety_5_Committed__c,Soybean_Variety_6_Committed__c, Soybean_Variety_7_Committed__c, Soybean_Variety_8_Committed__c,Cruiser_Maxx_Vibrance_Beans_Committed__c, VibranceMaxx_RFC_AgriClime_Lentils__c, VibranceMaxx_RTA_Agriclime_Lentils__c,VibranceMaxx_Intego_Agriclime_Lentils__c,Elatus_AgriClime_Lentils__c FROM Programs__r) FROM Contact WHERE id =: w.wint__Contact__c ];
                
                List<Lead> LeadId = [SELECT id, Name, Email FROM Lead WHERE id =: w.wint__Lead__c ];
                List<Campaign> campaigns = new List<Campaign>();
                List<CampaignMember> members = new List<CampaignMember>(); 
                List<Programs__c> listofPrograms = new List<Programs__c>();
                Id agriClimeRecordTypeId = Schema.SObjectType.Programs__c.getRecordTypeInfosByName().get('AgriClime Soybeans').getRecordTypeId();
                Id agriClimeLentilsRecordTypeId = Schema.SObjectType.Programs__c.getRecordTypeInfosByName().get('AgriClime Lentils').getRecordTypeId();                
                farmtest = (FarmWrapper)JSON.deserialize(w.wint__Any__c, FarmWrapper.class); 
                //Map<Id,Contact> conList = new Map<Id,Contact>();
                Map<Id,Lead> leadList = new Map<Id, Lead>();
                Double Area = 0;
                Double potentialCashback = 0;
                Double committedPurchase = 0;                
                //if(Trigger.isInsert)
                //{
                    for(Contact e: listofContacts){
                        //system.debug('Testing if it is taking contact data' +e.Name);
                        if(w.wint__Campaign__c == 'Canada_Soy_Manitoba_2021' || w.wint__Campaign__c == 'Canada_Soy_Saskatchewan_2021'){ 
                         e.AgriclimeProgramDetails__c = ('');
                        campaignMember soybeansMember = new CampaignMember(CampaignId  = '7013m000001dDv6', ContactId = e.Id, Status = 'Registered');
                        database.insert (soybeansMember,false); 
                        }
                        if(w.wint__Campaign__c == 'Canada Lentil'){
                        e.AgriclimeLentilsProgramDetails__c = ('');
                        campaignMember lentilsMember = new CampaignMember(CampaignId  = '7013m000001dDvB', ContactId = e.Id, Status = 'Registered');
                        database.insert (lentilsMember,false);
                        }                       
                        
                 }
                 
                    String title = farmtest.campaign.title;
                    system.debug('title is' +title);
                    
                    String season = farmtest.campaign.season;
                    system.debug('Season is' +season);
                 
                for(FarmWrapper.cls_farms fm : farmtest.farms){
                    String farmName = (fm.name !=null ? fm.name : '*No Field Name Specified*'); //fm.name;
                    Integer committedArea = fm.committedArea.intValue();
                    Area += committedArea;
                    String commitedAreaUoM = fm.commitedAreaUoM;                    
                    Decimal CashBack = fm.potentialCashback.setScale(2);
                    potentialCashback += CashBack;
                    String pc = potentialCashback.format();                    
                    String StartPayout = fm.weatherGuarantee;
                    //String actualCashbackCurrency = fm.currency;
                    double lattitude = (Double)fm.gridCell.location.lat;                    
                    double longitude = (Double)fm.gridCell.location.lng;                   
                    Decimal committedSpend = fm.committedSpend.setScale(2);
                    committedPurchase +=committedSpend;
                    String compspend = committedPurchase.format();
                    //String committedSpendCurrency = fm.currency;
                    List<String> productLabel = new List<String>();
                    List<String> productDetails = new List<String>();
                    List<String> seedcareDetails = new List<String>();
                    List<String> varietyDetails = new List<String>();
                    String weGuarantee = fm.weatherGuarantee;
                    String threshold = weGuarantee.substringBetween('if the rainfall during the selected guarantee period is below ', 'mm, up to a maximum payout of 30 % of the qualifying AgriClime purchases, if the rainfall is at or below');                   
                    String thresholdCashback = weGuarantee.substringAfter(' up to a maximum payout of 30 % of the qualifying AgriClime purchases, if the rainfall is at or below ');
                    String Prodslabel;
                    String prodsAmount;                   
                    String startPeriods;
                    Integer periodDuration;
                    for(FarmWrapper.cls_purchaseList purchase : fm.purchaseList){
                        String prdLabel = purchase.productLabel;
                        Double quantity = purchase.quantity;
                        Decimal price = purchase.price;
                        Decimal amts = (price*quantity).setScale(2);
                        //String amounts = (amount*quantity).format();
                        String prices = amts.format();						                        
                        String quantityUoM = purchase.quantityUoM;
                        String priceCurrency = purchase.priceCurrency;
                        //String prdDetails = prdLabel +','+' '+ '$'+ amounts +' '+amountCurrency;
                        String prdDetails = prdLabel +','+' '+ '$'+ prices +' '+'CAD'; 
                        productDetails.add(prdDetails);
                        if(prdLabel == 'CruiserMaxx Vibrance beans' || prdLabel == 'VibranceMaxx RFC'){
                            String purchaseSeedCareSummary = prdLabel + ','+quantity;
                            seedcareDetails.add(purchaseSeedCareSummary);
                        }
                        else{
                            String purchaseVarietySummary = prdLabel + ',' +quantity;
                            varietyDetails.add(purchaseVarietySummary);
                        }

                    }
                    
                    for(FarmWrapper.cls_riskPeriodList Periods : fm.riskPeriodList){
                        Date startDate = Periods.start;
                        Integer duration = Periods.duration;
                        periodDuration = duration;
                        Date EndDate = startDate.addDays(duration);                       
                        startPeriods = String.valueOf(startDate).removeEnd('00:00:00');                      
                    }                     
                    for(Contact d : listofContacts){ 
                        if(title == 'Canada_Soy_Manitoba_2021' || title == 'Canada_Soy_Saskatchewan_2021'){                        
                        //d.AgriclimeRefNumber__c = '<span style="font-size:18px;">Your Program Reference: <strong>' +w.wint__ReferenceNo__c+ '</strong>';
                        d.AgriclimeName__c = '<span style="font-size:18px;">Name: <strong>' +w.wint__FirstName__c + ' ' +w.wint__LastName__c+ '</strong>';
                        //d.AgriclimeCompanyName__c = '<span style="font-size:18px;">Company Name: <strong>' +w.wint__Company__c+ '</strong>';
						d.AgriclimeActualCashback__c = '<span style="font-size:18px;"><strong>Potential Cash Back Amount: ' +'$' +pc+' '+'CAD' +'</strong>';                        
                        d.AgriclimeCommittedSpend__c = '<span style="font-size:18px;"><strong>Total Committed Purchases: ' +'$' +compspend+'&nbsp;CAD</strong>';                           
                        d.AgriclimeProgramDetails__c += '<span style="font-size:20px;"><span style="color:#71840a;">Field: <strong>'+farmName+'</strong></span></span><br> <span style="font-size:18px;">Longitude: <strong>'+longitude+'</strong><br> Latitude: <strong>'+lattitude+'</strong><br> &nbsp;<br> <strong>Program&nbsp;Details</strong><br> Risk Period:</span></p> <ul> <li><span style="font-size:18px;">Start date: <strong>'+startPeriods+'</strong>, duration <strong>'+periodDuration+ '&nbsp;days</strong></span></li> </ul> <span style="font-size:18px;">Weather Guarantee:</span> <ul> <li><span style="font-size:18px;"><strong>Rainfall Threshold:'+' '+threshold+' &nbsp;mm</strong></span></li> <li><span style="font-size:18px;"><strong>Rainfall Threshold Exit (30% Cash-Back):'+' '+thresholdCashback+'</strong></span></li> </ul> <span style="font-size:18px;">Committed Area:</span><ul> <li><span style="font-size:18px;"><strong>'+String.valueOf(committedArea)+ '&nbsp;Acres</strong></span></ul></li><span style="font-size:18px;">Committed&nbsp;Product&nbsp;Details<span style="font-size:18px;"><ul> <strong>';                                                
                        d.AgriclimeStatus__c = 'Unsend';
                        d.AgriclimeCommittedArea__c = '<span style="font-size:18px;"><strong>Total Committed Area: ' +Area+ '&nbsp;Acres</strong><br>';                        
                        for(String p: productDetails){
                            d.AgriclimeProgramDetails__c +='<li>'+p+'<span style="font-size:18px;">';
                            d.AgriclimeProgramDetails__c +='<br>';
                        }                         
                        d.AgriclimeProgramDetails__c +='</strong></span></li> </ul> <p><span style="font-size:18px;"><strong></strong><br></span>';                        
                        //System.debug(+d.Programs.Id);
                     }
                        else if(title == 'Canada Lentil'){
                            d.AgriclimeName__c = '<span style="font-size:18px;">Name: <strong>' +w.wint__FirstName__c + ' ' +w.wint__LastName__c+ '</strong>';
                            d.AgriclimeLentilsCommittedArea__c = '<span style="font-size:18px;"><strong>Total Committed Area: ' +Area+ '&nbsp;Acres</strong><br>';
                            d.AgriclimeLentilsCommittedSpend__c = '<span style="font-size:18px;"><strong>Total Committed Purchases: ' +'$' +compspend+'&nbsp;CAD</strong>';
                            d.AgriclimeLentilsPotentialCashback__c = '<span style="font-size:18px;"><strong>Potential Cash Back Amount: ' +'$' +pc+' '+'CAD' +'</strong>';
                            d.AgriclimeLentilsProgramDetails__c += '<span style="font-size:20px;"><span style="color:#71840a;">Field: <strong>'+farmName+'</strong></span></span><br> <span style="font-size:18px;">Longitude: <strong>'+longitude+'</strong><br> Latitude: <strong>'+lattitude+'</strong><br> &nbsp;<br> <strong>Program&nbsp;Details</strong><br> Risk Period:</span></p> <ul> <li><span style="font-size:18px;">Start date: <strong>'+startPeriods+'</strong>, duration <strong>'+periodDuration+ '&nbsp;days</strong></span></li> </ul> <span style="font-size:18px;">Weather Guarantee:</span> <ul> <li><span style="font-size:18px;"><strong>Rainfall Threshold:'+' '+threshold+' &nbsp;mm</strong></span></li> <li><span style="font-size:18px;"><strong>Rainfall Threshold Exit (30% Cash-Back):'+' '+thresholdCashback+'</strong></span></li> </ul> <span style="font-size:18px;">Committed Area:</span><ul> <li><span style="font-size:18px;"><strong>'+String.valueOf(committedArea)+ '&nbsp;Acres</strong></span></ul></li><span style="font-size:18px;">Committed&nbsp;Product&nbsp;Details<span style="font-size:18px;"><ul> <strong>';                                                                                               
                            for(String p: productDetails){
                                d.AgriclimeLentilsProgramDetails__c +='<li>'+p+'<span style="font-size:18px;">';
                                d.AgriclimeLentilsProgramDetails__c +='<br>';
                                }
                        }
                        conList.put(d.Id,d);
                        setOfContactIds.add(d.Id);                          
                    } 
                       if(conList.size()>0 && (title == 'Canada_Soy_Manitoba_2021' || title == 'Canada_Soy_Saskatchewan_2021')){ 
                        List<Programs__c> listofUpdatePrograms = [SELECT id, Contact__r.Id, Vibrance_Maxx_RFC_Committed__c,Soybean_Variety_1_Committed__c, Soybean_Variety_2_Committed__c, Soybean_Variety_3_Committed__c, Soybean_Variety_4_Committed__c, Soybean_Variety_5_Committed__c,Soybean_Variety_6_Committed__c, Soybean_Variety_7_Committed__c, Soybean_Variety_8_Committed__c,Cruiser_Maxx_Vibrance_Beans_Committed__c,VibranceMaxx_RFC_AgriClime_Lentils__c, VibranceMaxx_RTA_Agriclime_Lentils__c, VibranceMaxx_Intego_Agriclime_Lentils__c, Elatus_AgriClime_Lentils__c FROM Programs__c WHERE Contact__r.Id IN : conList.keySet() AND RecordTypeId = :agriClimeRecordTypeId];
                       
                        if(listofUpdatePrograms.Size() > 0 ){
                     
                        for(Programs__c updatedprogramRecord : listofUpdatePrograms){
                        updatedprogramRecord.Soybean_Variety_1_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_2_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_3_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_4_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_5_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_6_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_7_Committed__c = null;
                        updatedprogramRecord.Soybean_Variety_8_Committed__c = null;
                        updatedprogramRecord.Cruiser_Maxx_Vibrance_Beans_Committed__c = null;
                        updatedprogramRecord.Vibrance_Maxx_RFC_Committed__c = null;
                        updatedprogramRecord.Total_Committed_Acres__c = Area;
                        for(FarmWrapper.cls_purchaseSummaryList purchaseSummary : farmtest.purchaseSummaryList){
                            String summaryProduct = purchaseSummary.productLabel;
                            Double quantity = purchaseSummary.quantity;

                         System.debug('Testing if it is entering into purchase summary for program record');
                        if (summaryProduct == 'S001-D8X ') {
                        
                        updatedprogramRecord.Soybean_Variety_1_Committed__c = quantity;

                        } 
                    
                         if(summaryProduct == 'S003-Z4X '){
                        
                         updatedprogramRecord.Soybean_Variety_2_Committed__c = quantity;
                        }
                    
                     if(summaryProduct == 'S005-C9X '){
                        
                        updatedprogramRecord.Soybean_Variety_3_Committed__c = quantity;
                        }
                    
                        if(summaryProduct == 'S006-M4X '){
                        //programRecord.Soybean_Variety_4__c = 'S006-M4X';
                        updatedprogramRecord.Soybean_Variety_4_Committed__c = quantity;
                         }
                   
                        if(summaryProduct == 'S007-A2XS'){
                        //programRecord.Soybean_Variety_5__c ='S007-A2XS';
                        updatedprogramRecord.Soybean_Variety_5_Committed__c = quantity;
                        }
                    
                        if(summaryProduct == 'S007-Y4 '){
                        //programRecord.Soybean_Variety_6__c ='S007-Y4';
                        updatedprogramRecord.Soybean_Variety_6_Committed__c = quantity;
                         }
                    
                        if(summaryProduct == 'S0009-F2X '){
                        
                        updatedprogramRecord.Soybean_Variety_7_Committed__c = quantity;
                         }
                    
                        if(summaryProduct == 'S0009-M2'){
                        
                        updatedprogramRecord.Soybean_Variety_8_Committed__c = quantity;
                        }
                   
                    
                        if(summaryProduct == 'CruiserMaxx Vibrance beans '){
                        
                        updatedprogramRecord.Cruiser_Maxx_Vibrance_Beans_Committed__c = quantity;
                        }
                   
                        if(summaryProduct == 'VibranceMaxx RFC '){
                       
                        updatedprogramRecord.Vibrance_Maxx_RFC_Committed__c = quantity;
                         }
                 
                    
                         } ProgramMap.put(updatedprogramRecord.Id, updatedprogramRecord);
                        } 
                            update listofUpdatePrograms;
                     }
                    }
                    if(conList.size()>0 && title == 'Canada Lentil'){ 
                        List<Programs__c> listofUpdatePrograms = [SELECT id, Contact__r.Id, Vibrance_Maxx_RFC_Committed__c,Soybean_Variety_1_Committed__c, Soybean_Variety_2_Committed__c, Soybean_Variety_3_Committed__c, Soybean_Variety_4_Committed__c, Soybean_Variety_5_Committed__c,Soybean_Variety_6_Committed__c, Soybean_Variety_7_Committed__c, Soybean_Variety_8_Committed__c,Cruiser_Maxx_Vibrance_Beans_Committed__c,VibranceMaxx_RFC_AgriClime_Lentils__c, VibranceMaxx_RTA_Agriclime_Lentils__c, VibranceMaxx_Intego_Agriclime_Lentils__c, Elatus_AgriClime_Lentils__c ,AgriClime_Lentils_Total_Committed_Acres__c FROM Programs__c WHERE Contact__r.Id IN : conList.keySet() AND RecordTypeId = :agriClimeLentilsRecordTypeId];
                       
                        if(listofUpdatePrograms.Size() > 0 ){
                             for(Programs__c updatedprogramRecord : listofUpdatePrograms){
                                 updatedprogramRecord.VibranceMaxx_RFC_AgriClime_Lentils__c = null;
                                 updatedprogramRecord.VibranceMaxx_RTA_Agriclime_Lentils__c = null;
                                 updatedprogramRecord.VibranceMaxx_Intego_Agriclime_Lentils__c = null;
                                 updatedprogramRecord.Elatus_AgriClime_Lentils__c = null;
                                 updatedprogramRecord.AgriClime_Lentils_Total_Committed_Acres__c = Area;
                             
                             for(FarmWrapper.cls_purchaseSummaryList purchaseSummary : farmtest.purchaseSummaryList){
                                String summaryProduct = purchaseSummary.productLabel;
                                Double quantity = purchaseSummary.quantity;
                                if (summaryProduct == 'VibranceMaxx RFC') {
                                    //programRecord.Soybean_Variety_1__c = 'S001-D8X ';
                                    updatedprogramRecord.VibranceMaxx_RFC_AgriClime_Lentils__c = quantity;
            
                                } 
                                
                                if(summaryProduct == 'VibranceMaxx RTA'){
                                    
                                    updatedprogramRecord.VibranceMaxx_RTA_Agriclime_Lentils__c = quantity;
                                }
                                
                                if(summaryProduct == 'VibranceMaxx Intego'){
                                    
                                    updatedprogramRecord.VibranceMaxx_Intego_Agriclime_Lentils__c = quantity;
                                }
                                
                                if(summaryProduct == 'Elatus'){
                                    
                                    updatedprogramRecord.Elatus_AgriClime_Lentils__c = quantity;
                                }                           
                            } ProgramMap.put(updatedprogramRecord.Id, updatedprogramRecord);
                         }
                         update listofUpdatePrograms;
                        }
                     }
                    if(Area != null){
                        totalCommittedArea = Area;
                    }
                } 
                
                
                for(Contact programContact : listofContacts){                   
                    if(Trigger.isInsert || (weboldMap.get(w.id).wint__Contact__c == null && w.wint__Contact__c <> null) ){ 
                      //if(Trigger.isInsert){ 
                    Programs__c programRecord = new Programs__c();
                   
                    if(title == 'Canada_Soy_Manitoba_2021' || title == 'Canada_Soy_Saskatchewan_2021'){
                    programRecord.Program_Reference__c = +w.wint__ReferenceNo__c;
                    programRecord.Account__c = programContact.Account.Id;
                    programRecord.Contact__c = programContact.Id;
                    programRecord.RecordtypeId = agriClimeRecordTypeId;
                    programRecord.Total_Committed_Acres__c =totalCommittedArea;
                    programRecord.Province__c = programContact.Account.BillingState;
                    listofPrograms.add(programRecord);
                    
                    for(FarmWrapper.cls_purchaseSummaryList purchaseSummary : farmtest.purchaseSummaryList){
                        String summaryProduct = purchaseSummary.productLabel;
                        Double quantity = purchaseSummary.quantity;
                        if (summaryProduct == 'S001-D8X ') {
                            //programRecord.Soybean_Variety_1__c = 'S001-D8X ';
                            programRecord.Soybean_Variety_1_Committed__c = quantity;
    
                        } 
                        
                        if(summaryProduct == 'S003-Z4X '){
                            
                            programRecord.Soybean_Variety_2_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'S005-C9X '){
                            
                            programRecord.Soybean_Variety_3_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'S006-M4X '){
                            
                            programRecord.Soybean_Variety_4_Committed__c = quantity;
                        }
                      
                        if(summaryProduct == 'S007-A2XS'){
                            
                            programRecord.Soybean_Variety_5_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'S007-Y4 '){
                            //programRecord.Soybean_Variety_6__c ='S007-Y4';
                            programRecord.Soybean_Variety_6_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'S0009-F2X '){
                            
                            programRecord.Soybean_Variety_7_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'S0009-M2'){
                            
                            programRecord.Soybean_Variety_8_Committed__c = quantity;
                        }
                        
                        
                        if(summaryProduct == 'CruiserMaxx Vibrance beans '){
                            
                            programRecord.Cruiser_Maxx_Vibrance_Beans_Committed__c = quantity;
                        }
                        
                        if(summaryProduct == 'VibranceMaxx RFC '){
                            
                            programRecord.Vibrance_Maxx_RFC_Committed__c = quantity;
                        }
                           
                    } 
                    //programRecord.Total_Committed_Acres__c = programRecord.Area;
                    }
                    
                    if(title == 'Canada Lentil'){
                    programRecord.AgriClime_Lentils_Program_Reference__c = +w.wint__ReferenceNo__c;
                    programRecord.Account__c = programContact.Account.Id;
                    programRecord.Contact__c = programContact.Id;
                    programRecord.RecordtypeId = agriClimeLentilsRecordTypeId;
                    programRecord.AgriClime_Lentils_Total_Committed_Acres__c =totalCommittedArea;
                    programRecord.Province__c = programContact.Account.BillingState;
                    listofPrograms.add(programRecord);
                    
                    for(FarmWrapper.cls_purchaseSummaryList purchaseSummary : farmtest.purchaseSummaryList){
                        String summaryProduct = purchaseSummary.productLabel;
                        Double quantity = purchaseSummary.quantity;
                        if (summaryProduct == 'VibranceMaxx RFC') {
                            //programRecord.Soybean_Variety_1__c = 'S001-D8X ';
                            programRecord.VibranceMaxx_RFC_AgriClime_Lentils__c = quantity;
    
                        } 
                        
                        if(summaryProduct == 'VibranceMaxx RTA'){
                            
                            programRecord.VibranceMaxx_RTA_Agriclime_Lentils__c = quantity;
                        }
                        
                        if(summaryProduct == 'VibranceMaxx Intego'){
                            
                            programRecord.VibranceMaxx_Intego_Agriclime_Lentils__c = quantity;
                        }
                        
                        if(summaryProduct == 'Elatus'){
                            
                            programRecord.Elatus_AgriClime_Lentils__c = quantity;
                        }                           
                    } 

                    }                            
                }
            }
                Insert ListofPrograms;
                for(Lead ld : LeadId){
                    if(w.wint__Email__c != null){
                        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                        list<String> toAddresses = new List<String>{'aakash.sidana@syngenta.com'};
                        singleMail.setToAddresses(toAddresses);
                        singleMail.setSubject('Lead needs to be converted for :'+' ' +ld.Name);
                        singleMail.setPlainTextBody('Please convert this lead to send out registration email to: ' +'<a href=' +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ld.Id+' >'+ ld.Name+'</a> <br/>' + '<br>' + 'Email  address:</b>' +' '+ ld.Email);
                        //singleMail.setHtmlBody('Please convert this lead to send out registration email to: <b> ' +ld.Name + '<br>' + 'Email  address:</b>' + ld.Email);
                        singleMail.setHtmlBody('Please convert this lead to send out registration email to: <b> ' +'<a href=' +System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ld.Id+' >'+ ld.Name+'</a> <br/>' + '<br>' + 'Email  address :</b>' +' '+ ld.Email);
                        Messaging.sendEMail(new Messaging.SingleEmailMessage[]{singleMail});
                        //system.debug('lead is' +ld);
                    }
                } 
            } 
            
        }  
        update conList.values();
    } 
}