//
//  ViewController.swift
//  mapKitTest
//
//  Created by Nigel Haney :-) on 3/8/18.
//  Copyright © 2018 Nigel Haney :-). All rights reserved.
//

import UIKit
import MapKit
import CoreMotion
import CoreLocation

//keyboard extension to hide keyboard when tapped outside
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(false, animated:true)
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(true, animated:false)
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapViewer: MKMapView!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var geoLabel: UILabel!
    //@IBOutlet weak var searchTextField: UITextField!
    
    
    @IBAction func resetViewButton(_ sender: Any) {
        let region = MKCoordinateRegion(center: wsuCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapViewer.setRegion(region, animated: true)
        }
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var testTextField: UITextField!
    
    @IBAction func currentLocationButton(_ sender: Any) {
        hidePinButtons()
        testTextField.text = ""
        if isInRegion(coord: mapViewer.userLocation.coordinate) {
            lookupLocation()
            
            //catches weird problem where on first press this doesn't work, just gotta press it again
            if(newLocation)
            {
                newLocation = false
                let region = MKCoordinateRegion(center: mapViewer.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapViewer.setRegion(region, animated: true)
                //print(locationManager.location)
                lookupLocation();
                print(selectedLocation)
                let newAddress = selectedLocation
                geoLabel.textColor = UIColor.green
                geoLabel.text = "Current Selection: \(newAddress)"
                validSelectionStatus = true
                //add an annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = selectedCoordinates
                annotation.title = newAddress
                self.mapViewer.removeAnnotations(self.mapViewer.annotations)
                self.mapViewer.addAnnotation(annotation)
                validSelectionStatus = true
                showToolBar()
            }
        }
        else
        {
            //error - not in WSU
            errorMessageDisplay(error: "Address not in WSU area.")
            pinDropped = false
            print("Address not in WSU area, could not select")
            validSelectionStatus = false
            hideToolBar()
        }
        if(geoLabel.text != "Current Selection: \(selectedLocation)")
        {
            geoLabel.text = "Current Selection: \(selectedLocation)"
        }
    }
    @IBAction func fromMapButton(_ sender: Any) {
        showPinButtons()
        testTextField.text = ""
        let center = mapViewer.centerCoordinate
        if(isInRegion(coord: center))
        {
            let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
            lookupLocationAt(loc: location)
        }
        else
        {
            canDropPin = false
            updatePinButtons()
        }
    }
    
    @IBOutlet weak var mapPin: UIImageView!
    
    @IBOutlet weak var dropPinButton: UIButton!
    @IBAction func dropPinAction(_ sender: Any) {
        //update selected location
        mapPin.isHidden = true
        //no zoom in on this one feels better!
        /*let region = MKCoordinateRegion(center: selectedCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapViewer.setRegion(region, animated: true)*/
        let newAddress = selectedLocation
        geoLabel.textColor = UIColor.green
        geoLabel.text = "Current Selection: \(newAddress)"
        validSelectionStatus = true
        //add an annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinates
        annotation.title = newAddress
        self.mapViewer.removeAnnotations(self.mapViewer.annotations)
        self.mapViewer.addAnnotation(annotation)
        canDropPin = false
        validSelectionStatus = true
        pinDropped = true
        dropPinButton.isEnabled = false
        showToolBar()
    }
    
    @IBOutlet weak var removePinButton: UIButton!
    @IBAction func removePinAction(_ sender: Any) {
        self.mapViewer.removeAnnotations(self.mapViewer.annotations)
        pinDropped = false
        mapPin.isHidden = false
        validSelectionStatus = false
        geoLabel.textColor = UIColor.white
        geoLabel.text = "Current Selection: "
        canDropPin = true
        dropPinButton.isEnabled = true
        hideToolBar()
    }
    @IBOutlet weak var pinLabel: UILabel!
    
    //string that stores the selected location
    var selectedLocation = ""
    var selectedCoordinates = CLLocationCoordinate2D()
    var newLocation = false
    //bool that tells if a location has been selected yet
    var validSelectionStatus = false
    //bool that allows user to set pin
    var canDropPin = false
    var pinDropped = false
    
    var locationManager: CLLocationManager!
    var geoCoder = CLGeocoder()
    
    let wsuCoordinates = CLLocationCoordinate2DMake(46.7319, -117.1542)
    var wsuRegion = MKCoordinateRegion()
    
    //checks to see if a coordinate is inside WSU
    func isInRegion(coord: CLLocationCoordinate2D) -> Bool
    {
        let location = coord
        let center   = wsuRegion.center
        var northWestCorner = CLLocationCoordinate2D()
        var southEastCorner = CLLocationCoordinate2D()
        
        northWestCorner.latitude  = center.latitude  - (wsuRegion.span.latitudeDelta  / 2.0);
        northWestCorner.longitude = center.longitude - (wsuRegion.span.longitudeDelta / 2.0);
        southEastCorner.latitude  = center.latitude  + (wsuRegion.span.latitudeDelta  / 2.0);
        southEastCorner.longitude = center.longitude + (wsuRegion.span.longitudeDelta / 2.0);
        
        if (
            location.latitude  >= northWestCorner.latitude &&
                location.latitude  <= southEastCorner.latitude &&
                
                location.longitude >= northWestCorner.longitude &&
                location.longitude <= southEastCorner.longitude
            )
        {
            //coordinate inside region
            return true
        }
        else
        {
            //coordinate outside region
            return false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hidePinButtons()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Here")
        findSearched(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Text field should return")
        print("\(textField.text!)")
        textField.resignFirstResponder()
        print("Text field should have resigned first responder status")
        return false;
    }

    
    func lookupLocation() {
        if let location = locationManager.location {
            geoCoder.reverseGeocodeLocation(location,
                                            completionHandler: geoCodeHandler)
        }
    }
    
    func lookupLocationAt(loc: CLLocation)
    {
        geoCoder.reverseGeocodeLocation(loc, completionHandler: geoCodeHandler)
    }
    
    func geoCodeHandler (placemarks: [CLPlacemark]?, error: Error?)
    {
        if let placemark = placemarks?.first
        {

                if let addressName = placemark.subThoroughfare{
                    let name = "\(placemark.subThoroughfare!) \(placemark.thoroughfare!)"
                    print("place name = \(name)")
                    //geoLabel.text = "Current Selection: \(name)"
                    selectedLocation = name
                    selectedCoordinates = (placemark.location?.coordinate)!
                    newLocation = true
                    canDropPin = true
                    if dropPinButton.isHidden == false
                    {
                        updatePinButtons()
                    }
                }
                else
                {
                    canDropPin = false
                    updatePinButtons()
                }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if let latitude = location?.coordinate.latitude {
            latLabel.text = "\(String(format:"%.6f", latitude))"
        }
        if let longitude = location?.coordinate.longitude {
            longLabel.text = "\(String(format:"%.6f", longitude))"
        }
    }
    
    // Delegate method called if location unavailable (recommended)
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        NSLog("locationManager error: \(error.localizedDescription)") }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse)) {
            self.startLocation()
        }
        else {
            self.stopLocation()
        }
    }
    
    func startLocation () {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapViewer.showsUserLocation = true
        let region = MKCoordinateRegion(center: wsuCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        mapViewer.setRegion(region, animated: false)
        //mapViewer.userTrackingMode = .follow
    }
    func stopLocation () {
        locationManager.stopUpdatingLocation()
    }
    
    func initializeLocation() { // called from start up method
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocation()
        case .denied, .restricted:
            print("location not authorized")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //search functionality
    func findSearched(_ search: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = search
        //search only happens in wsuRegion
        request.region = wsuRegion
        let search = MKLocalSearch(request: request)
        search.start(completionHandler: searchHandler)
    }
    
    func searchHandler (response: MKLocalSearchResponse?, error: Error?) {
        if let err = error {
            print("Error occured in search: \(err.localizedDescription)")
        } else if let resp = response {
            print("\(resp.mapItems.count) matches found")
            self.mapViewer.removeAnnotations(self.mapViewer.annotations)
            for item in resp.mapItems {
                //check to see if in WSU region - gets 1st one in region
                if(isInRegion(coord: item.placemark.coordinate) && searchIsDetailed(place: item.placemark))
                {
                    //zoom in camera to location
                    let region = MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    mapViewer.setRegion(region, animated: true)
                    //update selected location
                    let newAddress = getAddressFromPlacemark(place: item.placemark)
                    geoLabel.textColor = UIColor.green
                    geoLabel.text = "Current Selection: \(newAddress)"
                    selectedLocation = newAddress
                    validSelectionStatus = true
                    //add an annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.mapViewer.addAnnotation(annotation)
                    showToolBar()
                    break
                }
                else
                {
                    //error - not in WSU
                    if(searchIsDetailed(place: item.placemark))
                    {
                        errorMessageDisplay(error: "Address not in WSU area.")
                        pinDropped = false
                        print("Address not in WSU area, could not select")
                    }
                    else
                    {
                        errorMessageDisplay(error: "Search not detailed enough.")
                        pinDropped = false
                        print("Search not detailed enough, please try again.")
                    }
                    validSelectionStatus = false
                    hideToolBar()
                }
            }
        }
    }
    
    //checks to see if a valid address is available for the location
    func searchIsDetailed(place: MKPlacemark) -> Bool
    {
        if place.subThoroughfare != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    //gets the address from a placemark (format: subthoroughfare thoroughfare
    func getAddressFromPlacemark(place: MKPlacemark) -> String
    {
        var addressString = ""
        
        if place.subThoroughfare != nil {
            addressString = addressString + place.subThoroughfare! + " "
        }
        if place.thoroughfare != nil {
            addressString = addressString + place.thoroughfare!
        }
        
        return addressString
    }
    
    
    //displays error message and changes text to red
    func errorMessageDisplay(error: String)
    {
        geoLabel.textColor = UIColor.magenta
        geoLabel.text = "Current Selection: \(error)"
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if(dropPinButton.isHidden == false)
        {
            let center = mapView.centerCoordinate
            if(isInRegion(coord: center) && pinDropped == false)
            {
                let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
                lookupLocationAt(loc: location)
                canDropPin = true
                updatePinButtons()
            }
            else
            {
                canDropPin = false
                updatePinButtons()
            }
        }
    }
    
    func showPinButtons()
    {
        dropPinButton.isHidden = false
        removePinButton.isHidden = false
        pinLabel.isHidden = false
        if(pinDropped == false)
        {
            mapPin.isHidden = false
        }
        
    }
    
    func hidePinButtons()
    {
        dropPinButton.isHidden = true
        removePinButton.isHidden = true
        pinLabel.isHidden = true
        mapPin.isHidden = true
    }
    
    func updatePinButtons()
    {
        if(canDropPin)
        {
            if(pinDropped == false)
            {
                dropPinButton.isEnabled = true
                mapPin.isHidden = false
            }
            pinLabel.textColor = UIColor.green
            pinLabel.text = "Valid Drop Point: \(selectedLocation)"
        }
        else
        {
            dropPinButton.isEnabled = false
            pinLabel.textColor = UIColor.magenta
            if(pinDropped)
            {
                pinLabel.text = "Remove pin to drop a new one!"
            }
            else
            {
                pinLabel.text = "Invalid Drop Point"
            }
            mapPin.isHidden = true
        }
    }
    
    func hideToolBar()
    {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
    func showToolBar()
    {
        if(selectedLocation != "")
        {
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                navigationController.setToolbarHidden(true, animated: true)
            }
        }
        else
        {
            errorMessageDisplay(error: "Something went wrong")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toDetails") {
            let page2VC = segue.destination as! ReportViewController
            page2VC.selectedLocation = self.selectedLocation
        }
    }
    //unwind from second view
    @IBAction func unwindFromSecondView (sender: UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigation bar stuff
        self.navigationController?.presentTransparentNavigationBar()
        //let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        //navigationController?.navigationBar.titleTextAttributes = textAttributes
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).textColor = UIColor.white
        
        
        navigationItem.title = "Report Location"
        navigationItem.prompt = ""
        //delegates
        testTextField.delegate = self
        self.mapViewer.delegate = self
        hideKeyboardWhenTappedAround()
        
        //temporary overlay with phones coordinates, using for debugging for now
        latLabel.layer.zPosition = 1
        longLabel.layer.zPosition = 1
        
        //hide the mapPin initially and adjust it
        mapPin.layer.position = mapViewer.layer.position
        mapPin.layer.position.y = mapPin.layer.position.y - 100
        mapPin.layer.position.x = mapPin.layer.position.x - 10
        mapPin.isHidden = true
        //hide the pin dropping interface initially
        hidePinButtons()
        
        //set the WSU region (will be refined later)
        wsuRegion = MKCoordinateRegionMake(wsuCoordinates, MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
        
        //hide the toolbar
        hideToolBar()
        
        //initialize label
        geoLabel.textColor = UIColor.white
        geoLabel.text = "Current Selection: "
        //remove any previous annotations
        self.mapViewer.removeAnnotations(self.mapViewer.annotations)
        pinDropped = false
        canDropPin = false
        //text field initialization
        testTextField.text = ""
    
        //start location services
        initializeLocation()
        startLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

