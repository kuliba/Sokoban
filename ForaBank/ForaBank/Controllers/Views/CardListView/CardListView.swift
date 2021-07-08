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
    let newReuseIdentifier = "NewCardCell"
    let allReuseIdentifier = "AllCardCell"
    
    var cardList = [GetProductListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var onlyMy: Bool = true
    var filteredCardList = [GetProductListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var isFiltered = false {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    var didCardTapped: ((GetProductListDatum) -> Void)?
    
    var firstItemTap: (() -> Void)?
    var lastItemTap: (() -> Void)?
    
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
        commonInit(onlyMy: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(onlyMy: true)
    }
    
    required init(frame: CGRect = .zero, onlyMy: Bool) {
        super.init(frame: frame)
        commonInit(onlyMy: onlyMy)
    }
    

    func commonInit(onlyMy: Bool) {
        self.onlyMy = onlyMy
//        print("GEBUG: only:", self.onlyMy)
        
//        let height: CGFloat = self.onlyMy ? 110 : 80
        changeCardButtonCollection.isHidden = !self.onlyMy
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: self.onlyMy ? 120 : 90).isActive = true
        setupCollectionView()
        isHidden = true
        alpha = 0
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
                                          right: self.rightAnchor, height: self.onlyMy ? 30 : 0)
        collectionView.anchor(top: changeCardButtonCollection.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(NewCardCell.self, forCellWithReuseIdentifier: newReuseIdentifier)
        collectionView.register(AllCardCell.self, forCellWithReuseIdentifier: allReuseIdentifier)
    }
    
}

//MARK: - CollectionView DataSource
extension CardListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltered {
            return filteredCardList.count + 2
        } else {
            return cardList.count + 2
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cellFirst = collectionView.dequeueReusableCell(withReuseIdentifier: newReuseIdentifier, for: indexPath) as! NewCardCell
            return cellFirst
        } else if indexPath.item == cardList.count + 1 {
            let cellLast = collectionView.dequeueReusableCell(withReuseIdentifier: allReuseIdentifier, for: indexPath) as! AllCardCell
            return cellLast
        }  else {
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardCell
            
            if isFiltered {
                print("DEBUG:", #function, filteredCardList.count, indexPath)
                
                cell.card = filteredCardList[indexPath.item - 1]
            } else {
                print("DEBUG:", #function, cardList.count, indexPath)
                cell.card = cardList[indexPath.item - 1]
            }
            return cell
        }
    }
    
}

//MARK: - CollectionView FlowLayout
extension CardListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.item == 0 {
            return CGSize(width: 72, height: 72)
        } else if indexPath.item == cardList.count + 1 {
            return CGSize(width: 72, height: 72)
        }  else {
            return CGSize(width: 108, height: 72)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
}

//MARK: - CollectionView Delegate
extension CardListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            firstItemTap?()
            print("GoNew")
        } else if indexPath.item == cardList.count + 1 {
            lastItemTap?()
            print("GoAll")
        }  else {
            if isFiltered {
                let card = filteredCardList[indexPath.item - 1]
                didCardTapped?(card)
            } else {
                let card = cardList[indexPath.item - 1]
                didCardTapped?(card)
            }
        }
    }
}

