//
//  BankListView.swift
//  ForaBank
//
//  Created by Mikhail on 03.07.2021.
//

import UIKit

class BankListView: UIView {
    
    var seeAll = true
    
    //MARK: - Property
    let reuseIdentifier = "BankCell"
    
    var bankList = [BanksList]() {
        didSet { 
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var didBankTapped: ((BanksList) -> Void)?
    var didSeeAll: ((BanksList) -> Void)?
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    
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
        self.anchor(height: 100)
        setupCollectionView()
        isHidden = true
        alpha = 0
    }
    
    //MARK: - Helpers
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: self.topAnchor, left: self.leftAnchor,
                              bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BankCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        switch seeAll {
        case true:
            bankList.append(BanksList(memberID: "123", memberName: "Смотреть вс1е", memberNameRus: "Смотреть все", md5Hash: "", svgImage: "seeall", paymentSystemCodeList: ["123"]))
        default:
            break
        }
    }
    
}

//MARK: - CollectionView DataSource
extension BankListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return bankList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BankCell
            cell.bank = bankList[indexPath.item]
            return cell
    }
    
}

//MARK: - CollectionView FlowLayout
extension BankListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 76, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
}

//MARK: - CollectionView Delegate
extension BankListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
            if indexPath.item == 0 {
                let card = bankList[indexPath.item]
                didSeeAll?(card)
            } else {
                let card = bankList[indexPath.item]
                didBankTapped?(card)
            }
        
    }
}

