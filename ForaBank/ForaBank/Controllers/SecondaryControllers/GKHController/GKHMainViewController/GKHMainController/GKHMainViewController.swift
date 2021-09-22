//
//  GKHMViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import UIKit
import RealmSwift
import AVFoundation

class GKHMainViewController: UIViewController {
    
    // QR data
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var token: NotificationToken?
    
    public static func storyboardInstance() -> GKHMainViewController? {
        let storyboard = UIStoryboard(name: "GKHStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "GKHMain") as? GKHMainViewController
    }
    @IBOutlet weak var reqView: UIView!
    @IBOutlet weak var zayavka: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Загрузка истории операций
        AddHistoryList.add()
        
        reqView.add_CornerRadius(5)
        zayavka.add_CornerRadius(5)
        
        tableView.register(GKHHistoryHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.register(UINib(nibName: "GHKCell", bundle: nil), forCellReuseIdentifier: GHKCell.reuseId)
        
        setupNavBar()
//        operatorsList = realm?.objects(GKHOperatorsModel.self)
        observerRealm()
        operatorsList?.forEach({ op in
            if !op.parameterList.isEmpty {
            organization.append(op)
            }
        })
        
        NotificationCenter.default.addObserver(forName: .city, object: nil, queue: .none ) { [weak self] (value) in
            self?.searching = true
            let k = value.userInfo?["key"] as? String ?? ""
            self?.searchedOrganization = (self?.organization.filter { $0.region?.lowercased().prefix(k.count) ?? "" == k.lowercased() })!
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
    
}



