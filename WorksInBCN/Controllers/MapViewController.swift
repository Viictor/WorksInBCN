//
//  MapViewController.swift
//  WorksInBCN
//
//  Created by Victor Gabriel on 15/7/15.
//  Copyright (c) 2015 Digital Dosis. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    var firstLocation = false;
    var cards:Array<NSDictionary> = []
    var coordinates:NSArray = [];
    var moreInfoButton: MoreInfo = MoreInfo()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestLocation();
        mapView.delegate = self;
        setCamera();
        
        if ( downloadData() ) {
            loadWorksInMap()
            drawShapesInMap()
            
        } else {
            NSLog("Error downloading data")
        }
    }
    
    func locationNotification(latitude : Double, longitude : Double, radius: Double, identifier: String) {

        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = "Ok"
        localNotification.alertBody = identifier
        localNotification.regionTriggersOnce = true;
        localNotification.region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:
            latitude, longitude: longitude), radius: radius, identifier: identifier)
        localNotification.region!.notifyOnEntry = true;
        
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1;
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func requestLocation() {
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
    }
    
    func setCamera() {
        mapView.camera = GMSCameraPosition.cameraWithLatitude(41.388673, longitude: 2.156578, zoom: 13);
    }
    
    func downloadData() -> Bool {
        let error: NSError? = nil
        
        let mainBundle: NSBundle = NSBundle.mainBundle()
        let jsonFile: String = mainBundle.pathForResource("obres", ofType: "json")!
        
        
        let data: NSData = try! NSData(contentsOfFile: jsonFile, options: .DataReadingUncached)
        
        if (error != nil) {
            NSLog("Error %@", error!)
            return false
        }
        
        let obra = (try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as! Array<NSDictionary>
        
        if (error != nil) {
            NSLog("Error %@", error!)
            return false
        
        }
        cards = obra;
        
        loadCoordinates()
        
        return true
    }
    
    func loadCoordinates() -> Bool {
        
        let error: NSError? = nil
        
        let mainBundle: NSBundle = NSBundle.mainBundle()
        let jsonFile: String = mainBundle.pathForResource("coordinates", ofType: "json")!
        
        let data: NSData = try! NSData(contentsOfFile: jsonFile, options: .DataReadingUncached)
        
        if (error != nil) {
            NSLog("Error %@", error!)
            return false
        }
        
        let coords = (try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as! NSArray
        coordinates = coords;
        
        
        if (error != nil) {
            NSLog("Error %@", error!)
            return false
        }
        
        return true;
    }
    
    func loadWorksInMap() {
        
        let markerIcon = UIImage(named: "Pin")
        
        for var i = 0; i < self.cards.count; i++ {
            
            
            let card : NSDictionary = cards[i]
            
            var coordinates: UTMCoordinates = UTMCoordinates()
            coordinates.gridZone = 31
            coordinates.hemisphere = kUTMHemisphereNorthern
            
            
            coordinates.northing = (((card.valueForKeyPath("card.address.geo") as! NSDictionary)["@attributes"] as! NSDictionary)["latitude"] as! NSString).doubleValue
            
            coordinates.easting = (((card.valueForKeyPath("card.address.geo") as! NSDictionary)["@attributes"] as! NSDictionary)["longitude"] as! NSString).doubleValue
            
            let converter: GeodeticUTMConverter = GeodeticUTMConverter()
            let mark: CLLocationCoordinate2D = converter.UTMCoordinatesToLatitudeAndLongitude(coordinates)
            
            let marker = GMSMarker(position: mark)
            
            marker.title = card.valueForKeyPath("card.title") as! String
            
            marker.snippet = card.valueForKeyPath("card.period") as! NSString as String
            marker.icon = markerIcon
            marker.userData = card
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView
        }
    }
    
    func drawShapesInMap() {
        
        for var i = 0; i < self.cards.count; i++ {
        
            let coords = coordinates[i] as! NSArray;
            
            // Discard null values
            if let _ = coords[0][0] as? NSString {
            
                let rect = GMSMutablePath()
                rect.addCoordinate(CLLocationCoordinate2DMake( ( coords[0][0] as! NSString ).doubleValue, ( coords[1][0] as! NSString ).doubleValue));
                rect.addCoordinate(CLLocationCoordinate2DMake( ( coords[0][1] as! NSString ).doubleValue, ( coords[1][1] as! NSString ).doubleValue));
                rect.addCoordinate(CLLocationCoordinate2DMake( ( coords[0][2] as! NSString ).doubleValue, ( coords[1][2] as! NSString ).doubleValue));
                rect.addCoordinate(CLLocationCoordinate2DMake( ( coords[0][3] as! NSString ).doubleValue, ( coords[1][3] as! NSString ).doubleValue));
        
                let card : NSDictionary = cards[i]
                let polygon = GMSPolygon(path: rect)
        
                polygon.strokeWidth = CGFloat(i)
                polygon.title = card.valueForKeyPath("card.title") as! String
                polygon.fillColor = UIColor(red:0.49, green:0.46, blue:0.84, alpha:0.8)
                polygon.strokeColor = UIColor.clearColor()
                polygon.map = mapView
            
                polygon.tappable = true;
            }
        }
        
    }
    
    func moreInfoAction(sender : AnyObject) {
        
        let button = sender as! MoreInfo;
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let moreInfoView = storyboard.instantiateViewControllerWithIdentifier("MoreInfoView") as! MoreInfoViewController
        moreInfoView.obraInfo = button.marker.userData as! NSDictionary;

        self.navigationController?.pushViewController(moreInfoView, animated: true)
    }
    
    /** GMSMAPS DELEGATE METHODS **/
    
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        
        let area = overlay as! GMSPolygon
        
        let nWork = Int(area.strokeWidth);
        
        let marker = GMSMarker()
        marker.userData = cards[nWork];
        
        self.mapView(self.mapView, didTapMarker: marker)
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        moreInfoButton.alpha = 0.0;
        
        let button = MoreInfo()
        
        button.isRaised = true
        
        button.frame.size = CGSize(width: 55, height: 55)
        button.cornerRadius = button.frame.size.width / 2;
        button.rippleFromTapLocation = true;
        button.rippleBeyondBounds = false;
        button.tapCircleDiameter = max(button.frame.size.width, button.frame.size.height) * 1.3;
        button.titleFont = UIFont(name: "Avenir Next", size: 16)
        button.setImage(UIImage(named: "Plus-white"), forState: .Normal)
        button.backgroundColor = UIColor(red:0.95, green:0.44, blue:0.38, alpha:1)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
        button.marker = marker
        button.translatesAutoresizingMaskIntoConstraints = false
        
        moreInfoButton = button;
        
        moreInfoButton.addTarget(self, action: "moreInfoAction:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(moreInfoButton);
        
        let leftConstraint = NSLayoutConstraint(item: moreInfoButton,
            attribute: NSLayoutAttribute.Left,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0,
            constant: 10.0);
        
        let bottomConstraint = NSLayoutConstraint(item: moreInfoButton,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.BottomMargin,
            multiplier: 1.0,
            constant: -10.0);
        
        let constraintButtonWidth = NSLayoutConstraint (item: moreInfoButton,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: 55)
        
        let constraintButtonHeight = NSLayoutConstraint (item: moreInfoButton,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: 55)
        
        self.view.addConstraint(constraintButtonWidth)
        self.view.addConstraint(constraintButtonHeight)
        self.view.addConstraint(bottomConstraint)
        self.view.addConstraint(leftConstraint)
        
        return false;
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        moreInfoButton.alpha = 0;
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let button = MoreInfo()
        button.marker = marker;
        moreInfoAction(button);
    }
    
    func registerNotifications () {
        
        for var i = 0; i < self.cards.count; i++ {
            
            let card : NSDictionary = cards[i]
            
            var coordinates: UTMCoordinates = UTMCoordinates()
            coordinates.gridZone = 31
            coordinates.hemisphere = kUTMHemisphereNorthern
            coordinates.northing = (((card.valueForKeyPath("card.address.geo") as! NSDictionary)["@attributes"] as! NSDictionary)["latitude"] as! NSString).doubleValue
            coordinates.easting = (((card.valueForKeyPath("card.address.geo") as! NSDictionary)["@attributes"] as! NSDictionary)["longitude"] as! NSString).doubleValue
            let title = card.valueForKeyPath("card.title") as! String
            
            let converter: GeodeticUTMConverter = GeodeticUTMConverter()
            let mark: CLLocationCoordinate2D = converter.UTMCoordinatesToLatitudeAndLongitude(coordinates)
            
            locationNotification( mark.latitude , longitude:  mark.longitude, radius: 200, identifier: title)
        }
    }
    
    /** LOCATION DELEGATE METHODS **/
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true;
            registerNotifications();
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation! {
            
            if ( !firstLocation ) {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                firstLocation = true;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
