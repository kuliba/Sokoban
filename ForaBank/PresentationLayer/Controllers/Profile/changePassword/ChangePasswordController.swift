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



class ChangePasswordController: UIViewController {
    
    let cellId = "FeedOptionCell"
    var alertNotification = UIAlertController(title: "", message: "", preferredStyle: .alert)
    var gradientViews = [GradientView2]()
    var backSegueId: String? = nil
    var segueId: String? = nil
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var replayPassword: UITextField!
    @IBOutlet weak var buttonChangePassword: UIButton!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpTableView()
        oldPassword.textColor = .black
        newPassword.textColor = .black
        replayPassword.textColor = .black
        
        oldPassword.addTarget(self, action: #selector(activateButton), for: .editingChanged)
        newPassword.addTarget(self, action: #selector(activateButton), for: .editingChanged)
        replayPassword.addTarget(self, action: #selector(activateButton), for: .editingChanged)
        
        buttonChangePassword.isEnabled = false
        buttonChangePassword.alpha = 0.5
        
        let actionCancel = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
        alertNotification.addAction(actionCancel)
    }
    
    @objc func activateButton(){
        if oldPassword.text == "" || replayPassword.text == "" || newPassword.text == ""{
            buttonChangePassword.isEnabled = false
            buttonChangePassword.alpha = 0.5
        }else{
            buttonChangePassword.isEnabled = true
            buttonChangePassword.alpha = 1
        }
    }
    
    @IBAction func actionUpdatePassword(_ sender: Any) {
        
        guard newPassword.text == replayPassword.text else {
            alertNotification.message = "Пароли не совпадают"
            present(alertNotification, animated: true, completion: nil)
            return
        }
        
        NetworkManager.shared().changePassword(oldPassword: oldPassword.text!, newPassword: newPassword.text!) { [weak self](success, errorMessage) in
            if success{
                //self!.alertNotification.message = "Пароль успешно изменен"
                
                let alertSuccess = UIAlertController(title: "", message: "Пароль успешно изменен", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "ОК", style: .cancel) {[weak self] (_) in
                    self!.performSegue(withIdentifier: "unwindToSettingsViewController", sender: nil)
                }
                alertSuccess.addAction(actionCancel)
                self!.present(alertSuccess, animated: true, completion: nil)
            }else{
                self!.alertNotification.message = "Текущий пароль введен неверно"
                self!.present(self!.alertNotification, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func hideOldPassword(_ sender: UIButton) {
        oldPassword.isSecureTextEntry = !oldPassword.isSecureTextEntry
        if oldPassword.isSecureTextEntry{
            sender.setImage(UIImage(named: "hidden"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "hide_password"), for: .normal)
        }
    }
    
    
    @IBAction func hideNewPassword(_ sender: UIButton) {
        newPassword.isSecureTextEntry = !newPassword.isSecureTextEntry
        if newPassword.isSecureTextEntry{
            sender.setImage(UIImage(named: "hidden"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "hide_password"), for: .normal)
        }
    }
    
    
    @IBAction func hideReplyPassword(_ sender: UIButton) {
        replayPassword.isSecureTextEntry = !replayPassword.isSecureTextEntry
        if replayPassword.isSecureTextEntry{
            sender.setImage(UIImage(named: "hidden"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "hide_password"), for: .normal)
        }
    }
    
}


// MARK: - Private methods
private extension ChangePasswordController {

    func setUpTableView() {
        setAutomaticRowHeight()
        registerNibCell()
    }


    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

    func registerNibCell() {
        let nibCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellId)
    }
}
