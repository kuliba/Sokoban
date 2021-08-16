//
//  PaymentsViewControllerLayout.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

extension PaymentsViewController {
    func createCompositionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }
            switch section {
            case .payments:
                if self.payments.count > 0 {
                    return self.createPayments()
                } else {
                    return nil
                }
            case .transfers:
                if self.transfers.count > 0 {
                    return self.createTransfers()
                } else {
                    return nil
                }
            case .pay:
                if self.pay.count > 0 {
                    return self.createPay()
                } else {
                    return nil
                }
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }
    
    private func createPayments() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(88),
//            heightDimension: .fractionalHeight(0.12))
            heightDimension: .absolute(100))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .uniform(size: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = .init(horizontal: 8, vertical: 8)
        
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    private func createTransfers() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(104),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(124))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])
        
        group.contentInsets = .uniform(size: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 8)
        
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    
    private func createPay() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(0.73),
            widthDimension: .fractionalWidth(0.73),
//            heightDimension: .fractionalHeight(0.35))
            heightDimension: .absolute(180))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize, subitem: item, count: 3)
        
        group.contentInsets = .uniform(size: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 8)
            
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.absolute(20))
//            heightDimension: .estimated(1))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        return sectionHeader
    }

}

