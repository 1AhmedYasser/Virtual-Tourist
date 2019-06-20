//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store an array of photo objects and a stat message
struct PhotosResponse: Codable {
    let photos: PhotosObject
    let stat: String
}
