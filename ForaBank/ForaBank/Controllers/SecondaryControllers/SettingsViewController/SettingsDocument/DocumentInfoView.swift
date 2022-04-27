//
//  DocumentInfoView.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.04.2022.
//

import UIKit

struct DocumentInfoModel {
    
    let icon: String
    let title: String
    let description: String
    
    init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
    
}

class DocumentInfoView: UIView {

    var model: DocumentInfoModel?
    
    var topView: UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "headerView")
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        view.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }
    
    var infoImage: UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: model?.icon ?? "")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        return imageView
    }
    
    var titleLable: UILabel {
        let lable = UILabel()
        lable.text = model?.title
        lable.textColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)

        lable.font = UIFont(name: "Inter-SemiBold", size: 18)
        lable.numberOfLines = 0
        lable.textAlignment = .center
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        return lable
    }
    
    var infoLable: UILabel {
        let lable = UILabel()
        lable.text = model?.description
        lable.textColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)

        lable.font = UIFont(name: "Inter-SemiBold", size: 16)
        lable.numberOfLines = 0
        lable.textAlignment = .center
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        return lable
    }
    
    var copyButton: UIButton {
        let button = UIButton()
        button.setTitle("Скопировать", for: .normal)
        button.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        button.setTitleColor(UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1), for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 336.0).isActive = true
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(copyDescription), for: .touchUpInside)
        return button
    }
    
    @objc func copyDescription() {
        UIPasteboard.general.string = infoLable.text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    required init(model: DocumentInfoModel) {
        super.init(frame: .zero)
        self.model = model
        let stackView = UIStackView()
        stackView.axis          = .vertical
        stackView.distribution  = .fillProportionally
        stackView.alignment     = .center
        stackView.spacing       = 10
        
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(infoImage)
        stackView.addArrangedSubview(titleLable)
        stackView.addArrangedSubview(infoLable)
        stackView.addArrangedSubview(copyButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 300.0).isActive = true
    }
    
}


