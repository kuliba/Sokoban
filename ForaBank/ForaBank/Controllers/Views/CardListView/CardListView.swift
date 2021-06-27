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
            self.collectionView.reloadData()
        }
    }
    
    var didCardTapped: ((GetProductListDatum) -> Void)?
    
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
        self.heightAnchor.constraint(equalToConstant: 72).isActive = true
        setupCollectionView()
        isHidden = true
    }
    
    //MARK: - Helpers
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.fillSuperview()
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
}

//MARK: - CollectionView DataSource
extension CardListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CardCell
        
        cell.card = cardList[indexPath.item]

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

