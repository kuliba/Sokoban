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
        self.nameProduct.font = UIFont(name: "Roboto", size: 20)
        
        self.commentProduct.textColor = .black
        self.nameProduct.font = UIFont(name: "Roboto", size: 15)
        
        self.viewProduct.layer.cornerRadius = 5
        //self.buttonOpenProduct.layer.cornerRadius = buttonOpenProduct.frame.size.height / 2
        //self.buttonOpenProduct.titleLabel?.font.withSize(15)
        
    }
}
