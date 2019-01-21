//
//  ServicesViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 01/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import MapKit
import Hero

class ServicesViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var annotationsInfoView: UIView!
    @IBOutlet weak var annotationsInfoHeight: NSLayoutConstraint!
    @IBOutlet weak var zoomOutButton: OnMapButton!
    @IBOutlet weak var zoomInButton: OnMapButton!
    @IBOutlet weak var focusButton: OnMapButton!
    @IBOutlet weak var containerView: RoundedEdgeView!
    
    var branches = [BankBranch]()
    var annotations = [BankBranchAnnotation]()
    let serviceCellId = "ServicesCell"
    let locationManager = CLLocationManager()
    var searchBar: ServicesSearchCell?
    var needFocus: Bool = true
    
    let data_ = [
        [
            Service(name: "Отделения",             description: "< 100м", iconName: "services_departments",    isPartner: false),
            Service(name: "Банкоматы",             description: "< 50м",  iconName: "services_atms",           isPartner: false),
            Service(name: "Платежные устройства",  description: "< 50м",  iconName: "services_paymentdevices", isPartner: false)
        ], [
            Service(name: "Такси",                 description: "от 90₽",  iconName: "services_taxi",          isPartner: true),
            Service(name: "Билеты в кино",         description: "от 350₽", iconName: "services_movietickets",  isPartner: true),
            Service(name: "Просмотр ТВ",           description: "от 199₽", iconName: "services_tv",            isPartner: true),
            Service(name: "Скидки в магазинах",    description: "до 80%",  iconName: "services_sales",         isPartner: true),
            Service(name: "Бронирование гостиниц", description: "до 30%",  iconName: "services_hotels",        isPartner: true),
            Service(name: "Ж/Д и авиабилеты",      description: "до 40%",  iconName: "services_tickets",       isPartner: true),
            Service(name: "Страховка",             description: "до 50%",  iconName: "services_insurance",     isPartner: true)
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        self.annotationsInfoHeight.constant = 0
        mapView.isHidden = true
        hero.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.hero.modifiers = [
            HeroModifier.duration(0.3),
            HeroModifier.delay(0.2),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.beginWith([HeroModifier.opacity(1)]),
            HeroModifier.duration(0.5),
            //            HeroModifier.delay(0.2),
            HeroModifier.opacity(0)
        ]
        view.hero.id = "view"
        containerView.hero.id = "content"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        containerView.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.translate(CGPoint(x: 0, y: view.frame.height))
        ]
        view.hero.modifiers = [
            HeroModifier.duration(0.5),
            HeroModifier.opacity(0)
        ]
        view.hero.id = "view"
        containerView.hero.id = "content"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
        containerView.hero.modifiers = nil
        containerView.hero.id = nil
        view.hero.modifiers = nil
        view.hero.id = nil
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        zoomMap(byFactor: 2)
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        zoomMap(byFactor: 0.5)
    }
    
    @IBAction func focusOnMe(_ sender: Any) {
        needFocus = true
        locationManager.requestLocation()
    }
}

// MARK: - UITableView DataSource and Delegate
extension ServicesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data_.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data_[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: serviceCellId, for: indexPath) as? ServicesCell else {
            fatalError()
        }
        
        cell.titleLabel.text = data_[indexPath.section][indexPath.row].name
        cell.additionalTitleLabel.text = data_[indexPath.section][indexPath.row].description
        cell.logoImageView.image = UIImage(named: data_[indexPath.section][indexPath.row].iconName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = UINib(nibName: "ServicesHeader", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? ServicesHeader else {
                return nil
        }
        headerCell.titleLabel.text = section == 0 ? "Услуги ФораБанка" : "Партнерские сервисы"
        
        let headerView = UIView(frame: headerCell.frame)
        headerView.backgroundColor = .clear
        headerView.addSubview(headerCell)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performSegue(withIdentifier: "", sender: indexPath.row)
    }
}

// MARK: - Private methods
private extension ServicesViewController {
    
    func setUpTableView() {
        setTableViewDelegateAndDataSource()
        setTableViewContentInset()
        setAutomaticRowHeight()
        registerNibCell()
        setSearchView()
    }
    
    func setTableViewDelegateAndDataSource() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setAutomaticRowHeight() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func registerNibCell() {
        let nibCell = UINib(nibName: serviceCellId, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: serviceCellId)
    }
    
    func setSearchView() {
        guard let searchCell = UINib(nibName: "ServicesSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? ServicesSearchCell else {
                return
        }
        searchCell.mapButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        let searchView = UIView(frame: searchCell.frame)
        searchView.addSubview(searchCell)
        tableView.tableHeaderView = searchView
    }
    
    func setTableViewContentInset() {
        tableView.contentInset.top = 30
    }
}

// MARK: - Map methods
extension ServicesViewController {
    
