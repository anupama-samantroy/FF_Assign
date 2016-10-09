/* Class Name  : BouquetBuilderExtController 
* Description  : Extension Controller class for the BouquetBuilder page                
* Created By   : Developer 1     
* Created Date : 24-09-2016
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              24-09-2016           1000                   Initial Version
*/
public with sharing class BouquetBuilderExtController {
    
    //to hold the instance of the Bouquet to be created or edited
    public Bouquet__c bouquetRec {get; set;}
    
    //to hold the List of flowers to be displayed in the Flowers section
    public List<FlowerWrapper> lstFlowerWrapper {get; set;}
    
    //to hold the selected flower family
    public String selectedFlowerFamily {get; set;}
        
    //to hold the previous selected flower family
    public String prevSelectedFlowerFamily {get; set;}
    
    //to identify if new or existing bouquet
    public Boolean isEdit {get; set;}
    
    //to hold the Color set for the Pie Chart
    public String colourSet {get; set;}
    
    //to hold the total Cost of the Bouquet
    public Decimal totalCost {get; set;}
    
    //to hold the Blooms to be deleted 
    public Map<Id,Bloom__c> mapBloomToDelete {get; set;}
    
    //to hold the details of Blooms to be saved vs the Flower Id
    public Map<Id,Bloom__c> mapBloomToSave {get; set;}
    
    //to hold the details of Blooms to be Used in the Pie Chart
    public Map<Id,Bloom__c> mapBloomForChart {get; set;}
    
    //to hold the Flower details
    public Map<Id,Product2> mapFlower {get; set;} 
    
    //to hold the HTML color code for the flower color
    public Map<String,String> mapHTMLColor {get;set;}
    
    //standard set controller to implement pagination
    ApexPages.StandardSetController ssc ;
        
    //to hold number of record didsplayed on page
    private integer pageSize; 
    
    //CONSTRUCTOR
    public BouquetBuilderExtController(ApexPages.StandardController controller) {        
        
        //INITIALIZE all properties
        lstFlowerWrapper = new List<FlowerWrapper>();
        mapBloomToDelete = new Map<Id, Bloom__c>();
        mapBloomToSave = new Map<Id, Bloom__c>();
        mapFlower  = new Map<Id,Product2>();
        mapHTMLColor = new Map<String,String>();
        mapBloomForChart = new Map<Id,Bloom__c>();
        
        colourSet ='' ;
        totalCost = 0 ;
        pageSize = Integer.valueOf(System.Label.BouquetBuilderPageSize);
        
        //get the details of the existing Bouquet in case of edit
        if(controller.getId() != NULL){
            
            this.bouquetRec = (Bouquet__c) controller.getRecord();       
            bouquetRec = [SELECT Id, Name, Customer__c, Delivery_Date__c, Deliver_To__c, Message__c                              
                              FROM Bouquet__c
                          WHERE Id =: bouquetRec.Id ];
            
            isEdit = TRUE;
        }else{
            
            //initialize new bouquet record
            bouquetRec = new Bouquet__c();
            
            //populate the parent customer Id
            String sCustomerId = ApexPages.currentPage().getParameters().get(Label.CustomerFieldId);
            
            if(!String.isBlank(sCustomerId)){
            
                bouquetRec.Customer__c = sCustomerId;
            }
            isEdit = FALSE;    
        }
             
        //populate the flower details
        fetchFlowers();
    }  
    
    /**
    *   @author         Developer 1
    *   @description    To get the Flower Family Options
    *   @return         List<SelectOption>
    *   @parameters     None
    **/
    public List<SelectOption> getFlowerFamilyOptions(){
        
        List<SelectOption> lstOptions = new List<SelectOption>();
        
        //Add the Any type option 
        lstOptions.add(new SelectOption('','--Any Type--'));
        
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();           
       
        for( Schema.PicklistEntry f : ple){ 
            
            lstOptions.add(new SelectOption(f.getLabel(),f.getLabel()));    
        }
        
        return lstOptions;
    }
    
    /**
    *   @author         Developer 1
    *   @description    To get the Flowers to be shown on the Bouquet Builder
    *   @return         None
    *   @parameters     None
    **/
    public void fetchFlowers(){  
          
        String strQry = '';
        
        if(!isEdit){
        	
            //if new Bouquet then get all Flowers
            strQry = 'SELECT Id, Name, Family, IsActive, Color__c, Cost__c, HTML_Color_Code__c, Inventory_Remaining__c  FROM Product2';             
        }else{
            
            //get flowers and the Blooms for the Bouquet
            strQry = 'SELECT Id, Name, Family, IsActive, Color__c, Cost__c, HTML_Color_Code__c, Inventory_Remaining__c,  '+
                     ' (SELECT Id, Quantity__c,Flower__c FROM Blooms__r WHERE Bouquet__c = \'' + bouquetRec.Id + '\')' + 
                     ' FROM Product2';                     
        }
        
        //if Flower family is selected 
        if(selectedFlowerFamily != null){
        
            strQry += ' WHERE Family = \'' +  selectedFlowerFamily + '\'';       
        }
        
        //set the Default Order
        strQry += ' ORDER BY Cost__c, Color__c';
        
        
        List<Product2> lstFlowers = new List<Product2>();
        
        for(Product2 flowerObj: Database.Query(strQry)){
        
            // add to the list of Flowers if flower is Active OR 
            // if flower is already added to the existing Bouquet but is Inactive
            if(flowerObj.IsActive  || (!flowerObj.IsActive && flowerObj.Blooms__r.size() > 0)){
                
                lstFlowers.add(flowerObj);  
                
                //populate the map to store the Flower details vs the Flower Id -- To be used in the Pie Chart
                mapFlower.put(flowerObj.Id, flowerObj);
                
                //populate the map to store the HTML Color Code vs the Color -- To be used in the Pie Chart
                mapHTMLColor.put(flowerObj.Color__c, flowerObj.HTML_Color_Code__c);  
                
                //for the Existing Bouquet if there are Blooms for the Flower
                if(flowerObj.Blooms__r.size() > 0){
                    
                    //if Bloom is not already in the Map for Chart, then add the bloom for the flower
                    //For any bouquet, there is only one bloom for a given flower
                    if(!mapBloomForChart.containsKey(flowerObj.Id)){
                        
                        mapBloomForChart.put(flowerobj.Id,flowerObj.Blooms__r[0]);
                    }
                }              
            }
                
        }
        
        //set standard set controller for pagination
        ssc = new ApexPages.StandardSetController(lstFlowers);
        if(ssc != null){
            // to hold the previous selected flower family  
            prevSelectedFlowerFamily = selectedFlowerFamily;
        }
        
        // set the page size of set controller
        ssc.setPageSize(pageSize);
        
        // populate the wrapper class to be displayed on the page
        populateFlowerWrapper();
        
    }
    /**
    *   @author         Developer 1
    *   @description    return True if there is an error (blank quantity for a bloom) in the Flower table
    *   @return         Boolean
    *   @parameters     None
    **/
    private Boolean checkIsError(){
    	Boolean isError = False;
    	for(FlowerWrapper wrap :lstFlowerWrapper){
    		if(wrap.Bloom.Quantity__c == NULL){
    			isError = True;
				wrap.Bloom.Quantity__c.addError('Please enter a value.');
    		}
    	}
    	return isError;
    }
    /**
    *   @author         Developer 1
    *   @description    Method invoked (through action function) if the flower family is changed
    *   @return         None
    *   @parameters     None
    **/
    public void updateFlowersOnFamilyChange(){
    	
    	Boolean isError = checkIsError();
    	if(isError){
    		//revert back the previous selected flower family if any error found
    		selectedFlowerFamily = prevSelectedFlowerFamily;
    		showMessage('Please enter a value before changing the flower family.');
    	}
    	else{
        	//fetch the new flowers for any family change
        	fetchFlowers();
        }
    }
    
    /**
    *   @author         Developer 1
    *   @description    Populate the wrapper list to show on the Bouquet Builder
    *   @return         None
    *   @parameters     None
    **/
    public void populateFlowerWrapper(){
        
        //process the wrapper list if the list of wrapper is not blank
        if(!lstFlowerWrapper.isEmpty()){
        	processFlowerWrapperList();
        }
        // StandardSetController getRecords only fetches the records in the current page
        // and does not retain the values user entered before across pagination
        // update the flowerWrapperList to hold the user entered values
        for(sObject f: ssc.getRecords()){
            Product2 flowerObj = (Product2) f;
            
            // update the wrapper list if the current flower is already updated by User before
            // current flower is already included in the save map            
            if(mapBloomToSave.containsKey(flowerObj.Id)){ 
            
                lstFlowerWrapper.add(new FlowerWrapper(flowerObj, mapBloomToSave.get(flowerObj.Id)));     
            } 
            // check if the current flower has an existing bloom
            else if(!flowerObj.Blooms__r.isEmpty()){
                
                Bloom__c blm = (Bloom__c) flowerObj.Blooms__r[0];
                mapBloomToSave.put(f.Id, blm);
                FlowerWrapper wrapObj = new  FlowerWrapper(flowerObj, blm);
                lstFlowerWrapper.add(wrapObj); 
            }
            // if there is no existing bloom for the flower
            else{
                
                //for new Flower initialize the wrapper
                lstFlowerWrapper.add(new FlowerWrapper(flowerObj, new Bloom__c(Quantity__c = 0)));    
            } 
            
        }
                     
    }
    
    /**
    *   @author         Developer 1
    *   @description    Method to hold the inputs in case of filter change and Pagination 
    *   @return         None
    *   @parameters     None
    **/    
    public void processFlowerWrapperList(){
        
        for(FlowerWrapper fw: lstFlowerWrapper){
            // process if the Quantity is greater than Zero
            if(fw.bloom.Quantity__c > 0){
                
                //if the Quantity was changed from 0 to Non Zero then remove from the delete map first
                if(mapBloomToDelete.containsKey(fw.flower.Id)){
                    mapBloomToDelete.remove(fw.flower.Id);    
                }
                if(fw.bloom.Id == null){
                    //add the new Bloom (to be created) to the save map
                    Bloom__c newBloom = new Bloom__c(Quantity__c = fw.bloom.Quantity__c, Flower__c = fw.flower.Id);
                    mapBloomToSave.put(fw.flower.Id, newBloom);
                    
                     //add in the Map for the Chart
                    mapBloomForChart.put(fw.flower.Id,newBloom);
                }else{                      
                                       
                    //bloom to be updated -- add in the map to Update    
                    mapBloomToSave.put(fw.flower.Id, fw.bloom); 
                    
                    //add in the Map for the Chart
                    mapBloomForChart.put(fw.flower.Id,fw.Bloom); 
                             
                }            
            }else if(mapBloomToSave.containsKey(fw.flower.Id)){
            	//process if the Quantity is Zero   
            
                if(mapBloomToSave.get(fw.flower.Id).Id != null){
                                  
                    //Bloom to be deleted
                    mapBloomToDelete.put(fw.bloom.Id, fw.bloom);
                                            
                }else{
                
                    //remove from the Map to be saved if the quantity was changed from non Zero to 0                                               
                    mapBloomToSave.remove(fw.flower.Id);                      
                }
                
                //add in the Map for the Chart 
                mapBloomForChart.put(fw.flower.Id,fw.Bloom);     
            }    
        }
        
        //clear the current list of wrapper
        lstFlowerWrapper.clear();
    }
    
    /**
    *   @author         Developer 1
    *   @description    Method to be called from the Save button to save the Bouquet record.
    *                   create/update/delete the Bloom records
    *   @return         PageReference - To the Bouquet detail page in case of success
    *                   To the current page in case of any exceptions
    *   @parameters     None
    **/ 
    public PageReference saveBouquet(){
        PageReference pg;
        List<Bloom__c> lstBloomsToUpsert = new List<Bloom__c>();
        Savepoint sp;
        
        // method to update the user inputs for the current page before hitting "Save" button
        if(!lstFlowerWrapper.isEmpty()){
        	processFlowerWrapperList();
        }
        
        try{
            
            //create save point to roll back transaction 
            sp = Database.setSavepoint();
        
            // update or insert Bouquet record to save the details
            upsert bouquetRec;
            
            //delete the Blooms which are in the mapBloomToDelete
            if(!mapBloomToDelete.isEmpty()){
                delete mapBloomToDelete.values();
            }
            
            //populate the list of blooms to be updated/inserted
            if(!mapBloomToSave.isEmpty() ){
            
                for(Bloom__c blm : mapBloomToSave.values()) {
                    
                    //dont consider blooms which are to be deleted
                    if(!mapBloomToDelete.containsKey(blm.Id)){
                    
                        //only for new Blooms set the Bouquet Id
                        if(blm.Id == null){ 
                            blm.Bouquet__c =  bouquetRec.Id;
                        }  
                                      
                        lstBloomsToUpsert.add(blm); 
                    }       
                }   
            }
            
            if(!lstBloomsToUpsert.isEmpty()){
                upsert lstBloomsToUpsert;
            }
            
            pg = new ApexPages.StandardController(bouquetRec).view();            
            
        }catch(DMLException ex){
        
            // to roll back the DML operation if any one of the DML fails
            Database.rollback(sp);
            showMessage('Error while processing your request. Please contact system admin. Error :' + ex.getMessage());              
            
        }catch(Exception ex){
        
            // to roll back the DML operation if any one of the DML fails
            Database.rollback(sp);
            showMessage('Error while processing your request. Please contact system admin. Error :' + ex.getMessage());  
        }
        
        //return to the Bouquet detail Page if success
        return pg;
    }
    
    /**
    *   @author         Developer 1
    *   @description    To add the Message to the Page
    *   @return         None
    *   @parameters     None
    **/
    public void showMessage(String msg){
        ApexPages.Message pageMsg;
        pageMsg = new ApexPages.Message(ApexPages.Severity.Error, msg);            
        ApexPages.addMessage(pageMsg);
    }
    
    /**
    *   @author         Developer 1
    *   @description    This action method queries next set of Bloom
    *                   records when user clicks on Next button
    *   @return         PageReference
    *   @parameters     None
    **/    
    public Pagereference next(){
    	//check if there is no error (no blank Quantity for the bloom)
    	if(!checkIsError()){
	        ssc.next();
	        populateFlowerWrapper();
    	}
        return null;
    }
    
    /**
    *   @author         Developer 1
    *   @description    This action method queries previous set of Bloom
    *                   records when user clicks on Previous button
    *   @return         PageReference
    *   @parameters     None
    **/   
    public Pagereference previous(){
    	//check if there is no error (no blank Quantity for the bloom)
    	if(!checkIsError()){
	        ssc.previous();
	        populateFlowerWrapper();
    	}
        return null;
    }
    
    /**
    *   @author         Developer 1
    *   @description    This action method queries first set of Bloom
    *                   records when user clicks on First button
    *   @return         PageReference
    *   @parameters     None
    **/    
    public Pagereference first(){
    	//check if there is no error (no blank Quantity for the bloom)
        if(!checkIsError()){
        	ssc.first();
        	populateFlowerWrapper();
        }
        return null;
    }
    
    /**
    *   @author         Developer 1
    *   @description    This action method queries last set of Bloom
    *                   records when user clicks on Last button
    *   @return         PageReference
    *   @parameters     None
    **/    
    public Pagereference last(){
    	//check if there is no error (no blank Quantity for the bloom)
        if(!checkIsError()){
        	ssc.last();
        	populateFlowerWrapper();
        }
        return null;
    }
    
    /**
    *   @author         Developer 1
    *   @description    This method is used to check if there are Bloom
    *                   in the list to be displayed when user clicks on 
    *                   Previous
    *   @return         PageReference
    *   @parameters     None
    **/    
    public boolean getHasPrevious(){
        return !(ssc.getHasPrevious());
    }
    
    /**
    *   @author         Developer 1
    *   @description    This method is used to check if there are records 
    *                   in the list to be displayed when user clicks on 
    *                   Next
    *   @return         PageReference
    *   @parameters     None
    **/    
    public boolean getHasNext(){
        return !(ssc.getHasNext());
    }
    
    /**
    *   @author         Developer 1
    *   @description    This method returns the current index of the page
    *   @return         String
    *   @parameters     None
    **/    
    public string getCurrentIndex(){
        return string.valueof(ssc.getPageNumber());
    }
    
    /**
    *   @author         Developer 1
    *   @description    This method returns the total result size
    *   @return         String
    *   @parameters     None
    **/   
    public string getTotalResuts(){
        return string.valueof((ssc.getResultSize()/(Decimal)pageSize).round(System.RoundingMode.CEILING));
    }
    
    /**
    *   @author         Developer 1
    *   @description    To get the data to show the Pie Chart
    *   @return         List<PieChartData>
    *   @parameters     None
    **/
    public List<PieChartData> getChartData(){             
        List<PieChartData> c_data = new List<PieChartData>(); 
        totalCost = 0 ;
        colourSet= '';        
        Map<String,PieChartData> mapChart = new Map<String,PieChartData>();
        
        for(Bloom__c bloomObj: mapBloomForChart.values()){
            
            //Add to the chart data only when Quantity is greater than 0
            if(bloomObj.Quantity__c > 0 ){
            
                //calculate the Total Cost to be shown
                totalCost += (bloomObj.Quantity__c * mapFlower.get(bloomObj.Flower__c).Cost__c);
                
                Product2 flowerRec = mapFlower.get(bloomObj.Flower__c);
                //check if the flower color is not repeated for the chart
                if(!mapChart.containsKey(flowerRec.Color__c)){
                
                    mapChart.put(flowerRec.Color__c, new PieChartData(flowerRec.Color__c, bloomObj.Quantity__c ));    
                }else{
                	//if the flower color is repeated, add the quantity for the same color
                    decimal qty = mapChart.get(flowerRec.Color__c).data + bloomObj.Quantity__c ;
                    mapChart.put(flowerRec.Color__c, new PieChartData(flowerRec.Color__c, qty  ));    
                }
            }  
              
        }
        
        //if map for the chart has some data
        if(!mapChart.isEmpty()){
        
            for(String key: mapChart.keySet()){
                
                //add the PieChart data to the list
                c_data.add(mapChart.get(key)); 
                
                if(colourSet == ''){
                
                    colourSet += mapHTMLColor.get(key) ;     
                }else{
                
                    //add the HTML Color "comma" separated if its not aleady present
                    if(!colourSet.contains(mapHTMLColor.get(key))){
                    
                        colourSet +=  ',' + mapHTMLColor.get(key); 
                    }
                }  
            }
        }
        
        return c_data;
    }
    
    //Inner class to wrap the Bloom and Flower
    public class FlowerWrapper{
        
        public Product2 flower{get;set;}
        
        public Bloom__c bloom {get;set;}        
        
        //WRAPPER CONSTRUCTOR
        public FlowerWrapper(Product2 flower, Bloom__c bloom){
            
            this.flower = flower;
            this.bloom = bloom;           
        }
    }
    
    //Inner class for the Pie Chart
    public class PieChartData{
        public String flowerColor{ get; set; }  
        
        public Decimal data { get; set; }  
        
        // constructor of inner class
        public PieChartData(String flowerColor, Decimal data) {
        	
            this.flowerColor = flowerColor;  
            this.data = data;  
        }// end of inner constructor
          
    }  // end of wrapper class
}