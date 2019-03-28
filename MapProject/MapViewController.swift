//
//  LocationManager.swift
//  MapProject
//
//  Created by Rafae on 2018-07-31.
//  Copyright © 2018 Rafae. All rights reserved.
//
import MapKit
import CoreLocation

import Foundation
class MapViewController: ViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var locValue = CLLocationCoordinate2D()
    var currentValue = CLLocationCoordinate2D()

    var timer = Timer()
    var selectedAnnotation: MKPointAnnotation?
    var totalDistance : Double = 0.0
    var annotations = [MKAnnotation]()
    
    var distance : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.showAnnotations(annotations, animated: true)
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.counting), userInfo: nil, repeats: true)
        
    }
    
    @objc func counting() {
        print("counting....")
        print("Sending Post Request")
        postRequest()
        print("TIMER latitude:\(locValue.latitude), latitude:\(locValue.longitude)")
        addAnnotations(locValue)

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let localValue = manager.location?.coordinate else {return}
        self.currentValue = localValue
        
        calculateDistance()
        
        let span = MKCoordinateSpanMake(0.007, 0.007)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
//        addAnnotations(locValue)
        self.locValue = self.currentValue
        
//        print("latitude:\(locValue.latitude), latitude:\(locValue.longitude)")
        print("distance per interval: \(self.distance)")
        
    }
    
    func addAnnotations(_ coordinate: CLLocationCoordinate2D) -> Void {
        
        let annotation = MKPointAnnotation();
        annotation.coordinate = coordinate
        annotation.title = "The Road to Nowhere"
        annotation.subtitle = "current location"
        self.annotations.append(annotation)
        mapView.addAnnotations(annotations)
        
    }
    
    func calculateDistance() -> Void {
        
        let annotations = self.annotations

//            let coordinate = item.coordinate
        let location = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
        
//            let originValue = self.locValue
        let originLocation = CLLocation(latitude: self.currentValue.latitude, longitude: self.currentValue.longitude)
        self.distance = originLocation.distance(from: location)
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let currentAnnotation = view.annotation as? MKPointAnnotation else {return}
    }
    
    func postRequest() -> Void  {
        let latitude = self.locValue.latitude
        let longitude = self.locValue.longitude
        
        let data : [String: Double]
        data = ["latitude":  latitude, "longitude": longitude]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        guard let url = URL(string: "http://localhost:3000/home") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                print(error?.localizedDescription ?? "No data")
                
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String  : Any] {
                print("Success! Made conection to localhost:3000")
                print(responseJSON)
            }
            
        }
        task.resume()
        
    
    }

    
}
