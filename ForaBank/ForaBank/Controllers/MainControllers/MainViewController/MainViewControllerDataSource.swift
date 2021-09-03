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
            case .offer:
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: OfferCollectionViewCell.reuseId,
                        for: indexPath) as? OfferCollectionViewCell
                else {
                    fatalError("Unable to dequeue \(OfferCollectionViewCell.self)")
                }
                cell.backgroundColor = .red
                cell.backgroundColor = UIColor(patternImage: UIImage(named: "promoBanner2") ?? UIImage())

                return cell
            
//            case .transfers:
//                if item.id != 33{
//                    guard let cell = collectionView.dequeueReusableCell(
//                            withReuseIdentifier: ProductCell.reuseId,
//                            for: indexPath) as? ProductCell
//                    else {
//                        fatalError("Unable to dequeue \(ProductCell.self)")
//                    }
//
//                    cell.card = item.productList
//                    return cell
//                } else {
//                    guard let cell = collectionView.dequeueReusableCell(
//                            withReuseIdentifier: "AllCardCell",
//                            for: indexPath) as? AllCardCell
//                    else {
//                        fatalError("Unable to dequeue \(AllCardCell.self)")
//                    }
//
//                    return cell
//                }
//            case .offer:
//                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
//            case .pay:
//                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
//            case .openProduct:
//                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)
//            case .branches:
//                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)
//            case .investment:
//                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)  
//            case .services:
//                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)

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
                                        font: .boldSystemFont(ofSize: 18),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: true)
//            case .transfers:
//                sectionHeader.configure(text: section.description(),
//                                        font: .boldSystemFont(ofSize: 18),
//                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: false)
//                sectionHeader.seeAllButton.addTarget(self, action: #selector(passAllProducts), for: .touchUpInside)
//                sectionHeader.arrowButton.addTarget(self, action: #selector(expandingSection), for: .touchUpInside)
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 18),
                                        textColor: .black, expandingIsHidden: false, seeAllIsHidden: true)
            }
            
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

