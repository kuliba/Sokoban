//
//  ConfurmPaymentsVC.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import UIKit
import Combine

class PaymentsDetailsSuccessViewController: UIViewController {
    
    var operatorsViewModel: OperatorsViewModel?
    var printFormType: String?
    let confurmView = PaymentsDetailsView()
    let button = UIButton(title: "На главную")
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            confurmView.confurmVCModel = model
        }
    }
    
    //TODO: remove after refactoring
    private let model: Model = Model.shared
    private var bindings = Set<AnyCancellable>()
    var closeAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        confurmView.detailTapped = { () in
            self.openDetailVC()
        }
        
        confurmView.saveTapped = { [weak self] () in
            let vc = PDFViewerViewController()
            vc.id = self?.confurmVCModel?.paymentOperationDetailId
            vc.printFormType = self?.printFormType
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self?.present(navVC, animated: true, completion: nil)
        }
        
        confurmView.changeTapped = { [weak self] () in
            let controller = ChangeReturnCountryController(type: .changePay, operatorsViewModel: self?.operatorsViewModel)
            controller.confurmVCModel = self?.confurmVCModel
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        
        confurmView.returnTapped = { [weak self] () in
            let controller = ChangeReturnCountryController(type: .returnPay, operatorsViewModel: self?.operatorsViewModel)
            controller.confurmVCModel = self?.confurmVCModel
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        
        confurmView.templateTapped = { [weak self] in
            
            guard let self = self else {
                return
            }
            
            guard let templateButtonViewModel = self.confurmVCModel?.templateButtonViewModel,
                  case .sfp(let name, let paymentOperationDetailId) = templateButtonViewModel else {
                return
            }
            
            self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: name, paymentOperationDetailId: paymentOperationDetailId))
        }
        
        bind()
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.PaymentTemplate.Save.Complete:
                    let templateButtonViewModel: ConfirmViewControllerModel.TemplateButtonViewModel = .template(payload.paymentTemplateId)
                    confurmVCModel?.templateButtonViewModel = templateButtonViewModel
                    confurmView.updateTemplateButton(with: templateButtonViewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(button)
        button.anchor(
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingLeft: 20,
            paddingBottom: 20,
            paddingRight: 20,
            height: 48)
        
        view.addSubview(confurmView)
        confurmView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            bottom: button.topAnchor,
            right: view.rightAnchor,
            paddingTop: 120,
            paddingLeft: 20,
            paddingBottom: 90,
            paddingRight: 20)
        
    }
    
    @objc func doneButtonTapped() {
        self.view.window?.rootViewController?.dismiss(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
        operatorsViewModel?.closeAction()
        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
        guard let closeAction = closeAction else {
            return
        }
        closeAction()
    }
    
    func openDetailVC() {
        let vc = ContactConfurmViewController()
        vc.confurmVCModel = confurmVCModel
        vc.doneButton.isHidden = true
        vc.smsCodeField.isHidden = true
        vc.addCloseButton()
        if printFormType == "sbp"{
            vc.confurmVCModel?.payToCompany = true
        }
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        
        self.dismiss(animated: false)
        guard let closeAction = closeAction else {
            return
        }
        
        closeAction()
    }
}
