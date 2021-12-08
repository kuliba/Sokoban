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
        default:
            return CGSize(
                width: collectionView.bounds.width,
                height: 52)
        }
    }
    
}
