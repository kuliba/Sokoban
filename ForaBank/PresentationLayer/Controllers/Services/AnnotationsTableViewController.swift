/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import UIKit
import MapKit

class AnnotationsTableViewController: UITableViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var coordinations = CLLocationCoordinate2D()
    var annotations = [BankBranchAnnotation]() {
        didSet {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true) //скролим вверх(чтобы ячейка не смещалась)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        // для определения геолокации
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.tableFooterView = UIView()
        tableView.isPagingEnabled = true //позволяет уцентрить ячейку
    }

    @IBAction func actionCall(_ sender: Any) {
        // получаем индекс ячейки в которой нажата кнопка
        guard let indexPath = tableView.indexPathForRow(at: (sender as AnyObject).convert(CGPoint(),to: tableView)) else{return}
        var numberPhone = ""
        let cellNum = tableView.cellForRow(at: indexPath) // достаем ячейку
        if let cell = cellNum as? AnnotationTableViewCell {
            guard cell.phoneLabel.text != nil else{return} // получаем из нее телефон
            numberPhone = cell.phoneLabel.text!
        }
        // строка с двумя номерами
        if numberPhone.contains(";"){ // если в строке 2 номера, то создаем 2 вызова
            let arrayNumber = numberPhone.components(separatedBy: [";"])
            let numberPhoneReplace  = arrayNumber[0].replace(string: " ", replacement: "") // убираем пробелы
            guard let url = URL(string: "tel://\(numberPhoneReplace)") else{return}
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }else{ // если один
            let numberPhoneReplace  = numberPhone.replace(string: " ", replacement: "") // убираем пробелы
            guard let url = URL(string: "tel://\(numberPhoneReplace)") else{return}
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    
    @IBAction func actionRoute(_ sender: Any) {
        guard let indexPath = tableView.indexPathForRow(at: (sender as AnyObject).convert(CGPoint(),to: tableView)) else{return}
        let coordinates = CLLocationCoordinate2DMake(coordinations.latitude, coordinations.longitude) //геопозиция откуда
        let coondinateDest = annotations[indexPath.row].coordinate // геопозиция куда
        let source = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: coondinateDest))
        destination.name = annotations[indexPath.row].address
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return annotations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "annotationCell", for: indexPath)
       
        
        // Configure the cell...
        if let cell = cell as? AnnotationTableViewCell {
            cell.set(title: annotations[indexPath.row].title,
                     address: annotations[indexPath.row].address,
                     schedule: annotations[indexPath.row].schedule,
                     phone: annotations[indexPath.row].phone)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//MARK: Location
extension AnnotationsTableViewController{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        coordinations = locValue
    }
}
