import UIKit
import RealmSwift
import AVFoundation

protocol IMsg {
    func handleMsg(what: Int)
}

class InternetTVMainController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, IMsg {

    public static var iMsg: IMsg? = nil
    public static let msgHideLatestOperation = 1
    public static let msgPerformSegue = 2
    public static var latestOpIsEmpty = false
    public static func storyboardInstance() -> InternetTVMainController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "InternetTVMain") as? InternetTVMainController
    }

    @IBOutlet weak var reqView: UIView!
    @IBOutlet weak var zayavka: UIView!

    @IBOutlet weak var historyView: UIView!

    @IBOutlet weak var tableView: UITableView!

    var viewModel = InternetTVMainViewModel()
    var alertController: UIAlertController?
    var searching = false
    let searchController = UISearchController(searchResultsController: nil)
    let latestOperationView = InternetTVLatestOperationsView()

    func handleMsg(what: Int) {
        switch (what) {
        case InternetTVMainController.msgHideLatestOperation:
            historyView?.isHidden = true
            historyView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            break
        case InternetTVMainController.msgPerformSegue:
            performSegue(withIdentifier: "input", sender: self)
            break
        default:
            break
        }
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
        let gesture = UITapGestureRecognizer(target: self, action: #selector(titleDidTaped))
        titleView.addGestureRecognizer(gesture)
        return titleView
    }

    func changeTitle(_ text: String) {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.setTitle(title: text, subtitle: "")
        }
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
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .highlighted)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "qr_Icon"), style: .plain, target: self, action: #selector(onQR))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .highlighted)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        InternetTVMainController.iMsg = self
        viewModel.controller = self
        if historyView != nil {
            latestOperationView.frame = historyView.frame
            historyView.addSubview(latestOperationView)
        }
        if InternetTVMainController.latestOpIsEmpty {
            historyView?.isHidden = true
            historyView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        tableView.delegate = self
        tableView.dataSource = self
        AddAllUserCardtList.add {}
        navigationController?.isNavigationBarHidden = false
        reqView.add_CornerRadius(5)
        zayavka.add_CornerRadius(5)
        tableView.register(UINib(nibName: "GHKCell", bundle: nil), forCellReuseIdentifier: GHKCell.reuseId)
        setupNavBar()
        NotificationCenter.default.addObserver(forName: .city, object: nil, queue: .none) { [weak self] (value) in
            self?.searching = true
            let value = value.userInfo?["key"] as? String ?? ""
            if value == InternetTVCitySearchController.ALL_REGION {
                self?.searching = false
                self?.viewModel.searchedOrganization = self?.viewModel.organization ?? [GKHOperatorsModel]()
            } else {
                self?.viewModel.searchedOrganization = self?.viewModel.organization.filter {
                    ($0.region?.lowercased().contains(value.lowercased()) ?? false)
                            || ($0.region?.lowercased().contains(InternetTVCitySearchController.ALL_REGION.lowercased()) ?? false)
                } ?? [GKHOperatorsModel]()
            }
            self?.navigationItem.titleView = self?.setTitle(title: value, subtitle: "")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkQREvent()
        if InternetTVMainViewModel.latestOp != nil {
            handleMsg(what: InternetTVMainController.msgPerformSegue)
        }
    }

    @objc func titleDidTaped() {
        performSegue(withIdentifier: "citySearch", sender: self)
    }

    @objc func backAction() {
        //self.delegate?.goToBack()
        dismiss(animated: true, completion: nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func onQR() {
        PermissionHelper.checkCameraAccess(isAllowed: { granted, alert in
            if granted {
                DispatchQueue.main.async {
                    self.navigationController?.isNavigationBarHidden = true
                    self.performSegue(withIdentifier: "qr", sender: nil)
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !doStringContainsNumber(_string: searchText) {
            viewModel.searchedOrganization = viewModel.organization.filter {
                $0.name?.lowercased().contains(searchText.lowercased()) == true
            }
        } else {
            viewModel.searchedOrganization = viewModel.organization.filter {
                $0.synonymList.first?.lowercased().contains(searchText.lowercased()) == true
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

    func checkQREvent() {
        if let qrDataUnw = GlobalModule.qrData, let operatorModelUnw = GlobalModule.qrOperator {
            if operatorModelUnw.parentCode?.contains(GlobalModule.INTERNET_TV_CODE) == true {
                InternetTVMainViewModel.filter = GlobalModule.INTERNET_TV_CODE
            }
            if operatorModelUnw.parentCode?.contains(GlobalModule.UTILITIES_CODE) == true {
                InternetTVMainViewModel.filter = GlobalModule.UTILITIES_CODE
            }
            viewModel.qrData = qrDataUnw
            viewModel.operators = operatorModelUnw
            GlobalModule.qrData = nil
            GlobalModule.qrOperator = nil
            performSegue(withIdentifier: "input", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let op: GKHOperatorsModel!
        switch segue.identifier {

        case "input":
            InternetTVDetailsFormViewModel.additionalDic.removeAll()
            InternetTVInputCell.spinnerValuesSelected.removeAll()
            if let latestOp = InternetTVMainViewModel.latestOp {
                let dc = segue.destination as! InternetTVDetailsFormController
                dc.operatorData = latestOp.op
                dc.latestOperation = latestOp
                InternetTVMainViewModel.latestOp = nil
            } else {
                if tableView.indexPathForSelectedRow?.row != nil {
                    let index = (tableView.indexPathForSelectedRow?.row)!
                    if searching {
                        op = viewModel.searchedOrganization[index]
                    } else {
                        op = viewModel.organization[index]
                    }
                    let dc = segue.destination as! InternetTVDetailsFormController
                    dc.operatorData = op
                }
                // Переход по QR
                if viewModel.qrData.count != 0 {
                    let dc = segue.destination as! InternetTVDetailsFormController
                    dc.operatorData = viewModel.operators
                    dc.qrData = viewModel.qrData
                }
            }
            viewModel.qrData.removeAll()
        case "qr":
            let dc = segue.destination as! QRViewController
            //dc.delegate = self
        case .none:
            print()
        case .some(_):
            print()
        }
    }
}

extension InternetTVMainController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return viewModel.searchedOrganization.count
        } else {
            return viewModel.organization.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = viewModel.searchedOrganization[indexPath.row]
            cell.set(viewModel: model)
        } else {
            let model = viewModel.organization[indexPath.row]
            cell.set(viewModel: model)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.searchTextField.endEditing(true)
        performSegue(withIdentifier: "input", sender: self)
    }
}
