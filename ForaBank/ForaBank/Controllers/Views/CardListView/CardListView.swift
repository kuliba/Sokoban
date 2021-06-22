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
    var cardList = [Datum]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
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
        self.heightAnchor.constraint(equalToConstant: 60).isActive = true
        setupCollectionView()
        
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
        
        return CGSize(width: 108, height: 60)
    }
    
}

//MARK: - CollectionView Delegate
extension CardListView: UICollectionViewDelegate {
    
}

