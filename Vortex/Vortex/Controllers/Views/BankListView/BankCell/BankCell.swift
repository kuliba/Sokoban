//
//  BankCell.swift
//  ForaBank
//
//  Created by Mikhail on 03.07.2021.
//

import UIKit

class BankCell: UICollectionViewCell {
    
    //MARK: - Properties
    var bank: BanksList? {
        didSet { configure() }
    }
    
    private let bankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 40, width: 40)
        return imageView
    }()
    
    private let bankNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 11 )
        label.textAlignment = .center
        label.text = ""
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
        
        let viewModel = BankViewModel(bank: bank)
        
        bankNameLabel.text = viewModel.bankName
        
        bankImageView.image = viewModel.bankImage
    }
    
    func setupUI() {
        
        addSubview(bankImageView)
        addSubview(bankNameLabel)
        
        bankImageView.centerX(inView: self, topAnchor: self.topAnchor, paddingTop: 4)
        bankNameLabel.centerX(inView: self, topAnchor: bankImageView.bottomAnchor, paddingTop: 8)
        bankNameLabel.anchor(width: 64)
        
    }
    
}
