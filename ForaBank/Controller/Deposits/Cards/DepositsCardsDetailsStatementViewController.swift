//
//  DepositsCardsDetailsStatementViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 29/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsDetailsStatementViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let cellId = "DepositsHistoryCell"
    
    let data_ = [
        DepositHistoryDate(date: "Вчера, 5 сентября", amountTotal: "+560,15 ₽", transactions: [
            DepositHistoryTransaction(imageName: "deposit_history_transaction_capitalization", title: "Капитализация средств", subtitle: "Внутрибанковские операции", value: "5560,15 ₽", subvalue: ""),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_perevod", title: "Перевод между счетами", subtitle: "Внутрибанковские операции", value: "+10 000,00 ₽", subvalue: ""),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_metro", title: "METRO Store 1019", subtitle: "Гипермаркет", value: "-14 567,07 ₽", subvalue: "+1200 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_sidorova", title: "Инна Сидорова", subtitle: "За тренировки", value: "-5000,00 ₽", subvalue: "")
            ]),
        
        DepositHistoryDate(date: "4 сентября", amountTotal: "-6567,07 ₽", transactions: [
            DepositHistoryTransaction(imageName: "deposit_history_transaction_perekrestok", title: "PEREKRESTOK 24", subtitle: "Гипермаркет", value: "-2000,00 ₽", subvalue: "+65 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_azbuka", title: "Азбука Вкуса", subtitle: "Супермаркет", value: "-2100,00 ₽", subvalue: "+65 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_gerasimchuk", title: "Павел Герсимчук", subtitle: "За посиделки, которые…", value: "+507,70 ₽", subvalue: ""),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_vnesenie", title: "Внесение средств", subtitle: "Банкоматы и обменны…", value: "+5000,00 ₽", subvalue: ""),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_snyatie", title: "Снятие средств", subtitle: "Банкоматы и обменны…", value: "-500,00 ₽", subvalue: ""),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_perekrestok", title: "PEREKRESTOK", subtitle: "Гипермаркет", value: "-2100,00 ₽", subvalue: "+65 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_dyadushkakho", title: "Dyadushka KO", subtitle: "Гипермаркет", value: "-250,00 ₽", subvalue: "+65 бонусов")
            ]),
        
        DepositHistoryDate(date: "3 сентября", amountTotal: "+560,15 ₽", transactions: [
            DepositHistoryTransaction(imageName: "deposit_history_transaction_metro", title: "METRO Store 1019", subtitle: "Гипермаркет", value: "-14 567,07 ₽", subvalue: "+1200 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_perekrestok", title: "PEREKRESTOK 24", subtitle: "Гипермаркет", value: "-2000,00 ₽", subvalue: "+65 бонусов")
            ]),
        
        DepositHistoryDate(date: "2 сентября", amountTotal: "-6567,07 ₽", transactions: [
            DepositHistoryTransaction(imageName: "deposit_history_transaction_pyaterochka", title: "Pyatorochka Pechatniki", subtitle: "Продуктовый магазин", value: "1050,50 ₽", subvalue: "+10 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_azbuka", title: "Азбука Вкуса", subtitle: "Супермаркет", value: "-2100,00 ₽", subvalue: "+65 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_metro", title: "METRO Store 1019", subtitle: "Гипермаркет", value: "-507,70 ₽", subvalue: "+15 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_perekrestok", title: "PEREKRESTOK 24", subtitle: "Гипермаркет", value: "-2100,00 ₽", subvalue: "+65 бонусов"),
            DepositHistoryTransaction(imageName: "deposit_history_transaction_dyadushkakho", title: "Dyadushka KHO", subtitle: "Гипермаркет", value: "-250,00 ₽", subvalue: "+65 бонусов")
            ])
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
}

// MARK: - UITableView DataSource and Delegate
extension DepositsCardsDetailsStatementViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollUserInfo = ["tableView": tableView]
        NotificationCenter.default.post(name: NSNotification.Name("TableViewScrolled"), object: nil, userInfo: scrollUserInfo as [AnyHashable: Any])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsHistoryCell else {
            fatalError()
        }
        
        cell.imageView?.image = UIImage(named: data_[indexPath.section].transactions[indexPath.row].imageName)
        
        cell.titleLabel.text = data_[indexPath.section].transactions[indexPath.row].title
        cell.subTitleLabel.text = data_[indexPath.section].transactions[indexPath.row].subtitle
        
        cell.descriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].value
        cell.subdescriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].subvalue
        
        cell.bottomSeparatorView.isHidden = indexPath.row == data_[indexPath.section].transactions.endIndex - 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = UINib(nibName: "DepositsHistoryHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? DepositsHistoryHeader {
            let headerView = UIView(frame: headerCell.frame)
            headerView.addSubview(headerCell)
            headerView.backgroundColor = .clear
            headerCell.titleLabel.text = data_[section].date
            headerCell.subTitleLabel.text = data_[section].amountTotal
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        return 95
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "testtest", sender: nil)
    }
}

// MARK: - Private methods
private extension DepositsCardsDetailsStatementViewController {
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        registerNibCell()
        setSearchView()
    }
    
    func setTableViewDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setTableViewContentInsets() {
        tableView.contentInset.top = 35
        tableView.contentInset.bottom = -30
    }
    
    func registerNibCell() {
        let nibTemplateCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: cellId)
    }
    
    func setSearchView() {
        guard let searchCell = UINib(nibName: "DepositsSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? DepositsSearchCell else {
                return
        }
        searchCell.textField.placeholder = "Магазины, люди, суммы, даты"
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
}
