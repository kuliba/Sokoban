//
//  SettingTableViewController.swift
//  ForaBank
//
//  Created by Mikhail on 16.09.2021.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        nameLabel.text = ""
        phoneLabel.text = ""
        emailLabel.text = ""
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func sbpCellAction(_ sender: Any) {
    
        self.showActivity()
        getFastPaymentContractList { [weak self] contractList, error in
            self?.dismissActivity()
            if error != nil {
                self?.showAlert(with: "Ошибка", and: error!)
            } else {
                DispatchQueue.main.async {
                    let vc = MeToMeSettingViewController()
                    if contractList != nil {
                        vc.model = contractList
                    } else {
                        vc.model = []
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        NetworkManager<LogoutDecodableModel>.addRequest(.logout, [:], [:]) { _,_  in
            print("Logout :", "Вышли из приложения")
            DispatchQueue.main.async {
                UserDefaults.standard.setValue(false, forKey: "UserIsRegister")
                let navVC = UINavigationController(rootViewController: LoginCardEntryViewController())
                navVC.modalPresentationStyle = .fullScreen
                self.present(navVC, animated: true, completion: nil)
            }
            
        }
    }
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: fastPaymentContractFindList", model)
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
                completion(nil, model.errorMessage)
            }
        }
    }

}
