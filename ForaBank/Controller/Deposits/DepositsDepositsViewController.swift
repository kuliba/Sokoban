//
//  DepositsDepositsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 06/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsDepositsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let transitionAnimator = DepositsDepositsSegueAnimator()
    
    let cellId = "DepositsDepositCell"
    
    let data_ = [
        [
            "Зарплатный счет",
            "5505",
            "39 500 P"
        ], [
            "Моя сберочка",
            "4404",
            "55 560 P"
        ], [
            "Сейф",
            "3303",
            "23 543 P"
        ], [
            "Вклад Комфортный",
            "2202",
            "119 556 P"
        ], [
            "Бонусный счет",
            "1106",
            "5 500 P"
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OneOneViewController" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = transitionAnimator
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension DepositsDepositsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsDepositCell else {
            fatalError()
        }
        
        cell.titleLabel.text = data_[indexPath.row][0]
        cell.subTitleLabel.text = data_[indexPath.row][1]
        cell.amountLabel.text = data_[indexPath.row][2]
        cell.bottomSeparatorView.isHidden = indexPath.row == data_.endIndex - 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let addDepositButton = UIButton(frame: CGRect(x: footerView.frame.minX, y: footerView.frame.minY + 15, width: footerView.frame.width, height: 45))
            
            addDepositButton.setTitle("Добавить счет", for: .normal)
            addDepositButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            addDepositButton.setTitleColor(.black, for: [])
            
            addDepositButton.layer.borderWidth = 0.5
            addDepositButton.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
            addDepositButton.layer.cornerRadius = addDepositButton.frame.height / 2
            
            footerView.addSubview(addDepositButton)
            return footerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OneOneViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToDepositAction = UITableViewRowAction(style: .normal, title: "Пополнить счет") { [weak self] action, indexPath in
            self?.presentPaymentsDetailsViewController()
        }
        addToDepositAction.backgroundColor = UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1)
        return [addToDepositAction]
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sendAction = UIContextualAction(style: .normal, title: "Отправить") { [weak self] (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self?.presentPaymentsDetailsViewController()
        }
        sendAction.backgroundColor = UIColor(red: 234/255, green: 68/255, blue: 6/255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [sendAction])
    }
}

// MARK: - Private methods
private extension DepositsDepositsViewController {
    func presentPaymentsDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentsDetailsViewController") as? PaymentsDetailsViewController {
            present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - Table View Set Up Private methods
private extension DepositsDepositsViewController {
    
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

extension DepositsDepositsViewController: CustomTransitionOriginator, CustomTransitionDestination {
    var fromAnimatedSubviews: [String : UIView] {
        var views = [String : UIView]()
        views["tableView"] = tableView
        return views
    }
    
    var toAnimatedSubviews: [String : UIView] {
        var views = [String : UIView]()
        views["tableView"] = tableView
        return views
    }
}
