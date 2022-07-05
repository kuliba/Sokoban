import UIKit

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
        view.window?.rootViewController?.dismiss(animated: true)
        operatorsViewModel?.closeAction()
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
