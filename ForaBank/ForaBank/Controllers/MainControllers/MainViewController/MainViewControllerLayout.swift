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
            
            guard let section = Section(rawValue: sectionIndex),
                  let isSectionExpanded = self.sectionsExpanded.value[section] else {
                        
                return nil
            }
            
            switch section {
            case .updateInfo: return nil // old code, not used
            case .products:
                if self.productsViewModels.count > 0 {
                    return self.createProductSection(type: 1, isExpanded: isSectionExpanded)
                } else {
                    return nil
                }
            case .pay:
                if self.paymentsViewModels.count > 0 {
                    return self.createPaySection(isExpanded: isSectionExpanded)
                } else {
                    return nil
                }
            case .offer:
                if self.promoViewModels.count > 0 {
                    return self.createOffersSection(isExpanded: isSectionExpanded)
                } else {
                    return nil
                }
            case .currentsExchange:
                if self.exchangeRatesViewModels.count > 0 {
                    return self.createCurrencyExternalSection(isExpanded: isSectionExpanded)
                } else {
                    return nil
                }
            case .openProduct:
                if self.openProductViewModels.count > 0 {
                    return self.createOpenProduct(isExpanded: isSectionExpanded)
                } else {
                    return nil
                }
                
            case .atm:
                return self.createAtm(isExpanded: isSectionExpanded)

            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        layout.configuration = config
        
        return layout
    }

    private func createProductSection(type: Int?, isExpanded: Bool) -> NSCollectionLayoutSection {

        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            var groupSize = NSCollectionLayoutSize(widthDimension: .absolute(164), heightDimension: .absolute(104))
        
            if type == 32 {
                
                groupSize = NSCollectionLayoutSize(widthDimension: .absolute(112), heightDimension: .absolute(104))
            }
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,  subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 8, leading: 20, bottom: 32, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            
            if productTypeSelector.productTypes.count > 1 {
                
                section.boundarySupplementaryItems = [createSectionHeaderWithButtons()]
                
            } else {
                
                section.boundarySupplementaryItems = [createSectionHeader()]
            }
           
            return section
            
        } else {
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.01))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,  subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [createSectionHeader()]
            
            return section
        }
    }
    
    private func createOffersSection(isExpanded: Bool) -> NSCollectionLayoutSection {
        
        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(288),
              heightDimension: .absolute(124))
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 0, leading: 20, bottom: 32, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            return section
            
        } else {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(288), heightDimension: .absolute(0.01))
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
    }

    private func createCurrencyExternalSection(isExpanded: Bool) -> NSCollectionLayoutSection {

        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .absolute(124))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = .init(top: 16, leading: 20, bottom: 32, trailing: 0)
            section.orthogonalScrollingBehavior = .none

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            return section
            
        } else {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),heightDimension: .absolute(0.01))

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 20, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .none

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
    }

    private func createPaySection(isExpanded: Bool) -> NSCollectionLayoutSection {

        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(96))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 4
            section.contentInsets = .init(top: 16, leading: 20, bottom: 32, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            return section
            
        } else {
           
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(80), heightDimension: .absolute(0.01))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 20, bottom: 0, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
    }

    private func createOpenProduct(isExpanded: Bool) -> NSCollectionLayoutSection {

        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(124))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 20, bottom: 32, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]

            return section
            
        } else {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(0.1))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
  
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 20, bottom: 0, trailing: 20)
            section.orthogonalScrollingBehavior = .continuous

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
    }
    
    private func createAtm(isExpanded: Bool) -> NSCollectionLayoutSection {

        if isExpanded == true {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(124))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 20, bottom: 32, trailing: 20)

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]

            return section
            
        } else {
            
            let item = NSCollectionLayoutItem.withEntireSize()
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.1))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
  
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 16, leading: 20, bottom: 0, trailing: 20)

            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
    }

    
     func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
   
        return sectionHeader
    }
    func createSectionHeaderWithButtons() -> NSCollectionLayoutBoundarySupplementaryItem{
       let sectionHeaderSize = NSCollectionLayoutSize(
           widthDimension: .fractionalWidth(1),
           heightDimension: .absolute(60))
       
       let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
           layoutSize: sectionHeaderSize,
           elementKind: UICollectionView.elementKindSectionHeader,
           alignment: .top)

       return sectionHeader
   }

}

