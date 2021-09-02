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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowButton)
        addSubview(seeAllButton)
        addSubview(title)

        arrowButton.anchor(right: title.rightAnchor, paddingRight: -30, width: 24, height: 24)
        seeAllButton.anchor(right: self.rightAnchor, width: 32, height: 32)
        seeAllButton.setImage(UIImage(imageLiteralResourceName: "seeall"), for: .normal)
        arrowButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        arrowButton.tintColor = .gray
        arrowButton.centerY(inView: self)
        seeAllButton.centerY(inView: self)
        title.centerY(inView: self)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            title.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
    
    func configure(text: String, font: UIFont?, textColor: UIColor, expandingIsHidden: Bool, seeAllIsHidden: Bool) {
        title.textColor = textColor
        title.font = font
        title.text = text
        if title.text == "Оплатить" {
            title.alpha = 0.3
        }
        arrowButton.isHidden = expandingIsHidden
        seeAllButton.isHidden = seeAllIsHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
