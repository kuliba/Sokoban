//
//  PaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit
import AVFoundation

class PaymentsViewController: UIViewController {
    
    var strongSelf: PaymentsServiceViewModel?
    
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
    
    let phoneFormatter = PhoneNumberKitFormater()
    var getUImage: (String) -> UIImage? = { _ in nil}
    
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
        searchContact.trailingLeftButton.isHidden = true
        setupData()
        setupSearchBar()
        setupCollectionView()
        createDataSource(getUImage: getUImage)
        reloadData(with: nil)
        loadAllLastLatestPayments()
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
    }
    
    func setupData() {
        payments = MockItems.returnPayments()
        transfers = MockItems.returnTransfers()
        pay = MockItems.returnPay()
    }

// MARK: QR
    @objc func openQRCamera() {
        PermissionHelper.checkCameraAccess(isAllowed: { granted, alert in
                if granted{
                    DispatchQueue.main.async {
                        let controller = QRViewController.storyboardInstance()!
                        let nc = UINavigationController(rootViewController: controller)
                        nc.modalPresentationStyle = .fullScreen
                        self.present(nc, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        if let alertUnw = alert {
                            self.present(alertUnw, animated: true, completion: nil)
                        }
                    }
                }
            })
    }
    
    private func setupSearchBar() {
        searchContact.trailingRightButton.tintColor = .black
        searchContact.trailingRightAction = { self.openQRCamera() }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.backgroundColor = .white
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
    
    func loadAllLastLatestPayments() {
        let param = ["isPhonePayments": "true", "isCountriesPayments": "true", "isMobilePayments": "true", "isServicePayments": "true", "isInternetPayments": "true", "isTransportPayments":"true"]
        NetworkManager<GetAllLatestPaymentsDecodableModel>.addRequest(.getAllLatestPayments, param, [:]) { model, error in
            if error != nil {
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                lastPaymentsList.forEach { lastPayment in
                    switch lastPayment.type {
                    case "phone":
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    case "country":
                        let payment = PaymentsModel(lastCountryPayment: lastPayment)
                        self.payments.append(payment)
                    case "service":
                        let payment = PaymentsModel(lastGKHPayment: lastPayment)
                        self.payments.append(payment)
                    case "transport":
                        let payment = PaymentsModel(lastGKHPayment: lastPayment)
                        self.payments.append(payment)
                    case "mobile":
                        let payment = PaymentsModel(lastMobilePayment: lastPayment)
                        self.payments.append(payment)
                    case "internet":
                        let payment = PaymentsModel(lastInternetPayment: lastPayment)
                        self.payments.append(payment)
                    default:
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    }

                }
            } else {
            }
        }
    }

    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(model.data,nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
    }
}
