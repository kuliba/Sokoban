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
    let docDepositCell = "DocDepositCollectionViewCell"
    
    lazy var doneButton: UIButton = {
        let button = UIButton(title: "Открыть вклад")
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var product: OpenDepositDatum? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var choosenRate: TermRateSumTermRateList?
    
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
    
    @objc func doneButtonTapped() {
        let calculator = self.collectionView.cellForItem(at: [0,1]) as! CalculatorDepositCollectionViewCell
        
        let controller = ConfurmOpenDepositViewController()
        controller.product = calculator.viewModel
        controller.choosenRateList = calculator.choosenRateList
        controller.choosenRate = calculator.choosenRate
        let amount = calculator.moneyFormatter?.unformat(calculator.summTextField.text) ?? ""
        controller.startAmount = Float(amount) ?? 0
//        controller.bottomView.amountTextField.text = calculator.summTextField.text
        navigationController?.pushViewController(controller, animated: true)
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
        collectionView.register(UINib(nibName: docDepositCell, bundle: nil), forCellWithReuseIdentifier: docDepositCell)
        collectionView.register(DetailInformationCollectionViewCell.self, forCellWithReuseIdentifier: detailDepositCell)
        
    }
    
}

extension DepositCalculatorViewController: CalculatorDepositDelegate {
    func openDetailController(with model: [TermRateSumTermRateList]?) {
        print(#function)
        let controller = SelectDepositPeriodViewController()
        controller.elements = model
        controller.itemIsSelect = { elem in
            let calculator = self.collectionView.cellForItem(at: [0,1]) as! CalculatorDepositCollectionViewCell
            calculator.choosenRate = elem
            self.choosenRate = elem
        }
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true)
    }
}

extension DepositCalculatorViewController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if let nav = presented as? UINavigationController {
            if let controller = nav.viewControllers.first as? SelectDepositPeriodViewController {
                presenter.height = ((controller.elements?.count ?? 1) * 56) + 80
            }
        } else {
            presenter.height = (4 * 44) + 160
        }
        return presenter
    }
}
