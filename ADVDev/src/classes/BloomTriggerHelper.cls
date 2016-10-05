/* Class Name  : BloomTriggerHelper
* Description  : Helper class for the BloomTrigger 
*                1> Method to calculate the most used flower color by a customer 
*                2> Method to update the Flower Inventory
* Created By   : Developer 1     
* Created Date : 18-09-2016
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              18-09-2016           1000                   Initial Version
*/
public class BloomTriggerHelper{

    /**
    *   @author         Developer 1
    *   @description    Populate the Most User color on the Customer(Lead)
    *   @return         void
    *   @parameters     List of newly created/ updated Blooms, Map of Old Blooms, Boolean value for update
    **/
    public Static void updateMostUsedColor(List<Bloom__c> lstBlooms, Map<Id,Bloom__c> oldMap, Boolean isUpdate){
        //set to store the Customer Ids
        Set<Id> setCustomerIds = new Set<Id>();  
        
        //set to store the Bouquet Ids  
        Set<Id> setBouquetIds = new Set<Id>();    
        
        //iterate through the list of new/update/deleted Blooms to get the Parent Bouquet Ids
        for(Bloom__c bloomObj: lstBlooms){
            
            if(isUpdate){
            
                //if its update then check if Quanity or Flower has been modified
                if(bloomObj.Quantity__c != oldMap.get(bloomObj.Id).Quantity__c ||
                  (bloomObj.Flower__c != null && bloomObj.Flower__c !=  oldMap.get(bloomObj.Id).Flower__c)){
                  
                    setBouquetIds.add(bloomObj.Bouquet__c);    
                }
                
            }else{  
                //in case of insert or delete             
                if(bloomObj.Flower__c != null ){
                
                    setBouquetIds.add(bloomObj.Bouquet__c);
                    
                }
            }    
        }
        
        if(!setBouquetIds.isEmpty()){
        
            //List of Customers to be Updated with Most User Color         
            List<Lead> lstCustomersToUpdate = new List<Lead>();  
                 
            //All blooms for the setCustomers group by Customer and Color
            List<AggregateResult> lstAggregatedBloom = new List<AggregateResult>(); 
            
            //Map to store the Color vs the Customer Id
            Map<Id,String> mapColorvsCustomer = new Map<Id,String>(); 
            
            //Iterate through the bouquets to get the set of customer Ids
            for(Bouquet__c bouObj:  [Select Customer__c from Bouquet__c where Id IN: setBouquetIds ]){
                
                setCustomerIds.add(bouObj.Customer__c);   
                 
            }
            
            //Get the SUM of Quantity of Blooms per customer per flower color and order by Quantity and Color
            //So that the highest for a particular colour comes first 
            lstAggregatedBloom = [SELECT SUM(Quantity__c) totQty, Bouquet__r.Customer__c cust, Flower__r.Color__c color  
                                      FROM Bloom__c 
                                  WHERE Bouquet__r.Customer__c IN: setCustomerIds 
                                  GROUP BY Bouquet__r.Customer__c, Flower__r.Color__c 
                                  ORDER BY SUM(Quantity__c) DESC,  Flower__r.Color__c ];
                
            if(!lstAggregatedBloom.isEmpty()){
            
                for(AggregateResult arr: lstAggregatedBloom){
                
                    //If the customer does not already exists in the map then put the customer and the corresponding color in the map 
                    if(!mapColorvsCustomer.containsKey((Id) arr.get('cust'))){
                    
                        mapColorvsCustomer.put((Id) arr.get('cust'), (String) arr.get('color')); 
                        
                    }   
                }
            }
            
            //iterate through the map to form the List of customers to update
            if(!mapColorvsCustomer.isEmpty()){
            
                for(Id customerId: mapColorvsCustomer.keySet()){
                
                    Lead cust = new Lead(Id = customerId);
                    
                    cust.Most_Used_Color__c = mapColorvsCustomer.get(customerId);
                    
                    //Add in the list to be udpated
                    lstCustomersToUpdate.add(cust);
                }
            }
            
            //UPDATE the customers
            if(!lstCustomersToUpdate.isEmpty()){
                try{
                
                    update lstCustomersToUpdate;
                    
                }catch(Exception ex){
                
                    //Add error in case of exception
                    for(Bloom__c bloomObj : lstBlooms){
                    
                        bloomObj.addError(ex.getMessage());   
                         
                    }
                }
            }
        }
    }
    
     /**
    *   @author         Developer 1
    *   @description    Populate the Flower Inventory
    *   @return         void
    *   @parameters     List of newly created/ updated Blooms, Map of Old Blooms, Boolean value for update
    **/
    public static void updateFlowerInventory(List<Bloom__c> lstBlooms, Map<Id,Bloom__c> oldMap, Boolean isUpdate){
        
        Set<Id> setFlowerIds = new Set<Id>();
        
        //iterate through the list of new/update/deleted Blooms to get the Parent Flower Ids
        for(Bloom__c bloomObj: lstBlooms){
            
            if(isUpdate){
            
                //if its update then check if Quanity has been modified
                if(bloomObj.Quantity__c != oldMap.get(bloomObj.Id).Quantity__c ){
                  
                    setFlowerIds.add(bloomObj.Flower__c);                     
                       
                }
                
                //if Flower has been modified then add the new flower and old flower to the set
                if(bloomObj.Flower__c != null && bloomObj.Flower__c !=  oldMap.get(bloomObj.Id).Flower__c){
                    
                    //add the new Flower
                    setFlowerIds.add(bloomObj.Flower__c);
                    
                    //add the old Flower
                    setFlowerIds.add(oldMap.get(bloomObj.Id).Flower__c);
                        
                }
                
            }else{  
                 //in case of insert or delete          
                if(bloomObj.Flower__c != null){
                
                    setFlowerIds.add(bloomObj.Flower__c);    
                    
                }
            }    
        } 
        
        //process if Set of flowers is not empty
        if(!setFlowerIds.isEmpty()){
           
            //All blooms for the setFlowerIds group by Flower 
            List<AggregateResult> lstAggregatedBloom = new List<AggregateResult>();  
            
            //List of Flowers to update
            List<Product2> lstFlowersToUpdate = new List<Product2>();
            
            
            lstAggregatedBloom = [SELECT SUM(Quantity__c) qty, Flower__c flower 
                                    FROM Bloom__c 
                                  WHERE Flower__c IN: setFlowerIds 
                                  GROUP BY Flower__c   
                                 ];
                                 
           for(AggregateResult agg: lstAggregatedBloom ){
               Product2 flowerObj = new Product2(Id = (Id) agg.get('flower'));
               flowerObj.Inventory_Used__c = (Decimal) agg.get('qty');
               
               //add to the list to update
               lstFlowersToUpdate.add(flowerObj);
           }
           
           //Update the list 
           if(!lstFlowersToUpdate.isEmpty()){
               
               try{
               
                   update lstFlowersToUpdate;
                   
               }catch(Exception ex){
               
                    //Add error in case of exception
                    for(Bloom__c bloomObj : lstBlooms){
                    
                        bloomObj.addError(ex.getMessage());   
                     
                    }    
               }
           }
                  
        }
                   
    }
}