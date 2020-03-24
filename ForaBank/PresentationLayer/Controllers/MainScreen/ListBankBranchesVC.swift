//
//  ListBankBranchesVC.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 24.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import MapKit

class ListBankBranchesVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableViewBran: UITableView!

    let locationManager = CLLocationManager()
    var coordinations = CLLocationCoordinate2D() //текущаяя геолокация
    var branches = [BankBranch](){ //список банков из json 
        didSet {
            tableViewBran.reloadData()
            tableViewBran.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true) //скролим вверх(чтобы ячейка не смещалась)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBankBranch()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        // Do any additional setup after loading the view.
    }
    
}

//MARK: Action
extension ListBankBranchesVC{
    
    @IBAction func actionCancelVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRoute(_ sender: Any) {
        guard let indexPath = tableViewBran.indexPathForRow(at: (sender as AnyObject).convert(CGPoint(),to: tableViewBran)) else{return}
        let coordinates = CLLocationCoordinate2DMake(coordinations.latitude, coordinations.longitude) //геопозиция откуда
        guard let latitudeB = branches[indexPath.row].latitude, let longitudeB = branches[indexPath.row].longitude else {
            return
        }
        let coondinateDest = CLLocationCoordinate2D(latitude: latitudeB, longitude: longitudeB) // геопозиция куда
        let source = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: coondinateDest))
        destination.name = branches[indexPath.row].address
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func actionCall(_ sender: Any) {
        // получаем индекс ячейки в которой нажата кнопка
        guard let indexPath = tableViewBran.indexPathForRow(at: (sender as AnyObject).convert(CGPoint(),to: tableViewBran)) else{return}
        var numberPhone = ""
        let cellNum = tableViewBran.cellForRow(at: indexPath) // достаем ячейку
        if let cell = cellNum as? AnnotationTableViewCell {
            guard cell.phoneLabel.text != nil else{return} // получаем из нее телефон
            numberPhone = cell.phoneLabel.text!
        }
        // строка с двумя номерами
        if numberPhone.contains(";") || numberPhone.contains(","){ // если в строке 2 номера, то создаем 2 вызова
            let arrayNumber = numberPhone.components(separatedBy: [";",","])
            callNumber(arrayNumber[0])
        }else{ // если один
            callNumber(numberPhone)
        }
    }
    
}

//MARK: Table View
extension ListBankBranchesVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height * 0.2
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return branches.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "annotationCell", for: indexPath)
       
        
        // Configure the cell...
        if let cell = cell as? AnnotationTableViewCell {
            cell.set(title: branches[indexPath.row].name,
                     address: branches[indexPath.row].address,
                     schedule: branches[indexPath.row].schedule,
                     phone: branches[indexPath.row].phone)
        }
        cell.layoutIfNeeded()
        return cell
    }
}

//MARK: Get Bank Branch
extension ListBankBranchesVC{
    private func getBankBranch(){
        //получаем местонахождения всех точек
        NetworkManager.shared().getBankBranches { [weak self](success, data, errorMessage) in
            if success{ // проверка на корректность данных
                let decoder = JSONDecoder()
                if let data = data{ //проверяем что данные есть
                    if let branches = try? decoder.decode(BankBranches.self, from: data){
                        self!.branches = branches.branches
                    } else {
                        print("bank branches decoding failed")
                    }
                }
            }
        }
    }
}

//MARK: Location
extension ListBankBranchesVC{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        coordinations = locValue
    }
}
