/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Alamofire
import FlexiblePageControl
import Hero

class AccountsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!

    @IBOutlet weak var LabelNoProduct: UILabel!
    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!
    let transitionAnimator = AccountsSegueAnimator()

    let cellId = "DepositsDepositCell"



    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimation()
        setUpTableView()
        LabelNoProduct.isHidden = true

    }

    var accounts = [Account]() {
        didSet {
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
            hiddenAccount()

        }
    }
    func hiddenAccount() {
        if accounts.count == (0) {
            LabelNoProduct.isHidden = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (accounts == nil) {
            activityIndicatorView.startAnimation()
            LabelNoProduct.isHidden = false
        }
    }

    //MARK: - lifecycle


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetworkManager.shared().getDepos { (success, accounts) in
            if success {
                self.accounts = accounts ?? []
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductDetailsViewController {
            destination.account = accounts[(tableView.indexPathForSelectedRow?.row)!]
        }

    }



    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if tableView.indexPathForSelectedRow != nil {
            //tableView.deselectRow(at: selectedRow, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProductDetailsViewController", sender: Any?.self)

    }
}






// MARK: - UITableView DataSource and Delegate
extension AccountsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsDepositCell else {
            fatalError()
        }

        cell.titleLabel.text = accounts[indexPath.row].productName
        cell.subTitleLabel.text = maskedAccount(with: accounts[indexPath.row].accountNumber)
        cell.amountLabel.text = maskSum(sum: accounts[indexPath.row].balance)
        cell.currently.text = accounts[indexPath.row].currencyCode
        cell.bottomSeparatorView.isHidden = indexPath.row == accounts.endIndex - 1

        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let addDepositButton = UIButton(frame: CGRect(x: footerView.frame.minX, y: footerView.frame.minY + 15, width: footerView.frame.width, height: 45))

            addDepositButton.setTitle("Открыть счет", for: .normal)
            addDepositButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            addDepositButton.setTitleColor(.black, for: [])

            addDepositButton.layer.borderWidth = 0.5
            addDepositButton.layer.borderColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).cgColor
            addDepositButton.layer.cornerRadius = addDepositButton.frame.height / 2

            footerView.addSubview(addDepositButton)
            return footerView
        }

        return nil
    }



    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let account = accounts[indexPath.item]

        let addToDepositAction = UITableViewRowAction(style: .normal, title: "Пополнить счет") { [weak self] action, indexPath in
            store.dispatch(startPayment(sourceOption: nil, destionationOption: PaymentOption(product: account)))
        }
        addToDepositAction.backgroundColor = UIColor(red: 26 / 255, green: 188 / 255, blue: 156 / 255, alpha: 1)
        return [addToDepositAction]
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let account = accounts[indexPath.item]

        let sendAction = UIContextualAction(style: .normal, title: "Отправить") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            store.dispatch(startPayment(sourceOption: PaymentOption(product: account), destionationOption: nil))
        }
        sendAction.backgroundColor = UIColor(red: 234 / 255, green: 68 / 255, blue: 6 / 255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [sendAction])
    }
}

// MARK: - Private methods

private extension AccountsViewController {
    func presentPaymentDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentDetailsViewController {
            present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - Table View Set Up Private methods

private extension AccountsViewController {

    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewEstimatedAutomaticRowHeight()
        setTableViewContentInset()
        registerTableViewNibCell()
    }

    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setTableViewEstimatedAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

    func setTableViewContentInset() {
        tableView.contentInset.top = 15
    }

    func registerTableViewNibCell() {
        let nibTemplateCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: cellId)
    }
}

extension AccountsViewController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()
        views["tableView"] = tableView
        return views
    }

    var toAnimatedSubviews: [String: UIView] {
        var views = [String: UIView]()
        views["tableView"] = tableView
        return views
    }
}
