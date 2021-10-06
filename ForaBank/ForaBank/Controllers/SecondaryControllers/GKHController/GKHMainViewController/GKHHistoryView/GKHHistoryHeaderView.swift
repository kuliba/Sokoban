//
//  GKHHistoryHeaderView.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.08.2021.
//

import UIKit

class GKHHistoryHeaderView: UIView {
    
    private var caruselCollectionView = GKHCaruselCollectionView()
    
    private var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContents()
        if caruselCollectionView.cells.isEmpty {
            self.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        caruselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.addSubview(caruselCollectionView)
        self.addSubview(lineView)
        NSLayoutConstraint.activate([
    
            caruselCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            caruselCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            caruselCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            caruselCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
//            caruselCollectionView.heightAnchor.constraint(equalToConstant: 200),
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        caruselCollectionView.set(cells: GKHHistoryCaruselModel.fetchModel())
    }
}
