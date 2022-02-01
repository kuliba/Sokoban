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
        config.interSectionSpacing = 0
        
        layout.configuration = config
        
        return layout
    }
    
    
    private func createPayments() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(96))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .uniform(size: 0)
    
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        
        section.contentInsets = .init(top: 16, leading: 8, bottom: 32, trailing: 20)
        
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader(32)
        sectionHeader.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    private func createTransfers() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(104),
          heightDimension: .absolute(124))
    
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])
        
        group.contentInsets = .uniform(size: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 16, leading: 20, bottom: 32, trailing: 20)

        
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeader = createSectionHeader(24)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    
    private func createPay() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        var groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.81),
            heightDimension: .absolute(180))
        
        var group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize, subitem: item, count: 3)
        
        
        if self.view.frame.size.height > 900{
            groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.81),
                heightDimension: .absolute(250))
            
            group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize, subitem: item, count: 4)
        } 
        
        group.contentInsets = .uniform(size: 0)
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 10, leading: 20, bottom: 32, trailing: 20)
            
        section.orthogonalScrollingBehavior = .groupPaging
        
        let sectionHeader = createSectionHeader(24)
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    
    private func createSectionHeader( _ size: Int) -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension:.absolute(CGFloat(size)))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        return sectionHeader
    }

}

