//
//  OrderProductsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class OrderProductsViewController: UICollectionViewController {
    
    private let reuseIdentifier = "OrderProductsCollectionViewCell"
    var products = [OrderProductModel]()
    
    //MARK: - ViewLifeCycle
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выберите продукт"
        setupData()
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    //TODO: отрефакторить если будем получать с бэка
    //MARK: - API
    private func setupData() {
        products = MockItems.orderProducts()
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OrderProductsCollectionViewCell
        cell.viewModel = products[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = products[indexPath.row].orderURL else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