    @objc func showMap(sender: UIButton!) {
        tableView.isHidden = true
        mapView.isHidden = false
        zoomOutButton.isHidden = false
        zoomInButton.isHidden = false
//        focusButton.isHidden = false
        print("SHOW MAP \(mapView.subviews)")
        if searchBar != nil {
        } else if let searchBar = UINib(nibName: "ServicesSearchCell", bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as? ServicesSearchCell {
            searchBar.backgroundColor = nil
//            searchBar.frame.origin.x = 0
//            searchBar.frame.origin.y = 30
//            searchBar.frame.size.width = view.frame.width
//            searchBar.textField.backgroundColor = UIColor(red: 0.968522, green: 0.968688, blue: 0.968512, alpha: 1)
            searchBar.textField.backgroundColor = .white
            searchBar.textField.alpha = 1
            searchBar.textField.layer.cornerRadius = 3
            
            searchBar.textField.layer.shadowColor = UIColor.black.cgColor
            searchBar.textField.layer.shadowOffset = CGSize(width: 0, height: 3.0)
            searchBar.textField.layer.shadowOpacity = 0.12
            searchBar.textField.layer.shadowRadius = 6
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            mapView.addSubview(searchBar)
            mapView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sb]-0-|", options: [], metrics: nil, views: ["sb" : searchBar]))
            mapView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[sb(65)]", options: [], metrics: nil, views: ["sb" : searchBar]))
            searchBar.mapButton.setImage(UIImage(named: "icon_services_to_table"), for: .normal)
            searchBar.mapButton.addTarget(self, action: #selector(hideMap), for: .touchUpInside)
            searchBar.mapButton.backgroundColor = .white
            searchBar.mapButton.layer.cornerRadius = 5
            
            searchBar.mapButton.layer.shadowColor = UIColor.black.cgColor
            searchBar.mapButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
            searchBar.mapButton.layer.shadowOpacity = 0.12
            searchBar.mapButton.layer.shadowRadius = 6
            
//            let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
//            UIGraphicsBeginImageContext(rect.size)
//            let context = UIGraphicsGetCurrentContext()
//            
//            context?.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor)
//            context?.fill(rect)
//            
//            let image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            searchBar.mapButton.setBackgroundImage(image, for: .highlighted)
            self.searchBar = searchBar
        }
        
        mapView.delegate = self
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkLocationAuthorizationStatus()
        if annotations.count > 0 {
            return
        }
        if let branchesAsset = NSDataAsset(name: "bank_branches") {
            mapView.removeAnnotations(annotations)
            annotations = [BankBranchAnnotation]()
            let branchesData = branchesAsset.data
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            if let branches = try? decoder.decode(BankBranches.self, from: branchesData) {
                self.branches = branches.branches
                for b in self.branches {
                    if let l = b.latitude,
                        let long = b.longitude {
                        annotations.append(
                            BankBranchAnnotation(
                                coordinate: CLLocationCoordinate2D(latitude: l, longitude: long),
                                type: b.type,
                                title: b.name,
                                address: b.address,
                                schedule: b.schedule,
                                phone: b.phone
                            )
                        )
                    }
                }
            } else {
                print("bank branches decoding failed")
            }
            mapView.addAnnotations(annotations)
            mapView.register(BankBranchClusterView.self,
                             forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            mapView.register(BankBranchView.self,
                             forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//            mapView.register(BankBranchMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMApviewdef)
        }
    }
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            focusButton.isHidden = false
            locationManager.requestLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: mapView.region.span)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func hideMap(sender: UIButton!) {
        tableView.isHidden = false
        mapView.isHidden = true
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: false)
        zoomOutButton.isHidden = true
        zoomInButton.isHidden = true
        focusButton.isHidden = true
    }
    
    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.mapView.region
        var span: MKCoordinateSpan = mapView.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension ServicesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            focusButton.isHidden = false
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("locationManager didUpdateLocations: \(locations)")
        if let location = locations.first,
            needFocus == true {
//            print("locations.first \(locations.first)")
//            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            let delta = (mapView.region.span.latitudeDelta > 0.01) ? 0.01 : mapView.region.span.latitudeDelta
//            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
            mapView.setRegion(coordinateRegion, animated: true)
            needFocus = false
        }
//        let location = locations.first!
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
//        mapView.setRegion(coordinateRegion, animated: true)
//        locationManager?.stopUpdatingLocation()
//        locationManager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }
}

extension ServicesViewController: MKMapViewDelegate {
    
    //   1
    //  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //    guard let annotation = annotation as? Artwork else { return nil }
    //    // 2
    //    let identifier = "marker"
    //    var view: MKMarkerAnnotationView
    //    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    //      as? MKMarkerAnnotationView { // 3
    //      dequeuedView.annotation = annotation
    //      view = dequeuedView
    //    } else {
    //      // 4
    //      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    //      view.canShowCallout = true
    //      view.calloutOffset = CGPoint(x: -5, y: 5)
    //      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    //    }
    //    return view
    //  }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                 calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation as! BankBranchAnnotation
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
//            MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMaps(launchOptions: launchOptions)
//    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("did select")
        if let cluster = view.annotation as? MKClusterAnnotation,
            let aa = cluster.memberAnnotations as? [BankBranchAnnotation],
            let tableVC = children.first as? AnnotationsTableViewController {
            tableVC.annotations = aa
            centerMapOnLocation(coordinate: cluster.coordinate)
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.annotationsInfoHeight.constant = 150
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        if let a = view.annotation as? BankBranchAnnotation,
            let tableVC = children.first as? AnnotationsTableViewController {
            tableVC.annotations = [a]
            centerMapOnLocation(coordinate: a.coordinate)
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.annotationsInfoHeight.constant = 150
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        print("deselect")
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
            self.annotationsInfoHeight.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}
