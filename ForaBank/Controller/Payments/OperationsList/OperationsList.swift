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


class OperationList: UIViewController, StoreSubscriber {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var containerView: RoundedEdgeView!
    
    let templateCellId = "PaymentTemplateCell"
    let paymentCellId = "PaymentCell"
    

   
    var payments = [Operations]() 
    
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
extension OperationList: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let s = (isSignedUp == true) ? indexPath.section : indexPath.section + 1
            
            let section = payments[s]
            let index = indexPath.row
            
          guard let serviceCell = tableView.dequeueReusableCell(withIdentifier: paymentCellId, for: indexPath) as? PaymentCell  else {
            fatalError()
            
            }
                
        serviceCell.titleLabel.text = payments[index].name
        
                
                return serviceCell
    }
    
    
    
}

// MARK: - Private methods
private extension OperationList {
    
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
