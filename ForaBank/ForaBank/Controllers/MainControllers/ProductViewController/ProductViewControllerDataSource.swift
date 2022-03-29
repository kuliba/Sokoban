//
//  ProductViewControllerDataSource.swift
//  ForaBank
//
//  Created by Дмитрий on 14.09.2021.
//

import Foundation
import UIKit


extension ProductViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch product?.productType {
        case ProductType.card.rawValue:
            return products.filter({ $0.productType == ProductType.card.rawValue }).prefix(3).count
        case ProductType.account.rawValue:
            return products.filter({ $0.productType == ProductType.account.rawValue }).prefix(3).count
        case ProductType.deposit.rawValue:
            return products.filter({ $0.productType == ProductType.deposit.rawValue }).prefix(3).count
        case ProductType.loan.rawValue:
            return products.filter({ $0.productType == ProductType.loan.rawValue }).prefix(3).count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard  let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell  else {
            return UICollectionViewCell()
        }
        
        switch product?.productType {
        case ProductType.card.rawValue:
            let filterCard = products.filter({ $0.productType == ProductType.card.rawValue })
            item.cardImageView.image = filterCard[indexPath.row].smallDesign?.convertSVGStringToImage()
            return item
            
        case ProductType.account.rawValue:
            let filterAccount = products.filter({ $0.productType == ProductType.account.rawValue })
            item.cardImageView.image = filterAccount[indexPath.row].smallDesign?.convertSVGStringToImage()
            return item
            
        case ProductType.deposit.rawValue:
            let filterDeposit = products.filter({ $0.productType == ProductType.deposit.rawValue })
            item.cardImageView.image = filterDeposit[indexPath.row].smallDesign?.convertSVGStringToImage()
            return item
            
        case ProductType.loan.rawValue:
            var filterLoan = products.filter({ $0.productType == ProductType.loan.rawValue })
            let additionalAccount = products.filter({$0.number == product?.settlementAccount})
            filterLoan += additionalAccount
            
            item.cardImageView.image = filterLoan[indexPath.row].smallDesign?.convertSVGStringToImage()
            return item
            
        default:
            
            return item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch product?.productType {
        case ProductType.card.rawValue:
            let filterCard = products.filter({ $0.productType == ProductType.card.rawValue })
            product = filterCard[indexPath.item]
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            
        case ProductType.account.rawValue:
            let filterAccount = products.filter({ $0.productType == ProductType.account.rawValue })
            product = filterAccount[indexPath.item]
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            
        case ProductType.deposit.rawValue:
            let filterDeposit = products.filter({ $0.productType == ProductType.deposit.rawValue })
            product = filterDeposit[indexPath.item]
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            
        case ProductType.loan.rawValue:
            var filterLoan = products.filter({ $0.productType == ProductType.loan.rawValue })
            let additionalAccount = products.filter({$0.number == product?.settlementAccount})
            filterLoan += additionalAccount
            
            product = filterLoan[indexPath.item]
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            
        default:
            print("default")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        cell?.hideSelect()
    }
    
    func showSelect(item: CardCollectionViewCell, indexPath: IndexPath) {
        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        item.showSelect()
        item.isSelected = true
        item.cardImageView.alpha = 1
        item.selectedView.isHidden = false
    }
    
    func hideSelect(item: CardCollectionViewCell, indexPath: IndexPath) {
        item.isSelected = false
        item.hideSelect()
        item.cardImageView.alpha = 0.5
        item.selectedView.isHidden = true
    }
}
