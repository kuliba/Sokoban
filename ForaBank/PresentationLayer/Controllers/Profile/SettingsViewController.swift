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



class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!

    // MARK: - Properties

    var presenter: ISettingsPresenter?
    var gradientViews = [GradientView2]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
}

// MARK: - IListViewController

extension SettingsViewController: IListViewController {

    func setUpTableView() {
        setAutomaticRowHeight()
    }

    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension SettingsViewController: SettingsPresenterDelegate {

}
