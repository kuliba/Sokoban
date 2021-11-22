import UIKit
import RealmSwift
import AVFoundation

protocol IMsg {
    func handleMsg(what: Int)
}

class InternetTVMainController: UIViewController, UITableViewDelegate, UITableViewDataSource, QRProtocol, UISearchBarDelegate, IMsg {
    public static var iMsg: IMsg? = nil
    public static var latestOpIsEmpty = false

    public static func storyboardInstance() -> InternetTVMainController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "InternetTVMain") as? InternetTVMainController
    }

    @IBOutlet weak var reqView: UIView!
    @IBOutlet weak var zayavka: UIView!

    @IBOutlet weak var historyView: UIView!

    @IBOutlet weak var tableView: UITableView!

    // QR data
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var token: NotificationToken?
//    weak var delegate: GKHDelegate?
    var alertController: UIAlertController?
    var searching = false
    let searchController = UISearchController(searchResultsController: nil)
    var searchingText = ""
    var organization = [GKHOperatorsModel]()
    var searchedOrganization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    var operatorsList: Results<GKHOperatorsModel>? = nil
    lazy var realm = try? Realm()
    let latestOperationView = InternetTVLatestOperationsView()

    func handleMsg(what: Int) {
        historyView?.isHidden = true
        historyView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }

    func changeTitle(_ text: String) {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.setTitle(title: text, subtitle: "")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        InternetTVMainController.iMsg = self
        latestOperationView.frame = historyView.frame
        historyView.addSubview(latestOperationView)

        if InternetTVMainController.latestOpIsEmpty {
            historyView?.isHidden = true
            historyView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }

        tableView.delegate = self
        tableView.dataSource = self

        AddAllUserCardtList.add {
            print("Rasd 1")
        }

        navigationController?.isNavigationBarHidden = false

        /// Загрузка истории операций
        InternetTVLatestOperationRealm.load()

        reqView.add_CornerRadius(5)
        zayavka.add_CornerRadius(5)

        tableView.register(UINib(nibName: "GHKCell", bundle: nil), forCellReuseIdentifier: GHKCell.reuseId)

        setupNavBar()
        observerRealm()
        operatorsList?.forEach({ op in
            if !op.parameterList.isEmpty
                       && op.parentCode?.contains(GlobalModule.INTERNET_TV_CODE) ?? false {
                organization.append(op)
            }
        })
        organization.sort {
            $0.name ?? "" < $1.name ?? ""
        }
        tableView.reloadData()

        NotificationCenter.default.addObserver(forName: .city, object: nil, queue: .none) { [weak self] (value) in
            self?.searching = true
            let value = value.userInfo?["key"] as? String ?? ""
            if value == InternetTVCitySearchController.ALL_REGION {
                self?.searching = false
                self?.searchedOrganization = self?.organization ?? [GKHOperatorsModel]()
            } else {
                self?.searchedOrganization = self?.organization.filter {
                    ($0.region?.lowercased().contains(value.lowercased()) ?? false)
                            || ($0.region?.lowercased().contains(InternetTVCitySearchController.ALL_REGION.lowercased()) ?? false)
                } ?? [GKHOperatorsModel]()
            }
            self?.navigationItem.titleView = self?.setTitle(title: value, subtitle: "")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
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
            AVCaptureDevice.requestAccess(for: .video) {
                isAllowed($0)
            }
        @unknown default:
            print()
        }
    }

    @IBAction func gkhMain(_ unwindSegue: UIStoryboardSegue) {
    }

    deinit {
        print("GKH Deinit")
    }

    func setTitle(title: String, subtitle: String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "chevron.down")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        completeText.append(attachmentString)

        titleLabel.attributedText = completeText
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.frame.size.width, height: 15))
        titleView.addSubview(titleLabel)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.titleDidTaped))
        titleView.addGestureRecognizer(gesture)

        return titleView
    }

    @objc func titleDidTaped() {
        performSegue(withIdentifier: "citySearch", sender: self)
    }

    func setupNavBar() {

        navigationItem.titleView = setTitle(title: "Все регионы", subtitle: "")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_button"), style: .plain, target: self, action: #selector(backAction))

        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .highlighted)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "qr_Icon"), style: .plain, target: self, action: #selector(onQR))

        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .highlighted)

    }

    @objc func backAction() {
        //self.delegate?.goToBack()
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func onQR() {
        checkCameraAccess(isAllowed: {
            if $0 {
                // self.delegate?.goToQRController()
                DispatchQueue.main.async {
                    self.navigationController?.isNavigationBarHidden = true
                    self.performSegue(withIdentifier: "qr", sender: nil)
                }
            } else {
                guard self.alertController == nil else {
                    print("There is already an alert presented")
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedOrganization.count
        } else {
            return organization.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = searchedOrganization[indexPath.row]
            cell.set(viewModel: model)
        } else {
            let model = organization[indexPath.row]
            cell.set(viewModel: model)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.searchBar.searchTextField.endEditing(true)
        performSegue(withIdentifier: "input", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let op: GKHOperatorsModel!
        switch segue.identifier {

        case "input":
            // Если переход по нажатию на ячейку
            if self.tableView.indexPathForSelectedRow?.row != nil {
                let index = (self.tableView.indexPathForSelectedRow?.row)!
                if searching {
                    op = searchedOrganization[index]
                } else {
                    op = organization[index]
                }
                let dc = segue.destination as! InternetTVDetailsFormController
                dc.operatorData = op
            }
            // Переход по QR
            if qrData.count != 0 {
                let dc = segue.destination as! InternetTVDetailsFormController
                dc.operatorData = operators
                dc.qrData = qrData
            }
            qrData.removeAll()
        case "qr":
            let dc = segue.destination as! QRViewController
            dc.delegate = self

        case .none:
            print()
        case .some(_):
            print()
        }

    }

    func observerRealm() {
        operatorsList = realm?.objects(GKHOperatorsModel.self)
//        self.token = self.operatorsList?.observe { [weak self] (changes: RealmCollectionChange) in
//            guard (self?.tableView) != nil else {
//                return
//            }
//            switch changes {
//            case .initial:
//                self?.tableView.reloadData()
//            case .update(_, let deletions, let insertions, let modifications):
//                self?.tableView.beginUpdates()
//                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
//                self?.tableView.endUpdates()
//            case .error(let error):
//                fatalError("\(error)")
//            }
//        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !doStringContainsNumber(_string: searchText) {
            searchedOrganization = organization.filter {
                $0.name?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()
            }
        } else {
            searchedOrganization = organization.filter {
                $0.synonymList.first?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()
            }
        }
        searching = true

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }

    func doStringContainsNumber(_string: String) -> Bool {
        let numberRegEx = ".*[0-9]+.*"
        let testCase = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        return containsNumber
    }

    func setResultOfBusinessLogic(_ qr: [String: String], _ model: GKHOperatorsModel) {
        self.qrData = qr
        self.operators = model
        self.performSegue(withIdentifier: "input", sender: self)
    }
}
