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
    func sendValue( value : String)
}

class SearchBanksViewController: UIViewController {

    var delegate:ModalViewControllerDelegate?

    var searchActive : Bool = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var banks: [CardBank]? = nil
    var searchBank = [CardBank]()
    var banksLogo = UIImage(named: "banks-logos")
    var searching = false
    var SBPbankDefault = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "BanksTableViewCell", bundle: nil), forCellReuseIdentifier: "BanksCell")

            
                if let banksAsset = NSDataAsset(name: "banks") {
                    let banksData = banksAsset.data
                    let decoder = JSONDecoder()

                    if let banks = try? decoder.decode(CardBanks.self, from: banksData) {
                        self.banks = banks.banks
        //                for b in banks.banks {
        //                    print(b)

        //                }
                    } else {
                        print("banks decoding failed")
                    }
                }
    }

}


extension SearchBanksViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return banks!.count
        } else {
            return banks!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BanksCell", for: indexPath) as! BanksTableViewCell
        if searching{
            cell.label.text = banks![indexPath.row].name

        } else {
            cell.label.text = banks![indexPath.row].name
        }
        let imageArray = ["ru-binbank", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars", "ru-akbars"]
        var logoImage: [UIImage] = [
            UIImage(named: "ru-binbank")!,
            UIImage(named: "ru-binbank")!,
            UIImage(named: "ru-alfa")!,
            UIImage(named: "ru-atb")!,
            UIImage(named: "ru-avangard")!,
            UIImage(named: "ru-binbank")!,
            UIImage(named: "ru-ceb")!,
            UIImage(named: "ru-cetelem")!,
            UIImage(named: "ru-citi")!,
            UIImage(named: "ru-globex")!,
            UIImage(named: "ru-gpb")!,
            UIImage(named: "ru-hcf")!,
            UIImage(named: "ru-jugra")!,
            UIImage(named: "ru-mib")!,
            UIImage(named: "ru-mkb")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            UIImage(named: "ru-akbars")!,
            

        ]
        cell.label.text = banks![indexPath.row].name
        cell.imageBank.image = logoImage[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if !SBPbankDefault{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let scoreVC = storyboard?.instantiateViewController(withIdentifier: "SBPViewController") as! SBPViewController
            print(banks![indexPath.row].name!)
            scoreVC.bankName = banks![indexPath.row].name!
            delegate?.sendValue(value: banks![indexPath.row].name!)
            
        }else{
            //тут сохраняем банк по умолчанию
            guard let bankName = banks?[indexPath.row].name else {
                print("Не удалось сохранить СБП банк по умолчанию")
                return
            }
            UserDefaults.standard.set(bankName, forKey: "SPBBankDefault") //сохраняем по стандарту
            NotificationCenter.default.post(name: .init(rawValue: "SPBSaveBankDefault"), object: nil) //посылаем уведомление
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

extension SearchBanksViewController: UISearchBarDelegate{
     
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            searchBank = banks!
            tableView.reloadData()
            return
        }
        
        banks = (banks?.filter({ (banks) -> Bool in
            (banks.name?.lowercased().contains(searchText.lowercased()))!
        }))!
        searching = false

        tableView.reloadData()
    }

    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
          searchActive = true;
      }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
          searchActive = false;
      }

    private func searchBarCancelButtonClicked(searchBar: UISearchBar) {
          searchActive = false;
      }

    private func searchBarSearchButtonClicked(searchBar: UISearchBar) {
          searchActive = false;
      }
    
}
