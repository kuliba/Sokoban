/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import iCarousel
import DeviceKit
import Hero
import PassKit


class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!

    // MARK: - Properties

    @IBOutlet var setUpButtonView: UIView!
    var presenter: ISettingsPresenter?
    var gradientViews = [GradientView2]()
    let ud = UserDefaults.standard
    var checked = Bool()
    var checkBoxUse = "CheckBoxUse"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        notificationSettingsViewController()
        setUpButtonView.isHidden = true
        var applePayButton: PKPaymentButton?
               if !PKPaymentAuthorizationViewController.canMakePayments() {
                    // Apple Pay not supported
                    return
                  }
        
             applePayButton = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
                  applePayButton?.addTarget(self, action: #selector(self.setupPressed(_:)), for: .touchUpInside)
        
        applePayButton?.translatesAutoresizingMaskIntoConstraints = false
             self.setUpButtonView.addSubview(applePayButton!)
             applePayButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
             applePayButton?.widthAnchor.constraint(equalToConstant: 200).isActive = true
             applePayButton?.heightAnchor.constraint(equalToConstant: 60).isActive = true
             applePayButton?.bottomAnchor.constraint(equalTo: self.setUpButtonView.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc func setupPressed(_ sender: PKPaymentButton){
         let passLibrary = PKPassLibrary()
         passLibrary.openPaymentSetup()
       }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - IListViewController

extension SettingsViewController: IListViewController {

    func setUpTableView() {
        setAutomaticRowHeight()
    }

    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

    func reloadData() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in self?.tableView.reloadData() }, completion: nil)
    }
}

extension SettingsViewController: SettingsPresenterDelegate{
    
    func didSelectOption(option: UserSettingType) {
        switch option {
        case .changePassword:
            performSegue(withIdentifier: "showChangePassword", sender: nil)
            break
        case .changePasscode:
            let passcodeVC = ChangePasscodeVC()
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        case .allowedPasscode(_):
            if keychainCredentialsPasscode() == nil{
                let passcodeVC = ChangePasscodeVC()
                passcodeVC.modalPresentationStyle = .overFullScreen
                present(passcodeVC, animated: true, completion: nil)
            }
        case .bankSPBDefoult:
            print("Система быстрых платежей")
            performSegue(withIdentifier: "saveDefault", sender: nil)
//            guard let searchBanksViewController = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "SearchBanksViewController") as? SearchBanksViewController else {
//                return
//            }
//            searchBanksViewController.modalPresentationStyle = .overFullScreen
//            searchBanksViewController.SBPbankDefault = true
//            present(searchBanksViewController, animated: true, completion: nil)
        case .setUpApplePay:
            performSegue(withIdentifier: "setUpApplePay", sender: nil)
        case .nonDisplayBlockProduct:
            break
//            if UserDefaults.standard.bool(forKey: "mySwitchValue") == false{
//                UserDefaults.standard.setValue(true, forKey: "mySwitchValue")
//            }
//           print( UserDefaults.standard.bool(forKey: "mySwitchValue"))
            
        case .blockUser:
            NetworkManager.shared().blockUser { (success, error) in
                if success{
                    print("Blocked account")
                     NetworkManager.shared().logOut { (success) in
                              setupUnauthorizedZone()
                      }
                } else{
                    print("Hola!")
                }
            }
        default:
            break
        }
        
    }
    
}


//MARK: Navigation
extension SettingsViewController{
    @IBAction func unwindToSettingsViewController(_ unwindSegue: UIStoryboardSegue) {
    }
}


//MARK: Notification
extension SettingsViewController{
    
    @objc func updateTableView(){
        reloadData()
    }
    
    private func notificationSettingsViewController(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .init(rawValue: "SPBSaveBankDefault"), object: nil)
    }
}
