//
//  SectionHeader.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit
import SwiftUI

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    
    let container = UIStackView(frame: .zero)
    let title = UILabel(frame: .zero)
    let expandedIcon = UIImageView(frame: .zero)
    let seeAllButton = UIButton(frame: .zero)

    private var isExpanded: Bool = true
    private var expandAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        container.axis = .vertical
        container.distribution = .fill
        container.alignment = .leading
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
        
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let horizontalContainer = UIStackView(frame: .zero)
        horizontalContainer.axis = .horizontal
        horizontalContainer.distribution = .fill
        horizontalContainer.alignment = .center
        horizontalContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(horizontalContainer)
        
        let titleContainer = UIStackView(frame: .zero)
        titleContainer.axis = .horizontal
        titleContainer.distribution = .fill
        titleContainer.spacing = 8
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        horizontalContainer.addArrangedSubview(titleContainer)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addArrangedSubview(title)
        
        expandedIcon.image = UIImage(named: "chevron-downnew")
        expandedIcon.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.addArrangedSubview(expandedIcon)
        
        let spacerView = UIView(frame: .zero)
        spacerView.backgroundColor = .clear
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        horizontalContainer.addArrangedSubview(spacerView)
        let spacerWidthConstraint = spacerView.widthAnchor.constraint(equalToConstant: 375)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true

        seeAllButton.setImage(UIImage(imageLiteralResourceName: "seeall"), for: .normal)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        horizontalContainer.addArrangedSubview(seeAllButton)
        NSLayoutConstraint.activate([
            
            seeAllButton.heightAnchor.constraint(equalToConstant: 32),
            seeAllButton.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerDidTapped)))
    }
    
    func configure(text: String, font: UIFont?, textColor: UIColor, expandingIsHidden: Bool, seeAllIsHidden: Bool, onlyCards: Bool, isExpanded: Bool, expandAction: @escaping () -> Void, productSelectorViewModel: OptionSelectorView.ViewModel? = nil) {
        
        title.textColor = textColor
        title.font = font
        title.text = text
        if title.text == "Отделения и банкоматы" || title.text == "Инвестиции и пенсии"  || title.text == "Услуги и сервисы" {
            title.alpha = 0.3
        } else {
            title.alpha = 1
        }
        expandedIcon.isHidden = expandingIsHidden
        seeAllButton.isHidden = seeAllIsHidden
        
        self.isExpanded = isExpanded
        self.expandedIcon.transform = expandedIconTransform
        self.expandAction = expandAction
        
        removeProductTypeSelectorView()
        
        if let productSelectorViewModel = productSelectorViewModel {
            
            addProductTypeSelectorView(with: productSelectorViewModel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func headerDidTapped() {
        
        guard let expandAction = expandAction else {
            return
        }
        
        expandAction()
        isExpanded.toggle()
        
        UIView.animate(withDuration: 0.3) {
            
            self.expandedIcon.transform = self.expandedIconTransform
        }
    }
    
    var expandedIconTransform: CGAffineTransform {
        
        isExpanded ? .identity : .init(rotationAngle: deg2rad(-90))
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        
        return number * .pi / 180
    }
    
    func removeProductTypeSelectorView() {
        
        guard container.arrangedSubviews.count == 2 else {
            return
        }
        
        let productTypeSelectorView = container.arrangedSubviews[1]
        productTypeSelectorView.removeFromSuperview()
    }
    
    func addProductTypeSelectorView(with viewModel: OptionSelectorView.ViewModel) {
        
        guard let productTypeSelectorView = UIHostingController(rootView: OptionSelectorView(viewModel: viewModel)).view else {
            return
        }
        
        productTypeSelectorView.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(productTypeSelectorView)
    }
}
