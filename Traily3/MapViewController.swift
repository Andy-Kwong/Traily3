//
//  ViewController.swift
//  Traily3
//
//  Created by Andy Kwong on 1/18/18.
//  Copyright © 2018 Andy Kwong. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    
    var lat: Double = 0.0
    var long: Double = 0.0
    
    let locationManager = CLLocationManager()
    
    var mapView: MGLMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableBasicLocationServices()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 45.5076, longitude: -122.6736),
                          zoomLevel: 11, animated: false)
        view.addSubview(self.mapView)
        
        mapView.delegate = self
        let annotation = MyCustomPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.3753997, longitude: -121.9101584)
        annotation.title = "Coding Dojo"
        annotation.subtitle = "The Dojo, Yo"
        annotation.willUseImage = false
        mapView.addAnnotation(annotation)
        
        mapView.showsUserLocation = true
        
        drawPolyline()
        self.printWayPoints()

    }
    
    func drawPolyline() {
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        
        DispatchQueue.global(qos: .background).async(execute: {
            // Get the path for example.geojson in the app's bundle
            let jsonPath = Bundle.main.path(forResource: "tracks2", ofType: "geojson")
            let url = URL(fileURLWithPath: jsonPath!)
            
            do {
                // Convert the file contents to a shape collection feature object
                let data = try Data(contentsOf: url)
                let shapeCollectionFeature = try MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature
                
                if let polyline = shapeCollectionFeature.shapes.first as? MGLPolylineFeature {
                    // Optionally set the title of the polyline, which can be used for:
                    //  - Callout view
                    //  - Object identification
                    polyline.title = polyline.attributes["name"] as? String
                    
                    // Add the annotation on the main thread
                    DispatchQueue.main.async(execute: {
                        // Unowned reference to self to prevent retain cycle
                        [unowned self] in
                        self.mapView.addAnnotation(polyline)
                    })
                }
            }
            catch {
                print("GeoJSON parsing failed")
            }
            
        })
        
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 2.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            // Mapbox cyan
            return UIColor(red: 59/255, green:178/255, blue:208/255, alpha:1)
        }
        else
        {
            return .red
        }
    }
    
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            enableMyWhenInUseFeatures()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            enableMyWhenInUseFeatures()
            break
            
        case .notDetermined, .authorizedAlways:
            break
        }
    }
    
    func disableMyLocationBasedFeatures(){
        print("disableMyLocationBasedFeatures")
    }
    
    func enableMyWhenInUseFeatures(){
        print("enableMyWhenInUseFeaatures")
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 1.0 // In meters.
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if self.lat == 0.0 {
            self.lat = lastLocation.coordinate.latitude
            self.long = lastLocation.coordinate.longitude
            mapView.setCenter(CLLocationCoordinate2D(latitude: self.lat, longitude: self.long),
                              zoomLevel: 11, animated: false)
        } else {
            calcDistance(latitude1: self.lat, longitude1: self.long, latitude2: lastLocation.coordinate.latitude , longitude2: lastLocation.coordinate.longitude)
        }
        
        // Do something with the location.
    }
    
    func calcDistance (latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) -> Double {
        
        let coordinate1 = CLLocation(latitude: latitude1, longitude: longitude2)
        let coordinate2 = CLLocation(latitude: latitude2, longitude: longitude2)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2) // result is in meters
        print(distanceInMeters)
        return distanceInMeters
    }
    
    func popUp() {
        let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // This delegate method is where you tell the map to load a view for a specific annotation based on the willUseImage property of the custom subclass.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        // Assign a reuse identifier to be used by both of the annotation views, taking advantage of their similarities.
        let reuseIdentifier = "reusableDotView"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
            annotationView?.layer.borderWidth = 4.0
            annotationView?.layer.borderColor = UIColor.white.cgColor
            annotationView!.backgroundColor = UIColor(red:0.03, green:0.80, blue:0.69, alpha:1.0)
        }
        
        return annotationView
    }
    
    // This delegate method is where you tell the map to load an image for a specific annotation based on the willUseImage property of the custom subclass.
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        // For better performance, always try to reuse existing annotations.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "camera")
        
        // If there is no reusable annotation image available, initialize a new one.
        if(annotationImage == nil) {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "camera")!, reuseIdentifier: "camera")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func printWayPoints() {
        if let path = Bundle.main.path(forResource: "waypoints", ofType: "geojson") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let features : [NSDictionary] = jsonResult["features"] as? [NSDictionary] {
                        for waypoint: NSDictionary in features {
                            let annotation = MyCustomPointAnnotation()
                            for (name,value) in waypoint {
                                let key = name as! String
                                if key == "geometry" {
                                    let geometryfeatures = waypoint[key] as! NSDictionary
                                    for(geo_key, geo_val) in geometryfeatures {
                                        let geo_string = geo_key as! String
                                        if geo_string == "coordinates" {
                                        let coord_arr = geo_val as! [Double]
                                            annotation.coordinate = CLLocationCoordinate2D(latitude: coord_arr[1], longitude: coord_arr[0])
                                        print("lat: \(coord_arr[1])")
                                        print("long: \(coord_arr[0])")
                                        }
                                    }
                                }
                                if key == "properties" {
                                    let waypointfeatures = waypoint[key] as! NSDictionary
                                    for(k, v) in waypointfeatures {
                                        let key_string = k as! String
                                        if key_string == "desc"{
                                            annotation.title = v as! String
                                            print("Description: \(v)")
                                        } else if key_string == "name"{
                                            print("Name: \(v)")
                                            annotation.subtitle = v as! String
                                        }
                                    }
                                }
                            }
                            
                            annotation.willUseImage = false
                            print("AT ANNOTATION \(annotation.willUseImage)")
                            mapView.addAnnotation(annotation)
                        }
                    }
                } catch {}
            } catch {}
        }
    }
    
}


class MyCustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
}

