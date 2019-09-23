/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import Hero
import ReSwift


class PaymentsViewController: UIViewController, StoreSubscriber {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    
    let templateCellId = "PaymentTemplateCell"
    let paymentCellId = "PaymentCell"
    

   
    var payments = [Operations]() {
        didSet {
            tableView.reloadData()
     
            
        }
    }
    private var isSignedUp: Bool? = nil {
        didSet {
            if isSignedUp != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        NetworkManager.shared().getPaymentsList { (success, payments) in
            if success {
                self.payments = payments ?? []
            }
        }
        
        containerView.hero.modifiers = [
            HeroModifier.duration(0.3),
            HeroModifier.delay(0.2),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.beginWith([HeroModifier.opacity(1)]),
            HeroModifier.duration(0.5),
            //            HeroModifier.delay(0.2),
            HeroModifier.opacity(0)
        ]
        containerView.hero.id = "content"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        containerView.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.opacity(0)
        ]
        containerView.hero.id = "content"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
    }
    
    func newState(state: State) {
        
    }
}

// MARK: - UITableView DataSource and Delegate
extension PaymentsViewController: UITableViewDataSource, UITableViewDelegate {
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let s = (isSignedUp == true) ? indexPath.section : indexPath.section+1
        
        let section = payments[s]
        let index = indexPath.row
        
      guard let serviceCell = tableView.dequeueReusableCell(withIdentifier: paymentCellId, for: indexPath) as? PaymentCell  else {
        fatalError()
        
        }
            
            serviceCell.titleLabel.text = payments[indexPath.row].name
    
            
            return serviceCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PaymentsDetailsViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! ServicesHeader
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.addSubview(headerCell)
        
        headerCell.titleLabel.text = {
            let s = (isSignedUp == true) ? section : section+1

            if s == 0 {
                return "Шаблоны"
            } else if s == 1 {
                return "Переводы"
            } else if s == 2 {
                return "Оплата услуг"
            } else {
                return ""
            }
        }()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isSignedUp == true && section == 0 {
            
            let footerView = UIView(frame: CGRect(x: tableView.frame.minX + 20, y: 0, width: tableView.frame.width - 40, height: 95))
            let doneButton = UIButton(frame: CGRect(x: footerView.frame.minX, y: footerView.frame.minY + 15, width: footerView.frame.width, height: 45))
            
            doneButton.setTitle("Создать шаблон", for: .normal)
            doneButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
            doneButton.setTitleColor(.black, for: [])
            doneButton.layer.borderWidth = 0.5
            doneButton.layer.borderColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
            doneButton.layer.cornerRadius = doneButton.frame.height / 2
            
            footerView.addSubview(doneButton)
            return footerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSignedUp == true && section == 0 {
            return 95
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Private methods
private extension PaymentsViewController {
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInsets()
        setAutomaticRowHeight()
        registerNibCell()
    }
    
    func setTableViewContentInsets() {
        tableView.contentInset.top = -10
    }
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func registerNibCell() {
        let nibTemplateCell = UINib(nibName: templateCellId, bundle: nil)
        tableView.register(nibTemplateCell, forCellReuseIdentifier: templateCellId)
        
        let nibTransferCellIdCell = UINib(nibName: paymentCellId, bundle: nil)
        tableView.register(nibTransferCellIdCell, forCellReuseIdentifier: paymentCellId)
    }
}
