/* Class Name  : BloomTriggerHelperTest
* Description  : This test class will test the BloomTrigger functionalities
* Created By   : Developer 1     
* Created Date : 08-10-2015
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer 1              08-10-2015           1000                   Initial Version
*/
@isTest
private class BloomTriggerHelperTest{
    
    @testSetup
    static void setupData(){
    
        User floristUser = TestUtilities.createFloristUser();
        insert floristUser;
        
        //Create the Customer Records
        List<Lead> lstCustomers = new List<Lead>();
        for(Integer i = 0 ; i < 5 ; i ++){
        
            Lead testLead1 = new Lead(FirstName = 'John'+i, LastName = 'Cena'+i, Company = 'WWE');
           
            lstCustomers.add(testLead1);
        }      
        insert lstCustomers;
        
        //create Flower records
        List<Product2> lstFlowers = TestUtilities.createFlowers();
        insert lstFlowers;
        
        
        //create the Bouquet records running as Florist User
        System.runAs(floristUser){
            List<Bouquet__c> lstBouquet = new List<Bouquet__c>();
            
            //creating 2 bouquet for each of the Customers
            for(Integer i=0 ; i < 5 ; i++){
                Bouquet__c bouquet1 = new Bouquet__c(Customer__c = lstCustomers[i].Id);
                Bouquet__c bouquet2 = new Bouquet__c(Customer__c = lstCustomers[i].Id);  
                
                lstBouquet.add(bouquet1);
                lstBouquet.add(bouquet2);
            }
            insert lstBouquet;
        }
    }
    /*
        This method is to test the most used color of the flower on the Customer Record
    */
    @isTest
    static void TestMostUsedColorForCustomer(){
        //get the Florist User
        User floristUser = [SELECT ID FROM User WHERE Email= 'test@bb.com.test' LIMIT 1];
        
        //get the Customer Record
        Lead customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena1' LIMIT 1];
        
        //get the Bouquet record
        Bouquet__c bouquet = [SELECT Id FROM Bouquet__c WHERE Customer__c =:customer.Id LIMIT 1];        
        
        //Get the flowers Order by Flower Color i.e Blue, Green, Orange, Red, Yellow
        List<Product2> lstFlowers = [SELECT Id, Color__c FROM Product2 ORDER BY Color__c];
        
        //add multiple Blooms to this bouquet
        List<Bloom__c> lstBlooms = new List<Bloom__c>();
        
        for(Product2 flower : lstFlowers){
            
            //For the Red color flower add quantity 20 -- There are 2 Red Flowers
            if(flower.Color__c == 'Red'){
                              
                lstBlooms.add(TestUtilities.createBloom(bouquet.Id,flower.Id, 20));
                
            } else{    //for others add 10      
                
                lstBlooms.add(TestUtilities.createBloom(bouquet.Id,flower.Id, 10));   
            }  
        }          
        
        //Check that the Most Used Color for the Customer is Blank before creating blooms.
        system.assert(String.isBlank(customer.Most_Used_Color__c));
        
        test.startTest();
        //Running as a FLORIST user.
        System.runAs(floristUser){
        
            //insert the Blooms
            insert lstBlooms;
        }
        
        //as the Bloom for Red Flower the quantity is 40 the most used color should be Red for the Customer
        customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena1' LIMIT 1];
        
        system.assertEquals('Red', customer.Most_Used_Color__c );
        
        //Running as a FLORIST user changing the Quantity of the Orange Flower
        System.runAs(floristUser){
        
            //Change the Quantity of the Bloom for the Orange Flower
            Bloom__c blmOrange = [SELECT Id, Quantity__c FROM Bloom__c WHERE Quantity__c = 10 AND Flower__r.Color__c = 'Orange'  AND Flower__r.Name = 'Flower3' LIMIT 1];
            system.assertEquals(10, blmOrange.Quantity__c);
            
            //increase the Quantity to 30 from Earlier 10
            blmOrange.Quantity__c = 30;
            
            update blmOrange;
        }
        
        //Check now the Most Used Color of the Customer Should be changed to Orange as the Quantity is same for Orange and Red 
        //In the event of a tie, the color that is alphabetically first will win. 
        //as the Quantity for Orange Flower is 40, the most used color should be updated to Orange
        customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena1' LIMIT 1];
        
        system.assertEquals('Orange', customer.Most_Used_Color__c ); 
        
        //Running as a FLORIST user.
        System.runAs(floristUser){
        
            //Change the Flower of the Bloom for the red Flower - Flower4
            Bloom__c blmRed = [SELECT Id, Flower__c FROM Bloom__c WHERE Flower__r.Color__c='Red' AND Flower__r.Name = 'Flower4' ];
            
            //Change the Flower to Green Flower
            Product2 greenFlw = [SELECT Id from Product2 Where Name = 'Flower2' AND Color__c = 'Green' LIMIT 1];    //green flower
            blmRed.Flower__c = greenFlw.Id;
            
            update blmRed;
        }
        
        //Check now the Most Used Color for the Customer should be Green. Green and Orange has Same Quantity but Green is populated
        //as it comes alphabetically first.
        
        customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena1' LIMIT 1];
        
        system.assertEquals('Green', customer.Most_Used_Color__c ); 
        
        test.stopTest();
    }
    
