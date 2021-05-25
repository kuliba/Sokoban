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

    @IBOutlet weak var foraPreloader: RefreshView!
    let cellId = "DepositsDepositCell"

    var refreshView: RefreshView!

    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()


    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        tableView.refreshControl = tableViewRefreshControl
        // Getting the nib from bundle
        getRefereshView()
    }

    @objc func refreshTableView() {
        refreshView.startAnimation()
        NetworkManager.shared().getDepos { (success, accounts) in
            if success {
                self.accounts = accounts ?? []
            }

            self.refreshView.stopAnimation()
            self.tableViewRefreshControl.endRefreshing()
        }


    }

    func getRefereshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = tableViewRefreshControl.frame
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            tableViewRefreshControl.addSubview(refreshView)
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        foraPreloader.startAnimation()
        setUpTableView()
        LabelNoProduct.isHidden = true
        prepareUI()
        self.notifications()
    }

    var accounts = [Account]() {
        didSet {
            tableView.reloadData()
            foraPreloader.isHidden = true
            hiddenAccount()

        }
    }
    func hiddenAccount() {
        if accounts.count == 0 {
            LabelNoProduct.isHidden = false
        }else{
            LabelNoProduct.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (accounts.count == 0) {
            foraPreloader.startAnimation()
            LabelNoProduct.isHidden = true
        }
    }

    //MARK: - lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAccounts()
    }
    
    private func getAccounts(){
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

        cell.titleLabel.text = (accounts[indexPath.row].customName == nil) ? "\(accounts[indexPath.row].productName)":"\((accounts[indexPath.row].customName)!)"
        cell.subTitleLabel.text = maskedAccountNumber(number: accounts[indexPath.row].accountNumber, separator: ".")
        cell.amountLabel.text = maskSum(sum: accounts[indexPath.row].balance)
        cell.currently.text = accounts[indexPath.row].currencyCode
        cell.bottomSeparatorView.isHidden = indexPath.row == accounts.endIndex - 1

        return cell
    }
    
    public var screenHeight: CGFloat {
          return UIScreen.main.bounds.height
      }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: UIScreen.main.bounds.height ))
        let addDepositButton = UIButton(frame: CGRect(x: footerView.frame.minX, y: screenHeight - (screenHeight/4.5), width: footerView.frame.width, height: 45))
            addDepositButton.addTarget(nil, action: #selector(CarouselViewController.createProductButtonClicked), for: .touchUpInside)

            addDepositButton.setTitle("Открыть продукт", for: .normal)
            addDepositButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            addDepositButton.setTitleColor(.black, for: [])
            
            addDepositButton.layer.borderWidth = 0.5
            addDepositButton.layer.borderColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).cgColor
            addDepositButton.layer.cornerRadius = addDepositButton.frame.height / 2

            view.addSubview(addDepositButton)
            return footerView

    }



    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let account = accounts[indexPath.item]

        let addToDepositAction = UITableViewRowAction(style: .normal, title: "Пополнить счет") {action, indexPath in
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
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsSuccessViewController {
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

//MARK: Notification
private extension AccountsViewController{
    @objc func updateTableViewAccount(notification: Notification){
        self.getAccounts()
    }
    
    private func notifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAccount), name: NSNotification.Name(rawValue: "updateProductNameAccaunt"), object: nil)
    }
    
}
