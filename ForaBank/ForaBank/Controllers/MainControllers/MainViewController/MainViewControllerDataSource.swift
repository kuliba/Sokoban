//
//  MainViewControllerDataSource.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit
import SDWebImage

// MARK: - Data Source PaymentsViewControllerDataSource
extension MainViewController {
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PaymentsModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            
            switch section {
            case .products:
                switch item.id {
                case 32:
                    if item.name == "Cм.все"{
                        guard let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: "AllCardCell",
                            for: indexPath) as? AllCardCell
                        else {
                            fatalError("Unable to dequeue \(AllCardCell.self)")
                        }
                        
                        return cell
                    } else {
                        guard let cell = collectionView.dequeueReusableCell(
                            withReuseIdentifier: "OfferCard",
                            for: indexPath) as? OfferCard
                        else {
                            fatalError("Unable to dequeue \(OfferCard.self)")
                        }
                        
                        return cell
                    }
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ProductCell.reuseId,
                        for: indexPath) as? ProductCell
                    else {
                        fatalError("Unable to dequeue \(ProductCell.self)")
                    }
                    
                    cell.card = item.productListFromRealm
                    
                    return cell
                }
                
            case .offer:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: OfferCollectionViewCell.reuseId,
                    for: indexPath) as? OfferCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(OfferCollectionViewCell.self)")
                }
                
                let url = URL(string: self.promoViewModels[indexPath.row].iconName ?? "")
                cell.backgroundImageView.sd_setImage(with: url)
                
                return cell
                
            case .currentsExchange:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CurrencyExchangeCollectionViewCell.reuseId,
                    for: indexPath) as? CurrencyExchangeCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(CurrencyExchangeCollectionViewCell.self)")
                }
                if let euroBuy = self.dataEuro?.rateBuy{
                    
                    cell.rateBuyEuro.text = euroBuy.currencyFormatterForMain()
                }
                if let euroSell = self.dataEuro?.rateSell{
                    
                    cell.rateSellEuro.text = euroSell.currencyFormatterForMain()
                }
                if let usdBuy = self.dataUSD?.rateBuy{
                    
                    cell.rateBuyUSD.text = usdBuy.currencyFormatterForMain()
                }
                if let usdSell = self.dataUSD?.rateSell{
                    
                    cell.rateSellUSD.text =  usdSell.currencyFormatterForMain()
                }
                cell.backgroundColor = .red
                
                return cell
                
            case .pay:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PaymentsMainCell.reuseId,
                    for: indexPath) as? PaymentsMainCell
                else {
                    fatalError("Unable to dequeue \(PaymentsMainCell.self)")
                }
                cell.configure(with: item)
                
                return cell
                
            case .openProduct:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewProductCell.reuseId,
                    for: indexPath) as? NewProductCell
                else {
                    fatalError("Unable to dequeue \(NewProductCell.self)")
                }
                
                cell.configure(with: item)
                
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { [self]
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseId,
                for: indexPath) as? SectionHeader
            else { fatalError("Can not create new section header")
            }
            guard let section = Section(rawValue: indexPath.section),
                  let isSectionExpanded = self.sectionsExpanded.value[section] else {
                      
                      fatalError("Unknown section kind")
                  }
            
            let toggleAction: () -> Void = { [weak self] in self?.toggleExpanded(for: section) }
            switch section {
            case .offer:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 1),
                                        textColor: .black, expandingIsHidden: true, seeAllIsHidden: true, onlyCards: true, isExpanded: isSectionExpanded, expandAction: {})
                sectionHeader.isHidden = true
            case .products:
                let productSelectorViewModel = isSectionExpanded ? self.productTypeSelector.optionSelector : nil
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false, onlyCards: false, isExpanded: isSectionExpanded, expandAction: toggleAction, productSelectorViewModel: productSelectorViewModel)
                sectionHeader.seeAllButton.addTarget(self, action: #selector(passAllProducts), for: .touchUpInside)
                
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: true, onlyCards: true, isExpanded: isSectionExpanded, expandAction: toggleAction)
            }
            
            return sectionHeader
        }
    }
    
    @objc func passAllProducts() {
        
        let viewController = ProductsViewController()
        viewController.addCloseButton()
        //            viewController.products = self.productList
        let navVC = UINavigationController(rootViewController: viewController)
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true)
    }
}