    /*
        This method is to test the most used color of the flower on the Customer Record in Bulk
    */
    @isTest
    static void TestMostUsedColorForBulkCustomers(){
        
        //get the Florist User
        User floristUser = [SELECT ID FROM User WHERE Email= 'test@bb.com.test' LIMIT 1];
        
        //get the List of Customers 
        List<Lead> lstCustomer = [SELECT Id, Most_Used_Color__c FROM Lead];
        system.assertEquals(5, lstCustomer.size());
        
        //get the Bouquet records
        List<Bouquet__c> lstBouquet = [SELECT Id, Customer__c FROM Bouquet__c WHERE Customer__c IN:lstCustomer];        
        system.assertEquals(10, lstBouquet.size());
        
        //prepare a map to hold the List of Bouquet for each customer
        Map<Id,List<Bouquet__c>> mapBouquetVsCustomer = new Map<Id,List<Bouquet__c>>();
        for(Bouquet__c bou: lstBouquet ){
            if(!mapBouquetVsCustomer.containsKey(bou.Customer__c)){
                mapBouquetVsCustomer.put(bou.Customer__c, new List<Bouquet__c>());    
            }
            mapBouquetVsCustomer.get(bou.Customer__c).add(bou);    
        }
        
        //Get the flowers Order by Flower Color i.e Blue, Green, Orange, Red, Yellow
        List<Product2> lstFlowers = [SELECT Id, Color__c FROM Product2 ORDER BY Color__c];
        
        //List of Blooms to insert
        List<Bloom__c> lstBlooms = new List<Bloom__c>();
        
        //get the Bouquets for the First Customer
        List<Bouquet__c> bouquetCustomer1 = mapBouquetVsCustomer.get(lstCustomer[0].Id);
        system.assertEquals(2,bouquetCustomer1.size());
        
        /*****Adding Blooms to the Bouquets of First Customer ***/
        for(Product2 flower : lstFlowers){
            
            //For the Red color flower add quantity 20 in the first Bouquet and 10 in the second bouquet
            if(flower.Color__c == 'Red'){
            
                //first bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[0].Id,flower.Id, 20));
                //second bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[1].Id,flower.Id, 10)); 
            } else{    //for others add 10
            
                //first Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[0].Id,flower.Id, 10)); 
                //second Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[1].Id,flower.Id, 10));   
            }  
        }
        
        //check that 20 blooms have been added to the List
        System.assertEquals(20,lstBlooms.size());
        
        //get the Bouquets for the Second Customer from the Map
        List<Bouquet__c> bouquetCustomer2 = mapBouquetVsCustomer.get(lstCustomer[1].Id);
        system.assertEquals(2,bouquetCustomer2.size());
        
        /*****Adding Blooms to the Bouquets of Second Customer ***/
        for(Product2 flower : lstFlowers){
            
            //For the Blue color flower add quantity 20 in the first bouquet and 10 in the Second Bouquet
            if(flower.Color__c == 'Blue'){
                
                //first Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer2[0].Id,flower.Id, 20));                
                //second Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer2[1].Id,flower.Id, 10)); 
            } else{    //for others add 10
            
                //first Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer2[0].Id,flower.Id, 10));                
                //second Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer2[1].Id,flower.Id, 10));   
            }  
        }        
        //check that 20 more blooms have been added to the List and size is now 40
        System.assertEquals(40,lstBlooms.size());
        
        //Check that the Most Used Color for the Customer is Blank before creating blooms.
        system.assert(String.isBlank(lstCustomer[0].Most_Used_Color__c));
        system.assert(String.isBlank(lstCustomer[1].Most_Used_Color__c));
        
        test.startTest();
        
        //Running as a FLORIST user.
        System.runAs(floristUser){
        
            //insert the Blooms
            insert lstBlooms;
        }
        
        //For Customer 1 Red flower has quantity 60 So the Most Used color is Red
        Lead customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena0' LIMIT 1];
        
        system.assertEquals('Red', customer.Most_Used_Color__c );
        
        //For Customer 2 Blue Flower has Quantity 60 So the most used colour is Blue
        customer = [SELECT Id, Most_Used_Color__c FROM Lead WHERE LastName = 'Cena1' LIMIT 1];
        system.assertEquals('Blue', customer.Most_Used_Color__c );
        
        test.stopTest();
    }
    
