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

import MapKit


class TagCustomAnnoation: MKPointAnnotation {
    var objectData: NSManagedObject!
}



class ViewController: UIViewController, MKMapViewDelegate {

    let searchTextField: UITextField = UITextField()
    let mainMap = MKMapView()
    
    var globalMapData: [AnyObject] = []
    var filterView = Filter_View()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        mainMap.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        mainMap.delegate = self
        self.view.addSubview(mainMap)
        
        let searchBoxView = UIView(frame: CGRect(x: 15, y: 27, width: deviceSize.width - 30, height: 45))
        searchBoxView.backgroundColor = UIColor.white
        self.view.addSubview(searchBoxView)
        
        self.searchTextField.frame = CGRect(x: 0, y: 0, width: searchBoxView.frame.width, height: searchBoxView.frame.height)
        
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldDidChange(sender:)), for:UIControlEvents.editingChanged)
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldSelected(sender:)), for:UIControlEvents.editingDidBegin)
        
        searchBoxView.addSubview(self.searchTextField)
        
        let closeButtonImage = UIImageView(image: UIImage(named: "close"))
        closeButtonImage.frame = CGRect(x: Int(self.searchTextField.frame.maxX - 35), y: 10, width: 25, height: 25)
        self.searchTextField.addSubview(closeButtonImage)
        
        
        
        let mapData = mapDataModel()
        self.globalMapData = mapData.initPullData() as [AnyObject]
        

        for mapPOI in globalMapData{
            let selectedPOI = mapPOI as! NSManagedObject
            let buildingPin = TagCustomAnnoation()
     
            let buildingLocation = CLLocationCoordinate2DMake(selectedPOI.value(forKey: "lat") as! CLLocationDegrees, selectedPOI.value(forKey: "lng") as! CLLocationDegrees)
            
            buildingPin.coordinate = buildingLocation
            buildingPin.title = selectedPOI.value(forKey: "name") as! String?
            buildingPin.objectData = selectedPOI
            
            mainMap.addAnnotation(buildingPin)
            mainMap.showAnnotations(mainMap.annotations, animated: true)
        }
        

    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            
            let rightButton: AnyObject! = UIButton(type: .detailDisclosure)
            //UIButton.withType(UIButtonType.detailDisclosure)
            //rightButton.title(UIControlState.normal)
            
            pinView!.rightCalloutAccessoryView = rightButton as? UIView

        return pinView
    }
    
    
    @IBAction func unwindToMapFromDetailView(segue: UIStoryboardSegue) {}

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "moveToDetailView", sender: view)
        }
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moveToDetailView" )
        {
            
            var selectedObjectData = ((sender as! MKAnnotationView).annotation as! TagCustomAnnoation).objectData as NSManagedObject
            print("object: ",selectedObjectData)
            
            
            
            //Convert to dictonary data type
            let senderDictonary: NSMutableDictionary = [:]
            senderDictonary.setValue(selectedObjectData.value(forKey: "name"), forKey: "name")
            senderDictonary.setValue(selectedObjectData.value(forKey: "bld_code"), forKey: "code")
            senderDictonary.setValue(selectedObjectData.value(forKey: "category"), forKey: "category")
            senderDictonary.setValue(selectedObjectData.value(forKey: "lat"), forKey: "lat")
            senderDictonary.setValue(selectedObjectData.value(forKey: "lng"), forKey: "lng")
            
            mainMap.showAnnotations([((sender as! MKAnnotationView).annotation as! TagCustomAnnoation)], animated: true)

            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.data = senderDictonary
            
        }
    }
    
//    override func prepare(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if (segue.identifier == "Load View") {
//            // pass data to next view
//        }
//    }
    
//    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        print("Segue: ",segue)
//        if (segue.identifier == "moveToDetailView" )
//        {
//            print("Hello")
//            print(globalMapData[0])
//            
//            let selectedPOI = globalMapData[0] as! NSManagedObject
//            let buildingPin = MKPointAnnotation()
//            
//            let buildingLocation = CLLocationCoordinate2DMake(selectedPOI.value(forKey: "lat") as! CLLocationDegrees, selectedPOI.value(forKey: "lng") as! CLLocationDegrees)
//            
//            buildingPin.coordinate = buildingLocation
//            buildingPin.title = selectedPOI.value(forKey: "name") as! String?
//            mainMap.addAnnotation(buildingPin)
//            mainMap.showAnnotations(mainMap.annotations, animated: true)
//            
//            var detailViewController = segue.destination as! DetailViewController
//            
//            detailViewController.data = globalMapData[0] as! NSDictionary
//            
//        }
//        
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

