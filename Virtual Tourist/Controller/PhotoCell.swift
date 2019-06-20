//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Ahmed yasser on 5/25/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

// A class that handles custom collection cell
class PhotoCell: UICollectionViewCell {
    
    // MARK: Cell outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
