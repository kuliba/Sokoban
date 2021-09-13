//
//  PaymentsViewControllerLayout.swift
//  ForaBank
//
//  Created by Mikhail on 03.06.2021.
//

import UIKit

extension MainViewController {

    func createCompositionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }
            switch section {
            case .products:
                if self.products.count > 0{
                    return self.createProduct()
                } else {
                    return nil
                }
            case .pay:
                if self.pay.count > 0 {
                    return self.createPay()
                } else {
                    return nil
                }
            case .offer:
                if self.offer.count > 0 {
                    return self.createOffers()
                } else {
                    return nil
                }
            case .currentsExchange:
                if self.currentsExchange.count > 0 {
                    return self.createCurrencyExternal()
                } else {
                    return nil
                }
            case .openProduct:
                if self.openProduct.count > 0 {
                    return self.createOpenProduct()
                } else {
                    return nil
                }

            case .branches:
                return self.createSection()
            case .services:
                return self.createSection()
            case .investment:
                return self.createSection()
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        layout.configuration = config
        return layout
    }

    private func createProduct() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(164),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(117))
        
        
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])

        group.contentInsets = .uniform(size: 5)
        
        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 8)

        section.orthogonalScrollingBehavior = .continuous
        section.orthogonalScrollingBehavior = .paging
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
//
    private func createSection() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(0),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(0))

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])

        group.contentInsets = .uniform(size: 0)

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 0)

        section.orthogonalScrollingBehavior = .continuous

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func createOffers() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(288),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(124))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])
        
        group.contentInsets = .uniform(size: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(horizontal: 20, vertical: 10)
        
        section.orthogonalScrollingBehavior = .paging
        
//        let sectionHeader = nil
//        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    
//
    private func createCurrencyExternal() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
//            heightDimension: .fractionalHeight(0.35))
            heightDimension: .absolute(124))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize, subitem: item, count: 1)

        group.contentInsets = .uniform(size: 5)

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 10
        section.contentInsets = .init(horizontal: 20, vertical: 8)

        section.orthogonalScrollingBehavior = .continuous

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
//
    private func createPay() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(88),
//            heightDimension: .fractionalHeight(0.12))
            heightDimension: .absolute(100))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .uniform(size: 5)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4

        section.contentInsets = .init(horizontal: 20, vertical: 16)

        section.orthogonalScrollingBehavior = .paging

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    private func createOpenProduct() -> NSCollectionLayoutSection {

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
        section.contentInsets = .init(horizontal: 20, vertical: 16)

        section.orthogonalScrollingBehavior = .paging

        let sectionHeader = createSectionHeader()
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    
     func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(50))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        
        return sectionHeader
    }

}

