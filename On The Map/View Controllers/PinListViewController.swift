//
//  PinListViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let names = hardCodedNameData()
    let mapImage = UIImage(named: "icon_pin")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pinCell")!
        
        cell.textLabel?.text = names[ indexPath.row ]
        cell.imageView?.image = mapImage
        
        return cell
    }
    
    class func hardCodedNameData() -> [String] {
        
        return ["Mary", "Joe", "Billy Bob"]
    }
}
