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
                    case 32:
                       if item.name == "Cм.все"{
                            guard let cell = collectionView.dequeueReusableCell(
                                    withReuseIdentifier: "AllCardCell",
                                    for: indexPath) as? AllCardCell
                            else {
                                fatalError("Unable to dequeue \(AllCardCell.self)")
                            }
    //                                cell.widthAnchor.constraint(equalToConstant: 112).isActive = true
                            return cell
                        } else {
                            guard let cell = collectionView.dequeueReusableCell(
                                    withReuseIdentifier: "OfferCard",
                                    for: indexPath) as? OfferCard
                            else {
                                fatalError("Unable to dequeue \(OfferCard.self)")
                            }
                            
                            
    //                                cell.widthAnchor.constraint(equalToConstant: 112).isActive = true
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
//                        cell.statusPC = item.productList?.statusPC
//                        cell.status  = item.productList?.status

                                return cell
                    }
            case .offer:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: OfferCollectionViewCell.reuseId,
                        for: indexPath) as? OfferCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(OfferCollectionViewCell.self)")
                }
//                cell.backgroundColor = .red
//                cell.backgroundColor = UIColor(patternImage: UIImage(named: self.offer[indexPath.row].iconName!) ?? UIImage())
                cell.backgroundImageView.image = UIImage(named: self.offer[indexPath.row].iconName ?? "")

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
                                        textColor: .black, expandingIsHidden: true, seeAllIsHidden: true, onlyCards: true)
                sectionHeader.isHidden = true
            case .products:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false, onlyCards: productsDeposits.isEmpty)
                sectionHeader.seeAllButton.addTarget(self, action: #selector(passAllProducts), for: .touchUpInside)
                sectionHeader.arrowButton.addTarget(self, action: #selector(expandingSection), for: .touchUpInside)
                sectionHeader.changeCardButtonCollection.complition = { (select) in
                    switch select {
                    case 0:
                        productList = productsCardsAndAccounts
                        productsFromRealm.removeAll()
                        for i in productList {
                            self.productsFromRealm.append(PaymentsModel(productListFromRealm: i))
//                            self.reloadData(with: nil)

                        }
                        var snapshot = self.dataSource?.snapshot()
                        
                         let items = snapshot?.itemIdentifiers(inSection: .products)
                        
                         snapshot?.deleteItems(items ?? [PaymentsModel]())
                        snapshot?.appendItems(self.productsFromRealm, toSection: .products)
//                                snapshot?.reloadSections([.products])
                        
                        
                        self.dataSource?.apply(snapshot ?? NSDiffableDataSourceSnapshot<Section, PaymentsModel>())
                        selectable = false
                        isFiltered = false
                    case 1:
                        selectable = false
                        
//                       productList = productList.filter({$0.productType == "CARD" || $0.productType == "ACCOUNT"})
                        productList = productsDeposits
                        productsFromRealm.removeAll()
                        for i in productList {
                            self.productsFromRealm.append(PaymentsModel(productListFromRealm: i))
//                            self.reloadData(with: nil)

                        }
                        
                        var snapshot = self.dataSource?.snapshot()
                        
                         let items = snapshot?.itemIdentifiers(inSection: .products)
                        
                         snapshot?.deleteItems(items ?? [PaymentsModel]())
                        snapshot?.appendItems(self.productsFromRealm, toSection: .products)
//                                snapshot?.reloadSections([.products])
                        
                        
                        self.dataSource?.apply(snapshot ?? NSDiffableDataSourceSnapshot<Section, PaymentsModel>())
                        
                        isFiltered = true
                    default:
                        isFiltered = false
                        
//                        productList = productList.filter({$0.productType == "DEPOSIT"})

                    }
                }
//            case .transfers:
//                sectionHeader.configure(text: section.description(),
//                                        font: .boldSystemFont(ofSize: 18),
//                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false)
            
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: true, onlyCards: true)
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
//            viewController.products = self.productList
            let navVC = UINavigationController(rootViewController: viewController)
            navVC.modalPresentationStyle = .fullScreen
            
            present(navVC, animated: true)
    }
    @objc func expandingSection()  -> NSCollectionLayoutSection {
     
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(0),
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

