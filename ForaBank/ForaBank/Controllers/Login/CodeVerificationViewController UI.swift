//
//  CodeVerificationViewController UI.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit

extension CodeVerificationViewController {
    func setupUI() {
        title = "Вход"
        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .center
        smsCodeView.Base.changeInputNum(num: 6)
        
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(smsCodeView)
        
        titleLabel.centerX(inView: view, topAnchor: view.topAnchor, paddingTop: 30)
        smsCodeView.centerX(inView: view, topAnchor: titleLabel.bottomAnchor, paddingTop: 28)
        smsCodeView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                           paddingLeft: 20, paddingRight: 20, height: 60)
        subTitleLabel.centerX(inView: view, topAnchor: smsCodeView.bottomAnchor,
                              paddingTop: 20)
    }
}
