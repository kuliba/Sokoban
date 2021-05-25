//
//  OperationsListCollectionViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.05.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit


@available(iOS 13.0, *)
class OperationsListCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .orange
        collectionView.register(OperationsListCollectionViewCell.self, forCellWithReuseIdentifier: "OperationPreviewCell")
        
        
    }
 
    
  


    // MARK: UICollectionViewDataSource

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OperationPreviewCell", for: indexPath) as! OperationsListCollectionViewCell
        cell.label.text = "123"
        cell.backgroundView?.backgroundColor = .red
        return cell
    }

    // MARK: UICollectionViewDelegate

}
