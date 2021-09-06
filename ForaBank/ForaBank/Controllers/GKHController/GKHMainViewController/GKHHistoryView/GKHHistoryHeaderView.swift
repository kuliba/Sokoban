//
//  GKHHistoryHeaderView.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit

class GKHHistoryHeaderView: UITableViewHeaderFooterView {
    
    private var caruselCollectionView = GKHCaruselCollectionView()
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        caruselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        contentView.addSubview(caruselCollectionView)
        contentView.addSubview(lineView)
        NSLayoutConstraint.activate([
    
            caruselCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            caruselCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            caruselCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            caruselCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//            caruselCollectionView.heightAnchor.constraint(equalToConstant: 200),
            lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        caruselCollectionView.set(cells: GKHHistoryCaruselModel.fetchModel())
    }
}
