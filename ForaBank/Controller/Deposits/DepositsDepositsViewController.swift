//
//  DepositsDepositsViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 06/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import Alamofire

class DepositsDepositsViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    
    let transitionAnimator = DepositsDepositsSegueAnimator()
    
    let cellId = "DepositsDepositCell"
    
    
    
    private let baseURLString: String = "https://git.briginvest.ru/dbo/api/v2/"
    private var datadep = [Depos]()
    private var datedTransactions = [DatedTransactions]()
    
    

    func getBonds(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Depos    ]?) -> Void) {
        datadep = [Depos]()
        let url = baseURLString + "rest/getDepositList"
        Alamofire.request(url, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: MultiRange(200..<300, 401..<402))
            .validate(contentType: ["application/json"])
            .responseJSON { [unowned self] response in
                
                if let json = response.result.value as? Dictionary<String, Any> ,
                    let errorMessage = json["errorMessage"] as? String {
                    print("\(errorMessage) \(self)")
                    completionHandler(false, self.datadep)
                    return
                }
                
                switch response.result {
                case .success:
                    if let json = response.result.value as? Dictionary<String, Any>,
                        let data = json["data"] as? Array<Any> {
                        for cardData in data {
                            if let cardData = cardData as? Dictionary<String, Any>,
                                let original = cardData["original"] as? Dictionary<String, Any> {
                                let customName = cardData["customName"] as? String
                                let title = original["ownerAgentBrief"] as? String
                                let balance = original["balance"] as? String
                                let accountID = original["number"] as? String
                                let number = original["number"] as? String
                                let availableBalance = original["balance"] as? Double
                                let branch = original["branch"] as? String
                                let id = original["cardID"] as? String
                                var expirationDate: Date? = nil
                                if let validThru = original["validThru"] as? TimeInterval {
                                    expirationDate = Date(timeIntervalSince1970: (validThru/1000))
                                }
                                let datadep = Depos( paypass: nil,
                                                 title: title,
                                                 balance:balance,
                                                 accountID: accountID,
                                                 customName: customName,
                                                 number: number,
                                                 startDate: nil,
                                                 expirationDate: expirationDate,
                                                 availableBalance: availableBalance,
                                                 blockedMoney: nil,
                                                 updatingDate: nil,
                                                 tariff: nil,
                                                 id: id,
                                                 branch: branch)
                                self.datadep.append(datadep)
                            }
                        }
                        completionHandler(true, self.datadep)
                    } else {
                        print("rest/getDepositList cant parse json \(String(describing: response.result.value))")
                        completionHandler(false, self.datadep)
                    }
                    
                case .failure(let error):
                    print("rest/getDepositList \(error) \(self)")
                    completionHandler(false, self.datadep)
                }
        }
    }
    
    
    
  
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
        return datadep.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsDepositCell else {
            fatalError()
        }
        
        cell.titleLabel.text = datadep[0].title
        cell.subTitleLabel.text = datadep[0].accountID
        cell.amountLabel.text = datadep[2].balance
        cell.bottomSeparatorView.isHidden = indexPath.row == datadep.endIndex - 1
        
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
