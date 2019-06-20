//
//  PhotosObject.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store photo object information including an array of photo structs
struct PhotosObject: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}
