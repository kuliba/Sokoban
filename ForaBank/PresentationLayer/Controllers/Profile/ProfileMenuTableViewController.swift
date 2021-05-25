/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class ProfileMenuTableViewController: UITableViewController {

    @IBOutlet weak var repeatPayment: UIView!
    @IBOutlet weak var categorySort: UIButton!
    @IBOutlet weak var createTemplate: UIButton!
//    let backgroundColor =  UIColor(hexFromString: "EF4136")

    // MARK: - Actions

    @IBAction func messagesButtonClicked(_ sender: Any) {
        parent?.performSegue(withIdentifier: "ChatDialogsViewController", sender: nil)
    }
    @IBAction func settingsButtonClicked(_ sender: Any) {
        parent?.performSegue(withIdentifier: "SettingsViewController", sender: nil)
    }

    @IBAction func createTemplate(_ sender: Any) {
        let alertVC = UIAlertController(title: "Функционал недоступен", message: "Функционал временно недоступен", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        show(alertVC, sender: self)
    }

    
    @IBAction func historyButton(_ sender: Any) {
        self.parent?.performSegue(withIdentifier: "History", sender: nil)
    }
    @IBAction func quitButtonClicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userImageView")
        AuthenticationService.shared.logoutAndClearAllUserData()
    }
    
    @IBAction func aboutApp(_ sender: Any) {
        parent?.performSegue(withIdentifier: "AboutApp", sender: nil)
       }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? DepositsHistoryViewController{
//            vc.backgroundColor = UIColor(hexFromString: "EF4136")
//            self.parent?.performSegue(withIdentifier: "History", sender: backgroundColor)
//        }
//        if segue.identifier == "History"{
//           let vc = segue.destination as? DepositsHistoryViewController
//            vc?.backgroundColor = UIColor(hexFromString: "EF4136")
//            self.parent?.performSegue(withIdentifier: "History", sender: backgroundColor)
//
//        }
//    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.backgroundColor = UIColor.clear

    }
  
}
