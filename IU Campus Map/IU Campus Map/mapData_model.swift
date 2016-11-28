//
//  mapData_model.swift
//  IU Campus Map
//
//  Created by Liam Bolling on 11/27/16.
//
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON


class mapDataModel: NSObject {

    
    
    
    
    func searchMapData(searchText: String) -> NSArray{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MapData")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            var resultsArray = results as! [NSManagedObject]
            
            var filteredResultsArray: [NSManagedObject] = []
            
            for locationObject in resultsArray{
                
                let selectedPOI = locationObject
                let venueName = selectedPOI.value(forKey: "name") as! String
                let venueBuildingCode = selectedPOI.value(forKey: "bld_code") as! String
                
                if venueName.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredResultsArray.append(selectedPOI)
                }
                
                if venueBuildingCode.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredResultsArray.append(selectedPOI)
                }
                
                
            }
            
            return filteredResultsArray as NSArray
            
            
        } catch {
            
            
            
        }
        
        return ["error"]
        

        
    }
    
    
    
    
    func initPullData() -> NSArray{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MapData")

        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let resultsArray = results as! [NSManagedObject]
            
            
            if resultsArray.count == 0 {
                
                print("Nothing in here")
                
                if let path = Bundle.main.path(forResource: "data", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                        let jsonObj = JSON(data: data)
                        
                        if jsonObj != JSON.null {

                            
                            for building in jsonObj.array! {
                    
                                if building["lng"] != 0 && building["lat"] != 0 {
                    
                                    
                                    let entity =  NSEntityDescription.entity(forEntityName: "MapData", in: managedContext)
                                    let cacheObject = NSManagedObject(entity: entity!, insertInto: managedContext)
                                    
                                    cacheObject.setValue(building["category"].string, forKey: "category")
                                    cacheObject.setValue(building["lat"].double, forKey: "lat")
                                    cacheObject.setValue(building["architects"].string, forKey: "architects")
                                    cacheObject.setValue(building["year"].int, forKey: "year")
                                    cacheObject.setValue(building["description"].string, forKey: "bld_description")
                                    cacheObject.setValue(building["name"].string, forKey: "name")
                                    cacheObject.setValue(building["bld_code"].string, forKey: "bld_code")
                                    cacheObject.setValue(building["address"].string, forKey: "address")
                                    cacheObject.setValue(building["id"].string, forKey: "id")
                                    cacheObject.setValue(building["floors"].int, forKey: "floors")
                                    cacheObject.setValue(building["lng"].double, forKey: "lng")
                                    
                                    do {
                                        try managedContext.save()
                                    } catch {
                                        print("problem")
                                    }

                                }
                            }
                            
                            return results as NSArray
                            
                        }
                    }catch{
                        
                    }
                }
                
            }else{
                
                return results as NSArray
                
            }
            
            
        
            
            //                                    let buildingLocation = CLLocationCoordinate2DMake(building["lat"].double!, building["lng"].double!)
            //
            //                                    buildingPin.coordinate = buildingLocation
            //                                    buildingPin.title = building["name"].string
            //                                    mainMap.addAnnotation(buildingPin)
            //                                    mainMap.showAnnotations(mainMap.annotations, animated: true)
            
            
        }catch{
            print("error?")
            return ["error"] as NSArray
        }
        return ["error"] as NSArray
    }
    
    
}
