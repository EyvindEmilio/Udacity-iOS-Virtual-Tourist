//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Eyvind on 2/6/22.
//

import Foundation
import UIKit

class PhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    func startLoading() {
        ivPhoto.isHidden = true
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        ivPhoto.isHidden = false
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
    }
}
