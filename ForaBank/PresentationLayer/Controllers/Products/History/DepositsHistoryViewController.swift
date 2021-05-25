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

class DepositsHistoryViewController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let transitionAnimator = DepositsHistoryDetailsSegueAnimator()
    
    let cellId = "DepositsHistoryCell"
    var backgroundColor: UIColor?
    @IBOutlet weak var foraPreloader: RefreshView!
    let decoder = JSONDecoder()
    var selectIndex: Int? = nil
    var selectedSection: Int? = nil
 
    var sortedTransactionsStatement = [DatedTransactionsStatement]() {
        didSet{
            foraPreloader.isHidden = true
            self.tableView.reloadData()
        }
    }
    var filteredCandies: [DatedTransactionsStatement] = []
    var isSearchBarEmpty: Bool {
      return  true
    }
    var isFiltering: Bool {
      return !isSearchBarEmpty
    }
    var refreshView: RefreshView!
    
    var tableViewRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        return refreshControl
    }()
//    @IBOutlet weak var searchBar: UISearchBar!
    
    
    func prepareUI() {
        // Adding 'tableViewRefreshControl' to tableView
        tableView.refreshControl = tableViewRefreshControl
        // Getting the nib from bundle
//        getRefereshView()
    }
    
    @objc func refreshTableView() {
//          refreshView.startAnimation()
      NetworkManager.shared().getSortedFullStatement { [weak self] (success, fullStatement, error) in
                   print("DepositsHistoryViewController getSortedFullStatement \(success)")
                   if success {
                       self?.sortedTransactionsStatement = fullStatement ?? [DatedTransactionsStatement]()
                   }
               
        
//        self?.refreshView.stopAnimation()
        self?.tableViewRefreshControl.endRefreshing()
        }
      }
    
//    func getRefereshView() {
//        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
//            // Initializing the 'refreshView'
//            refreshView = objOfRefreshView
//            // Giving the frame as per 'tableViewRefreshControl'
//            refreshView.frame = tableViewRefreshControl.frame
//            // Adding the 'refreshView' to 'tableViewRefreshControl'
//            tableViewRefreshControl.addSubview(refreshView)
//        }
//    }
    
    
    func filterContentForSearchText(_ searchText: String,
                                    category: DatedTransactionsStatement? = nil) {
        filteredCandies = sortedTransactionsStatement.filter { (candy: DatedTransactionsStatement) -> Bool in
            return (candy.transactions as AnyObject).contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }

  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (sortedTransactionsStatement.count == 0) {
            foraPreloader.startAnimation()

        }


    }
    
    @IBOutlet weak var headerView: UIView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
//        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
          let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
                 searchBar.delegate = self
                 searchBar.placeholder = "Поиск"
            searchBar.backgroundColor = .white
                 tableView.tableHeaderView = searchBar
//        headerView.backgroundColor = .red
        view.backgroundColor = .white
//            let searchController = UISearchController(searchResultsController: nil)
//            searchController.searchResultsUpdater = self
//            searchController.obscuresBackgroundDuringPresentation = false
//            searchController.searchBar.placeholder = "Search Candies"
//            navigationItem.searchController = searchController

        
     
//        var firstOperation: [SBPModelPayment] = [SBPModelPayment(name: "Перевод через СБП", amount: 1000, payeeName: "Иванов Иван И.", resultOperation: "ok", status: "ok", date: "16.07.20", accountWriteOff: "-100", payeer: "+7 (926) 612-92-68", idNumber: "ПромсвязьБанк", bankPayeer: "ПромсвязьБанк", message: "Коле на др", idOperation: "xxxxxxxxx")]
//        var secondOperation: DepositHistoryTransaction = DepositHistoryTransaction(imageName: "sbpLogo", title: "Перевод по СБП", subtitle: "Иванов Иван И.", value: "-1000", subvalue: "-100")
//        let dateOperation: DatedTransactionsStatement = DatedTransactionsStatement(changeOfBalanse: -1000, date: Date(), transactions: [TransactionStatement(from: <#Decoder#>)])
//        sortedTransactionsStatement.append(dateOperation)
        foraPreloader.startAnimation()
        NetworkManager.shared().getSortedFullStatement { [weak self] (success, fullStatement, error) in
            print("DepositsHistoryViewController getSortedFullStatement \(success)")
            if success {
                self?.sortedTransactionsStatement = fullStatement ?? [DatedTransactionsStatement]()
            }
        }
        
        view.backgroundColor = backgroundColor
        
        
       if isModal == false {
                prepareUI()
 }
     
        definesPresentationContext = true
    }
    





    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil )
        navigationController?.popViewController(animated: true)
        print("Hola")
    }
    
    
    

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let _ = tableView.indexPathForSelectedRow {
            //tableView.deselectRow(at: selectedRow, animated: false)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare for segue \(segue.identifier ?? "nil")")
        if let destination = segue.destination as? DepositsHistoryDetailsViewController {
            destination.transaction = sortedTransactionsStatement[selectedSection!].transactions[selectIndex!]
            
               }
    }

}

