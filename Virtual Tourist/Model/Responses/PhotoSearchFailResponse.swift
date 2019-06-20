//
//  PhotoSearchFailResponse.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation

// A codable struct that store search failure stat , code and failure message
struct PhotoSearchFailResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}