    /*
        This method is to test the Flower Inventory when Blooms are added to the Bouquet
    */
    @isTest
    static void TestFlowerInventoryUsed(){
        //get the Florist User
        User floristUser = [SELECT ID FROM User WHERE Email= 'test@bb.com.test' LIMIT 1];
        
        //get the List of Customers 
        List<Lead> lstCustomer = [SELECT Id, Most_Used_Color__c FROM Lead];
        system.assertEquals(5, lstCustomer.size());
        
        //get the Bouquet records
        List<Bouquet__c> lstBouquet = [SELECT Id, Customer__c FROM Bouquet__c WHERE Customer__c IN:lstCustomer];        
        system.assertEquals(10, lstBouquet.size());
        
        //prepare a map to hold the List of Bouquet for each customer
        Map<Id,List<Bouquet__c>> mapBouquetVsCustomer = new Map<Id,List<Bouquet__c>>();
        for(Bouquet__c bou: lstBouquet ){
            if(!mapBouquetVsCustomer.containsKey(bou.Customer__c)){
                mapBouquetVsCustomer.put(bou.Customer__c, new List<Bouquet__c>());    
            }
            mapBouquetVsCustomer.get(bou.Customer__c).add(bou);    
        }
        
        //Get the flowers Order by Flower Color i.e Blue, Green, Orange, Red, Yellow
        List<Product2> lstFlowers = [SELECT Id, Color__c, Inventory_Remaining__c FROM Product2 ORDER BY Color__c];
        system.assertEquals(10, lstFlowers.size());
        
        //check that the Initial Inventory remaning is 100 for any flower
        system.assertEquals(100, lstFlowers[0].Inventory_Remaining__c );
        system.assertEquals(100, lstFlowers[3].Inventory_Remaining__c );
        system.assertEquals(100, lstFlowers[7].Inventory_Remaining__c );
                
        //add multiple Blooms to this bouquet
        List<Bloom__c> lstBlooms = new List<Bloom__c>();
        
        //get the Bouquets for the First Customer
        List<Bouquet__c> bouquetCustomer1 = mapBouquetVsCustomer.get(lstCustomer[0].Id);
        system.assertEquals(2,bouquetCustomer1.size());
        
        /*****Adding Blooms to the Bouquets of First Customer ***/
        for(Product2 flower : lstFlowers){
            
            //For the Red color flower add quantity 20 in the first Bouquet and 10 in the second bouquet
            if(flower.Color__c == 'Red'){
            
                //first bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[0].Id,flower.Id, 20));
                //second bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[1].Id,flower.Id, 10)); 
            } else{    //for others add 10
            
                //first Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[0].Id,flower.Id, 10)); 
                //second Bouquet
                lstBlooms.add(TestUtilities.createBloom(bouquetCustomer1[1].Id,flower.Id, 10));   
            }  
        }
        
        test.startTest();
        //Running as a FLORIST user.
        System.runAs(floristUser){
        
            //insert the Blooms
            insert lstBlooms;
        }
        
        //For Customer 1 Red flower has quantity 30 for each of the red flowers. So the Inventory Remaining  will be 70 for each red flower
        List<Product2> redFlowers = [SELECT Id,Inventory_Remaining__c  FROM Product2 WHERE Color__c = 'Red' LIMIT 2];
             
        system.assertEquals(70, redFlowers[0].Inventory_Remaining__c );
        system.assertEquals(70, redFlowers[1].Inventory_Remaining__c );
        
        //For Customer 1 Green flower has quantity 20 for each of the green flowers. So the Inventory Remaining  will be 80 for each green flower
        List<Product2> greenFlowers = [SELECT Id,Inventory_Remaining__c  FROM Product2 WHERE Color__c = 'Green' LIMIT 2];
        system.assertEquals(80, greenFlowers[0].Inventory_Remaining__c );
        system.assertEquals(80, greenFlowers[1].Inventory_Remaining__c );
        
        
        //Update the Blooms
        List<Bloom__c> bloomToupdate = new List<Bloom__c>();
        for(Bloom__c blm: [SELECT Id, Quantity__c, Flower__r.Color__c FROM Bloom__c]){
            if(blm.Flower__r.Color__c == 'Red'){
                //decrese the Quantity by 5
                blm.Quantity__c = blm.Quantity__c  - 5;
            }
            if(blm.Flower__r.Color__c == 'Green'){
                //Increase the Quantity by 5
                blm.Quantity__c = blm.Quantity__c  + 5;
            }
            bloomToupdate.add(blm);
        }
        //Running as a FLORIST user.
        System.runAs(floristUser){
        
            //insert the Blooms
            update bloomToupdate;
        }
        //For Customer 1 Red flower has now quantity 20 for each of the red flowers. So the Inventory Remaining  will be 80 for each red flower
        redFlowers = [SELECT Id,Inventory_Remaining__c  FROM Product2 WHERE Color__c = 'Red' LIMIT 2];
             
        system.assertEquals(80, redFlowers[0].Inventory_Remaining__c );
        system.assertEquals(80, redFlowers[1].Inventory_Remaining__c );
        
        //For Customer 1 Green flower has quantity 30 for each of the green flowers. So the Inventory Remaining  will be 70 for each green flower
        greenFlowers = [SELECT Id,Inventory_Remaining__c  FROM Product2 WHERE Color__c = 'Green' LIMIT 2];
        system.assertEquals(70, greenFlowers[0].Inventory_Remaining__c );
        system.assertEquals(70, greenFlowers[1].Inventory_Remaining__c );
        
        test.stopTest();
    }    
    
}