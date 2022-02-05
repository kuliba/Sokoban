//
//  DepositCalculatorViewControllerFlowLayout.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

extension DepositCalculatorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 20, left: 20, bottom: 90, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(
                width: collectionView.bounds.width - 40,
                height: 252)
            
        case 1:
            return CGSize(
                width: collectionView.bounds.width - 40,
                height: 388)
            
        case 2:
            let height = ((product?.detailedСonditions?.count ?? 1) * 44) + 40
            return CGSize(
                width: Int(collectionView.bounds.width) - 40,
                height: height)
        case 3:
            var height: CGFloat = 88
            if (product?.txtСondition?.count ?? 0) > 0 {
                product?.txtСondition?.forEach({ term in
                    height += requiredHeight(text: term, cellWidth: collectionView.bounds.width - 94) + 8
                })
            }
            return CGSize(
                width: collectionView.bounds.width - 40,
                height: height)
            
        case 4:
            return CGSize(
                width: collectionView.bounds.width - 40,
                height: 180)
            
        default:
            return CGSize(
                width: collectionView.bounds.width,
                height: 52)
        }
    }
    
    func requiredHeight(text: String?, cellWidth: CGFloat) -> CGFloat {
        let font = UIFont(name: "Inter-Regular", size: 14)
        let label: UILabel = UILabel(
            frame: CGRect(x: 0, y: 0,
                          width: cellWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
}
