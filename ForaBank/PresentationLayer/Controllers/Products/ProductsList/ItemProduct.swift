//
//  ItemProductsList.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 27.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//


class ItemProduct: UICollectionViewCell{
    
    @IBOutlet weak var viewProduct: UIView!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var nameProduct: UILabel!
    @IBOutlet weak var commentProduct: UILabel!
    @IBOutlet weak var buttonOpenProduct: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.nameProduct.textColor = .black
        self.nameProduct.font = UIFont(name: "Roboto-Regular", size: 15)
        
        self.commentProduct.textColor = .black
        self.commentProduct.font = UIFont(name: "Roboto-light", size: 13)
        
        self.viewProduct.layer.cornerRadius = 10
        
        self.imageProduct.contentMode = .scaleAspectFit
        
    }
}
