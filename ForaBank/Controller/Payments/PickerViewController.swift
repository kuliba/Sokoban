//
//  PickerViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var pickerItems = [IPickerItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell?
        let pickerItem = pickerItems[indexPath.item]

        switch pickerItem.itemType {
        case .paymentOption:
            let ddCell = tableView.dequeueReusableCell(withIdentifier: String(describing: DropDownTableViewCell.self), for: indexPath) as? DropDownTableViewCell
            ddCell?.setupLayout(withPickerItem: pickerItem)
            cell = ddCell
            break
        case .plain:
            cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
            break
        default:
            break
        }

        return cell ?? UITableViewCell()
    }
}
