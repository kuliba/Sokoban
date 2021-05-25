//
//  ProductListSheetsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 18.05.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import UBottomSheet

class ProductListSheetsViewController: UIViewController, Draggable {
    
    var sheetCoordinator: UBottomSheetCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PickerProductTableViewCell", bundle: nil), forCellReuseIdentifier: "PickerProductTableViewCell")
        // Do any additional setup after loading the view.
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


extension ProductListSheetsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerProductTableViewCell") as? PickerProductTableViewCell
        return cell!
    }
    
    
}


