//
//  PinListViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let mapImage = UIImage(named: "icon_pin")
    var mapImageDisabled = UIImage(named: "icon_pin_disabled")
    
    let colourForValidURL = UIColor.black
    let colourForInvalidURL = UIColor.lightGray
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshStudentLocations))
        navigationItem.title = AppDelegate.appName
        
        StudentLocationsLoader.loadStudentLocationsIfEmpty { (error) in
            self.tableView.reloadData()
            if error != nil {
                //consider showing error alert
                print(error!)
            }
        }
    }
    
    @objc private func refreshStudentLocations() {
        
        StudentLocationsLoader.refreshStudentLocations { (error) in
            self.tableView.reloadData()
        }
    }
    
    private func filterOutBadData( _ locations: [StudentLocation]) -> [StudentLocation] {
        
        var results = [StudentLocation]()
        var keys = Set<String>()
        
        for loc in locations {
            guard loc.uniqueKey != "nil" else { continue }
            guard !keys.contains( loc.uniqueKey ) else { continue }
            
            keys.insert( loc.uniqueKey )
            results.append( loc )
        }
        
        return results
    }
    
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
        }
        else {
            cell.textLabel?.textColor = colourForInvalidURL
            cell.imageView?.image = mapImageDisabled
        }
        
        return cell
    }
}
