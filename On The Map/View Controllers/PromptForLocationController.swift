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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let placeholderText = "Enter Your Location Here"
    
    // set by caller
    var newStudentLocationHandler: NewStudentLocation?
    
    
    // MARK: - Code begins
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTopText()
        configureLocationTextFieldWithStandardPlaceholder()
        
        dismissKeyboardOnTapOutsideField()
    }
    private func configureNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonHit))
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.shadowImage = UIImage()
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
    
    private func configureLocationTextFieldWithStandardPlaceholder() {
        
        locationTextField.returnKeyType = .done
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let locationPlaceholder = "Enter Your Location Here"
        
        let attributedLocationPlaceholder = NSMutableAttributedString(string: locationPlaceholder,
                                                                      attributes: textAttributes)
        locationTextField.attributedPlaceholder = attributedLocationPlaceholder
    }
    
    @objc private func cancelButtonHit() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findEnteredLocationOnMap(_ sender: UIButton) {
        
        guard let locationText = locationTextField.text,
                !locationText.isEmpty,
                locationText != placeholderText
        else {
            return
        }

        activityIndicator.startAnimating()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString( locationText, completionHandler: handleFindLocationResult(placemarks:error:))
    }
    
    private func handleFindLocationResult( placemarks: [CLPlacemark]?, error: Error? ) {

        activityIndicator.stopAnimating()
        guard error == nil else {
            print( "Could not find address: \(error!)" )
            showFindLocationFailure(message: error!.localizedDescription )
            return
        }
        guard let placemarks = placemarks,
                !placemarks.isEmpty,
                let placemark = placemarks.first
        else {
            print( "No error, but location not found" )
            showFindLocationFailure(message: "Location not recognized")
            return
        }
        
        print( locationTextField.text!,
               placemark.location!.coordinate.latitude,
               placemark.location!.coordinate.longitude )

        let vc = PromptForLinkController.instantiate() as! PromptForLinkController
        vc.coordinate = placemark.location?.coordinate
        vc.coordinateName = placemark.name ?? locationTextField.text
        vc.newStudentLocationHandler = newStudentLocationHandler
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showFindLocationFailure( message: String ) {
        
        print( "Location not recognized: \(message)" )
        let alertVC = UIAlertController(title: "Location not recognized",
                                        message: message,
                                        preferredStyle: .alert)
        alertVC.addAction( UIAlertAction(title: "OK", style: .default, handler: nil ))
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - textfield delegate method to dismiss the keyboard
extension PromptForLocationController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        locationTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        findOnMapButton.isEnabled = false
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = textField.text!.count + string.count - range.length
        findOnMapButton.isEnabled = newLength > 0
        
        return true
    }
}
