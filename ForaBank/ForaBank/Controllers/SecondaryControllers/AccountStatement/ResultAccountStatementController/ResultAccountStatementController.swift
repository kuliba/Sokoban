//
//  ResultAccountStatementController.swift
//  ForaBank
//
//  Created by Mikhail on 17.11.2021.
//

import UIKit

class ResultAccountStatementController: UIViewController {
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    
    var model: ResultAccountStatementModel? {
        didSet {
            guard let model = model else { return }
            setupData(model: model)
        }
    }
    
    var dateField = ForaInput(
        viewModel: ForaInputModel(
            title: "Время заказа документа",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false,
            showChooseButton: false))
    
    var periodField = ForaInput(
        viewModel: ForaInputModel(
            title: "Период",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false,
            showChooseButton: false))
    
    var cardFromField: CardChooseView = {
        let cardView =  CardChooseView()
        
        cardView.titleLabel.text = "Банковский продукт"
        cardView.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardView.imageView.isHidden = false
        cardView.leftTitleAncor.constant = 64
        cardView.layoutIfNeeded()
        return cardView
    }()
    
    var stackView = UIStackView(arrangedSubviews: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    @IBAction func watchDocumentButtonTapped(_ sender: Any) {
        print(#function)
        
//        let vc = AccountStatementPDFController()
//        let navVC = UINavigationController(rootViewController: vc)
//        navVC.modalPresentationStyle = .fullScreen
//        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func goToMainButtonTapped(_ sender: Any) {
        dismissViewControllers()
    }
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func setupUI() {
        stackView = UIStackView(arrangedSubviews: [dateField, periodField, cardFromField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(stackView)
        stackView.anchor(
            top: topLabel.bottomAnchor,
            left: view.leftAnchor, right: view.rightAnchor,
            paddingTop: 64)
    }
    
    private func setupData(model: ResultAccountStatementModel) {
        cardFromField.model = model.product
    }
    
}

