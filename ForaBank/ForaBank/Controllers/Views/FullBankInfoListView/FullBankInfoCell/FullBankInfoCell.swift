//
//  FullBankInfoCell.swift
//  ForaBank
//
//  Created by Mikhail on 28.07.2021.
//

import UIKit

class FullBankInfoCell: UICollectionViewCell {
    
    //MARK: - Properties
    var bank: BankFullInfoList? {
        didSet { configure() }
    }
    var index: IndexPath?
    
    let bankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 40, width: 40)
        return imageView
    }()
    
    let bankNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    let bicLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
        label.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return label
    }()

    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    func configure() {
        guard let bank = bank else { return }
        guard let index = index else { return }
        let viewModel = FullBankInfoListViewModel(bank: bank, index: index)
        bankNameLabel.text = viewModel.bankName
        bankImageView.image = viewModel.bankImage
        bankImageView.backgroundColor = viewModel.backgroundColor
        bankImageView.layer.cornerRadius = viewModel.cornerRadius
        bicLabel.text = bank.bic
        bicLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }
    
    func setupUI() {
//        backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.968627451, alpha: 1)
//        layer.cornerRadius = 8
//        clipsToBounds = true
        addSubview(bankImageView)
        addSubview(bankNameLabel)
        addSubview(bicLabel)
        
        bankImageView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 4)
        bankNameLabel.centerX(inView: self, topAnchor: bankImageView.bottomAnchor, paddingTop: 8)
        bankNameLabel.anchor(left: leftAnchor, right: rightAnchor, width: 64)
        bicLabel.centerX(inView: self, topAnchor: bankNameLabel.bottomAnchor, paddingTop: 2)
        bicLabel.anchor(left: leftAnchor, right: rightAnchor, width: 64)
    }
    
}
