//
//  GKHInputFooter.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.08.2021.
//

import UIKit

final class GKHFooterView: UIView {

    var stackView = UIStackView(arrangedSubviews: [])
    var cardFromField = CardChooseView()
    
    var cardListView = CardListView(onlyMy: false)
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    init(text: String) {
        super.init(frame: .zero)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()

        stackView = UIStackView(arrangedSubviews: [cardFromField, cardListView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
//        contentView.addSubview(stackView)
        
        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Width
        let leadingContraint = contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
//        leadingContraint.priority = .defaultHigh

        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Height
        let topConstraint = contentView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor)
        topConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
//            leadingContraint,
//            topConstraint,
//
//            contentView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
////            contentView.heightAnchor.constraint(equalToConstant: 200),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
        setupActions()
    }

    func setupActions() {
        cardFromField.didChooseButtonTapped = { () in
            print("cardField didChooseButtonTapped")
            self.openOrHideView(self.cardListView)
        }

        cardListView.didCardTapped = { card in
            self.cardFromField.cardModel = card
            self.hideView(self.cardListView, needHide: true)
        }
    }
    
    
    //MARK: - Animation
    func openOrHideView(_ view: UIView) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == true {
                    view.isHidden = false
                    view.alpha = 1
                } else {
                    view.isHidden = true
                    view.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    func hideView(_ view: UIView, needHide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
}
