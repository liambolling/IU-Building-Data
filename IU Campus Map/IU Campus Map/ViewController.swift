//
//  ViewController.swift
//  IU Campus Map
//
//  Created by Liam Bolling on 11/5/16.
//
//

import UIKit
import MapKit
import SwiftyJSON
import CoreData


class ViewController: UIViewController {

    let searchTextField: UITextField = UITextField()
    let mainMap = MKMapView()
    
    var globalMapData: [AnyObject] = []
    var filterView = Filter_View()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mainMap = MKMapView()
        mainMap.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        self.view.addSubview(mainMap)
        
        let searchBoxView = UIView(frame: CGRect(x: 15, y: 27, width: deviceSize.width - 30, height: 45))
        searchBoxView.backgroundColor = UIColor.white
        self.view.addSubview(searchBoxView)
        
        self.searchTextField.frame = CGRect(x: 0, y: 0, width: searchBoxView.frame.width, height: searchBoxView.frame.height)
        
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldDidChange(sender:)), for:UIControlEvents.editingChanged)
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldSelected(sender:)), for:UIControlEvents.editingDidBegin)
        
        searchBoxView.addSubview(self.searchTextField)
        
        var closeButtonImage = UIImageView(image: UIImage(named: "close"))
        closeButtonImage.frame = CGRect(x: Int(self.searchTextField.frame.maxX - 35), y: 10, width: 25, height: 25)
        self.searchTextField.addSubview(closeButtonImage)
        
        
        
        let mapData = mapDataModel()
        self.globalMapData = mapData.initPullData() as [AnyObject]
        

        for mapPOI in globalMapData{
            print((mapPOI as! NSManagedObject).value(forKey: "name"))
            
            let selectedPOI = mapPOI as! NSManagedObject
            let buildingPin = MKPointAnnotation()
            let buildingLocation = CLLocationCoordinate2DMake(selectedPOI.value(forKey: "lat") as! CLLocationDegrees, selectedPOI.value(forKey: "lng") as! CLLocationDegrees)

            buildingPin.coordinate = buildingLocation
            buildingPin.title = selectedPOI.value(forKey: "name") as! String?
            mainMap.addAnnotation(buildingPin)
            mainMap.showAnnotations(mainMap.annotations, animated: true)
        }
        
        
//        for building in self.globalGeoData {
//            
//            if building["lng"] != 0 && building["lat"] != 0 {
//                
//                let buildingPin = MKPointAnnotation()
//                
//                let buildingLocation = CLLocationCoordinate2DMake(building["lat"].double!, building["lng"].double!)
//                
//                buildingPin.coordinate = buildingLocation
//                buildingPin.title = building["name"].string
//                mainMap.addAnnotation(buildingPin)
//                mainMap.showAnnotations(mainMap.annotations, animated: true)
//            
//            }
//        }
    }
    
    
//    
//    func loadData() {
//        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
//                let jsonObj = JSON(data: data)
//                
//                if jsonObj != JSON.null {
//                    
//                    self.globalGeoData = jsonObj.array!
//                    
//                }
//            }catch{
//                
//            }
//        }
//    }
    
    
    
    
    
    
    
    
    func textFieldSelected(sender:AnyObject){
        filterView = Filter_View(frame: CGRect(x: 15, y: 85, width: deviceSize.width - 30, height: deviceSize.height - 40))
        filterView.addTableData(mapData: self.globalMapData as NSArray)
        filterView.backgroundColor = UIColor.green
        self.view.addSubview(filterView)
    }
    
    
    
    
    func textFieldDidChange(sender: AnyObject){
        
        let mapData = mapDataModel()
        var filterMapData = mapData.searchMapData(searchText: self.searchTextField.text!) as [AnyObject]

        filterView.setFilteredMapData(filteredArray: filterMapData as NSArray)
        
        
        
//        let term = self.searchTextField.text
//        
//        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
//                let jsonObj = JSON(data: data)
//                
//                if jsonObj != JSON.null {
//                    
//                    let infoArray = jsonObj.array
//                    
//                    for elem in infoArray! {
//                        if term != "" {
//                            
//                            if term?.lowercased() == elem["bld_code"].string?.lowercased() {
//                                print("FOUND CODE")
//                                print(elem)
//                            }
//                            
//                            if term?.lowercased() == elem["name"].string?.lowercased() {
//                                print("FOUND NAME")
//                                print(elem)
//                            }
//                            
//                        }
//                    }
//                    
//                    
//                } else {
//                    print("Could not get json from file, make sure that file contains valid json.")
//                }
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        } else {
//            print("Invalid filename/path.")
//        }
        
        
    }
    
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

