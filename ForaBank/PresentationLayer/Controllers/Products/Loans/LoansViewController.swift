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

    
    @IBOutlet weak var noLabelImage: UIImageView!
    
    var product: String?
    let transitionAnimator = LoansSegueAnimator()
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView! //tblProductApple

    @IBOutlet weak var activityInd: ActivityIndicatorView!

    let cellId = "DepositsObligationsCell"
    
    @IBOutlet weak var foraPreloader: RefreshView!
    @IBOutlet weak var LabelNoProduct: UILabel!
    let firstLoan: Loan = Loan(Amount: 100, currencyCode: "63", principalDebt: 100, userAnnual: 100, branchBrief: "BreanchBried", ownerAgentBrief: "Owner", accountNumber: "123", accountID: "123", customName: "123", accountList: "accountList", number: "number", blocked: false, DateValue: "DateValue", expirationDate: "expirationDate", availableBalance: 123, blockedMoney: 123, updatingDate: "updateDate", tariff: "tariff", loanID: 123, branch: "branch", maskedNumber: "maskNumber", currentInterestRate: 123, dateEnd: "dateEnd", isClosed: false, loanName: "loanName")
     let secondLoan: Loan = Loan(Amount: 100, currencyCode: "63", principalDebt: 100, userAnnual: 100, branchBrief: "BreanchBried", ownerAgentBrief: "Owner", accountNumber: "123", accountID: "123", customName: "123", accountList: "accountList", number: "number", blocked: false, DateValue: "DateValue", expirationDate: "expirationDate", availableBalance: 123, blockedMoney: 123, updatingDate: "updateDate", tariff: "tariff", loanID: 123, branch: "branch", maskedNumber: "maskNumber", currentInterestRate: 123, dateEnd: "dateEnd", isClosed: false, loanName: "loanName")
    
  var refreshView: RefreshView!
     
     var tableViewRefreshControl: UIRefreshControl = {
         let refreshControl = UIRefreshControl()
         refreshControl.backgroundColor = .clear
         refreshControl.tintColor = .clear
         refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
         return refreshControl
     }()
     
     
    @IBAction func backButtonClicked(_ sender: Any) {
  view.endEditing(true)
     self.navigationController?.popViewController(animated: true)
     if navigationController == nil {
         dismiss(animated: true, completion: nil)
     }
    
    }
  
    
    
     func prepareUI() {
         // Adding 'tableViewRefreshControl' to tableView
         tableView.refreshControl = tableViewRefreshControl
         // Getting the nib from bundle
         getRefereshView()
     }
     
     @objc func refreshTableView() {
           refreshView.startAnimation()
      NetworkManager.shared().getLoans { (success, loans) in
                 if success {
                     self.loan = loans ?? []
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
        
    var loan = [Loan]() {
        didSet {
//            loan.append(firstLoan)
//            loan.append(secondLoan)
            tableView.reloadData()
            foraPreloader.isHidden = true
            hiddenAccount()
            
        }
    }
    func hiddenAccount(){
        if loan.count == (0) {
            LabelNoProduct.isHidden = false
        }
    }    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        foraPreloader.startAnimation()
        setUpTableView()
        LabelNoProduct.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .white
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = noLabelImage.bounds
        noLabelImage.addSubview(blurredEffectView)
        prepareUI()
        
        self.notifications() //ставим уведомления
    }
    
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (loan.count == 0) {
            foraPreloader.startAnimation()
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoansDetailsViewController {
            destination.loan = loan[(tableView.indexPathForSelectedRow?.row)!]
        }

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLoansVC()
    }
    
    private func getLoansVC(){
        NetworkManager.shared().getLoans { (success, loans) in
            if success {
                self.loan = loans ?? []
            }
        }
    }
 

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if let selectedRow = tableView.indexPathForSelectedRow {
//            //tableView.deselectRow(at: selectedRow, animated: false)
//            performSegue(withIdentifier: "LoansDetailsViewController", sender: nil)
//
//        }
//
//
//    }



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

        cell.titleLabel.text = (loan[indexPath.row].customName == nil) ? "\((loan[indexPath.row].number)!)":"\((loan[indexPath.row].customName)!)"
        cell.currently.text = loan[indexPath.row].currencyCode
        cell.subTitleLabel.text = maskSum(sum: loan[indexPath.row].userAnnual!)
        cell.descriptionLabel.text = maskSum(sum: loan[indexPath.row].principalDebt!)
        cell.bottomSeparatorView.isHidden = indexPath.row == loan.endIndex - 1

        return cell
    }




    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToDepositAction = UITableViewRowAction(style: .normal, title: "Пополнить счет") { [weak self] action, indexPath in
            self?.presentPaymentDetailsViewController()
        }
        addToDepositAction.backgroundColor = UIColor(red: 26 / 255, green: 188 / 255, blue: 156 / 255, alpha: 1)
        return [addToDepositAction]
    }



}

// MARK: - Private methods
private extension LoansViewController {
    func presentPaymentDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsSuccessViewController {
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

//MARK: Notification
private extension LoansViewController{
    
    @objc func updateTableViewLoans(notification: Notification){
        getLoansVC()
    }
    
    private func notifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewLoans), name: NSNotification.Name(rawValue: "updateProductNameLoan"), object: nil)
    }
}
