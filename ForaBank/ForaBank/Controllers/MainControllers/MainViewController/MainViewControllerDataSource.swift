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
            case .payments:
                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
            case .transfers:
                return self.configure(collectionView: collectionView, cellType: ProductCell.self, with: item, for: indexPath)
            case .offer:
                return self.configure(collectionView: collectionView, cellType: OrderProductsCollectionViewCell.self, with: item, for: indexPath)
            case .pay:
                return self.configure(collectionView: collectionView, cellType: CurrencyExchangeCollectionViewCell.self, with: item, for: indexPath)
            }
        })
        dataSource?.supplementaryViewProvider = {
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
            case .payments:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 18),
                                        textColor: .black)
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 18),
                                        textColor: .black)
            }
            
            return sectionHeader
        }
    }
}

