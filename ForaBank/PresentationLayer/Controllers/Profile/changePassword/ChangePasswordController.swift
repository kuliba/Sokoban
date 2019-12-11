/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import iCarousel
import DeviceKit
import Hero



class ChangePasswordController: UIViewController {
    var gradientViews = [GradientView2]()

    var backSegueId: String? = nil
    var segueId: String? = nil
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!

    @IBAction func backButtonClicked(_ sender: Any) {
        view.endEditing(true)
        segueId = backSegueId
        navigationController?.popViewController(animated: true)
        if navigationController == nil {
            dismiss(animated: true, completion: nil)
        }
    }


    let cellId = "FeedOptionCell"





    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpTableView()



    }
}


// MARK: - Private methods
private extension ChangePasswordController {

    func setUpTableView() {
        setAutomaticRowHeight()
        registerNibCell()
    }


    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

    func registerNibCell() {
        let nibCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: cellId)
    }
}
