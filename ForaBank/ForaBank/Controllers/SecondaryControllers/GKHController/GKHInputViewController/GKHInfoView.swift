//
//  GKHInfoView.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.11.2021.
//

import UIKit

class GKHInfoView: UIView {

    var clouseButton: UIButton {
        let button = UIButton()
        button.setTitle("Закрыть", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        return button
    }
    
    var infoImage: UIImageView {
        let imageName = "alert-circle"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 88.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 88.0).isActive = true
        return imageView
    }
    
    let lable = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lable.font = UIFont.systemFont(ofSize: 17)
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        
        let stackView = UIStackView()
        stackView.axis          = .vertical
        stackView.distribution  = .fillProportionally
        stackView.alignment     = .fill
        stackView.spacing       = 5
        
        stackView.addArrangedSubview(clouseButton)
        stackView.addArrangedSubview(infoImage)
        stackView.addArrangedSubview(lable)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

