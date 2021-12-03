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
        if products.count > 3{
            return 4
        } else {
            return products.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case products.count:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell
    //        item?.card = products[indexPath.item]
            item?.cardImageView.image = UIImage(named: "cardMore")
//            item?.backgroundColor = .gray
//            item?.selectedView.isHidden = true
            
//            item?.isSelected = false
            if products.count > 0, indexPath.item > 3, product?.number == products[indexPath.row].number{
                item?.showSelect()
                item?.isSelected = true
                item?.cardImageView.alpha = 1
                item?.selectedView.isHidden = false
                self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                
            } else {
                item?.isSelected = false
                item?.hideSelect()
                item?.showSelect()
                item?.cardImageView.alpha = 0.5
                item?.selectedView.isHidden = true
            }

//            item?.showSelect()
            return item ?? UICollectionViewCell()
        default:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell
    //        item?.card = products[indexPath.item]
//            item?.selectedView.isHidden = true
            item?.cardImageView.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
//            if firstTimeLoad{
//                item?.isSelected = false
//            }
            if products.count > 0, indexPath.item != 3, product?.number == products[indexPath.item].number {
                self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                item?.showSelect()
                item?.isSelected = true
                item?.cardImageView.alpha = 1
                item?.selectedView.isHidden = false
                
            } else {
                item?.isSelected = false
                item?.hideSelect()
                item?.showSelect()
                item?.cardImageView.alpha = 0.5
                item?.selectedView.isHidden = true
            }

            return item ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView?.showAnimatedGradientSkeleton()
        historyArray.removeAll()
        historyArrayAccount.removeAll()
        sorted.removeAll()
        groupByCategory.removeAll()
        tableView?.reloadInputViews()
        tableView?.isSkeletonable = true
        
        statusBarView.showAnimatedGradientSkeleton()
       
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
        
        if firstTimeLoad, products.count != 0{
            firstTimeLoad = false
//            self.collectionView?.selectItem(at: IndexPath(item: indexItem ?? 0, section: 0), animated: true, scrollPosition: .bottom)
            let cell = collectionView.cellForItem(at: IndexPath(item: indexItem ?? 0, section: 0)) as? CardCollectionViewCell
//            product = products[self.indexItem ?? 0]
            cell?.showSelect()
        } else {
            if indexPath.item < products.count{
                if indexItem ?? 0 < 3{
//                    product = products[indexPath.item]
                    self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                } else {
//                    product = products[indexPath.item]
                    indexItem = 0
                }
                
//                guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else {return}
//                cell.showSelect()
            } else {
                self.collectionView?.deselectItem(at: indexPath, animated: true)
                let vc = ProductsViewController()
                vc.addCloseButton()
                vc.delegateProducts = self
                present(vc, animated: true, completion: nil)
            }
        }
        if product?.status == "Заблокирована банком" || product?.status == "Блокирована по решению Клиента" || product?.status == "BLOCKED_CREDIT" || product?.status == "BLOCKED_DEBET" || product?.status == "BLOCKED", product?.statusPC == "3" || product?.statusPC == "5" || product?.statusPC == "6"  || product?.statusPC == "7"  || product?.statusPC == "20"  || product?.statusPC == "21" ||  product?.statusPC == nil{
            card.addSubview(blockView)
            button.isEnabled = false
            button.alpha = 0.4
            button2.isEnabled = false
            button2.alpha = 0.4
            button4.setTitle("Разблокирова.", for: .normal)
            button4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let btnImage4 = UIImage(named: "unlock")
            button4.tintColor = .black
            button4.setImage(btnImage4 , for: .normal)
            blockView.isHidden = false
            activateSlider.isHidden = true
        } else if product?.status == "Действует" || product?.status == "Выдано клиенту", product?.statusPC == "17"{
                button.isEnabled = false
                button.alpha = 0.4
                button2.isEnabled = false
                button2.alpha = 0.4
                button4.isEnabled = false
                button4.alpha = 0.4
                activateSlider.isHidden = false
                blockView.isHidden = true
        } else {
            if product?.productType == "DEPOSIT"{
                button.isUserInteractionEnabled = false
                button.alpha = 0.4
                button2.isUserInteractionEnabled = false
                button2.alpha = 0.4
            } else {
                button2.isEnabled = true
                button2.alpha = 1
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        cell?.hideSelect()
    }
}
