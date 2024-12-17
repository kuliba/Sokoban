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
        return productsCount > 0 ? products.count+1 : products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell  else {
            return UICollectionViewCell()
        }
        
        guard let buttonItem = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreButtonCollectionViewCell", for: indexPath) as? MoreButtonCollectionViewCell  else {
            return UICollectionViewCell()
        }
            
        if productsCount > 0, indexPath.item == products.count {
            
            return buttonItem
            
        } else {
            
            item.cardImageView.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
        }
        
        if product?.number == products[indexPath.row].number {
            
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell) != nil {
            
            product = products[indexPath.item]
            
        } else {
            
            let vc = ProductsViewController()
            
            vc.delegateProducts = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {}
}
