//
//  ChatDialogsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 27/09/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import AppLocker

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var changePinCode: UIButton!
    let refreshControl = UIRefreshControl()
    let dialogCellId = "DialogCell"
    
  
    // MARK: - Actions
    @IBAction func backButtonClicked(_ sender: Any) {
//        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func changePinCode(sender: Any){
        AppLocker.present(with: .change)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        setSearchView()
        
        // Prepare back button for animation

        
        // Prepare back button for animation
        backButton.alpha = 0
        backButton.frame.origin.x += 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackButton()
    }
    
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    

    
}

private extension SettingsViewController {
    
 

    
   
    
    @objc func refreshData() {
        
    }
    
    func animateBackButton() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.allowUserInteraction],
            animations: {
                self.backButton.alpha = 1
                self.backButton.frame.origin.x -= 5
        },
            completion: { _ in
                
        })
    }
    func setSearchView() {
        guard let searchCell = UINib(nibName: "SearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
                return
        }
       
    }
}
