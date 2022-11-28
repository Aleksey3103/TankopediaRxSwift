//
//  TankCollectionViewCell.swift
//  NetworkTanks
//
//  Created by Oleksii Savchenko on 21.11.2022.
//

import UIKit
import Nuke

class TankCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(model: Datum) {
        self.nameLabel.text = model.name
        self.imagePhoto.image = UIImage(named: "\(model.images)")
        if let tankImage = model.images.imageUrl {
            Nuke.loadImage(with: tankImage, into: imagePhoto)
        }
    }
}
