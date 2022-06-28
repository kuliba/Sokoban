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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var labelArray: [UILabel]!
    
    var banksName: [String]? {
        didSet {
            guard banksName != nil else { return }
            collectionView.reloadData()
        }
    }
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "BanksCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: BanksCollectionViewCell.refCell)
        
        
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
            
            self.banksName = banks
            
//            if banks.count > 0 {
//                for i in 0..<banks.count {
//                    if i < self.labelArray.count {
//                        self.labelArray[i].text = banks[i]
//                    }
//                }
//
//                self.labelArray.forEach { label in
//                    if label.text == "" {
//                        label.isHidden = true
//                    }
//                }
//
//
//            } else {
//                self.labelArray.forEach { label in
//                    label.isHidden = true
//                }
//            }
        }
    }
    
    
    @IBAction private func chooseButtonTapped(_ sender: Any) {
        didChooseButtonTapped?()
    }
    
    
}

extension BanksView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return banksName?.count ?? 0
        }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: BanksCollectionViewCell.refCell,
                    for: indexPath) as! BanksCollectionViewCell
            
        let bank = banksName?[indexPath.item]
        cell.configure(with: bank, and: indexPath)
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = banksName?[indexPath.item].count ?? 0
        return CGSize(width:  count > 22
                      ? 230 : count * 11, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
        
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
