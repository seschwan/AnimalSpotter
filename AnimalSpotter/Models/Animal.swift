//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Seschwan on 5/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class Animal: Codable {
    let id: Int
    let name: String
    let timeSeen: Date
    let latitude: Double
    let longitude: Double
    let description: String
    let imgageURL: String
}
