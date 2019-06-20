//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store photo information that is used to download the photo from flicker
struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
}
