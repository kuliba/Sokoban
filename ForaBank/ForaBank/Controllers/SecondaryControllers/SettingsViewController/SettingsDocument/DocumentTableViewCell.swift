//
//  DocumentTableViewCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.04.2022.
//

import UIKit

class DocumentTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        collectionView.reloadData()
        self.backgroundColor = .blue
        
    }
    
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let frame = CGRect(x: 0, y: 0, width: 200, height: 150)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        return collectionView
    }()
    
    private func setupCollectionView() {
        
        self.contentView.addSubview(collectionView)
        
        collectionView.anchor(top: self.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
        
        collectionView.backgroundColor = .red
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.register(UINib.init(nibName: "DocumentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewID")
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewID", for: indexPath as IndexPath) as! DocumentCollectionViewCell
        
        cell.backgroundColor = .greenSea
        return cell
    }

}

extension DocumentTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight = 135
        let itemWidth = 135
    
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 20, bottom: 8, right: 8)
    }
    
}
