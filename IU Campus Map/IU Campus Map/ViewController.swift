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



class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    let searchTextField: UITextField = UITextField()
    let mainMap = MKMapView()
    
    var reverseMainMapCenter:AnyObject? = nil
    var reverseMainMapZoom:AnyObject? = nil
    
    var globalMapData: [AnyObject] = []
    var filterView: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        mainMap.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        mainMap.delegate = self
        mainMap.showsUserLocation = true
        self.view.addSubview(mainMap)
        
        let searchBoxView = UIView(frame: CGRect(x: 15, y: 27, width: deviceSize.width - 30, height: 45))
        searchBoxView.backgroundColor = UIColor.white
        self.view.addSubview(searchBoxView)
        
        self.searchTextField.frame = CGRect(x: 0, y: 0, width: searchBoxView.frame.width - 75, height: searchBoxView.frame.height)
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldDidChange(sender:)), for:UIControlEvents.editingChanged)
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldSelected(sender:)), for:UIControlEvents.editingDidBegin)
        
        searchBoxView.addSubview(self.searchTextField)
        
        let closeButtonImage = UIImageView(image: UIImage(named: "close"))
        closeButtonImage.frame = CGRect(x: Int(searchBoxView.frame.maxX - 45), y: 10, width: 25, height: 25)
        searchBoxView.addSubview(closeButtonImage)
        
        let closeButton = UIButton()
        closeButton.frame = CGRect(x: Int(searchBoxView.frame.maxX - 45), y: 10, width: 25, height: 25)
        closeButton.addTarget(self, action:#selector(ViewController.removeFilterView(sender:)), for:.touchUpInside)
        searchBoxView.addSubview(closeButton)
        
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
    
    
    func fromFilterToMap(object: NSManagedObject){
        
        self.filterView?.removeFromSuperview()
        view.endEditing(true)

        performSegue(withIdentifier: "moveToDetailView", sender: object)
    }
    
    
    @IBAction func unwindToMapFromDetailView(segue: UIStoryboardSegue) {

        mainMap.setRegion(self.reverseMainMapCenter as! MKCoordinateRegion, animated: true)
        
    }

    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "moveToDetailView", sender: view)
        }
    }
    
    
    func removeFilterView(sender: AnyObject){
        self.filterView?.removeFromSuperview()
        self.searchTextField.text = ""
        view.endEditing(true)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var selectedObjectData: NSManagedObject
        self.reverseMainMapCenter = mainMap.region as AnyObject?
        
        
        if (segue.identifier == "moveToDetailView" && sender is MKPinAnnotationView) {
            selectedObjectData = ((sender as! MKAnnotationView).annotation as! TagCustomAnnoation).objectData as NSManagedObject
            mainMap.showAnnotations([((sender as! MKAnnotationView).annotation as! TagCustomAnnoation)], animated: true)
        }else{
            selectedObjectData = sender as! NSManagedObject
            let tempAnnotation = MKPointAnnotation()
            tempAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedObjectData.value(forKey: "lat") as! CLLocationDegrees, longitude: selectedObjectData.value(forKey: "lng") as! CLLocationDegrees)
            mainMap.showAnnotations([tempAnnotation], animated: true)
        }
        
        //Convert to dictonary data type
        let senderDictonary: NSMutableDictionary = [:]
        senderDictonary.setValue(selectedObjectData.value(forKey: "name"), forKey: "name")
        senderDictonary.setValue(selectedObjectData.value(forKey: "bld_code"), forKey: "code")
        senderDictonary.setValue(selectedObjectData.value(forKey: "category"), forKey: "category")
        senderDictonary.setValue(selectedObjectData.value(forKey: "lat"), forKey: "lat")
        senderDictonary.setValue(selectedObjectData.value(forKey: "lng"), forKey: "lng")
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.data = senderDictonary
        
    }

    
    
    
    func textFieldSelected(sender:AnyObject){
        self.filterView = Filter_View(frame: CGRect(x: 15, y: 85, width: deviceSize.width - 30, height: deviceSize.height - 40), viewController: self)
        (self.filterView as! Filter_View).addTableData(mapData: self.globalMapData as NSArray)
        self.view.addSubview(self.filterView as! Filter_View)
    }
    
    
    
    
    func textFieldDidChange(sender: AnyObject){
        
        let mapData = mapDataModel()
        let filterMapData = mapData.searchMapData(searchText: self.searchTextField.text!) as [AnyObject]

        (self.filterView as! Filter_View).setFilteredMapData(filteredArray: filterMapData as NSArray)
        
    }
    
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

