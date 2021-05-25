//
//  SBPTableViewViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.08.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class SBPTableViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    
   @IBAction func backButtonClicked(_ sender: Any) {
           self.navigationController?.popViewController(animated: true)
           if navigationController == nil {
               dismiss(animated: true, completion: nil)
           }
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UINib(nibName: "SBPTableViewCell", bundle: nil), forCellReuseIdentifier: "SBPTableViewCell")
        tableView?.register(UINib(nibName: "SetUpDefaultBankTableViewCell", bundle: nil), forCellReuseIdentifier: "SetUpDefaultBankTableViewCell")
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 150))
        let image = UIImageView(image: UIImage(named: "sbp.png-large"))
        image.contentMode = .scaleAspectFit
        footerView.addSubview(image)
        image.center = footerView.center
        return footerView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SBPTableViewCell", for: indexPath) as? SBPTableViewCell
                 cell?.descriptionLabel.text = "Подключая данную функцию, Вы предосталяете согласие на обработку Ваших персональных данных в целях совершения переводов д/с с использованием сервисов СБП."
                 cell?.titleLabel.text = "Принимать и отправлять переводы через СБП"
                 return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SetUpDefaultBankTableViewCell", for: indexPath) as? SetUpDefaultBankTableViewCell
            
            return cell!
        }
      
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "setDefaultBank", sender: nil)
    }
   
    
    
}
