//
//  ConfurmPaymentsVC.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import UIKit

class PaymentsDetailsSuccessViewController: UIViewController {
    
    var id: Int?
    var printFormType: String?
    let confurmView = PaymentsDetailsView()
    let button = UIButton(title: "На главную")
    var confurmVCModel: ConfirmViewControllerModel? {
        didSet {
            guard let model = confurmVCModel else { return }
            confurmView.confurmVCModel = model
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        button.addTarget(self, action:#selector(doneButtonTapped), for: .touchUpInside)
        confurmView.detailTapped = { () in
            self.openDetailVC()
        }
        
        confurmView.saveTapped = { [weak self] () in
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
        
        view.addSubview(confurmView)
        confurmView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
            bottom: button.topAnchor, right: view.rightAnchor,
            paddingTop: 120,  paddingLeft: 20, paddingBottom: 90, paddingRight: 20)
        
    }
    
    @objc func doneButtonTapped() {
        print(#function)
        dismissViewControllers()
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
        self.view.window?.rootViewController?.dismiss(animated: true)
    }

  
    
}
