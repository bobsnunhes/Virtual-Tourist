//
//  PhotosCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by roberto fernandes filho on 03/06/2018.
//  Copyright © 2018 Betocorporation. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityItem: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleWidth]
        imageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isUserInteractionEnabled = false
        self.imageView.image = nil
    }
    
    
    func startLoading() {
        activityItem.startAnimating()
        imageView.alpha = CGFloat(0.5)
    }
    
    func stopLoading() {
        activityItem.stopAnimating()
        imageView.alpha = 1
    }
}
