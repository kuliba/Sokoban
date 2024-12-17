//
//  DepositSuccessViewController.swift
//  ForaBank
//
//  Created by Mikhail on 07.12.2021.
//

import UIKit

class DepositSuccessViewController: UIViewController {

    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var optionsButtons: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    let model = Model.shared
    var id: Int?
    var printFormType: String?
    
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            setupData(with: model)
        }
    }
    var termField = ForaInput(
        viewModel: ForaInputModel(
            title: "Срок вклада",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false))
    
    var closeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Дата закрытия",
            image: #imageLiteral(resourceName: "date"),
            isEditable: false))
    
    var incomeField = ForaInput(
        viewModel: ForaInputModel(
            title: "Сумма вклада",
            image: #imageLiteral(resourceName: "Frame 579"),
            isEditable: false))
    
    var cardFromField = CardChooseView()
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.addArrangedSubview(termField)
        stackView.addArrangedSubview(closeField)
        stackView.addArrangedSubview(incomeField)
        stackView.addArrangedSubview(cardFromField)

        amountLabel.isHidden = true
        cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }
        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.choseButton?.isHidden = true
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        
        cardFromField.model = confurmVCModel?.cardFromRealm
 
        self.model.action.send(ModelAction.Products.Update.ForProductType(productType: .deposit))
        
        if let paymentFromCardId = confurmVCModel?.cardFromCardId {
            
            if let cardId = NumberFormatter().number(from: paymentFromCardId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
        
        if let fromAcccountId = self.confurmVCModel?.cardFromAccountId {
            
            if let cardId = NumberFormatter().number(from: fromAcccountId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
        
        descriptionLabel.text = ""
        
        if confurmVCModel?.status == .antifraudCanceled {
            termField.isHidden = true
            closeField.isHidden = true
            cardFromField.isHidden = true
            incomeField.isHidden = true
            
            optionsButtons.isHidden = true
            depositLabel.text = "Операция временно приостановлена в целях безопасности"
            depositLabel.textColor = .systemRed
            descriptionLabel.text = Payments.Success.antifraudSubtitle
            amountLabel.text = confurmVCModel?.summTransction ?? ""
            amountLabel.isHidden = false
            descriptionLabel.text = Payments.Success.antifraudSubtitle
            
            statusImage.image = UIImage(named: "waiting")
        }
    }

    
    @IBAction func OpenDocumentButtonTapped(_ sender: Any) {
        saveTapped()
    }
    
    @IBAction func detailButtonTapped(_ sender: Any) {
        openDetailVC()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismissViewControllers()
    }
    
    func setupData(with model: ConfirmViewControllerModel) {
        cardFromField.getUImage = { self.model.images.value[$0]?.uiImage }
        cardFromField.model = model.cardFromRealm
        termField.text = model.phone ?? ""
        incomeField.text = model.summTransction
        closeField.text = model.dateOfTransction
    }
    
    func openDetailVC() {
        let vc = ContactConfurmViewController()
        vc.getUImage = { self.model.images.value[$0]?.uiImage }
        vc.confurmVCModel = confurmVCModel
        vc.doneButton.isHidden = true
        vc.smsCodeField.isHidden = true
        vc.addCloseButton()
        
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
    
    func saveTapped() {
        let vc = PDFViewerViewController()
        vc.id = self.id
        vc.printFormType = self.printFormType
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
    }
}