// MARK: - UITableView DataSource and Delegate
extension DepositsHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering{
        return filteredCandies.count
        }
        return sortedTransactionsStatement.count
        
        }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return filteredCandies[section].transactions.count
               }
                return sortedTransactionsStatement[section].transactions.count
               
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsHistoryCell else {
            fatalError()
        }
        let transactonStatement: TransactionStatement
        
        if isFiltering {
            transactonStatement = filteredCandies[indexPath.section].transactions[indexPath.row]
        } else {
          transactonStatement = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row]
        }
//        cell.imageView?.image = UIImage(named: data_[indexPath.section].transactions[indexPath.row].imageName)
//
        cell.titleLabel.text = transactonStatement.comment
//        cell.subTitleLabel.text = data_[indexPath.section].transactions[indexPath.row].subtitle
//
//        cell.descriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].value
//        cell.subdescriptionLabel.text = data_[indexPath.section].transactions[indexPath.row].subvalue
//
//        cell.bottomSeparatorView.isHidden = indexPath.row == data_[indexPath.section].transactions.endIndex - 1
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.bounds.width/2
        cell.iconImageView.layer.masksToBounds = true
        if sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("DEBIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
            cell.iconImageView.backgroundColor = UIColor(hexFromString: "ED433D")
//            cell.iconImageView.image = UIImage(named: "feed_option_paymentstransactions")
            cell.iconImageView.sizeToFit()
        } else if sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame {
            cell.iconImageView.backgroundColor = UIColor(red: 4/255, green: 160/255, blue: 133/255, alpha: 1)
//            cell.iconImageView.image = UIImage(named: "feed_option_exchangerate")
            cell.iconImageView.sizeToFit()
        }
       
        cell.subTitleLabel.isHidden = true
        cell.subdescriptionLabel.isHidden = true
        cell.commentLabel.isHidden = false
        if let amount = sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].amount {
            //                cell.descriptionLabel.text = String.init(format: "%.2d", amount)
            let f = NumberFormatter()
//            f.numberStyle = .currency
//            switch transactonStatement.clientCurrencyCode { //определяем валюту
//                    case "RUB":
//                    f.locale = Locale(identifier: "ru_RU")
//                    case "USD":
//                    f.locale = Locale(identifier: "en_US")
//                    case "EUR":
//                    f.locale = Locale(identifier: "de_DE")
//                    default: //если не нашли подходящую валюту
//                    f.locale = Locale(identifier: "ru_RU")
//
//                    }
            
//            f.locale = Locale(identifier: "\(String(describing: getSymbol(forCurrencyCode: transactonStatement.clientCurrencyCode ?? "")))")
            f.usesGroupingSeparator = true
            f.currencyGroupingSeparator = " "
            if let amountString = f.string(from: NSNumber(value: amount)),
                amountString.count > 0{
                let splited = amountString.split(separator: ",")
                let attributedStr = NSMutableAttributedString.init(string: (sortedTransactionsStatement[indexPath.section].transactions[indexPath.row].operationType?.compare("CREDIT", options: .caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedSame ? "+":"-") + amountString + " " + getSymbol(forCurrencyCode: transactonStatement.clientCurrencyCode ?? "")!)
//                attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)],
//                                            range:NSRange(location: 0, length: splited.first!.count))
//                attributedStr.addAttributes([NSAttributedString.Key.font : UIFont.init(name: "Roboto-Light", size: 13) ?? UIFont.systemFont(ofSize: 13)],
//                                            range:NSRange(location: splited.first!.count, length: splited.last!.count))
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
        selectIndex = indexPath.item
        selectedSection = indexPath.section
//        performSegue(withIdentifier: "sbpDetails", sender: self)
        performSegue(withIdentifier: "DepositsHistoryDetailsViewController", sender: self)
        
        
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

    }
}


extension DepositsHistoryViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    
    }
}
