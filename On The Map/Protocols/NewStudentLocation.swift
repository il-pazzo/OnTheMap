//
//  NewStudentLocation.swift
//  On The Map
//
//  Created by Glenn Cole on 8/19/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

protocol NewStudentLocation {
    var newStudentLocation: StudentLocation? { get set }
    func handleNewStudentLocation()
}
