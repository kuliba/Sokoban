//
//  PaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit
import AVFoundation

class PaymentsViewController: UIViewController {
    
    // QR data
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var alertController: UIAlertController?
    
    weak var delegate: PaymentsViewControllerDelegate?
    
    var payments = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var transfers = [PaymentsModel]()
    var pay = [PaymentsModel]()
    
    lazy var searchContact: NavigationBarUIView = UIView.fromNib()
    
    enum Section: Int, CaseIterable {
        case payments, transfers, pay
        func description() -> String {
            switch self {
            case .payments:
                return "Платежи"
            case .transfers:
                return "Перевести"
            case .pay:
                return "Оплатить"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.black ], for: .selected)
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PaymentsModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        view.addSubview(searchContact)
        searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 48)
        searchContact.textField.alpha = 0.5
        searchContact.searchIcon.alpha = 0.5
        searchContact.bellIcon.isHidden = true
        setupData()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        loadLastPhonePayments()
        loadLastPayments()
        loadLastMobilePayments()
    
        loadAllLastMobilePayments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil {
            let controller = InternetTVMainController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
        navigationController?.navigationBar.isHidden = true
        loadAllLastMobilePayments()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        loadAllLastMobilePayments()
//    }
    
    func setupData() {
        payments = MockItems.returnPayments()
        transfers = MockItems.returnTransfers()
        pay = MockItems.returnPay()
    }

// MARK: QR
    @objc func openSetting() {
        checkCameraAccess(isAllowed: {
                if $0 {
                    DispatchQueue.main.async {
                        let controller = QRViewController.storyboardInstance()!
                        let nc = UINavigationController(rootViewController: controller)
                        nc.modalPresentationStyle = .fullScreen
                        self.present(nc, animated: true)
                    }
                } else {
                    guard self.alertController == nil else {
                        return
                    }
                    self.alertController = UIAlertController(title: "Внимание", message: "Для сканирования QR кода, необходим доступ к камере", preferredStyle: .alert)
                    guard let alert = self.alertController else {
                        return
                    }
                    alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: { (action) in
                        self.alertController = nil
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
    }
    
    private func setupSearchBar() {
        searchContact.secondButton.tintColor = .black
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        searchContact.secondButton.addGestureRecognizer(gesture)
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        view.addSubview(collectionView)
        collectionView.anchor(top: searchContact.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(PaymentsCell.self, forCellWithReuseIdentifier: PaymentsCell.reuseId)
        collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
        collectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.reuseId)
        collectionView!.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        
        snapshot.appendSections([.payments, .transfers, .pay])
        snapshot.appendItems(payments, toSection: .payments)
        snapshot.appendItems(transfers, toSection: .transfers)
        snapshot.appendItems(pay, toSection: .pay)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
    }
}

//MARK: - API
extension PaymentsViewController {
    
    func loadLastPayments() {
        NetworkManager<GetPaymentCountriesDecodableModel>.addRequest(.getPaymentCountries, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let lastPaymentsList = model.data else { return }
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let mod = ChooseCountryHeaderViewModel(model: lastPayment)
                        let payment = PaymentsModel(lastCountryPayment: mod)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let mod = ChooseCountryHeaderViewModel(model: lastPayment)
                        let payment = PaymentsModel(lastCountryPayment: mod)
                        self.payments.append(payment)
                    }
                }
            }
        }
    }
    
    func loadLastPhonePayments() {
        NetworkManager<GetLatestPaymentsDecodableModel>.addRequest(.getLatestPayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
    
    func loadLastMobilePayments() {
        NetworkManager<GetLatestMobilePaymentsDecodableModel>.addRequest(.getLatestMobilePayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let payment = PaymentsModel(lastMobilePayment: lastPayment)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let payment = PaymentsModel(lastMobilePayment: lastPayment)
                        self.payments.append(payment)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                
            }
        }
    }
    
    func loadAllLastMobilePayments() {
        let param = ["isPhonePayments": "true", "isCountriesPayments": "true", "isServicePayments": "true", "isMobilePayments": "true"]
        NetworkManager<GetAllLatestPaymentsDecodableModel>.addRequest(.getAllLatestPayments, param, [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                let payArr = lastPaymentsList.prefix(3)
                payArr.forEach { lastPayment in
                    let payment = PaymentsModel(lastGKHPayment: lastPayment)
//                    self.payments.append(payment)
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }

    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: fastPaymentContractFindList", model)
            if model.statusCode == 0 {
                completion(model.data,nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(nil, model.errorMessage)
            }
        }
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
