//
//  SectionHeader.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    
    let title = UILabel()
    let arrowButton = UIButton()
    let seeAllButton = UIButton()
    let changeCardButtonCollection = AllCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowButton)
        addSubview(seeAllButton)
        addSubview(title)

        arrowButton.anchor(right: title.rightAnchor, paddingRight: -30, width: 24, height: 24)
        seeAllButton.anchor(right: self.rightAnchor, width: 32, height: 32)
        seeAllButton.setImage(UIImage(imageLiteralResourceName: "seeall"), for: .normal)
        arrowButton.setImage(UIImage(named: "chevron-downnew"), for: .normal)
        arrowButton.imageView?.sizeToFit()
        arrowButton.tintColor = .gray
        arrowButton.centerY(inView: self)
        seeAllButton.centerY(inView: self)
//        title.centerY(inView: self)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        title.anchor(height: 24)
        changeCardButtonCollection.complition = { (select) in
            switch select {
            case 1:
                print("case 1")
            case 2:
                
                print("case 2")
            default: break
                print("case default")
            }
        }
    }
    
    func configure(text: String, font: UIFont?, textColor: UIColor, expandingIsHidden: Bool, seeAllIsHidden: Bool) {
        title.textColor = textColor
        title.font = font
        title.text = text
        if title.text == "Оплатить" ||  title.text == "Отделения и банкоматы" || title.text == "Инвестиции и пенсии"  || title.text == "Услуги и сервисы" {
            title.alpha = 0.3
        } else {
            title.alpha = 1
        }
        title.centerY(inView: self)
        arrowButton.isHidden = expandingIsHidden
        seeAllButton.isHidden = seeAllIsHidden
        if title.text == "Мои продукты"{
            self.addSubview(changeCardButtonCollection)
            title.anchor(top: self.topAnchor, height: 24)
            changeCardButtonCollection.anchor(top: title.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, height: 24)
            title.backgroundColor = .cyan
        } else {
            changeCardButtonCollection.removeFromSuperview()
            title.backgroundColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
