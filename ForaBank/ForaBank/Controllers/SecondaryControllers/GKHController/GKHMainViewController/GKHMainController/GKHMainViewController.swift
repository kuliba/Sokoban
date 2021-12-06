//
//  GKHMViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import UIKit
import RealmSwift
import AVFoundation

class GKHMainViewController: UIViewController, UITableViewDelegate {
    
    public static func storyboardInstance() -> GKHMainViewController? {
        let storyboard = UIStoryboard(name: "GKHStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "GKHMain") as? GKHMainViewController
    }
    
    // QR data
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var token: NotificationToken?
//    weak var delegate: GKHDelegate?
    // Тип оператора (одношаговый или многошаговый)
    var operatorType: Bool?
    
    @IBOutlet weak var reqView: UIView!
    @IBOutlet weak var zayavka: UIView!
    @IBOutlet weak var historyView: UIView!
    
    var alertController: UIAlertController?
    
    func changeTitle(_ text: String) {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.setTitle(title: text, subtitle: "")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    var searching = false
    let searchController = UISearchController(searchResultsController: nil)
    var searchingText = ""
    
    var organization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searchedOrganization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    var operatorsList: Results<GKHOperatorsModel>? = nil
    
    lazy var realm = try? Realm()
    let history = GKHHistoryHeaderView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        history.frame = historyView.frame
        historyView.addSubview(history)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.isNavigationBarHidden = false
        
        /// Загрузка истории операций
        AddHistoryList.add()
        
        reqView.add_CornerRadius(5)
        zayavka.add_CornerRadius(5)
        
        tableView.register(UINib(nibName: "GHKCell", bundle: nil), forCellReuseIdentifier: GHKCell.reuseId)
        
        setupNavBar()
        observerRealm()
        operatorsList?.forEach({ op in
            if !op.parameterList.isEmpty && op.parentCode?.contains(GlobalModule.UTILITIES_CODE) ?? false {
                organization.append(op)
                self.operators = op
            }
        })
        
        NotificationCenter.default.addObserver(forName: .city, object: nil, queue: .none ) { [weak self] (value) in
            self?.searching = true
            let k = value.userInfo?["key"] as? String ?? ""
            self?.searchedOrganization = (self?.organization.filter { $0.region?.lowercased().prefix(k.count) ?? "" == k.lowercased() })!
            self?.navigationItem.titleView = self?.setTitle(title: k, subtitle: "")
        }
        
        history.cellData = { [weak self] _ , model in
            self?.qrData = ["История": ""]
            self?.operators = model
            self?.defineOperatorType(self?.operators?.puref ?? "") { [weak self] value in
                self?.operatorType = value
                DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "input", sender: self)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func checkCameraAccess(isAllowed: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            // Доступ к камере не был дан
            isAllowed(false)
        case .restricted:
            isAllowed(false)
        case .authorized:
            // Есть разрешение на доступ к камере
            isAllowed(true)
        case .notDetermined:
            // Первый запрос на доступ к камере
            AVCaptureDevice.requestAccess(for: .video) { isAllowed($0) }
        @unknown default:
            print()
        }
    }
    
    @IBAction func gkhMain(_ unwindSegue: UIStoryboardSegue) {}
    
    deinit {
        print("GKH Deinit")
    }
    
}



