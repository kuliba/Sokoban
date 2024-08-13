import UIKit
import Combine

class InternetTVSuccessViewController: UIViewController {
    
    var operatorsViewModel: OperatorsViewModel?
    var id: Int?
    var printFormType: String?
    let mainView = InternetTVSuccessView()
    let button = UIButton(title: "На главную")
    var confirmModel: InternetTVConfirmViewModel? {
        didSet {
            guard let model = confirmModel else { return }
            mainView.confirmModel = model
        }
    }
    
    private let model: Model = Model.shared
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        mainView.detailTapped = { () in
            self.openDetailVC()
        }
        
        mainView.saveTapped = { [weak self] () in
            let vc = PDFViewerViewController()
            vc.id = self?.id
            vc.printFormType = self?.printFormType
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            self?.present(navVC, animated: true, completion: nil)
        }
        
        mainView.templateTapped = { [weak self] in
            
            guard let self = self else {
                return
            }
            
            guard let templateButtonViewModel = self.confirmModel?.templateButtonViewModel,
                  case .sfp(let name, let paymentOperationDetailId) = templateButtonViewModel else {
                return
            }
            
            self.model.action.send(ModelAction.PaymentTemplate.Save.Requested(name: name, paymentOperationDetailId: paymentOperationDetailId))
        }
        
        bind()
        
        if let fromCardId = self.confirmModel?.cardFromCardId {
            
            if let cardId = NumberFormatter().number(from: fromCardId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
        
        if let toCardId = self.confirmModel?.cardToCardId {
            
            if let cardId = NumberFormatter().number(from: toCardId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
        
        if let toAcccountId = self.confirmModel?.cardToAccountId {
            
            if let cardId = NumberFormatter().number(from: toAcccountId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
        
        if let fromAcccountId = self.confirmModel?.cardFromAccountId {
            
            if let cardId = NumberFormatter().number(from: fromAcccountId) {
                let integerCardId = cardId.intValue
                self.model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: integerCardId))
            }
        }
    }
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.PaymentTemplate.Save.Complete:
                    let templateButtonViewModel: InternetTVConfirmViewModel.TemplateButtonViewModel = .template(payload.paymentTemplateId)
                    confirmModel?.templateButtonViewModel = templateButtonViewModel
                    mainView.updateTemplateButton(with: templateButtonViewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        view.addSubview(button)
        button.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                      right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                      paddingRight: 20, height: 48)
        
        view.addSubview(mainView)
        mainView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
            bottom: button.topAnchor, right: view.rightAnchor,
            paddingTop: 120,  paddingLeft: 20, paddingBottom: 90, paddingRight: 20)
        
    }
    
    @objc func doneButtonTapped() {
        self.model.action.send(ModelAction.Products.Update.Total.All(isCalledOnAuth: false))
        view.window?.rootViewController?.dismiss(animated: true)
        operatorsViewModel?.closeAction()
        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
    }
    
    func openDetailVC() {
        let vc = InternetTVConfirmViewController()
        vc.viewModel = confirmModel
        vc.doneButton.isHidden = true
        vc.smsCodeField.isHidden = true
        vc.countryField.isHidden = true
        vc.phoneField.isHidden = true
        vc.nameField.isHidden = true
        vc.bankField.isHidden = true
        vc.numberTransactionField.isHidden = true
        vc.cardToField.isHidden = true
        vc.sumTransactionField.isHidden = false
        vc.taxTransactionField.isHidden = false
        vc.currTransactionField.isHidden = true
        vc.currencyTransactionField.isHidden = true
        vc.addCloseButton()
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}
