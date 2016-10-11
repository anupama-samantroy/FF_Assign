/* Trigger Name  : BloomTrigger 
* Description  : Trigger on Bloom Object on after events. The trigger contains the following functionalities 
*                1> Method to calculate the most used flower color by a customer 
*                2> Method to calculate the Flower Inventory( Inventory Used)
* Created By   : Developer 1     
* Created Date : 08-10-2016
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              08-10-2016           1000                   Initial Version
*/


trigger BloomTrigger on Bloom__c (after insert , after update, after delete) {
    
    if(trigger.isInsert || trigger.isUpdate){
    
        //Call the method to update the Most Used color
        BloomTriggerHelper.updateMostUsedColor(trigger.new, trigger.oldMap, trigger.isUpdate);
        
        //Call the method to update the Flower Inventory
        BloomTriggerHelper.updateFlowerInventory(trigger.new, trigger.oldMap, trigger.isUpdate);
    }
    else if(trigger.isDelete){
        //Call the method to update the Most Used color
        BloomTriggerHelper.updateMostUsedColor(trigger.old, trigger.oldMap, trigger.isUpdate);
        
        //Call the method to update the Flower Inventory
        BloomTriggerHelper.updateFlowerInventory(trigger.old, trigger.oldMap, trigger.isUpdate);    
    }
}