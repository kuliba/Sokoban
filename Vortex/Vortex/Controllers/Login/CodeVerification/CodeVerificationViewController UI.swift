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
        navigationController?.navigationBar.backgroundColor = .white
        
        subTitleLabel.numberOfLines = 2
        subTitleLabel.textAlignment = .center
        subTitleLabel.alpha = 0.5
        subTitleLabel.textColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1)
        subTitleLabel.text = "Код отправлен на \(viewModel.phone ?? "+7 ... ... ..")\nЗапросить повторно можно через"
        smsCodeView.Base.changeInputNum(num: 6)
//        timerLabel.isHidden = true
        repeatCodeButton.isHidden = true
        
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(smsCodeView)
        view.addSubview(timerLabel)
        view.addSubview(repeatCodeButton)
        
        titleLabel.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor,
                           paddingTop: 20)
        smsCodeView.centerX(inView: view, topAnchor: titleLabel.bottomAnchor,
                            paddingTop: 35)
        smsCodeView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                           paddingLeft: 20, paddingRight: 20, height: 60)
        subTitleLabel.centerX(inView: view, topAnchor: smsCodeView.bottomAnchor,
                              paddingTop: 40)
        timerLabel.centerX(inView: subTitleLabel, topAnchor: subTitleLabel.bottomAnchor,
                           paddingTop: 32)
        repeatCodeButton.centerX(inView: subTitleLabel, topAnchor: subTitleLabel.bottomAnchor,
                                 paddingTop: 32)
    }
}
