//
//  CardsScrollView.swift
//  ForaBank
//
//  Created by Mikhail on 28.09.2021.
//

import UIKit
import RealmSwift

final class CardsScrollView: UIView {
    
    //MARK: - Property
    let reuseIdentifier = "CardCell"
    let newReuseIdentifier = "NewCardCell"
    let allReuseIdentifier = "AllCardCell"

    let model: Model = .shared
        
    var cardList = [UserAllCardsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var canAddNewCard = false
    var onlyCard: Bool = false
    var onlyMy: Bool = true
    var filteredCardList = [UserAllCardsModel]() {
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
    
    var didCardTapped: ((Int) -> Void)?
    
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
    
    required init(frame: CGRect = .zero, onlyMy: Bool, onlyCard: Bool = false, deleteDeposit: Bool = false, loadProducts: Bool = true, loans: Bool = false) {
        super.init(frame: frame)
        commonInit(onlyMy: onlyMy, onlyCard: onlyCard, deleteDeposit: deleteDeposit, loadProducts: loadProducts, loans: loans)
    }
    
    func commonInit(onlyMy: Bool, onlyCard: Bool = false, deleteDeposit: Bool = false, loadProducts: Bool = true, loans: Bool = false) {
        self.onlyMy = onlyMy
        self.onlyCard = onlyCard
        
        if loadProducts {

            let products = ReturnAllCardList.cards()
            
            products.forEach({ op in
                if onlyCard {
                    if op.productType == "CARD" {
                        
                        cardList.append(op)
                    }
                } else {
                    if deleteDeposit {
                        if op.productType != "DEPOSIT" {
                            cardList.append(op)
                        }
                    } else {
                            
                            cardList.append(op)
                    }
                }
            })
            if !loans {
                cardList = cardList.filter({$0.productType != ProductType.loan.rawValue})
            }
        }
        
        changeCardButtonCollection.isHidden = !self.onlyMy
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: self.onlyMy ? 125 : 95).isActive = true
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
                self.filteredCardList = self.cardList.filter { $0.productType == "ACCOUNT" || $0.productType == "DEPOSIT" }
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
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardsScrollCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(NewCardCell.self, forCellWithReuseIdentifier: newReuseIdentifier)
        collectionView.register(AllCardCell.self, forCellWithReuseIdentifier: allReuseIdentifier)
    }
    
}

//MARK: - CollectionView DataSource
extension CardsScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltered {
            return filteredCardList.count
        } else {
            if canAddNewCard {
                return cardList.count + 2
            } else {
                return cardList.count + 1
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Если нужно добавлять новую карту
        if canAddNewCard {
            if indexPath.item == 0 {
                let cellFirst = collectionView.dequeueReusableCell(withReuseIdentifier: newReuseIdentifier, for: indexPath) as! NewCardCell
                return cellFirst
            } else if indexPath.item == cardList.count + 1 {
                let cellLast = collectionView.dequeueReusableCell(withReuseIdentifier: allReuseIdentifier, for: indexPath) as! AllCardCell
                return cellLast
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardsScrollCell
                cell.getUImage = { self.model.images.value [$0]?.uiImage }
                if isFiltered {
                    cell.card = filteredCardList[indexPath.item - 1]
                } else {
                    cell.card = cardList[indexPath.item - 1]
                }
                return cell
            }
            
            // Если Не нужно добавлять новую карту
        } else {
            if  indexPath.item == cardList.count  {
                let cellLast = collectionView.dequeueReusableCell(withReuseIdentifier: allReuseIdentifier, for: indexPath) as! AllCardCell

                return cellLast
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardsScrollCell
                cell.getUImage = { self.model.images.value [$0]?.uiImage }

                if isFiltered {
                    
                    cell.card = filteredCardList[indexPath.item ]
                } else {
                    
                    cell.card = cardList[indexPath.item]
                }
                return cell
            }
        }
    }
    
}

//MARK: - CollectionView FlowLayout
extension CardsScrollView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight = 72
        let bigItemWidth = 112
        let smallItemWidth = 72
        
        if canAddNewCard {
            if indexPath.item == 0 {
                return CGSize(width: smallItemWidth, height: itemHeight)
            } else if indexPath.item == cardList.count + 1 {
                return CGSize(width: smallItemWidth, height: itemHeight)
            }  else {
                return CGSize(width: bigItemWidth, height: itemHeight)
            }
        } else {
            if indexPath.item == cardList.count  {
                return CGSize(width: smallItemWidth, height: itemHeight)
            }  else {
                return CGSize(width: bigItemWidth, height: itemHeight)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 20, bottom: 8, right: 8)
    }
}

//MARK: - CollectionView Delegate
extension CardsScrollView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if canAddNewCard {
            
            if indexPath.item == 0 {
                firstItemTap?()
                
            } else if indexPath.item == cardList.count + 1 {
                lastItemTap?()
                
            }  else {
                if isFiltered {
                    let card = filteredCardList[indexPath.item]
                    didCardTapped?(card.id)
                } else {
                    let card = cardList[indexPath.item - 1]
                    didCardTapped?(card.id)
                }
            }
        } else {
            if indexPath.item == cardList.count {
                lastItemTap?()
                
            }  else {
                if isFiltered {
                    let card = filteredCardList[indexPath.item]
                    didCardTapped?(card.id)
                } else {
                    let card = cardList[indexPath.item]
                    didCardTapped?(card.id)
                }
            }
        }
    }
}

