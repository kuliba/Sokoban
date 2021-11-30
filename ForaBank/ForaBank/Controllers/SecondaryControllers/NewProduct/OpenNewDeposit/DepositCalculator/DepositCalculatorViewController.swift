//
//  DepositCalculatorViewController.swift
//  ForaBank
//
//  Created by Mikhail on 01.12.2021.
//

import UIKit

class DepositCalculatorViewController: UICollectionViewController {
    
    let mainDepositCell = "MainDepositCollectionViewCell"
    let calculatorDepositCell = "CalculatorDepositCollectionViewCell"
    let detailDepositCell = "DetailInformationCollectionViewCell"
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Открыть вклад")
        
        return button
    }()
    
    var product: OpenDepositDatum? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        title = "Подробнее"
        setupCollectionView()
        view.addSubview(doneButton)
        doneButton.anchor(
             left: view.leftAnchor,
             bottom: view.safeAreaLayoutGuide.bottomAnchor,
             right: view.rightAnchor,
             paddingLeft: 20,
             paddingBottom: 20,
             paddingRight: 20,
             height: 48)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: mainDepositCell, bundle: nil), forCellWithReuseIdentifier: mainDepositCell)
        collectionView.register(UINib(nibName: calculatorDepositCell, bundle: nil), forCellWithReuseIdentifier: calculatorDepositCell)
        collectionView.register(DetailInformationCollectionViewCell.self, forCellWithReuseIdentifier: detailDepositCell)
        
    }
    
}

