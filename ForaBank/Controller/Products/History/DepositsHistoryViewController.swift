/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit

struct DepositHistoryDate: Codable {
    let date: String
    let amountTotal: String
    let transactions: [DepositHistoryTransaction]
}

struct DepositHistoryTransaction: Codable {
    let imageName: String
    let title: String
    let subtitle: String
    let value: String
    let subvalue: String
}

class DepositsHistoryViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let transitionAnimator = DepositsHistoryDetailsSegueAnimator()
    
    let cellId = "DepositsHistoryCell"
    
    let decoder = JSONDecoder()
    
 
    var sortedTransactionsStatement = [DatedTransactionsStatement]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        NetworkManager.shared().getSortedFullStatement { [weak self] (success, fullStatement, error) in
            print("DepositsHistoryViewController getSortedFullStatement \(success)")
            if success {
                self?.sortedTransactionsStatement = fullStatement ?? [DatedTransactionsStatement]()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare for segue \(segue.identifier ?? "nil")")
        if segue.identifier == "DepositsHistoryDetailsViewController" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = transitionAnimator
        }
    }
}

// MARK: - UITableView DataSource and Delegate
extension DepositsHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedTransactionsStatement.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTransactionsStatement[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsHistoryCell else {
            fatalError()
        }
        
//        cell.imageView?.image = UIImage(named: data_[indexPath.section].transactions[indexPath.row].imageName)
//
        cell.titleLabel.text = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].comment
//        cell.subTitleLabel.text = data_[indexPath.section].transactions[indexPath.row].subtitle
//
//        cell.descriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].value
//        cell.subdescriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].subvalue
//
//        cell.bottomSeparatorView.isHidden = indexPath.row == data_[indexPath.section].transactions.endIndex - 1
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.bounds.width/2
        cell.iconImageView.layer.masksToBounds = true
        if sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("DEBIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
            cell.iconImageView.backgroundColor = .red
        } else if sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
            cell.iconImageView.backgroundColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
        }
       
        cell.subTitleLabel.isHidden = true
        cell.subdescriptionLabel.isHidden = true
        cell.commentLabel.isHidden = false
        if let amount = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].amount {
            //                cell.descriptionLabel.text = String.init(format: "%.2d", amount)
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.locale = Locale(identifier: "ru_RU")
            f.usesGroupingSeparator = true
            f.currencyGroupingSeparator = " "
            if let amountString = f.string(from: NSNumber(value: amount)),
                amountString.count > 0{
                let splited = amountString.split(separator: ",")
                let attributedStr = NSMutableAttributedString.init(string: (sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame ? "+":"-") + amountString)
                attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)],
                                            range:NSRange(location: 0, length: splited.first!.count))
                attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Light", size: 13) ?? UIFont.systemFont(ofSize: 13)],
                                            range:NSRange(location: splited.first!.count+1, length: splited.last!.count))
                cell.descriptionLabel.attributedText = attributedStr
            }
            if sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
                cell.descriptionLabel.textColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
            } else {
                cell.descriptionLabel.textColor = UIColor.darkText
            }
        }
        cell.commentLabel.text = nil//sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].comment
        
        
//        cell.bottomSeparatorView.isHidden = indexPath.row == data_[indexPath.section].transactions.endIndex - 1
        cell.bottomSeparatorView.isHidden = indexPath.row == sortedTransactionsStatement[indexPath.section].transactions.endIndex - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DepositsHistoryDetailsViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
}

// MARK: - Private methods
private extension DepositsHistoryViewController {
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        // setAutomaticRowHeight()
        registerNibCell()
        setSearchView()
    }
    
    func setTableViewContentInsets() {
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
//    func setAutomaticRowHeight() {
//        tableView.estimatedRowHeight = 50
//        tableView.rowHeight = UITableView.automaticDimension
//    }
    
    func registerNibCell() {
        let nibTemplateCell = UINib(nibName: cellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: cellId)
    }
    
    func setSearchView() {
        guard let searchCell = UINib(nibName: "DepositsSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? UIView else {
                return
        }
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
}
