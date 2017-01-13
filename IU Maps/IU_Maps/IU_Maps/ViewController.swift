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
import Google
import MapKit


class TagCustomAnnoation: MKPointAnnotation {
    var objectData: NSManagedObject!
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    let searchTextField: UITextField = UITextField()
    let mainMap = MKMapView()
    
    let blackBackground = UIView()
    var parentView = UIView()
    let searchBoxView = UIView()
    
    var reverseMainMapCenter:AnyObject? = nil
    var reverseMainMapZoom:AnyObject? = nil
    
    var globalMapData: [AnyObject] = []
    var filterView: AnyObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.blackBackground.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        self.blackBackground.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        mainMap.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        mainMap.delegate = self
        mainMap.tintColor = IUColors.crimson
        mainMap.showsUserLocation = true
        self.parentView.addSubview(mainMap)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Map")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.view.backgroundColor = UIColor.black
        
        parentView.frame = CGRect(x: 0, y: 0, width: deviceSize.width, height: deviceSize.height)
        parentView.layer.cornerRadius = 5
        parentView.clipsToBounds = true
        self.view.addSubview(parentView)
        
        searchBoxView.frame = CGRect(x: 15, y: 27, width: deviceSize.width - 30, height: 45)
        searchBoxView.backgroundColor = UIColor.white
        searchBoxView.layer.cornerRadius = 5.0
        searchBoxView.layer.borderWidth = 1.0
        searchBoxView.layer.borderColor = UIColor.clear.cgColor
        searchBoxView.layer.masksToBounds = true
        
        searchBoxView.layer.shadowColor = UIColor.lightGray.cgColor
        searchBoxView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        searchBoxView.layer.shadowRadius = 2.0
        searchBoxView.layer.shadowOpacity = 1.0
        searchBoxView.layer.masksToBounds = false
        self.view.addSubview(searchBoxView)
        
        let centerButtonBackground = UIView()
        centerButtonBackground.frame = CGRect(x: deviceSize.width - 75, y: deviceSize.height - 75, width: 60, height: 60)
        centerButtonBackground.backgroundColor = UIColor.white
        centerButtonBackground.layer.cornerRadius = 30.0
        centerButtonBackground.layer.borderWidth = 1.0
        centerButtonBackground.layer.borderColor = UIColor.clear.cgColor
        centerButtonBackground.layer.masksToBounds = true
        
        centerButtonBackground.layer.shadowColor = UIColor.lightGray.cgColor
        centerButtonBackground.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        centerButtonBackground.layer.shadowRadius = 2.0
        centerButtonBackground.layer.shadowOpacity = 1.0
        centerButtonBackground.layer.masksToBounds = false
        self.view.addSubview(centerButtonBackground)
        
        let centerButtonImage = UIImageView(image: UIImage(named: "center"))
        centerButtonImage.image = centerButtonImage.image!.withRenderingMode(.alwaysTemplate)
        centerButtonImage.tintColor = IUColors.crimson
        centerButtonImage.frame = CGRect(x: deviceSize.width - 62, y: deviceSize.height - 62, width: 34, height: 34)
        self.view.addSubview(centerButtonImage)
        
