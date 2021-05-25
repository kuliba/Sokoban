//
//  ListOperationViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 16.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

protocol ListOperationViewControllerProtocol {
    func backFromDismiss(value: String?, key: String?, index: Int?, valueKey: String, fieldEmpty: Bool, segueId: String, listInputs: [ListInput?], parameters:[Additional])
}

class ListOperationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
   
    var titleText: String?
    var operationList: [OperationsDetails]? = []
    var listInput: ListInput?
    var data: [AnywayPaymentInputs?] = [] {
        didSet{
            activityIndicator.stopAnimating()
        }
    }
    var listArray: [[String]]?
    var listFiltered = [[String]]()
    var segueId: Int?
    var parameters: [Additional]? = []
    var lastParameters: [Additional]? = []
    var puref: String?
    var variableTransferValue: String?
    var dataFromContact: String?
    var country: [String:String] = [:]{
        didSet{
            country = country.filter({$0.key != ""})
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var mainViewController: ContactViewController?
    var searching: Bool?
    
    var item = 0

    
    func setParameters(value: String?, key: String?){
//        var parametersList: [Additional] = []
        
        self.item = 0
        if !data.isEmpty{
            let parameterItem = Additional(fieldid: item, fieldname: data[0]?.data?.listInputs?[self.segueId ?? 0].id, fieldvalue: key)
            self.parameters?.append(parameterItem)
        } else {
            let parameterItem = Additional(fieldid: item, fieldname: listInput?.id, fieldvalue: value)
            self.parameters?.append(parameterItem)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicator.startAnimation()
        tableView.isUserInteractionEnabled = false
        searchBar.isUserInteractionEnabled = false
        if listInput != nil, titleText != "Наименование (или часть наименования) города", titleText != "Наименование Банка" {
            setParameters(value: searchBar.text, key: nil)
            NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue ?? "")", puref: puref) { [self] (success, data, errorMessage) in
                
                if success{
                    NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
        //                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
                        if errorMessage == nil{
            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: parameters) {  (success, data, errorMessage) in
                if success ?? false{
                    
                    self.data = data
                    activityIndicator.stopAnimating()
                    tableView.isUserInteractionEnabled = true
                    searchBar.isUserInteractionEnabled = true
//                    print(dataClean2)
                    
//                    var astr = data[0]?.data?.listInputs?[0].dataType?
//                        .components(separatedBy: ";")
//                        .reduce([String: String]()) {
//                            aggregate, element in
//                            var elements = element.components(separatedBy: "=")
//                            if elements.count < 2 {
//                                elements.insert("N/A", at: 0)
//                            }
//                            return  [elements[0]:elements[1]]
//                        }
                    
                    
                    let keyValueStrings = data[0]?.data?.listInputs?[0].dataType?.components(separatedBy: ";")
                    let dictionary = keyValueStrings?.reduce([String: String]()) {
                        aggregate, element in

                        var newAggregate = aggregate

                        let elements = element.components(separatedBy: "=")
                        let key = elements[0]

                        // replace nil with the value you want to use if there is no value
                        let value = (elements.count > 1) ? elements[1] : nil
                        newAggregate[key] = value

                        return newAggregate
                    }
                    
                    country = dictionary ?? [:]
                    tableView.reloadData()
                    
                    
                } else {
                    AlertService.shared.show(title: errorMessage, message: "", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: {_ in dismiss(animated: true, completion: nil)}, okCompletion: {_ in dismiss(animated: true, completion: nil)})
                }
            }
                        }
                    }
                }
            }
            tableView.reloadData()
            if searchBar.text?.count != 0{
                searching = true
                tableView.reloadData()
            } else {
                searching = false
                listFiltered.removeAll()
                tableView.reloadData()
            }
                            

        } else if  titleText == "Наименование (или часть наименования) города" || titleText == "Наименование Банка"  {
            activityIndicator.startAnimation()
            setParameters(value: searchBar.text, key: nil)
            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: parameters) { [self]  (success, data, errorMessage) in
                if success ?? false{
                    
                    self.data = data
                    activityIndicator.stopAnimating()
                    tableView.isUserInteractionEnabled = true
                    searchBar.isUserInteractionEnabled = true
//                    print(dataClean2)
                    
//                    var astr = data[0]?.data?.listInputs?[0].dataType?
//                        .components(separatedBy: ";")
//                        .reduce([String: String]()) {
//                            aggregate, element in
//                            var elements = element.components(separatedBy: "=")
//                            if elements.count < 2 {
//                                elements.insert("N/A", at: 0)
//                            }
//                            return  [elements[0]:elements[1]]
//                        }
                    
                    
                    let keyValueStrings = data[0]?.data?.listInputs?[self.segueId ?? 0].dataType?.components(separatedBy: ";")
                    let dictionary = keyValueStrings?.reduce([String: String]()) {
                        aggregate, element in

                        var newAggregate = aggregate

                        let elements = element.components(separatedBy: "=")
                        let key = elements[0]

                        // replace nil with the value you want to use if there is no value
                        let value = (elements.count > 1) ? elements[1] : nil
                        newAggregate[key] = value

                        return newAggregate
                    }
                    
                    country = dictionary ?? [:]
                    tableView.reloadData()
                    
                    
                } else {
                    AlertService.shared.show(title: errorMessage, message: "", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: {_ in dismiss(animated: true, completion: nil)}, okCompletion: {_ in dismiss(animated: true, completion: nil)})
                }
            }

        }
    }
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if listInput != nil, titleText != "Наименование (или часть наименования) города" {
//            setParameters(value: searchBar.text, key: nil)
//            NetworkManager.shared().getAnywayPaymentBegin(numberCard: "\(variableTransferValue ?? "")", puref: puref) { [self] (success, data, errorMessage) in
//
//                if success{
//                    NetworkManager.shared().getAnywayPayment { [self] (success, data, errorMessage) in
//        //                    data.filter({$0 ?.data?.listInputs?[0].readOnly == false})
//                        if errorMessage == nil{
//            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: parameters) {  (success, data, errorMessage) in
//                if success ?? false{
//
//                    self.data = data
////                    print(dataClean2)
//
////                    var astr = data[0]?.data?.listInputs?[0].dataType?
////                        .components(separatedBy: ";")
////                        .reduce([String: String]()) {
////                            aggregate, element in
////                            var elements = element.components(separatedBy: "=")
////                            if elements.count < 2 {
////                                elements.insert("N/A", at: 0)
////                            }
////                            return  [elements[0]:elements[1]]
////                        }
//
//
//                    let keyValueStrings = data[0]?.data?.listInputs?[0].dataType?.components(separatedBy: ";")
//                    let dictionary = keyValueStrings?.reduce([String: String]()) {
//                        aggregate, element in
//
//                        var newAggregate = aggregate
//
//                        let elements = element.components(separatedBy: "=")
//                        let key = elements[0]
//
//                        // replace nil with the value you want to use if there is no value
//                        let value = (elements.count > 1) ? elements[1] : nil
//                        newAggregate[key] = value
//
//                        return newAggregate
//                    }
//
//                    country = dictionary ?? [:]
//                    tableView.reloadData()
//
//
//                }
//            }
//                        }
//                    }
//                }
//            }
//            tableView.reloadData()
//            if searchBar.text?.count != 0{
//                searching = true
//                tableView.reloadData()
//            } else {
//                searching = false
//                listFiltered.removeAll()
//                tableView.reloadData()
//            }
//
//
//        } else if  titleText == "Наименование (или часть наименования) города" {
//            setParameters(value: searchBar.text, key: nil)
//            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: parameters) { [self]  (success, data, errorMessage) in
//                if success ?? false{
//
//                    self.data = data
////                    print(dataClean2)
//
////                    var astr = data[0]?.data?.listInputs?[0].dataType?
////                        .components(separatedBy: ";")
////                        .reduce([String: String]()) {
////                            aggregate, element in
////                            var elements = element.components(separatedBy: "=")
////                            if elements.count < 2 {
////                                elements.insert("N/A", at: 0)
////                            }
////                            return  [elements[0]:elements[1]]
////                        }
//
//
//                    let keyValueStrings = data[0]?.data?.listInputs?[0].dataType?.components(separatedBy: ";")
//                    let dictionary = keyValueStrings?.reduce([String: String]()) {
//                        aggregate, element in
//
//                        var newAggregate = aggregate
//
//                        let elements = element.components(separatedBy: "=")
//                        let key = elements[0]
//
//                        // replace nil with the value you want to use if there is no value
//                        let value = (elements.count > 1) ? elements[1] : nil
//                        newAggregate[key] = value
//
//                        return newAggregate
//                    }
//
//                    country = dictionary ?? [:]
//                    tableView.reloadData()
//
//
//                }
//            }
//
//        }
//    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        activityIndicator.startAnimation()
            guard let listValue = self.listArray else {
                return
            }
            let listFilteredValue = (listArray?.filter({$0[1].lowercased().contains(searchText.lowercased())}))!
            listFiltered = listFilteredValue
            tableView.reloadData()
            if searchText.count != 0{
                searching = true
                tableView.reloadData()
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.stopAnimating()
                searching = false
                listFiltered.removeAll()
                tableView.reloadData()
            }
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        guard let listValue = self.listArray else {
//            return false
//        }
//        let listFilteredValue = (listArray?.filter({$0[1].contains(text)}))!
//        listFiltered = listFilteredValue
//        tableView.reloadData()
        
        return text != nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        parameters?.append(contentsOf: lastParameters ?? [])
        self.titleLabel.text = titleText
        configureTableView()
        searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    func base64Convert(base64String: String?) -> UIImage{
         if (base64String?.isEmpty)! {
             return #imageLiteral(resourceName: "no_image_found")
         }else {
             // !!! Separation part is optional, depends on your Base64String !!!
             let temp = base64String?.components(separatedBy: ",")
             let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
             let decodedimage = UIImage(data: dataDecoded)
             return decodedimage!
         }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listArray == nil, puref == nil {
        return operationList?.count ?? 0
        } else if searching ?? false, puref == nil {
            return listFiltered.count
        } else if country.count >= 1 {
            return country.count
        }else {
            return listArray?.count ?? 0
        }
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         tableView.register(UINib.init(nibName: "BanksTableViewCell", bundle: .main), forCellReuseIdentifier: "BanksCell")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BanksCell", for: indexPath) as? BanksTableViewCell else { return  UITableViewCell()}
        if listArray == nil, puref == nil{
            cell.label.text = operationList?[indexPath.item].nameList?[0].value
            cell.imageStar.isHidden = true
            cell.defaultBank.isHidden = true
          
            if operationList?[indexPath.item].logotypeList?.isEmpty ?? false {
                print("Pusto")
            } else {
            let imageHeader = operationList?[indexPath.item].logotypeList?[0].content
            let imageTry = base64Convert(base64String: imageHeader)
            cell.imageBank.image = UIImage(data: imageTry.pngData()!)
            }
        } else if searching ?? false, puref == nil {
            cell.label.text = listFiltered[indexPath.row][1]
            cell.imageStar.isHidden = true
            cell.imageBank.isHidden = true
            cell.defaultBank.isHidden = true
        } else if country.count >= 1{
            
            let dictItem = Array(country)[indexPath.row]
            let key = dictItem.key
            let value = dictItem.value
            cell.label.text = value
            cell.imageStar.isHidden = true
            cell.imageBank.isHidden = true
            cell.defaultBank.isHidden = true
        } else {
            cell.label.text = listArray?[indexPath.row][1]
            cell.imageStar.isHidden = true
            cell.imageBank.isHidden = true
            cell.defaultBank.isHidden = true
            
        }
        
        return cell
     }
    
    func configureTableView() {
        //First One I tried then later commented it out
        tableView.rowHeight = UITableView.automaticDimension
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: true)

        //Second One I tried
        let edgeInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        tableView.contentInset = edgeInset
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "selectEvent"{
              let operationDetails = segue.destination as! OperationDetailViewController
//
            } else {
              print("Error")

           }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching ?? false, puref == nil {
            self.mainViewController?.backFromDismiss(value: listFiltered[indexPath.row][1], key: listFiltered[indexPath.row][0], index: segueId, valueKey: listFiltered[indexPath.row][0], fieldEmpty: true, segueId: titleText!, listInputs: [], parameters: [] )
            mainViewController?.onUserAction(value: listFiltered[indexPath.row][1], key: listFiltered[indexPath.row][0])
            dismiss(animated: true, completion: nil)
        } else if puref != nil{
            activityIndicator.startAnimation()
            tableView.isUserInteractionEnabled = false
            let dictItem = Array(country)[indexPath.row]
            let key = dictItem.key
            let value = dictItem.value
            setParameters(value: value, key: key)
            NetworkManager.shared().getAnywayPaymentFinal(memberId: "contactAdress", amount: "10", numberPhone: "12", parameters: parameters) { [self]  (success, data, errorMessage) in
                if success ?? false{
                    self.mainViewController?.backFromDismiss(value: value, key: key, index: self.segueId, valueKey: key, fieldEmpty: true, segueId: titleText!, listInputs: data[0]?.data?.listInputs ?? [], parameters: parameters ?? [])
                    mainViewController?.onUserAction(value: value, key: value)
                    dismiss(animated: true, completion: nil)
                } else {
                    AlertService.shared.show(title: errorMessage, message: "", cancelButtonTitle: "Отмена", okButtonTitle: "Ок", cancelCompletion: {_ in dismiss(animated: true, completion: nil)}, okCompletion: {_ in dismiss(animated: true, completion: nil)})
                    tableView.isUserInteractionEnabled = true
                }
            }
           
        } else {
            self.mainViewController?.backFromDismiss(value: listArray?[indexPath.row][1], key: listArray?[indexPath.row][0], index: segueId, valueKey: listArray?[indexPath.row][0] ?? "", fieldEmpty: true, segueId: titleText!, listInputs: [], parameters: [])
            mainViewController?.onUserAction(value: listArray?[indexPath.row][1], key: listArray?[indexPath.row][0])
            dismiss(animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func separateString <K,V>(lhs: Dictionary<K,V>, rhs: Dictionary<K,V>) -> Dictionary<K,V> {
        var result = Dictionary<K,V>()

        for (key, value) in lhs {
            result[key] = value
        }
        for (key, value) in rhs {
            result[key] = value
        }

        return result
    }

}
