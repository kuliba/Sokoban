//
//  ProductCell.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import Foundation
import UIKit
import SwiftUI
import CardUI

class ProductCell: UICollectionViewCell, SelfConfiguringCell {
 
    func configure<U>(with value: U) where U : Hashable {
        guard let card = card else { return }
        
        let viewModel = CardViewModelFromRealm(card: card)
        backgroundImageView.image =  card.largeDesign?.convertSVGStringToImage()
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
    }
    
    
    static var reuseId: String = "ProductCell"
    //MARK: - Properties
    var card: UserAllCardsModel? {
        didSet { configure() }
    }
    
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 24, width: 24)
        return imageView
    }()
    
    private let maskCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12 )
        label.text = ""
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14 )
        label.text = ""
        return label
    }()
    
    private let cardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14 )
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.text = "Зарплатная"
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let statusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var stackView: UIStackView = {
        
        let stackV = UIStackView(arrangedSubviews: [])
        stackV.alignment = .center
        stackV.axis = .horizontal
        stackV.spacing = 18
        stackV.distribution = .fill
        return stackV
    }()
    
    private var updatingAnimationsView: UIView?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func hendleShareTapped() {}
    
    //MARK: - Helpers
    func configure() {
        guard let card = card else { return }
        
        let viewModel = CardViewModelFromRealm(card: card)
        
        backgroundImageView.image =  card.largeDesign?.convertSVGStringToImage()
        
        balanceLabel.text = viewModel.balance
        balanceLabel.textColor = viewModel.colorText
        cardNameLabel.text = viewModel.cardName
        cardNameLabel.textColor = viewModel.colorText
        cardNameLabel.alpha = 0.5
        maskCardLabel.text = viewModel.maskedcardNumber
        maskCardLabel.textColor = viewModel.colorText
        logoImageView.image = viewModel.logoImage
        if card.status == "Действует" || card.status == "Выдано клиенту", card.statusPC == "17"{
            statusImage.image = UIImage(named: "unactivated")
            maskCardLabel.alpha = 0.5
            cardNameLabel.alpha = 0.5
            balanceLabel.alpha = 0.5
            logoImageView.alpha = 0.5
            backgroundImageView.alpha = 0.8
        } else if card.status == "Заблокирована банком" || card.status == "Блокирована по решению Клиента" || card.status == "Блокирована по решению Клиента" || card.status == "BLOCKED_DEBET" || card.status == "BLOCKED_CREDIT" || card.status == "BLOCKED" || card.statusPC == "3" || card.statusPC == "5" || card.statusPC == "6" || card.statusPC == "7" || card.statusPC == "20" || card.statusPC == "21" {
            statusImage.image = UIImage(named: "blockProduct")
            maskCardLabel.alpha = 0.5
            cardNameLabel.alpha = 0.5
            balanceLabel.alpha = 0.5
            logoImageView.alpha = 0.5
            backgroundImageView.alpha = 0.8
        } else {
            statusImage.image = UIImage(named: "")
            maskCardLabel.alpha = 1
            cardNameLabel.alpha = 1
            balanceLabel.alpha = 1
            logoImageView.alpha = 1
            backgroundImageView.alpha = 1
        }
        
        
        if card.productType == "DEPOSIT"{
            balanceLabel.textColor = .black
            cardNameLabel.textColor = UIColor(hexString: "#999999")
            maskCardLabel.textColor = .black
            guard let number = card.accountNumber?.suffix(4) else {
                return
            }
            maskCardLabel.text = number.description
        }
        
        if card.productType == ProductType.loan.rawValue {
            guard let number = card.settlementAccount?.suffix(4) else {
                return
            }
            maskCardLabel.text = number.description
        }
    }
    
    func setupUI() {
        
        backgroundColor = .clear
        layer.cornerRadius = 8
        clipsToBounds = true
        layer.shadowColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1).cgColor
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize()
        let shadowPath = UIBezierPath(
            rect: CGRect(x: 15, y: 20,
                         width: self.frame.width * 0.785,
                         height: self.frame.height * 0.785))
        layer.shadowPath = shadowPath.cgPath
        
        addSubview(backgroundImageView)
        addSubview(stackView)
        addSubview(cardNameLabel)
        addSubview(balanceLabel)
        addSubview(statusImage)

        backgroundImageView.fillSuperview()

        stackView.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 14, paddingLeft: 16, height: 19)
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(maskCardLabel)
        
        maskCardLabel.anchor(height: 18)
        
        logoImageView.anchor(width: 18, height: 18)
        
        statusImage.center(inView: self)
        
        cardNameLabel.anchor(top: maskCardLabel.bottomAnchor, left: self.leftAnchor, bottom: balanceLabel.topAnchor, right: self.rightAnchor,
                             paddingTop: 25, paddingLeft: 12, paddingRight: 8)
        cardNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        cardNameLabel.anchor(width: 80)
        cardNameLabel.numberOfLines = 2
        cardNameLabel.lineBreakMode = .byWordWrapping

        balanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        balanceLabel.anchor(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                            paddingLeft: 12, paddingBottom: 11, paddingRight: 30, height: 16)

    }
}


