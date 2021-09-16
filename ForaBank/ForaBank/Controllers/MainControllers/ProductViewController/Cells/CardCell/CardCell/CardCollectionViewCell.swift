//
//  CardCollectionViewCell.swift
//  ForaBank
//
//  Created by Дмитрий on 16.09.2021.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var cardImageView: UIImageView!
    override var isSelected: Bool{
        didSet{
            if self.isSelected{
                cardImageView.alpha = 1
            } else {
                cardImageView.alpha = 0.5
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedView?.backgroundColor = .black
        selectedView.layer.cornerRadius = frame.size.width/2
        selectedView.alpha = 0.3
        
        self.selectedView.isHidden = true
    }
    
    func showSelect(){
        self.selectedView.isHidden = false
    }
    
    func hideSelect(){
        self.selectedView.isHidden = true
    }
}
