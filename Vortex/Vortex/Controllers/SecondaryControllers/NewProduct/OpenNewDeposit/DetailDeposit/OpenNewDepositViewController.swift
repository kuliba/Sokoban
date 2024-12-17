//
//  OpenNewDepositViewController.swift
//  ForaBank
//
//  Created by Mikhail on 26.11.2021.
//

import UIKit

class OpenNewDepositViewController: UICollectionViewController {
    
    private let reuseIdentifier = "OpenNewDepositViewControllerCell"
    var products = [OpenDepositDatum]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDeposit()
        
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        title = "Вклады"
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }

    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OpenNewDepositViewControllerCell
        cell.viewModel = products[indexPath.row]
        cell.index = indexPath
        cell.delegate = self
        return cell
    }
    
    //MARK: - API
    
    private func loadDeposit() {
        NetworkManager<GetDepositProductListDecodableModel>.addRequest(.getDepositProductList, [:], [:]) { model, error in
            
            if let error = error {
                self.showAlert(with: "Error", and: error)
            } else {
                guard let product = model?.data else { return }
                self.products = product
            }
        }
    }
}


extension OpenNewDepositViewController: OpenNewDepositDelegate {
    func openCalculatorController(indexPath: IndexPath) {
        let controller = DepositCalculatorViewController()
        controller.product = products[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openDetailController(indexPath: IndexPath) {
        let controller = DetailInformationViewController()
        controller.elements = products[indexPath.row].detailedСonditions
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true)
    }
}

extension OpenNewDepositViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if let nav = presented as? UINavigationController {
            if let controller = nav.viewControllers.first as? DetailInformationViewController {
                presenter.height = ((controller.elements?.count ?? 1) * 44) + 140
            }
        } else {
            presenter.height = (4 * 44) + 160
        }
        return presenter
    }
}

