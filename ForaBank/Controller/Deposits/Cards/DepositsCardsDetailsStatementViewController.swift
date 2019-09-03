/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

class DepositsCardsDetailsStatementViewController: UIViewController, TabCardDetailViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let cellId = "DepositsHistoryCell"
    var displayedPeriod: (Date, Date) = (Calendar.current.date(byAdding: .year, value: -5, to: Date())!, Date())
    var datedTransactions = [DatedTransactions]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    var card: Card? = nil
    func set(card: Card?) {
        self.card = card
    }
    let data_ = [
        DepositHistoryDate(date: "Вчера, 5 сентября", amountTotal: "+560,15 ₽", transactions: [
            DepositHistoryTransaction(imageName: "deposit_history_transaction_capitalization", title: "", subtitle: "", value: "5560,15 ₽", subvalue: ""),
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cardNumber = card?.number {
            NetworkManager.shared().getTransactionsStatement(forCardNumber: cardNumber,
                                                             fromDate: displayedPeriod.0,
                                                             toDate: displayedPeriod.1) { [weak self] (success, datedTransactions) in
                if let datedTransactions = datedTransactions,
                    success == true {
                    self?.datedTransactions = datedTransactions
                }
            }
        }
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
        if card != nil {
            return datedTransactions.count
        }
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if card != nil {
            return datedTransactions[section].transactions.count
        }
        return data_[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsHistoryCell else {
            return UITableViewCell()
        }
        if card != nil {
            cell.imageView?.image = nil
            cell.titleLabel.text = nil
            cell.subTitleLabel.text = nil
            cell.descriptionLabel.text = nil
            cell.subdescriptionLabel.text = nil
            cell.commentLabel.text = nil
            if let image = datedTransactions[indexPath.section].transactions[indexPath.row].counterpartImageURL {
                cell.imageView?.image = UIImage(named: image)
            }
            if let title = datedTransactions[indexPath.section].transactions[indexPath.row].counterpartName {
                cell.titleLabel.text = title
            }
            if let subtitle = datedTransactions[indexPath.section].transactions[indexPath.row].details {
                cell.subTitleLabel.text = subtitle
            }
            if let amount = datedTransactions[indexPath.section].transactions[indexPath.row].amount,
                let locale = datedTransactions[indexPath.section].transactions[indexPath.row].currency {
//                cell.descriptionLabel.text = String.init(format: "%.2d", amount)
                let f = NumberFormatter()
                f.numberStyle = .currency
                f.locale = Locale(identifier: locale)
                f.usesGroupingSeparator = true
                f.currencyGroupingSeparator = " "
                if let amountString = f.string(from: NSNumber(value: amount)),
                    amountString.count > 0{
                    let splited = amountString.split(separator: ",")
                    let attributedStr = NSMutableAttributedString.init(string: (amount>0 ? "+":"") + amountString)
                    attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)],
                        range:NSRange(location: 0, length: splited.first!.count))
                    attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Light", size: 13) ?? UIFont.systemFont(ofSize: 13)],
                                                range:NSRange(location: splited.first!.count+1, length: splited.last!.count))
                    cell.descriptionLabel.attributedText = attributedStr
                }
                if amount>0 {
                    cell.descriptionLabel.textColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
                } else {
                    cell.descriptionLabel.textColor = UIColor.darkText
                }
            }
            if let bonuses = datedTransactions[indexPath.section].transactions[indexPath.row].bonuses,
                bonuses>0{
                cell.subdescriptionLabel.text = "+\(bonuses) бонусов"
            }
            
            cell.bottomSeparatorView.isHidden = indexPath.row == datedTransactions[indexPath.section].transactions.endIndex - 1
            return cell
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
            if card != nil {
                headerCell.titleLabel.text = nil
                headerCell.subTitleLabel.text = nil
                if let date = datedTransactions[section].dateTo {
                    let f = DateFormatter()
                    f.doesRelativeDateFormatting = true
                    f.locale = Locale(identifier: "ru_RU")
                    f.dateStyle = .full
                    let relativeDate = f.string(from: date)
                    let ff = DateFormatter()
                    ff.locale = Locale(identifier: "ru_RU")
                    ff.dateFormat = "dd MMMM"
                    let nonrelativeDate = ff.string(from: date)
//                    if relativeDate.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                    if relativeDate.count > 8 {
                        headerCell.titleLabel.text = nonrelativeDate
                    } else {
                        headerCell.titleLabel.text = "\(relativeDate), \(nonrelativeDate)"
                    }
                }
                if let amount = datedTransactions[section].changeOfBalanse,
                    let locale = datedTransactions[section].currency {
                    let f = NumberFormatter()
                    f.numberStyle = .currency
                    f.locale = Locale(identifier: locale)
                    f.usesGroupingSeparator = true
                    f.currencyGroupingSeparator = " "
                    if let amountString = f.string(from: NSNumber(value: amount)),
                        amountString.count > 0{
                        headerCell.subTitleLabel.text = (amount>0 ? "+":"") + amountString
                    }
                    if amount>0 {
                        headerCell.subTitleLabel.textColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
                    } else {
                        headerCell.subTitleLabel.textColor = UIColor.darkText
                    }
                }
                return headerView
            }
            
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
