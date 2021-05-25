//
//  CompleteSBPBankVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 17.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class CompleteSBPBankVC: UIViewController {
    
    @IBOutlet weak var buttonComplete: ButtonRounded!
    @IBOutlet weak var viewBack: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let frame:CGRect   = CGRect(x: 50, y: 30, width: 200, height: 300)
        self.view.frame    = frame
        self.buttonComplete.changeEnabled(isEnabled: true)
//        self.viewBack.backgroundColor = UIColor(red: 52/255, green: 168/255, blue: 89/255, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionCompleteReturn(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
