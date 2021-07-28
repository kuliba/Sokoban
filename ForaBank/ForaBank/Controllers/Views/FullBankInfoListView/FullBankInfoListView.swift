//
//  FullBankInfoListView.swift
//  ForaBank
//
//  Created by Mikhail on 28.07.2021.
//

import UIKit

class FullBankInfoListView: UIView {
    
    var seeAll = true
    
    //MARK: - Property
    let reuseIdentifier = "BankCell"
    
    var bankList = [BankFullInfoList]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var didBankTapped: ((BankFullInfoList) -> Void)?
    var didSeeAll: (() -> Void)?
    
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
        collectionView.register(FullBankInfoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        switch seeAll {
//        case true:
//            bankList.append(BanksList(memberID: "123", memberName: "Смотреть вс1е", memberNameRus: "Смотреть все", md5Hash: "", svgImage: "seeall", paymentSystemCodeList: ["123"]))
//        default:
//            break
//        }
    }
    
}

//MARK: - CollectionView DataSource
extension FullBankInfoListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seeAll ? bankList.count + 1 : bankList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FullBankInfoCell
        switch seeAll {
        case true:
            if indexPath.item == 0 {
                cell.bankImageView.image = UIImage(named: "seeall")
                cell.bankNameLabel.text = "Смотреть"
                cell.bicLabel.text = "все"
                cell.bicLabel.textColor = .black
            } else {
                cell.index = indexPath
                cell.bank = bankList[indexPath.item - 1]
            }
        default:
            cell.index = indexPath
            cell.bank = bankList[indexPath.item]
        }
        return cell
    }
    
}

//MARK: - CollectionView FlowLayout
extension FullBankInfoListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 76, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
}

//MARK: - CollectionView Delegate
extension FullBankInfoListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch seeAll {
        case true:
            if indexPath.item == 0 {
                didSeeAll?()
            } else {
                let card = bankList[indexPath.item - 1]
                didBankTapped?(card)
            }
        default:
            let card = bankList[indexPath.item]
            didBankTapped?(card)
        }
    }
}
