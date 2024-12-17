//
//  DocumentCollectionViewCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.04.2022.
//

import UIKit

struct DocumentSettingModel {

    let icon: String
    let title: String
    let subtitle: String
    
    init(icon: String, title: String, subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

class DocumentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    func addData(_ index: Int, data: [DocumentSettingModel]) {
        iconImage.image = UIImage(named: data[index].icon)
        title.text = data[index].title
        subtitle.text = data[index].subtitle
        
        title.font = UIFont(name: "Inter-Medium", size: 14)
        subtitle.font = UIFont(name: "Inter-Regular", size: 14)
        
        title.textColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)
        subtitle.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        title.numberOfLines = 0
        subtitle.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}
