//
//  Loans.swift
//  ForaBank
//
//  Created by Дмитрий on 13/08/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation


import UIKit



class LoansViewController: UIViewController {

    var product: String?
    let transitionAnimator = LoansSegueAnimator()
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView! //tblProductApple

    @IBOutlet weak var activityInd: ActivityIndicatorView!

    let cellId = "DepositsObligationsCell"


    var loan = [Loan]() {
        didSet {
            tableView.reloadData()
            activityInd.stopAnimating()
        }
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityInd.startAnimation()
        setUpTableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (loan == nil) {
            activityInd.startAnimation()

        }


    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoansDetailsViewController {
            destination.loan = loan[(tableView.indexPathForSelectedRow?.row)!]
        }

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetworkManager.shared().getLoans { (success, loans) in
            if success {
                self.loan = loans ?? []
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            //tableView.deselectRow(at: selectedRow, animated: false)
            performSegue(withIdentifier: "LoansDetailsViewController", sender: nil)

        }


    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "LoansDetailsViewController", sender: nil)

    }


}



// MARK: - UITableView DataSource and Delegate
extension LoansViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loan.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsObligationsCell else {
            fatalError()
        }

        cell.titleLabel.text = loan[indexPath.row].number
        cell.currently.text = loan[indexPath.row].currencyCode
        cell.subTitleLabel.text = maskSum(sum: loan[indexPath.row].userAnnual!)
        cell.descriptionLabel.text = maskSum(sum: loan[indexPath.row].principalDebt!)
        cell.bottomSeparatorView.isHidden = indexPath.row == loan.endIndex - 1

        return cell
    }




    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToDepositAction = UITableViewRowAction(style: .normal, title: "Пополнить счет") { [weak self] action, indexPath in
            self?.presentPaymentsDetailsViewController()
        }
        addToDepositAction.backgroundColor = UIColor(red: 26 / 255, green: 188 / 255, blue: 156 / 255, alpha: 1)
        return [addToDepositAction]
    }



}

// MARK: - Private methods
private extension LoansViewController {
    func presentPaymentsDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsDetailsViewController") as? PaymentsDetailsViewController {
            present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - Table View Set Up Private methods
private extension LoansViewController {

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

extension LoansViewController: CustomTransitionOriginator, CustomTransitionDestination {
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
