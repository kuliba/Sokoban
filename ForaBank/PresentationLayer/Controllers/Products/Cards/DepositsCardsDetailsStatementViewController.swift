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
    var sortedTransactionsStatement = [DatedCardTransactionsStatement]() {
        didSet{
            self.tableView.reloadData()
            }
    }
    var arrayLaonSchedules = [LaonSchedules](){
        didSet{
            self.tableView.reloadData()
            }
    }
    var datedTransactions = [DatedTransactions]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    var cardHistory = [DatedCardTransactionsStatement]()
    var card: Card? = nil
    func set(card: Card?) {
        self.card = card
    }
 
    let decoder = JSONDecoder()
    var selectIndex: Int? = nil
    var selectedSection: Int? = nil
    var requisite: String = "" //реквизит по которому нужно получить историю
    var idProduct: Int = 0  //id выбранного продукта
    var typeProduct = ProductType.card //тип продукта по которому нужно получить историю

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        self.getHistoryProduct(typeProduct)
    //let cardNumber = card as? CardDetailsViewController
        
    }
    
    //заполняем массив с историей по нужному продукту
    private func getHistoryProduct(_ productType: ProductType){
        if productType == .card{
            NetworkManager.shared().getHistoryCard(cardNumber: "\(requisite)") { [weak self] (success, error) in
                print("CardHistory getCardHistory \(success)")
                if success{
                    self!.sortedTransactionsStatement = error ?? [DatedCardTransactionsStatement]()
                }
            }
        }else if productType == .deposit{
            NetworkManager.shared().getHistoryDeposit(id: idProduct, name: "Depodit") { [weak self] (success, historyStatment) in
                if success{
                    self!.sortedTransactionsStatement = historyStatment ?? [DatedCardTransactionsStatement]()
                }
            }
        }else if productType == .account{
            NetworkManager.shared().getHistoryDeposit(id: idProduct, name: "Account") { [weak self] (success, historyStatment) in
                if success{
                    self!.sortedTransactionsStatement = historyStatment ?? [DatedCardTransactionsStatement]()
                }
            }
        }else if productType == .loan{
            NetworkManager.shared().getLoansPayment { [weak self] (success, arrayLoanSchedule) in
                if success{
                    print("arrayLoanSchedule = ", arrayLoanSchedule![0])
                    guard arrayLoanSchedule != nil, arrayLoanSchedule?.count != 0 else {return}
                    self!.arrayLaonSchedules = arrayLoanSchedule!
                }
            }
        }
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//            if let selectedRow = tableView.indexPathForSelectedRow {
//                //tableView.deselectRow(at: selectedRow, animated: false)
//
//            }
    }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        print("prepare for segue \(segue.identifier ?? "nil")")
            if let destination = segue.destination as? DepositsCardsDetailsStatementDetailsViewController {
                destination.transaction = sortedTransactionsStatement[selectedSection!].transactions[selectIndex!]
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
        if typeProduct == .loan{
            return 1
        }
        return sortedTransactionsStatement.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if typeProduct == .loan{
            return arrayLaonSchedules.count
        }
        return sortedTransactionsStatement[section].transactions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//                   return sortedTransactionsStatement[indexPath.section].transactions.count
//        }
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
            if let title = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].comment {
                cell.titleLabel.text = title
            }
            if let subtitle = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].comment {
                cell.subTitleLabel.text = subtitle
            }
            if let amount = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].amount,
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

        if sortedTransactionsStatement.count != 0{
            cell.titleLabel.text = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].comment
            cell.commentLabel.text = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].accountNumber
            cell.descriptionLabel.text = String( sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].amount!)
        }else if arrayLaonSchedules.count != 0{
            cell.titleLabel.text = arrayLaonSchedules[indexPath.row].actionType
            cell.commentLabel.text = arrayLaonSchedules[indexPath.row].actionTypeBrief
            cell.descriptionLabel.text = "\(arrayLaonSchedules[indexPath.row].paymentAmount ?? 0)"
            print(arrayLaonSchedules[indexPath.row].paymentDate)
        }
        
        
        cell.subTitleLabel.isHidden = true
        cell.subdescriptionLabel.isHidden = true
        cell.commentLabel.isHidden = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if typeProduct == .loan{
            return DepositsHistoryHeader()
        }
        
        let headerCell = UINib(nibName: "DepositsHistoryHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! DepositsHistoryHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        headerView.backgroundColor = .clear
        //        headerCell.titleLabel.text = data_[section].date
        //        headerCell.subTitleLabel.text = data_[section].amountTotal
        let date = sortedTransactionsStatement[section].date
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
        let amount = sortedTransactionsStatement[section].changeOfBalanse
        let f2 = NumberFormatter()
        f2.numberStyle = .currency
        f2.locale = Locale(identifier: "ru_RU")
        f2.usesGroupingSeparator = true
        f2.currencyGroupingSeparator = " "
        if let amountString = f2.string(from: NSNumber(value: amount)),
            amountString.count > 0{
            headerCell.subTitleLabel.text = (amount>0 ? "+":"") + amountString
        }
        if amount>0 {
            headerCell.subTitleLabel.textColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
        } else {
            headerCell.subTitleLabel.textColor = UIColor.darkText
        }
        
        return headerView
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
          selectIndex = indexPath.item
          selectedSection = indexPath.section
          performSegue(withIdentifier: "testtest", sender: self)
          
          
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
