//
//  GKHHistoryHeaderView.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit

class GKHHistoryHeaderView: UITableViewHeaderFooterView {
    
    private var caruselCollectionView = GKHCaruselCollectionView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        caruselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(caruselCollectionView)
        NSLayoutConstraint.activate([
    
            caruselCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            caruselCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            caruselCollectionView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
            caruselCollectionView.heightAnchor.constraint(equalToConstant: 350),
        ])
        caruselCollectionView.set(cells: GKHHistoryCaruselModel.fetchModel())
    }
}