        let centerButton = UIButton()
        centerButton.frame = CGRect(x: deviceSize.width - 75, y: deviceSize.height - 75, width: 60, height: 60)
        centerButton.addTarget(self, action:#selector(ViewController.centerMap(sender:)), for:.touchUpInside)
        self.view.addSubview(centerButton)
        
        self.searchTextField.frame = CGRect(x: 0, y: 0, width: deviceSize.width - 105, height: 45)
        self.searchTextField.placeholder = "Try \"Wells Library\" or \"HH\""
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldDidChange(sender:)), for:UIControlEvents.editingChanged)
        self.searchTextField.addTarget(self, action:#selector(ViewController.textFieldSelected(sender:)), for:UIControlEvents.editingDidBegin)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.searchTextField.frame.size.height))
        self.searchTextField.leftView = paddingView
        self.searchTextField.leftViewMode = .always
        
        searchBoxView.addSubview(self.searchTextField)
        
        let closeButtonImage = UIImageView(image: UIImage(named: "close"))
        closeButtonImage.image = closeButtonImage.image!.withRenderingMode(.alwaysTemplate)
        closeButtonImage.tintColor = IUColors.grey
        closeButtonImage.frame = CGRect(x: Double((searchBoxView.frame.maxX - 50)), y: 12.5, width: 20.0, height: 20.0)
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
            mainMap.showAnnotations(mainMap.annotations, animated: false)
        }
        
        let defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.179171966319643, longitude: -86.516948181381849), span: MKCoordinateSpan(latitudeDelta: 0.0352384713549867, longitudeDelta: 0.026284824198924639))
        mainMap.setRegion(defaultRegion, animated: true)
    }
    
    func centerMap(sender: AnyObject){
        
        DispatchQueue.global(qos: .background).async {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "BUTTON", action: "CENTER_MAP", label: nil, value: nil).build()  as [NSObject : AnyObject])
        }
        
        let defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.179171966319643, longitude: -86.516948181381849), span: MKCoordinateSpan(latitudeDelta: 0.0352384713549867, longitudeDelta: 0.026284824198924639))
        mainMap.setRegion(defaultRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        pinView?.tintColor = IUColors.crimson
        pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.image = UIImage(named: "dot")
        pinView?.canShowCallout = true
        let rightButton: AnyObject! = UIButton(type: .detailDisclosure)
        pinView!.rightCalloutAccessoryView = rightButton as? UIView
        
        return pinView
    }
    
    
    func fromFilterToMap(object: NSManagedObject){
        
        DispatchQueue.global(qos: .background).async {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "SEARCH QUERY", action: String(describing: self.searchTextField.text!), label: nil, value: nil).build()  as [NSObject : AnyObject])
        }
        
        self.filterView?.removeFromSuperview()
        view.endEditing(true)
        performSegue(withIdentifier: "moveToDetailView", sender: object)
    }
    
    
    @IBAction func unwindToMapFromDetailView(segue: UIStoryboardSegue) {
        mainMap.setRegion(self.reverseMainMapCenter as! MKCoordinateRegion, animated: true)
        self.blackBackground.removeFromSuperview()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "moveToDetailView", sender: view)
        }
    }
    
    
    //    DispatchQueue.global(qos: .background).async {
    //    print("This is run on the background queue")
    //
    //    DispatchQueue.main.async {
    //    print("This is run on the main queue, after the previous code in outer block")
    //    }
    //    }
    
    //    let tracker = GAI.sharedInstance().defaultTracker
    //    let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
    //        withCategory: "SomeCategory",
    //        action: "SomeAction",
    //        label: "SomeLabel",
    //        value: nil).build()
    //    tracker.send(eventTracker as [NSObject : AnyObject]!)
    
    //    ga('send', 'event', {
    //    eventCategory: 'Outbound Link',
    //    eventAction: 'click',
    //    eventLabel: event.target.href
    //    });
    
    func removeFilterView(sender: AnyObject){
        self.filterView?.removeFromSuperview()
        self.searchTextField.text = ""
        view.endEditing(true)
        self.blackBackground.removeFromSuperview()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var selectedObjectData: NSManagedObject
        self.reverseMainMapCenter = mainMap.region as AnyObject?
        
        if (segue.identifier == "moveToDetailView" && sender is MKAnnotationView) {
            selectedObjectData = ((sender as! MKAnnotationView).annotation as! TagCustomAnnoation).objectData as NSManagedObject
            mainMap.showAnnotations([((sender as! MKAnnotationView).annotation as! TagCustomAnnoation)], animated: true)
            mainMap.selectAnnotation(((sender as! MKAnnotationView).annotation as! TagCustomAnnoation), animated: true)
        }else{
            selectedObjectData = sender as! NSManagedObject
            let tempAnnotation = MKPointAnnotation()
            tempAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedObjectData.value(forKey: "lat") as! CLLocationDegrees, longitude: selectedObjectData.value(forKey: "lng") as! CLLocationDegrees)
            mainMap.showAnnotations([tempAnnotation], animated: true)
            mainMap.selectAnnotation(tempAnnotation, animated: true)
        }
        
        self.view.addSubview(self.blackBackground)
        
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
        self.view.addSubview(self.blackBackground)
        
        self.view.addSubview(self.searchBoxView)
        searchBoxView.addSubview(self.searchTextField)
        self.searchTextField.becomeFirstResponder()
        
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

