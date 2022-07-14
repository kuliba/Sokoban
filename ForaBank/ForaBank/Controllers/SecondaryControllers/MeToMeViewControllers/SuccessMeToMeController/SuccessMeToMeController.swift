//
//  SuccessMeToMeController.swift
//  ForaBank
//
//  Created by Mikhail on 10.08.2021.
//

import UIKit

struct SuccessMeToMeModel {
    var amount: Double?
    var bank: BankFullInfoList?
}

class SuccessMeToMeController: UIViewController {
    
    var viewModel: SuccessMeToMeModel?
    
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    //MARK: - Viewlifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        guard let model = self.viewModel else { return }
        fillData(model: model)
    }
    
    func fillData(model: SuccessMeToMeModel) {
        self.currencyLabel.text = model.amount?.currencyFormatter(symbol: "RUB")
        self.bankLabel.text = model.bank?.fullName
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print(#function)
        dismissViewControllers()
    }
    
    
    // MARK:- Dismiss and Pop ViewControllers
    func dismissViewControllers() {
        self.view.window?.rootViewController?.dismiss(animated: true)
        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
    }

    
}
