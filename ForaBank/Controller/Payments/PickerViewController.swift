//
//  PickerViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 26/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var pickerItems = [IPickerItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: DropDownTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DropDownTableViewCell.self))
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        contentView.layer.cornerRadius = 5.0
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
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
            ddCell?.setupLayout(withPickerItem: pickerItem, isDroppable: false)
            cell = ddCell
            break
        case .plain:
            cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
            break
        }

        return cell ?? UITableViewCell()
    }
}
