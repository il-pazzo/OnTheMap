//
//  PinListViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let mapImage = UIImage(named: "icon_pin")
    var mapImageDisabled = UIImage(named: "icon_pin_disabled")
    
    let colourForValidURL = UIColor.black
    let colourForInvalidURL = UIColor.lightGray

    let mapButton = UIImage(named: "icon_pin")
    var newStudentLocation: StudentLocation?

    
    // MARK: - Code begins
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        
        StudentLocationsLoader.loadStudentLocationsIfEmpty( completion: handleTableLoad(error:))
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

    @objc private func promptForNewLocation() {
        
        let nc = UIStoryboard.main.instantiateViewController( withIdentifier: AppDelegate.navControllerIdentifierPromptForNewLocation ) as! UINavigationController
        
        let rc = nc.topViewController as! PromptForLocationController
        rc.newStudentLocationHandler = self
        
        present( nc, animated: true )
    }
    
    @objc private func refreshStudentLocations() {
        
        StudentLocationsLoader.refreshStudentLocations( completion: handleTableLoad(error:))
    }
    
    private func handleTableLoad( error: Error? ) {
        
        self.tableView.reloadData()
        if error != nil {
            showLoadFailure(message: error!.localizedDescription)
            print(error!)
        }
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

// MARK: - tableview delegate, data source
extension PinListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationsModel.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pinCell")!
        let loc = StudentLocationsModel.studentLocations[ indexPath.row ]
        
        cell.textLabel?.text = loc.fullName
        cell.detailTextLabel?.text = loc.uniqueKey
        
        if loc.isValidURL {
            cell.textLabel?.textColor = colourForValidURL
            cell.imageView?.image = mapImage
            cell.isUserInteractionEnabled = true
        }
        else {
            cell.textLabel?.textColor = colourForInvalidURL
            cell.imageView?.image = mapImageDisabled
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let loc = StudentLocationsModel.studentLocations[ indexPath.row ]
        
        UIApplication.shared.open(URL(string: loc.mediaURL)!, options: [:], completionHandler: nil)
    }
}

// MARK: - NewStudentLocation protocol

extension PinListViewController: NewStudentLocation {
    
    func handleNewStudentLocation() {
        addStudentLocation(loc: newStudentLocation)
    }
    private func addStudentLocation( loc: StudentLocation? ) {
        
        guard let loc = loc else {
            return
        }
        
        StudentLocationsModel.studentLocations.insert(loc, at: 0)
        tableView.reloadData()
    }
}
