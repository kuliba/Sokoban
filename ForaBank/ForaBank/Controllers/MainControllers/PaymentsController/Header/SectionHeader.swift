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
//        self.backgroundColor = .green
        arrowButton.anchor(right: title.rightAnchor, paddingRight: -30, width: 24, height: 24)
        seeAllButton.anchor(right: self.rightAnchor, width: 32, height: 32)
        seeAllButton.setImage(UIImage(imageLiteralResourceName: "seeall"), for: .normal)
        arrowButton.setImage(UIImage(named: "chevron-downnew"), for: .normal)
        arrowButton.imageView?.sizeToFit()
        arrowButton.tintColor = .gray
        arrowButton.centerY(inView: self.title)
        seeAllButton.centerY(inView: self.title)
//        title.centerY(inView: self)
//        NSLayoutConstraint.activate([
//            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            title.topAnchor.constraint(equalTo: self.topAnchor)
//        ])
//        title.anchor(height: 24)
  
    }
    
    func configure(text: String, font: UIFont?, textColor: UIColor, expandingIsHidden: Bool, seeAllIsHidden: Bool, onlyCards: Bool) {
        title.textColor = textColor
        title.font = font
        title.text = text
        if title.text == "Оплатить" ||  title.text == "Отделения и банкоматы" || title.text == "Инвестиции и пенсии"  || title.text == "Услуги и сервисы" {
            title.alpha = 0.3
        } else {
            title.alpha = 1
        }
        arrowButton.isHidden = expandingIsHidden
        seeAllButton.isHidden = seeAllIsHidden
        if title.text == "Мои продукты"{
            self.addSubview(changeCardButtonCollection)
            title.anchor(top: self.topAnchor, height: 24)
            changeCardButtonCollection.isHidden = onlyCards
            changeCardButtonCollection.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, paddingLeft: -10, paddingBottom: 0, height: 24)
            
            changeCardButtonCollection.button_1.setTitle("Карты и счета", for: .normal)
            changeCardButtonCollection.button_2.setTitle("Вклады", for: .normal)
            changeCardButtonCollection.button_3.isHidden = true
            arrowButton.centerY(inView: title)
            seeAllButton.centerY(inView: title)
            
        } else {
//            title.centerY(inView: self)
            changeCardButtonCollection.removeFromSuperview()
            title.backgroundColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
