//
//  LoginCardEntryViewController UI.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

extension LoginCardEntryViewController {
    
    func setupUI() {
        setupBackground()
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(creditCardView)
        view.addSubview(orderCardView)
        setupConstraints()

        let image = UIImage(systemName: "arrow.down")?.withRenderingMode(.alwaysOriginal)
        let arrowImage = UIImageView(image: image)
        view.addSubview(arrowImage)
        arrowImage.setDimensions(height: 15, width: 15)
        arrowImage.centerY(inView: titleLabel, leftAnchor: titleLabel.rightAnchor, paddingLeft: 8)
    }
    
    fileprivate func setupBackground() {
        view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "BackgroundLine"))
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor ,right: view.rightAnchor,
                         paddingBottom: 160)
    }
    
    fileprivate func setupConstraints() {
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                          paddingTop: 54, paddingLeft: 20)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                             paddingTop: 8, paddingLeft: 20)
        creditCardView.anchor(top: subTitleLabel.bottomAnchor, left: view.leftAnchor,
                              right: view.rightAnchor, paddingTop: 50,
                              paddingLeft: 20, paddingRight: 20, height: 204)
        orderCardView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor, paddingLeft: 20, paddingBottom: 50,
                             paddingRight: 20, height: 72)
    }
}
