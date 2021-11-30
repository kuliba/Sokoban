//
//  DepositCalculatorViewControllerDataSource.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit


// MARK: UICollectionViewDataSource
extension DepositCalculatorViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainDepositCell, for: indexPath) as! MainDepositCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calculatorDepositCell, for: indexPath) as! CalculatorDepositCollectionViewCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailDepositCell, for: indexPath) as! DetailInformationCollectionViewCell
            cell.elements = product?.detailedСonditions
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
}
