//
//  Test2ViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/18/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit
import MapKit

class PromptForLocationController: UIViewController {

    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    let placeholderText = "Enter Your Location Here"
    
    var newStudentLocationHandler: NewStudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTopText()
        configureLocationTextFieldAsManualPlaceholder()
        
        self.dismissKeyboardOnTapOutsideField()
    }
    private func configureNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonHit))
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    private func configureTopText() {
        
        topTextLabel.numberOfLines = 0
        
        let questionText = "Where are you\nstudying\ntoday?"
        let questionAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35.0)
        ]
        let attributedQuestionText = NSMutableAttributedString(string: questionText,
                                             attributes: questionAttributes)
        
        let blackTextAttribute: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let blackRange = attributedQuestionText.mutableString.range(of: "studying")
        attributedQuestionText.addAttributes( blackTextAttribute, range: blackRange )
        
        topTextLabel.attributedText = attributedQuestionText
    }
    
    private func configureLocationTextFieldAsManualPlaceholder() {
        
        locationTextField.text = placeholderText
        locationTextField.returnKeyType = .done
    }
    
    @objc private func cancelButtonHit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findEnteredLocationOnMap(_ sender: UIButton) {
        
        guard let locationText = locationTextField.text,
                !locationText.isEmpty,
                locationText != placeholderText
        else {
            return
        }

        fakeHandleLocationResult()
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString( locationText, completionHandler: handleFindLocationResult(placemarks:error:))
    }
    
    private func handleFindLocationResult( placemarks: [CLPlacemark]?, error: Error? ) {
        guard error == nil else {
            print( "Could not find address: \(error!)" )
            return
        }
        guard let placemarks = placemarks,
                !placemarks.isEmpty,
                let placemark = placemarks.first
        else {
            print( "No error, but location not found" )
            return
        }
        
        let vc = PromptForLinkController.instantiate() as! PromptForLinkController
        vc.coordinate = placemark.location?.coordinate
        vc.newStudentLocationHandler = newStudentLocationHandler
        self.navigationController?.pushViewController(vc, animated: true)
        
        print( locationTextField.text!,
               placemark.location!.coordinate.latitude,
               placemark.location!.coordinate.longitude )
    }
    private func fakeHandleLocationResult() {

        let vc = PromptForLinkController.instantiate() as! PromptForLinkController
        vc.newStudentLocationHandler = newStudentLocationHandler
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PromptForLocationController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if locationTextField.text == placeholderText {
            locationTextField.text = ""
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        locationTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if locationTextField.text?.isEmpty ?? true {
            locationTextField.text = placeholderText
        }
    }
}

extension PromptForLocationController {
    
    func dismissKeyboardOnTapOutsideField() {
        
        let tap = UITapGestureRecognizer( target: self, action: #selector(endEditingOnTap))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func endEditingOnTap() {
        
        self.view.endEditing( true )
    }
}
