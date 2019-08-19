//
//  PromptForLinkController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/19/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit
import MapKit

class PromptForLinkController: UIViewController {

    @IBOutlet weak var linkContainerView: UIView!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    let placeholderText = "Enter a Link to Share Here"

    var coordinate: CLLocationCoordinate2D?
    // Rome, italy 41.889282 12.4935822
    let lat = 41.889282
    let lng = 12.4935822

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardOnTapOutsideField()

        configureNavigationBar()
        configureLinkTextFieldAsManualPlaceholder()

        showMapPin()
        print( "date:", NSDate())
    }
    private func configureNavigationBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonHit))
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = linkContainerView.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
    }
    private func configureLinkTextFieldAsManualPlaceholder() {
        
        linkField.text = placeholderText
        linkField.returnKeyType = .done
    }
    @objc private func cancelButtonHit() {
        
        self.dismiss(animated: true, completion: nil)
    }
    private func showMapPin() {
        
        if coordinate == nil {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        guard let coordinate = coordinate else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        self.mapView.addAnnotation( annotation )
        self.mapView.showAnnotations([annotation], animated: true)
    }
    
    @IBAction func shareLocation(_ sender: Any) {
        
        let newLoc = buildStudentLocation()
        StudentLocationsModel.studentLocations.insert( newLoc, at: 0 )
        self.dismiss(animated: true, completion: nil)
    }
    private func buildStudentLocation() -> StudentLocation {
        
        let now = "\(NSDate())"
        return StudentLocation(uniqueKey: "gckey",
                               objectId: "gcobjid",
                               createdAt: now,
                               updatedAt: now,
                               firstName: "Uknow",
                               lastName: "Hu",
                               longitude: lng,
                               latitude: lat,
                               mapString: "Iowa",
                               mediaURL: "https://apple.com")
    }
}

extension PromptForLinkController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if linkField.text == placeholderText {
            linkField.text = ""
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        linkField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if linkField.text?.isEmpty ?? true {
            linkField.text = placeholderText
        }
    }
}
extension PromptForLinkController {
    
    func dismissKeyboardOnTapOutsideField() {
        
        let tap = UITapGestureRecognizer( target: self, action: #selector(endEditingOnTap))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func endEditingOnTap() {
        
        self.view.endEditing( true )
    }
}
