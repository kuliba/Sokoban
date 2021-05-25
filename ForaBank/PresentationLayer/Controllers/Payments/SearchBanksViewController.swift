//
//  SearchBanksViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.04.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate
{
    func sendValue(_ value : String?,_ image: String?,_ backgroundColor: String?, memberId: String?, defaultBank: Bool?)
    
}

class SearchBanksViewController: UIViewController {

    var delegate:ModalViewControllerDelegate?
    var idDefaultBank = String()
    var searchActive : Bool = false
    var activityIndicator = ActivityIndicatorView()
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView?
    var bankList:[BLBankList]?{
        didSet{
            self.tableView?.reloadData()
        }
    }
    var banks: [BLBankList]? = nil
    var searchBank:[BLBankList]? = nil
    var banksLogo = UIImage(named: "banks-logos")
    var searching = false
    var SBPbankDefault = false
    
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var headerView: UIView!
    var defaultBank: CardBank = CardBank(name: "ПромсвязьБанк", nameEn: "nameEn ", alias: "ru-psb", backgroundColor: "#c5cfef", backgroundColors: ["String"], textColor: "black", prefixes: ["prefiex"], logoStyle: "style", backgroundLightness: "light")
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar?.tintColor = .black
        view.backgroundColor = .white
        tableView?.backgroundColor = .white
//        bankList?.data?.sorted(by: {})
        activityIndicator.setUpAnimation()
        activityIndicator.startAnimation()
        NetworkManager.shared().findBankList { (success, bankList, errorMessage) in
//            self.bankList = bankList
            let defaultBank = bankList?.data?.filter {$0.id == self.idDefaultBank}
            
           let sortedArrayOfBanks = bankList?.data?.sorted(by: { (bankList, sortedBanks) -> Bool in
            if defaultBank?.count ?? 0 > 0{
                return bankList.memberID ?? "" == defaultBank?[0].memberID ?? ""
            } else {
                return bankList.memberNameRus?.lowercased() ?? "" < bankList.memberNameRus?.lowercased() ?? ""
            }
            })
            self.bankList = [BLBankList(data: sortedArrayOfBanks, errorMessage: "nil", result: "OK")]
            self.bankList?[0].data = self.bankList?[0].data?.filter({$0.memberID != "100000000217"})
            self.bankList?[0].data?.sort(by: { (a, i) -> Bool in
                let sorted = a.memberNameRus?.lowercased() ?? "" < i.memberNameRus?.lowercased() ?? ""
                return sorted
            })
            
        }
        let navigationController = UINavigationController()
//        navigationController.navigationBar.backgroundColor = UIColor(hexFromString: "EA4644")!
         navigationController.topViewController?.title = "Контакты"
         navigationController.title = "Контакты"
         navigationController.navigationBar.tintColor = .white
        
            self.searchBar?.isTranslucent = false
            self.searchBar?.backgroundImage = UIImage()
        
//        view.backgroundColor = UIColor(hexFromString: "EA4644")!
//        self.headerView.backgroundColor = UIColor(hexFromString: "EA4644")
        if let banksAsset = NSDataAsset(name: "banks") {
                    let banksData = banksAsset.data
                    let decoder = JSONDecoder()

                    if let banks = try? decoder.decode(CardBanks.self, from: banksData) {
//                        self.banks = banks.banks
        //                for b in banks.banks {
        //                    print(b)

        //                }
                    } else {
                        print("banks decoding failed")
                    }
                }
//        
//        banks?.append(defaultBank)
//        banks?.insert(defaultBank, at: 0)

    }

}


extension SearchBanksViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            let banksNonFora = self.searchBank?[0].data?.filter({$0.memberID != "100000000217"})
            return banksNonFora?.count ?? 0
        } else {
            let banksNonFora = self.bankList?[0].data?.filter({$0.memberID != "100000000217"})
            return banksNonFora?.count ?? 0
        }
    }
    

    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib.init(nibName: "BanksTableViewCell", bundle: .main), forCellReuseIdentifier: "BanksCell")
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "BanksCell", for: indexPath) as! BanksTableViewCell
        cell.imageBank.isHidden = false
        
//        cell.imageBank.image = UIImage(named: "100000000001")
        if searching{
            cell.label.text = searchBank?[0].data?[indexPath.item].memberNameRus
            cell.imageBank.image = UIImage(named: "\(searchBank?[0].data?[indexPath.item].memberID ?? "")")
        } else {
            cell.imageBank.image = UIImage(named: "\(bankList?[0].data?[indexPath.item].memberID ?? "")")
            cell.label.text = bankList?[0].data?[indexPath.item].memberNameRus
        }

        if bankList?[0].data?[indexPath.row].memberID == self.idDefaultBank{
            cell.imageStar.isHidden = false
            cell.defaultBank.isHidden = false
        } else{
            cell.imageStar.isHidden = true
            cell.defaultBank.isHidden = true
        }
