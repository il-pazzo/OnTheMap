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
    
    let names = hardCodedNameData()
    let mapImage = UIImage(named: "icon_pin")

    override func viewDidLoad() {
        super.viewDidLoad()

//        ParseClient.getStudentLocations { (studentLocations, error) in
//            StudentLocationsModel.studentLocations = self.filterOutBadData( studentLocations )
//            self.tableView.reloadData()
//        }
        StudentLocationsLoader.loadStudentLocationsIfEmpty { (error) in
            self.tableView.reloadData()
            if error != nil {
                //consider showing error alert
                print(error!)
            }
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
        
        cell.textLabel?.text = StudentLocationsModel.studentLocations[ indexPath.row ].fullName
        cell.imageView?.image = mapImage
        cell.detailTextLabel?.text = StudentLocationsModel.studentLocations[indexPath.row].uniqueKey
        
        return cell
    }
    
    class func hardCodedNameData() -> [String] {
        
        return ["Mary", "Joe", "Billy Bob"]
    }
}
