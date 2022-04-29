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
        if product?.termRateCapList != nil {
            return 6
        } else {
            return 5
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainDepositCell, for: indexPath) as! MainDepositCollectionViewCell
            cell.viewModel = product
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calculatorDepositCell, for: indexPath) as! CalculatorDepositCollectionViewCell
            cell.viewModel = product
            cell.delegate = self
            return cell
            
        case 2:
            if product?.termRateCapList != nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: termsCapitCell, for: indexPath) as! DetailCapitCollectionViewCell
                cell.viewModel = product
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailDepositCell, for: indexPath) as! DetailInformationCollectionViewCell
                cell.viewModel = product
                return cell
            }
        case 3:
            if product?.termRateCapList != nil {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailDepositCell, for: indexPath) as! DetailInformationCollectionViewCell
                cell.viewModel = product
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: termsDepositCell, for: indexPath) as! TermsDepositCollectionViewCell
                cell.documentsList = product?.txtСondition ?? []
                return cell
            }
        case 4:
            if product?.termRateCapList != nil {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: termsDepositCell, for: indexPath) as! TermsDepositCollectionViewCell
                cell.documentsList = product?.txtСondition ?? []
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: docDepositCell, for: indexPath) as! DocDepositCollectionViewCell
                cell.documentsList = product?.documentsList
                return cell
            }
            
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: docDepositCell, for: indexPath) as! DocDepositCollectionViewCell
            cell.documentsList = product?.documentsList
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
}
