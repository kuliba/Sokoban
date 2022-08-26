//
//  InfoViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 18.05.2022.
//

import UIKit

class InfoViewController: UIViewController {
    
    let titleLabel = UILabel(text: "Вы можете снять полную сумму вклада и выплаченных процентов", font: .systemFont(ofSize: 16))
    var infoTitle: String? = nil
    let image = UIImageView(image: .init(named: "alert-circle"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    func setupUI() {
        view.addSubview(image)
        view.addSubview(titleLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16)
        
        if let infoTitle = infoTitle {
            
            titleLabel.text = infoTitle
        }
    }

    fileprivate func setupConstraints() {
        
        image.centerX(inView: view)
        titleLabel.anchor(top: image.bottomAnchor, left: view.leftAnchor,  bottom: view.bottomAnchor, right: view.rightAnchor,
                          paddingTop: 24, paddingLeft: 20, paddingBottom: 80, paddingRight: 20)
    
    }
}
