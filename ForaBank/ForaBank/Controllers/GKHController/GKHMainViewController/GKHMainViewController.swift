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
    
    public static func storyboardInstance() -> GKHMainViewController? {
        let storyboard = UIStoryboard(name: "GKHStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "GKHMain") as? GKHMainViewController
    }
    
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
        
        tableView.register(UINib(nibName: "GHKCell", bundle: nil), forCellReuseIdentifier: GHKCell.reuseId)
        setupNavBar()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        operatorsList?.forEach({ op in
            organization.append(op)
        })
        
        NotificationCenter.default.addObserver(forName: .city, object: nil, queue: .none ) { [weak self] (value) in
            self?.searching = true
            let k = value.userInfo?["key"] as? String ?? ""
            self?.searchedOrganization = (self?.organization.filter { $0.region?.lowercased().prefix(k.count) ?? "" == k.lowercased() })!
        }
    }
    
    func doStringContainsNumber( _string : String) -> Bool{
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        return containsNumber
        
    }
    
    @IBAction func qrCodeButton(_ sender: UIButton) {
//        checkCameraAccess(isAllowed: {
//            if $0 {
//                    DispatchQueue.main.async {
//                        self.performSegue(withIdentifier: "qr", sender: nil)
//                    }
//            } else {
//                guard self.alertController == nil else {
//                        print("There is already an alert presented")
//                        return
//                    }
//                self.alertController = UIAlertController(title: "\(self.attention)", message: "\(self.attention_2)", preferredStyle: .alert)
//                    guard let alert = self.alertController else {
//                        return
//                    }
//                alert.addAction(UIAlertAction(title: "\(self.gotIt)", style: .default, handler: { (action) in
//                        self.alertController = nil
//                    }))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
//            }
//        })
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

