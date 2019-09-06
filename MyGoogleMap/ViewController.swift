//
//  ViewController.swift
//  MyGoogleMap
//
//  Created by INVISION on 25/8/2562 BE.
//  Copyright © 2562 INVISION. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import DynamicColor
import LMGeocoder
import RandomColorSwift
import Alamofire

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mMapView: GMSMapView!
    var locationManager: CLLocationManager!
    var locationInPlist: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMap()
//        self.setupTracking()
        self.loadMarker()
        self.loadPolygon()
        
    
    }

    @IBAction func switchMapType (sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            self.mMapView.mapType = .normal
        case 1:
            self.mMapView.mapType = .satellite
        default:
            self.mMapView.mapType = .hybrid
        }
    }
    
    // Setup Map
    func setupMap() {
        self.mMapView.settings.compassButton = true
        self.mMapView.settings.myLocationButton = true
        self.mMapView.isMyLocationEnabled = true
        self.mMapView.isTrafficEnabled = true
        self.mMapView.delegate = self
    }
    
//     Tracking Map
    func setupTracking(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 50.0 // Metre
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("updata location")
        if let currentLocation = locations.first{
        self.mMapView.camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 15.0)
        }
    }
    
//     Pin Map
    func loadMarker(){
        let filePath = Bundle.main.path(forResource: "Locations", ofType: "plist")!  //Load Location
        self.locationInPlist = NSArray(contentsOfFile: filePath)! as [AnyObject]
//        print(self.locationInPlist)
        
        var bounds = GMSCoordinateBounds()
        for locationDict in self.locationInPlist{
            
            let marker_lat = locationDict["latitude"] as! Double
            let marker_lng = locationDict["longitude"] as! Double
            let marker_title = locationDict["name"] as! String
            let marker_icon = locationDict["image"] as! String
            
            let position = CLLocationCoordinate2D(latitude: marker_lat, longitude: marker_lng)
            let marker = GMSMarker(position: position)
            marker.title = marker_title
            marker.icon = UIImage(named: marker_icon)
            marker.map = self.mMapView
            bounds = bounds.includingCoordinate(marker.position)
        }
        
        self.mMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80))
    }
    
//     Draw line Polygon
    func loadPolygon() {
        let path = GMSMutablePath()
        for locationDict in self.locationInPlist{
            let marker_lat = locationDict["latitude"] as! Double
            let marker_lng = locationDict["longitude"] as! Double
            path.addLatitude(marker_lat, longitude:marker_lng)
        }
        let polygon = GMSPolygon()
        polygon.path = path
        polygon.fillColor = UIColor(hexString: "#1193F4").withAlphaComponent(0.3)
        polygon.strokeColor = UIColor(hexString: "#1193F4").withAlphaComponent(0.6)
        polygon.strokeWidth = 2
        polygon.isTappable = true
        polygon.map = self.mMapView
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {  //ดัก overlay ของ polygon
//        print(overlay)
        if let polygon = overlay as? GMSPolygon {
            polygon.fillColor = randomColor(hue: .random, luminosity: .dark).withAlphaComponent(0.3)
        }else if let polyline = overlay as? GMSPolyline {
            polyline.strokeColor = randomColor(hue: .random, luminosity: .dark).withAlphaComponent(0.7)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//       print("Long Press")
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.performSegue(withIdentifier: "Street", sender: location) // ส่งค่า method
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  // segue คือไว้เปลี่ยนหน้า หรือส่งค่าไปหน้าอื่น ๆ
        if let targetVC = segue.destination as? StreetViewController {
            targetVC.position = (sender as! CLLocation).coordinate
        }
        
    }
    
    func sendLocationToDatabase(title: String, lat: Double, lng: Double){   //send location to database
        let params: Parameters = ["lat": lat, "lng": lng, "title": title]
        let url = "http://192.168.0.135:8081/location"
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { (response) in
            switch response.result {
                case.success(let value):
                    if let dict = value as? NSDictionary {
                        if let rs = dict["result"] as? String {
                            self.showAlertWithCloseOutSideEnable(responseMsg: rs)
                        }
                    }
                    break;
            default:
                print(response.error ?? "unknow error")
            }
        }
    }
    
    func showAlertWithCloseOutSideEnable(responseMsg:String){
        let alertVC = UIAlertController(title: "Response", message: responseMsg, preferredStyle: .alert)
        self.present(alertVC, animated: true) {
            alertVC.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose(_:))))
        }
    }
    
    @objc func alertClose(_ alert:UIAlertController){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    @IBAction func onClickSearch(sender: AnyObject){ // ปุ่ม search
        let placeVC = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.country = "TH"
        placeVC.autocompleteFilter = filter
        placeVC.delegate = self
        present(placeVC, animated: true, completion: nil)
        
    }
    
    func addMarker(title: String, snippet: String, coordinate: CLLocationCoordinate2D){ // add marker
        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.snippet = snippet
        marker.appearAnimation = .pop
        marker.icon = UIImage(named: "user_pin")
        marker.map = self.mMapView
        self.mMapView.selectedMarker = marker
        self.mMapView.animate(toLocation: coordinate)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addMarker(title: place.name!, snippet: place.formattedAddress!, coordinate: place.coordinate)
        dismiss(animated: true, completion: nil)
        self.sendLocationToDatabase(title: place.name!, lat: place.coordinate.latitude, lng: place.coordinate.longitude)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
