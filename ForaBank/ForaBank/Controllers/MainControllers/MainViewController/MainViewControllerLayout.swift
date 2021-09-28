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
        config.interSectionSpacing = 0
        layout.configuration = config
        return layout
    }

    private func createProduct() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(164),
//            heightDimension: .fractionalHeight(0.2))
          heightDimension: .absolute(104))

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item])
//        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
//        group.contentInsets = .init(top: 12, leading: 20, bottom: 19, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 20, leading: 20, bottom: 32, trailing: 20)
        
        
        section.orthogonalScrollingBehavior = .paging
        let sectionHeader = createSectionHeader()
        sectionHeader.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
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
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)

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
        
//        group.contentInsets = .uniform(size: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 20, bottom: 32, trailing: 20)


        section.orthogonalScrollingBehavior = .continuous
        
//        let sectionHeader = nil
//        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    
//
    private func createCurrencyExternal() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.95),
//            heightDimension: .fractionalHeight(0.35))
            heightDimension: .absolute(124))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize, subitem: item, count: 1)

//        group.contentInsets = .uniform(size: 5)

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 0
        
        section.contentInsets = .init(top: 20, leading: 20, bottom: 32, trailing: 0)


        section.orthogonalScrollingBehavior = .none

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        sectionHeader.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
//
    private func createPay() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem.withEntireSize()
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
//            heightDimension: .fractionalHeight(0.12))
            heightDimension: .absolute(96))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 4
        section.contentInsets = .init(top: 20, leading: 8, bottom: 32, trailing: 20)
        
        
        section.orthogonalScrollingBehavior = .continuous
        let sectionHeader = createSectionHeader()
        sectionHeader.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 0)
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
        

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 20, leading: 20, bottom: 32, trailing: 20)


        section.orthogonalScrollingBehavior = .continuous

        let sectionHeader = createSectionHeader()
        
        section.boundarySupplementaryItems = [sectionHeader]
        sectionHeader.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)

        return section
    }

    
     func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(24))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
         
         sectionHeader.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        
        return sectionHeader
    }

}

