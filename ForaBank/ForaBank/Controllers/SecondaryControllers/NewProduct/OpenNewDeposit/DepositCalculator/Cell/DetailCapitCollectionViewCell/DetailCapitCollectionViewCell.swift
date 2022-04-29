//
//  DetailCapitCollectionViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 28.04.2022.
//

import UIKit

class DetailCapitCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleStakView: UIStackView!
    
    var viewModel: OpenDepositDatum? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        guard let capRate = viewModel.termRateCapList?.first else { return }
        
        
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 0
        stack.isUserInteractionEnabled = true
        
        addSubview(stack)
        stack.anchor(top: titleStakView.bottomAnchor, left: leftAnchor, right: rightAnchor)
        
        if let capTermRateSum = capRate.termRateSum {
            for num in 0 ..< capTermRateSum.count {
                let cell = DetailCapitView()
                
                let rate = viewModel.termRateList?.first?.termRateSum
                rate?.forEach { term in
                    if term.sum == capTermRateSum[num].sum {
                        
                        cell.amount.text = (capTermRateSum[num].sum ?? 0).currencyFormatterForMain()
                        cell.rateleft.text = "\(term.termRateList?[0].rate ?? 0) (\(capTermRateSum[num].termRateList?[0].rate ?? 0))"
                        cell.rateRight.text = "\(term.termRateList?[1].rate ?? 0) (\(capTermRateSum[num].termRateList?[1].rate ?? 0))"
                        
                    }
                }
                
                if num/2 == 0 {
                    if num == 0 {
                        cell.backgroundColor = .clear
                    } else {
                        cell.backgroundColor = .white
                    }
                } else {
                    cell.backgroundColor = .clear
                }
                stack.addArrangedSubview(cell)
                
            }
        }
    }
    
}