//        cell.label.text = bankList?[0].data?[indexPath.row].memberNameRus
//        cell.imageView?.frame =
//        cell.imageBank.image = UIImage(named: "question")
//        cell.imageBank.backgroundColor = UIColor(hexFromString: "#ffffff")
        cell.imageBank.layer.cornerRadius = cell.imageBank.frame.size.width/2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching{
            
            delegate?.sendValue(searchBank?[0].data?[indexPath.item].memberNameRus, searchBank?[0].data?[indexPath.item].memberID, "#ffffff", memberId: searchBank?[0].data?[indexPath.item].memberID, defaultBank: indexPath.row == 0)
            //тут сохраняем банк по умолчанию
//            guard let bankName = banks?[indexPath.row].name else {
//                print("Не удалось сохранить СБП банк по умолчанию")
//                return
//            }
//            UserDefaults.standard.set(bankName, forKey: "SPBBankDefault") //сохраняем по стандарту
            NotificationCenter.default.post(name: .init(rawValue: "SPBSaveBankDefault"), object: nil) //посылаем уведомление
        }else if !SBPbankDefault{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let scoreVC = storyboard?.instantiateViewController(withIdentifier: "SBPViewController") as! SBPViewController
//            print(banks![indexPath.row].name!)
            scoreVC.bankName = bankList?[0].data?[indexPath.row].memberNameRus ?? "Банк не выбран"
            delegate?.sendValue(bankList?[0].data?[indexPath.row].memberNameRus, bankList?[0].data?[indexPath.row].memberID, "#ffffff", memberId: bankList?[0].data?[indexPath.row].memberID, defaultBank: indexPath.row == 0)
            
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchBanksViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NetworkManager.shared().findBankList { (success, bankList, errorMessage) in
//            self.bankList = bankList
            let defaultBank = bankList?.data?.filter {$0.id == self.idDefaultBank}
            
           let sortedArrayOfBanks = bankList?.data?.sorted(by: { (bankList, sortedBanks) -> Bool in
            if defaultBank?.count ?? 0 > 0{
                return bankList.memberID ?? "" == defaultBank?[0].memberID ?? ""
            } else {
                return bankList.memberNameRus?.lowercased() ?? "" < bankList.memberNameRus?.lowercased() ?? ""
            }
            })
            self.bankList = [BLBankList(data: sortedArrayOfBanks, errorMessage: "nil", result: "OK")]
            self.bankList?[0].data?.sort(by: { (a, i) -> Bool in
                let sorted = a.memberNameRus?.lowercased() ?? "" < i.memberNameRus?.lowercased() ?? ""
                return sorted
            })
            self.bankList?[0].data = self.bankList?[0].data?.filter({$0.memberID != "100000000217"})
            
        }

        
//        searchBank?.append(contentsOf: bankList ?? [])
        let filteredBanks = bankList
        searchBank = bankList
        self.searchBank?[0].data = searchBank?[0].data?.filter({ ($0.memberNameRus?.lowercased().hasPrefix(searchText.lowercased()) ?? true)})
        if searchText == ""{
            searching = false
            NetworkManager.shared().findBankList { (success, bankList, errorMessage) in
    //            self.bankList = bankList
                let defaultBank = bankList?.data?.filter {$0.id == self.idDefaultBank}
                
               let sortedArrayOfBanks = bankList?.data?.sorted(by: { (bankList, sortedBanks) -> Bool in
                if defaultBank?.count ?? 0 > 0{
                    return bankList.memberID ?? "" == defaultBank?[0].memberID ?? ""
                } else {
                    return bankList.memberNameRus?.lowercased() ?? "" < bankList.memberNameRus?.lowercased() ?? ""
                }
                })
                self.bankList = [BLBankList(data: sortedArrayOfBanks, errorMessage: "nil", result: "OK")]
                self.bankList?[0].data?.sort(by: { (a, i) -> Bool in
                    let sorted = a.memberNameRus?.lowercased() ?? "" < i.memberNameRus?.lowercased() ?? ""
                    return sorted
                })
                self.bankList?[0].data = self.bankList?[0].data?.filter({$0.memberID != "100000000217"})
                
            }
            tableView?.reloadData()

        } else {
            searching = true
            tableView?.reloadData()

        }
  

        tableView?.reloadData()
    }

    internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
          searchActive = true;
      }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
          searchActive = false;
      }

    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
          searchActive = false;
      }

    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          searchActive = false;
      }

}
