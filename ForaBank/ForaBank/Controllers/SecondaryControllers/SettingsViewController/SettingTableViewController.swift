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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

}
