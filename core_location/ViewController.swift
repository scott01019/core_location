//
//  ViewController.swift
//  core_location
//
//  Created by Scott Burnette on 3/15/18.
//  Copyright © 2018 Scott Burnette. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var timer : Timer = Timer()
    var totalDistance : CLLocationDistance = 0.0
    var minAltitude : CLLocation?
    var maxAltitude : CLLocation?
    var lastLocation : CLLocation?
    @IBOutlet weak var mapView : MKMapView!
    var locationManager : CLLocationManager = CLLocationManager()
    
    @IBAction func startButtonPressed(_ sender: UIBarButtonItem) {
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        lastLocation = locationManager.location!
        minAltitude = lastLocation
        maxAltitude = lastLocation
        pin(location: lastLocation!)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    @IBAction func stopButtonPressed(_ sender: UIBarButtonItem) {
        pin(location: locationManager.location!)
        locationManager.stopUpdatingLocation()
    }
    
    func pin(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView.addAnnotation(annotation)
    }
    
    func drawRedLine(start: CLLocation, end: CLLocation) {
        let coordinates = [ CLLocationCoordinate2D(latitude: start.coordinate.latitude, longitude: start.coordinate.longitude),
                            CLLocationCoordinate2D(latitude: end.coordinate.latitude, longitude: end.coordinate.longitude) ]
        let polyline = MKPolyline(coordinates: coordinates, count: 2)
        mapView.add(polyline)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        totalDistance = totalDistance + (lastLocation?.distance(from: locations[locations.count - 1]))!
        
        if let last = lastLocation {
            drawRedLine(start: last, end: locations[locations.count - 1])
        }
        lastLocation = locations[locations.count - 1]
        
        if Double((lastLocation?.altitude)!) > Double((maxAltitude?.altitude)!) {
            maxAltitude = lastLocation
        }
        if Double((lastLocation?.altitude)!) < Double((minAltitude?.altitude)!) {
            minAltitude = lastLocation
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
}

