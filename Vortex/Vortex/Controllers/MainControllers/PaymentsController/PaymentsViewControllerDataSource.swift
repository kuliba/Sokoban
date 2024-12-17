//
//  PaymentsViewControllerDataSource.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit


// MARK: - Data Source PaymentsViewControllerDataSource
extension PaymentsViewController {
       
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PaymentsModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            switch section {
            case .payments:
                return self.configure(collectionView: collectionView, cellType: PaymentsCell.self, with: item, for: indexPath)
            case .transfers:
                return self.configure(collectionView: collectionView, cellType: TransferCell.self, with: item, for: indexPath)
            case .pay:
                return self.configure(collectionView: collectionView, cellType: PayCell.self, with: item, for: indexPath)
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
                                        font: .boldSystemFont(ofSize: 24),
                                        textColor: .black, expandingIsHidden: true, seeAllIsHidden: true, onlyCards: true, isExpanded: true, expandAction: {})
            default:
                sectionHeader.configure(text: section.description(),
                                        font: .boldSystemFont(ofSize: 20),
                                        textColor: .black, expandingIsHidden: true, seeAllIsHidden: true, onlyCards: true, isExpanded: true, expandAction: {})
                
            }
            
            return sectionHeader
        }
    }
}
