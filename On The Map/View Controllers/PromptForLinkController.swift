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
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    var newStudentLocationHandler: NewStudentLocation?

    // set by caller
    var coordinate: CLLocationCoordinate2D?
    var coordinateName: String?
    
    
    // MARK: - Code begins
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardOnTapOutsideField()

        configureNavigationBar()
        configureLinkTextFieldWithStandardPlaceholder()
        configureSubmitButton()

        showMapPin()
    }
    private func configureNavigationBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonHit))
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = linkContainerView.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
    }

    private func configureLinkTextFieldWithStandardPlaceholder() {
        
        linkTextField.returnKeyType = .done
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let linkPlaceholder = "Enter a Link to Share Here"
        
        let attributedLinkPlaceholder = NSMutableAttributedString(string: linkPlaceholder,
                                                                  attributes: textAttributes)
        linkTextField.attributedPlaceholder = attributedLinkPlaceholder
    }
    
    private func configureSubmitButton() {
        
        if coordinate == nil {
            submitButton.isEnabled = false
            submitButton.titleLabel?.text = "No Location"
            return
        }
    }

    @objc private func cancelButtonHit() {
        
        self.dismiss(animated: true, completion: nil)
    }
    private func showMapPin() {
        
        guard let coordinate = coordinate else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        self.mapView.addAnnotation( annotation )
    }
    
    @IBAction func shareLocation(_ sender: Any) {
        
        let newLoc = buildStudentLocation()
        newStudentLocationHandler?.newStudentLocation = newLoc
        
        ParseClient.addNewStudentLocation(loc: newLoc, completion: handleNewStudentLocation(success:error:))
    }
    private func buildStudentLocation() -> StudentLocation {
        
        let now = "\(NSDate())"
        return StudentLocation(uniqueKey: ParseClient.Auth.key,
                               objectId: "gcobjid",
                               createdAt: now,
                               updatedAt: now,
                               firstName: ParseClient.studentInfo?.firstName ?? "?",
                               lastName: ParseClient.studentInfo?.lastName ?? "?",
                               longitude: coordinate!.longitude,
                               latitude: coordinate!.latitude,
                               mapString: coordinateName ?? "?",
                               mediaURL: linkTextField.text ?? "" )
    }
    private func handleNewStudentLocation( success: Bool, error: Error? ) {
        
        guard error == nil else {
            print( "Add failed:", error?.localizedDescription ?? "An error occurred" )
            return
        }
        
        self.dismiss(animated: true, completion: newStudentLocationHandler?.handleNewStudentLocation)
    }
}

extension PromptForLinkController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        linkTextField.resignFirstResponder()
        return true
    }
}

// MARK: - Dismiss keyboard on taps outside field
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
