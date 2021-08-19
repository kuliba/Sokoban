//
//  GKHDetailViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit

class GKHInputViewController: UIViewController {
    
    var operatorData: GKHOperatorsModel?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  let q = GKHDataSorted.a("ФИО плательщика")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let a = operatorData
        print()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {

       //     self.goButton.isHidden = false

        }
    }

}
