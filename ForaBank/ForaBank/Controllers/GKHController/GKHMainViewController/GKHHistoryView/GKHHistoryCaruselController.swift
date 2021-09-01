//
//  GKHHistoryCaruselController.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit

class GKHHistoryCaruselController: UIViewController {
    
    private var caruselCollectionView = GKHCaruselCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(caruselCollectionView)
        
        caruselCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        caruselCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        caruselCollectionView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        caruselCollectionView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        caruselCollectionView.set(cells: GKHHistoryCaruselModel.fetchModel())
    }

    

}
