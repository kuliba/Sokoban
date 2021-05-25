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
    var callBack: ((_ number: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: String(describing: DropDownTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: DropDownTableViewCell.self))
        modalPresentationStyle = .fullScreen
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        contentView.layer.cornerRadius = 5.0
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension PickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        if touch.view?.frame.height ?? 0 >= CGFloat(70) {
            return false
        }

        if touch.view == view {
            return true
        }
        return false
    }
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return pickerItems.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell?
        guard indexPath.section == 1 else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")

            cell?.imageView?.image = UIImage(named: "payments_transfer_to-bank-client")
            cell?.textLabel?.text = "Клиенту банка"

            return cell ?? UITableViewCell()
        }

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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }

        let alert = showInputDialog(title: "Add number",
                                    subtitle: "Please enter the new number below.",
                                    actionTitle: "Add",
                                    cancelTitle: "Cancel",
                                    inputPlaceholder: "New number",
                                    inputKeyboardType: .numberPad)
        { (input: String?) in
            self.dismiss(animated: true) {
                self.callBack?(input ?? "")
            }
            print("The new number is \(input ?? "")")
        }
        self.present(alert, animated: true, completion: nil)
        // tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}