enum Status: String, Codable, Equatable {
        
    case blockedByClient = "Блокирована по решению Клиента"
    case active = "Действует"
    case issuedToClient = "Выдано клиенту"
    case blockedByBank = "Заблокирована банком"
    case notBlocked = "NOT_BLOCKED"
    case blockedDebet = "BLOCKED_DEBET"
    case blockedCredit = "BLOCKED_CREDIT"
    case blocked = "BLOCKED"
}

enum StatusPC: String, Decodable {
    
    case active = "0"
    case operationsBlocked = "3"
    case blockedByBank = "5"
    case lost = "6"
    case stolen = "7"
    case notActivated = "17"
    case temporarilyBlocked = "20"
    case blockedByClient = "21"
}


extension ProductCell {
    
    var isUpdating: Bool {
        
        get { updatingAnimationsView != nil }
        set {
            
            if newValue == true {
                
                guard updatingAnimationsView == nil else {
                    return
                }
                
                let containerView = UIView(frame: .zero)
                containerView.backgroundColor = .clear
                containerView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(containerView)
                NSLayoutConstraint.activate([
                    containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    containerView.topAnchor.constraint(equalTo: topAnchor),
                    containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
                
                let animatedGradientView = createAnimatedGradientView()
                animatedGradientView.backgroundColor = .clear
                animatedGradientView.translatesAutoresizingMaskIntoConstraints = false
                animatedGradientView.layer.compositingFilter = "overlayBlendMode"
                containerView.addSubview(animatedGradientView)
                NSLayoutConstraint.activate([
                    animatedGradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    animatedGradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    animatedGradientView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    animatedGradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
                
                let animatedDotsView = createAnimatedDotsView()
                animatedDotsView.backgroundColor = .clear
                animatedDotsView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(animatedDotsView)
                NSLayoutConstraint.activate([
                    animatedDotsView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    animatedDotsView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
                ])
                
                updatingAnimationsView = containerView
                
                // show up animated
                updatingAnimationsView?.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    
                    self.updatingAnimationsView?.alpha = 1.0
                }
                
            } else {
                
                // dismiss animated
                UIView.animate(withDuration: 0.2) {
                    
                    self.updatingAnimationsView?.alpha = 0
                    
                } completion: { _ in
                    
                    self.updatingAnimationsView?.removeFromSuperview()
                    self.updatingAnimationsView = nil
                }
            }
        }
    }

    func createAnimatedGradientView() -> UIView {
        
        UIHostingController(rootView: AnimatedGradientView(duration: 3.0)).view
    }
    
    func createAnimatedDotsView() -> UIView {
        
        UIHostingController(rootView: DotsAnimations()).view
    }
}
