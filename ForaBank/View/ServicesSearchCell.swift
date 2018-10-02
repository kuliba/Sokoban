//
//  ServicesSearchCell.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 01/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class ServicesSearchCell: UIView {

    // MARK: - Properties
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapButton: UIButton!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setTextFieldAndButtonRounded()
        setTextFieldIconImageView()
    }
}

// MARK: - Private methods
private extension ServicesSearchCell {
    
    func setTextFieldAndButtonRounded() {
        textField.layer.cornerRadius = 5
        mapButton.layer.cornerRadius = 5
    }
    
    func setTextFieldIconImageView() {
        let leftView = UIView(frame: CGRect(x: 10, y: 10, width: 30, height: 16))
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: "icon_search")
        imageView.alpha = 0.7
        imageView.contentMode = .scaleAspectFit
        
        leftView.addSubview(imageView)
        
        textField.leftView = leftView
        textField.leftViewMode = .always
    }
}

