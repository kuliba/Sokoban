//
//  DepositSuccessViewController.swift
//  ForaBank
//
//  Created by Mikhail on 07.12.2021.
//

import UIKit

class DepositSuccessViewController: UIViewController {

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

        cardFromField.titleLabel.text = "Счет списания"
        cardFromField.titleLabel.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        cardFromField.imageView.isHidden = false
        cardFromField.choseButton.isHidden = true
        cardFromField.leftTitleAncor.constant = 64
        cardFromField.layoutIfNeeded()
        
        
        cardFromField.model = confurmVCModel?.cardFromRealm
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
        cardFromField.model = model.cardFromRealm
        termField.text = model.phone ?? ""
        incomeField.text = model.summTransction ?? ""
    }
    
    func openDetailVC() {
        let vc = ContactConfurmViewController()
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
        self.view.window?.rootViewController?.dismiss(animated: true)
    }

    
    
}
