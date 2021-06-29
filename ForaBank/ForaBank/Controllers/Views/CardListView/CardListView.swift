//
//  CardListView.swift
//  ForaBank
//
//  Created by Mikhail on 22.06.2021.
//

import UIKit

class CardListView: UIView {
    
    //MARK: - Property
    let reuseIdentifier = "CardCell"
    var cardList = [GetProductListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var filteredCardList = [GetProductListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var isFiltered = false
    
    var didCardTapped: ((GetProductListDatum) -> Void)?
    let changeCardButtonCollection = AllCardView()
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
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 110).isActive = true
        setupCollectionView()
        isHidden = true
        changeCardButtonCollection.complition = { (select) in
            switch select {
            case 1:
                self.isFiltered = true
                self.filteredCardList = self.cardList.filter { $0.productType == "CARD" }
            case 2:
                self.isFiltered = true
                self.filteredCardList = self.cardList.filter { $0.productType == "ACCOUNT" }
            default:
                self.isFiltered = false
            }
        }
    }
    
    //MARK: - Helpers
    private func setupCollectionView() {
        addSubview(changeCardButtonCollection)
        addSubview(collectionView)
        changeCardButtonCollection.anchor(top: self.topAnchor, left: self.leftAnchor,
                                          right: self.rightAnchor, height: 30)
        collectionView.anchor(top: changeCardButtonCollection.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
}

//MARK: - CollectionView DataSource
extension CardListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltered {
            return filteredCardList.count
        } else {
            return cardList.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardCell
        
        if isFiltered {
            cell.card = filteredCardList[indexPath.item]
        } else {
            cell.card = cardList[indexPath.item]
        }
        return cell
    }
    
}

//MARK: - CollectionView FlowLayout
extension CardListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 108, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
}

//MARK: - CollectionView Delegate
extension CardListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = cardList[indexPath.item]
        didCardTapped?(card)
    }
}

