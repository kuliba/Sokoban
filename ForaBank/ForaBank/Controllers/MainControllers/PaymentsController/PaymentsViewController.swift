//
//  PaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit


class PaymentsViewController: UIViewController {
    
    var payments = [PaymentsModel]()
    var transfers = [PaymentsModel]()
    var pay = [PaymentsModel]()
    
    enum Section: Int, CaseIterable {
        case payments, transfers, pay
        func description() -> String {
            switch self {
            case .payments:
                return "Платежи"
            case .transfers:
                return "Перевести"
            case .pay:
                return "Оплатить"
            }
        }
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PaymentsModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Платежи"
        view.backgroundColor = .white
        setupData()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        
    }
    
    func setupData() {
        payments = MockItems.returnPayments()
        transfers = MockItems.returnTransfers()
        pay = MockItems.returnPay()
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Название категории, ИНН"
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "scanCard")?.withTintColor(.black), for: .bookmark, state: .normal)
        searchController.searchBar.backgroundColor = .white
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(PaymentsCell.self, forCellWithReuseIdentifier: PaymentsCell.reuseId)
        collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
        collectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.reuseId)
        
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        
        snapshot.appendSections([.payments, .transfers, .pay])
        snapshot.appendItems(payments, toSection: .payments)
        snapshot.appendItems(transfers, toSection: .transfers)
        snapshot.appendItems(pay, toSection: .pay)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
        
    }
    
}

