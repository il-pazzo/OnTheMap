//
//  MapViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let mapButton = UIImage(named: "icon_pin")
    let detailButton = UIButton(type: .detailDisclosure)
    let customButton = UIButton(type: .custom)
    
    // required by NewStudentLocation protocol
    var newStudentLocation: StudentLocation?
    
    
    // MARK: - Code begins
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        StudentLocationsLoader.loadStudentLocationsIfEmpty(completion: mapAllStudentLocations(error:))
    }
    
    private func configureNavigationBar() {
        
        let logoutItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        let newLocationItem = UIBarButtonItem(image: mapButton, style: .plain, target: self, action: #selector(promptForNewLocation))
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshStudentLocations))
        
        navigationItem.leftBarButtonItems = [ logoutItem, newLocationItem ]
        navigationItem.rightBarButtonItems = [ refreshItem ]
        
        navigationItem.title = AppDelegate.appName
    }
    
    @objc private func logout() {
        
        ParseClient.killSession { (success, error) in
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func refreshStudentLocations() {
        
        mapView.removeAnnotations( mapView.annotations )
        StudentLocationsLoader.refreshStudentLocations( completion: mapAllStudentLocations(error:))
    }
    
    @objc private func promptForNewLocation() {
        
        let nc = UIStoryboard.main.instantiateViewController( withIdentifier: AppDelegate.navControllerIdentifierPromptForNewLocation ) as! UINavigationController
        
        let rc = nc.topViewController as! PromptForLocationController
        rc.newStudentLocationHandler = self
        
        present( nc, animated: true )
    }

    // MARK: - Show all annotations on map
    private func mapAllStudentLocations(error: Error?) {
        
        guard error == nil else {
            showLoadFailure(message: error!.localizedDescription )
            return
        }
        
        var annotations = [MKPointAnnotation]()
        
        for loc in StudentLocationsModel.studentLocations {
            
            let annotation = buildPointAnnotationFrom(loc: loc)
            annotations.append( annotation )
        }
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
    }
    private func buildPointAnnotationFrom( loc: StudentLocation ) -> MKPointAnnotation {
        
        let lat = loc.latitude
        let long = loc.longitude
        let coordinate = CLLocationCoordinate2D( latitude: lat, longitude: long)
        
        let name = loc.fullName
        let mediaURL = loc.mediaURL
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        annotation.subtitle = loc.isValidURL ? mediaURL : nil
        
        return annotation
    }
    
    private func showLoadFailure( message: String ) {
        
        print( "load failure: \(message)" )
        let alertVC = UIAlertController(title: "Location load failed",
                                        message: message,
                                        preferredStyle: .alert)
        alertVC.addAction( UIAlertAction(title: "OK", style: .default, handler: nil ))
        present(alertVC, animated: true, completion: nil)
    }
}
    
// MARK: - MKMapViewDelegate

// Here we create a view with a "right callout accessory view". You might choose to look into other
// decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
// method in TableViewDataSource.
//
extension MapViewController: MKMapViewDelegate {
    
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
    //
    func mapView( _ mapView: MKMapView,
                  annotationView view: MKAnnotationView,
                  calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - NewStudentLocation protocol
extension MapViewController: NewStudentLocation {
    
    func handleNewStudentLocation() {
        addStudentLocation(loc: newStudentLocation)
    }
    
    private func addStudentLocation( loc: StudentLocation? ) {
        
        guard let loc = loc else {
            return
        }
        
        let annotation = buildPointAnnotationFrom(loc: loc)
        mapView.addAnnotation( annotation )
    }
}

