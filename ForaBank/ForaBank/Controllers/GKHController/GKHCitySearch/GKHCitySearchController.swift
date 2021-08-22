//
//  GKHCitySearchController.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.08.2021.
//

import UIKit
import RealmSwift

class GKHCitySearchController: UIViewController {
    
    var operatorsList: Results<GKHOperatorsModel>? = nil
    
    var searchText = ""
    
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
    
    var searching = false
    
    lazy var realm = try? Realm()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        operatorsList?.forEach({ op in
            organization.append(op)
        })
        textField.delegate = self
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        if let vc = GKHMainViewController.storyboardInstance() {
            dismiss(animated: true, completion: {
                if self.searching {
                    NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key" : self.searchText])
                } else {
                    if self.searchText != "" {
                        NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key" : self.searchText])
                    }
                    
                }
//                vc.changeTitle(self.searchText)
//                vc.searching = true
//                if self.searchText != "" {
//                    vc.searchingText = self.searchText
//                }
            })
        }
    }
    
}

extension GKHCitySearchController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            searchedOrganization = organization.filter { $0.region?.lowercased().prefix(updatedText.count) ?? "" == updatedText.lowercased() }
            searchText = updatedText
            searching = true
        }
        return true
    }
    
}
