//
//  MapViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let detailButton = UIButton(type: .detailDisclosure)
    let customButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshStudentLocations))
        navigationItem.title = AppDelegate.appName

        StudentLocationsLoader.loadStudentLocationsIfEmpty(completion: mapAllStudentLocations(error:))
    }

    @objc private func refreshStudentLocations() {
        
        mapView.removeAnnotations( mapView.annotations )
        StudentLocationsLoader.refreshStudentLocations( completion: mapAllStudentLocations(error:))
    }

    private func mapAllStudentLocations(error: Error?) {
        
        var annotations = [MKPointAnnotation]()
        
        for loc in StudentLocationsModel.studentLocations {
            
            let lat = loc.latitude
            let long = loc.longitude
            let coordinate = CLLocationCoordinate2D( latitude: lat, longitude: long)
            
            let name = loc.fullName
            let mediaURL = loc.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = name
            annotation.subtitle = loc.isValidURL ? mediaURL : nil
            
            annotations.append( annotation )
        }
        
        self.mapView.addAnnotations(annotations)
        self.mapView.showAnnotations(annotations, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        // subtitle -- the url -- is type "String??". Invalid values were set to nil
        if annotation.subtitle != nil, annotation.subtitle! != nil {
            pinView!.rightCalloutAccessoryView = detailButton
        }
        else {
            pinView!.rightCalloutAccessoryView = nil
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
//                app.openURL(URL(string: toOpen)!)
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
