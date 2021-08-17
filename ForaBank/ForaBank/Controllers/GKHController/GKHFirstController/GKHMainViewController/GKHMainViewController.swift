//
//  GKHMViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import UIKit
import RealmSwift
import AVFoundation

class GKHMainViewController: UIViewController, UISearchBarDelegate {
    
    var alertController: UIAlertController?
    
    @IBOutlet weak var tableView: UITableView!
    var searching = false
    let searchController = UISearchController(searchResultsController: nil)
    
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
                self.tableView.reloadData()
            }
        }
    }
    
    var operatorsList: Results<GKHOperatorsModel>? = nil
    
    lazy var realm = try? Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "GHKCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: GHKCell.reuseId)
        setupNavBar()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.register(
                    GKHMainViewHeader.nib,
                    forHeaderFooterViewReuseIdentifier:
                        GKHMainViewHeader.reuseIdentifier
                )
        self.tableView.register(
                    GKHMainViewFooterView.nib,
                    forHeaderFooterViewReuseIdentifier:
                        GKHMainViewFooterView.reuseIdentifier
                )
        
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

