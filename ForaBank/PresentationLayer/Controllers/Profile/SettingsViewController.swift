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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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

    func reloadData() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in self?.tableView.reloadData() }, completion: nil)
    }
}

extension SettingsViewController: SettingsPresenterDelegate {
    func didSelectOption(option: UserSettingType) {
        switch option {
        case .changePassword:
            performSegue(withIdentifier: "showChangePassword", sender: nil)
            break
        case .changePasscode:
            //performSegue(withIdentifier: "showChangePasscod", sender: nil)
            let passcodeVC = ChangePasscodeVC()
            passcodeVC.modalPresentationStyle = .overFullScreen
            present(passcodeVC, animated: true, completion: nil)
        default:
            break
        }
    }
}


//MARK: Navigation
extension SettingsViewController{
    @IBAction func unwindToSettingsViewController(_ unwindSegue: UIStoryboardSegue) {
    }
}
