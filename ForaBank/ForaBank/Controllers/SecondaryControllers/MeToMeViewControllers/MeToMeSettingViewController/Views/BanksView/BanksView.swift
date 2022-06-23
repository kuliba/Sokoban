//
//  BanksView.swift
//  ForaBank
//
//  Created by Mikhail on 20.09.2021.
//

import UIKit

class BanksView: UIView {
    
    //MARK: - Property
    let kContentXibName = "BanksView"
    
    
    @IBOutlet var labelArray: [UILabel]!
    
    
    var consentList: [ConsentList]? {
        didSet {
            guard let list = consentList else { return }
            setupList(consentList: list)
        }
    }
    
    @IBOutlet var contentView: UIView!
    
    
    var didChooseButtonTapped: (() -> Void)?
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.anchor(height: 130)
        
        
    }
    
    private func setupList(consentList: [ConsentList]) {
        
        DispatchQueue.main.async {
            let allBanks = Model.shared.dictionaryFullBankInfoList()
            
            var banks: [String] = []
            
            consentList.forEach { bank in
                allBanks?.forEach({ fullBank in
                    let fullBankItem = fullBank.fullBankInfoList
                    if fullBankItem.memberID == bank.bankId {
                        banks.append(fullBankItem.rusName ?? "")
                    }
                })
            }
            if banks.count > 0 {
                
                for i in 0..<banks.count {
                    if i < self.labelArray.count {
                        self.labelArray[i].text = banks[i]
                    }
                }
                
                self.labelArray.forEach { label in
                    if label.text == "" {
                        label.isHidden = true
                    }
                }
                
                
            } else {
                self.labelArray.forEach { label in
                    label.isHidden = true
                }
            }
        }
    }
    
    
    @IBAction private func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
    
    
}
