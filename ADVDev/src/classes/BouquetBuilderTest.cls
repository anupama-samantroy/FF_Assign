/* Class Name  : BouquetBuilderTest
* Description  : This test class will test the Bouquet Builder Page 
* Created By   : Developer 1     
* Created Date : 08-10-2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              08-10-2015           1000                   Initial Version
*/
@isTest
private class BouquetBuilderTest{
    
    @testSetup
    static void setupData(){
    
        User floristUser = TestUtilities.createFloristUser();
        insert floristUser;
        
        //Create the Customer Record
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Cena', Company = 'WWE');           
        insert testLead ;
        
        //create Flower records
        List<Product2> lstFlowers = TestUtilities.createFlowersForPage();
        insert lstFlowers;
        
        
        //create the Bouquet record running as Florist User
        System.runAs(floristUser){
           
            Bouquet__c bouquet = new Bouquet__c(Customer__c = testLead.Id);
            insert bouquet ;
        }
    }
    
    /*
        To Test the creation of a new Bouquet 
    */
    @isTest
    static void testNewBouquetCreation(){
        //get the Florist User
        User floristUser = [SELECT ID FROM User WHERE Email= 'test@bb.com.test' LIMIT 1];
        
        //get the Customer
        Lead cust = [SELECT Id FROM Lead WHERE LastName = 'Cena' LIMIT 1];
        
        Test.startTest();
            System.runAs(floristUser){               
                Test.setCurrentPage(Page.BouquetBuilder);
                Bouquet__c bou = new Bouquet__c();
                ApexPages.currentPage().getParameters().put(Label.CustomerFieldId,cust.Id);
                
                ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bou);
                BouquetBuilderExtController extCtrl = new BouquetBuilderExtController (stdCtrl);
                
                //check that on Load there were 5 flowers Shown  
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                //check that the Chart is not Shown
                System.assert(extCtrl.mapBloomForChart .size() == 0);
                //check that the selected Family is null
                System.assert(extCtrl.selectedFlowerFamily == NULL);
                //check the number of pages in the Flowers Section should be 4 as 16 flowers
                System.assertEquals('4',extCtrl.getTotalResuts());
               
                
                //testing get Flower Family Options Method
                List<SelectOption> familyOptions = extCtrl.getFlowerFamilyOptions();
                system.assert(familyOptions.size() >= 1);
                
                //Make the Quantity of first flower as null
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = NULL;
                //change the Family filter
                extCtrl.selectedFlowerFamily = 'Family1';
                extCtrl.updateFlowersOnFamilyChange();
                
                ApexPages.Message[] pageMsgs = ApexPages.getMessages();
                System.assertNotEquals(0,pageMsgs.size());
                                
                //check that the error for Quantity null is on the page
                Boolean msgFound = false;
                for( ApexPages.Message msg : pageMsgs){
                    if(msg.getSummary() == 'Please enter a value before changing the flower family.'
                        && msg.getSeverity() == ApexPages.Severity.Error)
                    {
                        msgFound = true;    
                    }
                }
                
                //check that there should be a message
                System.assert(msgFound);
                
                //Make the Quantity of first flower as Zero
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 0;
                
                //Now select a Family for which there are no Flowers
                //change the Family filter
                extCtrl.selectedFlowerFamily = 'No Family';
                extCtrl.updateFlowersOnFamilyChange();
                
                //check that the List of Flowers is 0
                System.assert(extCtrl.lstFlowerWrapper.size() == 0);
                
                //Now change the Flower Family to 'Family3'
                extCtrl.selectedFlowerFamily = 'Family3';
                extCtrl.updateFlowersOnFamilyChange();
                
                //check that the List of Flowers is 5
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                System.assert(extCtrl.getTotalResuts() == '2');
                
                //Testing pagination methods
                extCtrl.next();
                System.assert(extCtrl.lstFlowerWrapper.size() == 1);
                System.assert(extCtrl.getHasPrevious() == false);
                System.assert(extCtrl.getHasNext() == true);
                System.assert(extCtrl.getCurrentIndex() == '2');
                
                extCtrl.previous();
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                System.assert(extCtrl.getHasPrevious() == true);
                System.assert(extCtrl.getHasNext() == false);
                System.assert(extCtrl.getCurrentIndex() == '1');
                
                extCtrl.last();
                System.assert(extCtrl.lstFlowerWrapper.size() == 1);
                System.assert(extCtrl.getHasPrevious() == false);
                System.assert(extCtrl.getHasNext() == true);
                System.assert(extCtrl.getCurrentIndex() == '2');
                
                extCtrl.first();
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                System.assert(extCtrl.getHasPrevious() == true);
                System.assert(extCtrl.getHasNext() == false);
                System.assert(extCtrl.getCurrentIndex() == '1');
                
                //Fill the Bouquet Details
                extCtrl.BouquetRec.Deliver_To__c ='Doctor';
                extCtrl.BouquetRec.Message__c ='Hi Doctor';
                extCtrl.BouquetRec.Delivery_Date__c = System.Today();
                
                //fill the flower details
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 10;
                extCtrl.lstFlowerWrapper[1].Bloom.Quantity__c = 10;
                extCtrl.last();                         
                // get the chart details
                extCtrl.getChartData();
                System.assertEquals(60,extCtrl.totalCost);
                 
                //Now change the Flower Family to 'Family1'
                extCtrl.selectedFlowerFamily = 'Family1';
                extCtrl.updateFlowersOnFamilyChange(); 
                //fill the flower details
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 10;
                
                extCtrl.updateFlowersOnFamilyChange();
                extCtrl.getChartData();
                //check the total cost 
                System.assertEquals(70,extCtrl.totalCost);
                extCtrl.saveBouquet();
                System.assert(extCtrl.bouquetRec.Id != null);
                
                List<Bloom__c> blooms = [SELECT Id FROM Bloom__c WHERE Bouquet__c=:extCtrl.bouquetRec.Id];
                System.assertEquals(3,blooms.size());
            }
        Test.stopTest();
    }
    
    /*
        To Test the edit of an existing Bouquet 
    */
    @isTest
    static void testEditBouquet(){
        //get the Florist User
        User floristUser = [SELECT ID FROM User WHERE Email= 'test@bb.com.test' LIMIT 1];
        
        //get the Customer
        Lead cust = [SELECT Id FROM Lead WHERE LastName = 'Cena' LIMIT 1];
        
        Test.startTest();
            System.runAs(floristUser){               
                Test.setCurrentPage(Page.BouquetBuilder);
                Bouquet__c bou = new Bouquet__c();
                ApexPages.currentPage().getParameters().put(Label.CustomerFieldId,cust.Id);
                
                ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bou);
                BouquetBuilderExtController extCtrl = new BouquetBuilderExtController (stdCtrl);
                
                //check that on Load there were 5 flowers Shown  
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                //check that the Chart is not Shown
                System.assert(extCtrl.mapBloomForChart .size() == 0);
                //check that the selected Family is null
                System.assert(extCtrl.selectedFlowerFamily == NULL);
                //check the number of pages in the Flowers Section should be 4 as 16 flowers
                System.assertEquals('4',extCtrl.getTotalResuts());
               
                
                //testing get Flower Family Options Method
                List<SelectOption> familyOptions = extCtrl.getFlowerFamilyOptions();
                system.assert(familyOptions.size() >= 1);
                   
                //Now change the Flower Family to 'Family3'
                extCtrl.selectedFlowerFamily = 'Family3';
                extCtrl.updateFlowersOnFamilyChange();
                
                //check that the List of Flowers is 5
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                System.assert(extCtrl.getTotalResuts() == '2');
                
                //Fill the Bouquet Details
                extCtrl.BouquetRec.Deliver_To__c ='Doctor';
                extCtrl.BouquetRec.Message__c ='Hi Doctor';
                extCtrl.BouquetRec.Delivery_Date__c = System.Today();
                
                //fill the flower details
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 10;
                extCtrl.lstFlowerWrapper[1].Bloom.Quantity__c = 10;
                
                system.assertEquals('Green',extCtrl.lstFlowerWrapper[1].Flower.Color__c );
                extCtrl.last();                         
                // get the chart details
                extCtrl.getChartData();
                System.assertEquals(60,extCtrl.totalCost);
                 
                //Now change the Flower Family to 'Family1'
                extCtrl.selectedFlowerFamily = 'Family1';
                extCtrl.updateFlowersOnFamilyChange(); 
                //fill the flower details
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 10;
                
                extCtrl.updateFlowersOnFamilyChange();
                extCtrl.getChartData();
                //check the total cost 
                System.assertEquals(70,extCtrl.totalCost);
                PageReference pgSave = extCtrl.saveBouquet();
                PageReference pg = new ApexPages.StandardController(extCtrl.bouquetRec).view();  
                System.assert(extCtrl.bouquetRec.Id != null);
                System.assertEquals(pg.getURL(),pgSave.getURL());
                
                List<Bloom__c> blooms = [SELECT Id FROM Bloom__c WHERE Bouquet__c=:extCtrl.bouquetRec.Id];
                System.assertEquals(3,blooms.size());
                
                Test.setCurrentPage(Page.BouquetBuilder);
                stdCtrl = new ApexPages.StandardController(extCtrl.bouquetRec);
                extCtrl = new BouquetBuilderExtController (stdCtrl);
                
                //check that on Load there were 5 flowers Shown  
                System.assert(extCtrl.lstFlowerWrapper.size() == 5);
                
                //The first flower will be Blue  for Family 3 for which we entered 10 earlier
                System.assert(extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c == 10);
                System.assert(extCtrl.lstFlowerWrapper[0].Flower.Color__c == 'Blue');
                
                //Change this Flower Quantity to 20 now
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 20;
                //got to the Next Page
                extCtrl.next();
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 30;
                
                //click the last button so that the Chart data gets refreshed with latest
                extCtrl.last();                         
                // get the chart details
                extCtrl.getChartData();
                System.assertEquals(140,extCtrl.totalCost);    //$1 * 20 + $2 * 30 + 3 *10 + 3* 10
                
                pgSave = extCtrl.saveBouquet();
                pg = new ApexPages.StandardController(extCtrl.bouquetRec).view();
                System.assert(extCtrl.bouquetRec.Id != null);
                System.assertEquals(pg.getURL(),pgSave.getURL());
                
                //check that the number of blooms are 4 now
                blooms = [SELECT Id FROM Bloom__c WHERE Bouquet__c=:extCtrl.bouquetRec.Id];
                System.assertEquals(4,blooms.size());
                
                //come back to the Bouquet Builder page
                Test.setCurrentPage(Page.BouquetBuilder);                
                stdCtrl = new ApexPages.StandardController(extCtrl.bouquetRec);
                extCtrl = new BouquetBuilderExtController (stdCtrl);
                
                //check that the First Blooms qunatity has been increased to 20 now
                System.assert(extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c == 20);
                System.assert(extCtrl.lstFlowerWrapper[0].Flower.Color__c == 'Blue');
                
                //Remove the first flower by changing the Quantity to 0
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 0;
                extCtrl.saveBouquet();
                
                //check that the number of blooms are 3 again as the Blue flower has been chaged to 0 
                blooms = [SELECT Id FROM Bloom__c WHERE Bouquet__c=:extCtrl.bouquetRec.Id];
                System.assertEquals(3,blooms.size());
                
                //come back to the Bouquet Builder page
                Test.setCurrentPage(Page.BouquetBuilder);                
                stdCtrl = new ApexPages.StandardController(extCtrl.bouquetRec);
                extCtrl = new BouquetBuilderExtController (stdCtrl);
                
                //check that the First Blooms qunatity has been cahnged to 0 now
                System.assert(extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c == 0);
                System.assert(extCtrl.lstFlowerWrapper[0].Flower.Color__c == 'Blue');
                
                //set the quantity to 5 now
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 5;
                //got to the Next Page
                extCtrl.next();
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 5;
                
                //got to the Previous Page so that the Chart data can be refreshed
                extCtrl.previous();
                
                // get the chart details
                extCtrl.getChartData();
                System.assertEquals(75,extCtrl.totalCost);    //$1 * 5 + $2 * 5 + $3 *10 + $3 * 10
                
                //change the quantity to 0 again
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 0;
                
                //go to the last Page
                extCtrl.last();
               
                //come back to first page again and Change the quantity of First flower to 10 instead of 0
                extCtrl.first();
                
                extCtrl.lstFlowerWrapper[0].Bloom.Quantity__c = 10;
                //got to the Next Page
                extCtrl.next();
                //get the chart details
                extCtrl.getChartData();
                System.assertEquals(80,extCtrl.totalCost);    //$1 * 10 + $2 * 5 + $3 *10 + $3 * 10
                
                extCtrl.saveBouquet();
                //check that the number of blooms are 4
                blooms = [SELECT Id FROM Bloom__c WHERE Bouquet__c=:extCtrl.bouquetRec.Id];
                System.assertEquals(4,blooms.size());
            }
        Test.stopTest();
    }
    
}