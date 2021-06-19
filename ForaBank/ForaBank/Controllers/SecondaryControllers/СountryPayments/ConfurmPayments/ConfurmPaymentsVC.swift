//
//  ConfurmPaymentsVC.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import UIKit

class ConfurmPaymentsVC: UIViewController {
    
    let confurmView = ConfurmPaymentsView()
    let button = UIButton(title: "На главную",
                          titleColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                          backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                          isBorder: true)
    
    var confurmVCModel: ConfurmViewControllerModel? {
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
    }
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        
        view.addSubview(button)
        button.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                      right: view.rightAnchor, paddingLeft: 20, paddingBottom: 20,
                      paddingRight: 20, height: 44)
        
        view.addSubview(confurmView)
        confurmView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, paddingTop: 120, paddingLeft: 20, paddingRight: 20)
        confurmView.layer.cornerRadius = 16
        confurmView.clipsToBounds = true
        
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
        vc.title = "Детали операции"
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
    }
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
}
