//
//  MainViewControllerDataSource.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit


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
                    case 33:
                        guard let cell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: "AllCardCell",
                                for: indexPath) as? AllCardCell
                        else {
                            fatalError("Unable to dequeue \(AllCardCell.self)")
                        }
                        
                        
//                                cell.widthAnchor.constraint(equalToConstant: 112).isActive = true
                        return cell
                    case 32:
                        guard let cell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: "OfferCard",
                                for: indexPath) as? OfferCard
                        else {
                            fatalError("Unable to dequeue \(OfferCard.self)")
                        }
                        
                        
//                                cell.widthAnchor.constraint(equalToConstant: 112).isActive = true
                        return cell
                    default:
                        guard let cell = collectionView.dequeueReusableCell(
                                withReuseIdentifier: ProductCell.reuseId,
                                for: indexPath) as? ProductCell
                        else {
                            fatalError("Unable to dequeue \(ProductCell.self)")
                        }
                                cell.card = item.productList
                                return cell
                    }
            case .offer:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: OfferCollectionViewCell.reuseId,
                        for: indexPath) as? OfferCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(OfferCollectionViewCell.self)")
                }
                cell.backgroundColor = .red
                cell.backgroundColor = UIColor(patternImage: UIImage(named: self.offer[indexPath.row].iconName!) ?? UIImage())

                return cell
            case .currentsExchange:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CurrencyExchangeCollectionViewCell.reuseId,
                        for: indexPath) as? CurrencyExchangeCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(CurrencyExchangeCollectionViewCell.self)")
                }
                cell.rateBuyEuro.text = self.dataEuro?.rateBuy?.currencyFormatter(symbol: "")
                cell.rateSellEuro.text = self.dataEuro?.rateSell?.currencyFormatter(symbol: "")
                cell.rateBuyUSD.text = self.dataUSD?.rateBuy?.currencyFormatter(symbol: "")
                cell.rateSellUSD.text = self.dataUSD?.rateSell?.currencyFormatter(symbol: "")
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
//            case .offer:
//                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
//            case .pay:
//                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
//            case .openProduct:
//                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)
            case .branches:
                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)
            case .investment:
                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)  
            case .services:
                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)

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
            guard let section = Section(rawValue: indexPath.section)
                else { fatalError("Unknown section kind")
            }
            switch section {
            case .offer:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 1),
                                        textColor: .black, expandingIsHidden: true, seeAllIsHidden: true)
                sectionHeader.isHidden = true
            case .products:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false)
                sectionHeader.seeAllButton.addTarget(self, action: #selector(passAllProducts), for: .touchUpInside)
                sectionHeader.arrowButton.addTarget(self, action: #selector(expandingSection), for: .touchUpInside)
//            case .transfers:
//                sectionHeader.configure(text: section.description(),
//                                        font: .boldSystemFont(ofSize: 18),
//                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false)
            
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: true)
            }
            
//            if sectionHeader.title.text == "Отделения и банкоматы" || sectionHeader.title.text == "Инвестиции и пенсии"  || sectionHeader.title.text == "Услуги и сервисы" {
//                sectionHeader.title.alpha = 0.3
//                sectionHeader.arrowButton.alpha = 0.3
//            } else {
//                sectionHeader.title.alpha = 1
//                sectionHeader.arrowButton.alpha = 1
//            }
            
            return sectionHeader
        }
    }
    
    

    
    @objc func passAllProducts(){
            let viewController = ProductsViewController()
            viewController.addCloseButton()
            let navVC = UINavigationController(rootViewController: viewController)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
    }
    @objc func expandingSection()  -> NSCollectionLayoutSection {
     
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(0),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(0))
    
        if groupSize.widthDimension == .absolute(0){
            self.collectionView.reloadData()
        }
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])
        group.contentInsets = .uniform(size: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 16)
        
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}

