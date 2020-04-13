/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import FlexiblePageControl
import Hero

class DepositsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButton(_ sender: Any) {
         let alertVC = UIAlertController(title: "Функционал недоступен", message: "Функционал временно недоступен", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
               alertVC.addAction(okAction)
               show(alertVC, sender: self)
     }
    @IBOutlet weak var ForaIndicator: RefreshView!
    
    @IBOutlet weak var tableView: CustomTableView!
    var color2: UIColor = .black

    let cellId = "DepositsObligationsCell"

    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    //    let data_ = [
//        ["deposits_obligations_afk",
//         "АФК-Система, Sistema-19",
//         "Предложений по бумаге нет",
//         "8,83%"
//        ],
//
//        ["deposits_obligations_gazprom",
//         "Газпром, GAZ-37",
//         "Предложений по бумаге нет",
//         "5,37%"
//        ],
//
//        ["deposits_obligations_veb",
//         "ВЭБ, VEB-23",
//         "Предложений по бумаге нет",
//         "4,04%"
//        ],
//
//        ["deposits_obligations_rosnef",
//         "Роснэфть, RosNef-22",
//         "Гипермаркет",
//         "3,84%"
//        ]
//    ]
    @IBOutlet weak var LabelNoProduct: UILabel!

    
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
        
        NetworkManager.shared().getBonds { (success, deposits) in
                  if success {
                      self.deposits = deposits ?? []
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
       
    
    var deposits = [Deposit]() {
        didSet {
            tableView.reloadData()
            ForaIndicator.isHidden = true
            hiddenAccount()

        }
    }
    func hiddenAccount() {
        if deposits.count == 0 {
            LabelNoProduct.isHidden = false
        }else{
            LabelNoProduct.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (deposits.count == 0) {
            ForaIndicator.startAnimation()
        }
    }




    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ForaIndicator.startAnimation()
        setUpTableView()
        LabelNoProduct.isHidden = true
        prepareUI()
        tableView.backgroundColor = .white
        
        self.notifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getBondsVC()
    }
    
    private func getBondsVC(){
        NetworkManager.shared().getBonds { (success, deposits) in
            if success {
                self.deposits = deposits ?? []
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DepositDetailsViewController {
            destination.deposit = deposits[(tableView.indexPathForSelectedRow?.row)!]
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        if let selectedRow = tableView.indexPathForSelectedRow {
//            // tableView.deselectRow(at: selectedRow, animated: false)
//        }
    }
}

// MARK: - TableView DataSource Delegate

extension DepositsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deposits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? DepositsObligationsCell else {
            fatalError()
        }

        cell.titleLabel.text = (deposits[indexPath.row].customName == nil) ? "\((deposits[indexPath.row].depositProductName)!)":"\((deposits[indexPath.row].customName)!)"
        cell.subTitleLabel.text = maskedCardNumber(number: deposits[indexPath.row].accountNumber!, separator: " ")
        cell.descriptionLabel.text = maskSum(sum: deposits[indexPath.row].balance!)
        cell.currently.text = deposits[indexPath.row].currencyCode

        return cell
    }

    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let doneButton = UIButton(type: .system)
      
            doneButton.addTarget(nil, action: #selector(CarouselViewController.createProductButtonClicked), for: .touchUpInside)

            
        doneButton.frame = CGRect(x: footerView.frame.minX, y: screenHeight - (screenHeight/4.5), width: footerView.frame.width, height: 45)

            doneButton.setTitle("Открыть продукт", for: .normal)

            doneButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)

            doneButton.setTitleColor(.black, for: [])
     

            doneButton.layer.borderWidth = 0.5
            doneButton.layer.borderColor = UIColor(red: 211 / 255, green: 211 / 255, blue: 211 / 255, alpha: 1).cgColor

            doneButton.layer.cornerRadius = doneButton.frame.height / 2

            view.addSubview(doneButton)
            return footerView
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DepositDetailsViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }
}

// MARK: - Private methods
private extension DepositsViewController {
    func presentPaymentDetailsViewController() {
        if let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsSuccessViewController {
            present(vc, animated: true, completion: nil)
        }
    }
}


// MARK: - Private methods
private extension DepositsViewController {

    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        setAutomaticRowHeight()
        registerNibCell()
    }

    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setTableViewContentInsets() {
        tableView.contentInset.top = 15
    }

    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }

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

//MARK: Notification
private extension DepositsViewController{
    
    @objc func updateTableViewLoans(notification: Notification){
        self.getBondsVC()
    }
    
    private func notifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewLoans), name: NSNotification.Name(rawValue: "updateProductNameDeposit"), object: nil)
    }
}
