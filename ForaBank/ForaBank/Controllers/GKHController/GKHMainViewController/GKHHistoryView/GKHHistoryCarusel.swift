//
//  GKHHistoryCarusel.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit


class GKHCaruselCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cells = [GKHHistoryCaruselModel]()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(GKHCaruselCollectionViewCell.self, forCellWithReuseIdentifier: GKHCaruselCollectionViewCell.reuseId)
        
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = GKHConstants.galleryMinimumLineSpacing
        contentInset = UIEdgeInsets(top: 0, left: GKHConstants.leftDistanceToView, bottom: 0, right: GKHConstants.rightDistanceToView)
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    func set(cells: [GKHHistoryCaruselModel]) {
        self.cells = cells
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: GKHCaruselCollectionViewCell.reuseId, for: indexPath) as! GKHCaruselCollectionViewCell
        if !cells.isEmpty {
            cell.mainImageView.image = cells[indexPath.row].mainImage
            cell.nameLabel.text = cells[indexPath.row].banksName
            cell.smallDescriptionLabel.text = cells[indexPath.row].inn
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: GKHConstants.galleryItemWidth, height: frame.height * 0.8)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
