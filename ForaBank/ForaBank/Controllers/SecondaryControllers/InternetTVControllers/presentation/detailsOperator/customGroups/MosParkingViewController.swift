import UIKit
import RealmSwift
import Foundation


class MosParkingViewController: BottomPopUpViewAdapter, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate, IMsg {

    public static func storyboardInstance() -> InternetTVDetailsFormController? {
        let storyboard = UIStoryboard(name: "InternetTV", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "InternetTVDetail") as? InternetTVDetailsFormController
    }
    
    static var iMsg: IMsg? = nil
    static let msgUpdateTable = 3
    static var mosParkingList: MosParkingListData? = nil
    
    var dicMosGroups = [String:[String:String]]()
    var operatorData: GKHOperatorsModel?
    var viewModel = InternetTVDetailsFormViewModel()
    var selectedRegion = "" {
        didSet {
            updateRegionUI()
        }
    }
    var selectedPeriod = "" {
        didSet {
            updatePeriodUI()
        }
    }
    
    @IBOutlet weak var btnYearOutlet: UIButton!
    
    @IBOutlet weak var btnMounthOutlet: UIButton!
    
    @IBOutlet weak var btnTopUpOutlet: UIButton!
    
    @IBOutlet weak var imgCheck1: UIImageView!
    
    @IBOutlet weak var imgCheck2: UIImageView!
    
    @IBOutlet weak var imgCheck3: UIImageView!
    
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var imgMapMoscow: UIImageView!
    
    @IBAction func btnYear(_ sender: Any) {
        selectedPeriod = "Годовая"
    }
    
    @IBAction func btnMonth(_ sender: Any) {
        selectedPeriod = "Месячная"
    }
    
    @IBAction func btnTopUp(_ sender: Any) {
        selectedPeriod = "Пополнение"
        performSegue(withIdentifier: "details", sender: self)
    }
    
    @IBAction func btnRange1(_ sender: Any) {
        selectedRegion = dicMosGroups["0"]?["text"] ?? ""
    }
    
    @IBAction func btnRange2(_ sender: Any) {
        selectedRegion = dicMosGroups["1"]?["text"] ?? ""
    }
    
    @IBAction func btnRange3(_ sender: Any) {
        selectedRegion = dicMosGroups["2"]?["text"] ?? ""
    }
    
    @IBAction func btnContinue(_ sender: Any) {
        performSegue(withIdentifier: "details", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MosParkingViewController.iMsg = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        MosParkingViewController.iMsg = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InternetTVApiRequests.getClientInfo()
        view.backgroundColor = .white
        setupToolbar()
        handleMsg(what: -1)
    }

    func setupToolbar() {
        let operatorsName = operatorData?.name ?? ""
        let inn = operatorData?.synonymList.first ?? ""
        navigationItem.titleView = setTitle(title: operatorsName, subtitle: "ИНН " +  inn )

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit

        if let svg = operatorData?.logotypeList.first?.svgImage {
            imageView.image = svg.convertSVGStringToImage()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        } else {
            imageView.image = UIImage(named: "GKH")
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.frame.size.width,  height: 30))
        titleView.setDimensions(height: 30, width: 250)
        titleView.addSubview(titleLabel)
        titleLabel.numberOfLines = 3;
        titleLabel.anchor( left: titleView.leftAnchor, right: titleView.rightAnchor)

        return titleView
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .custom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dc = segue.destination as? InternetTVDetailsFormController {
            var value = "-1"
            if let list = MosParkingViewController.mosParkingList?.mosParkingList {
                for item in list {
                    if item.text == selectedRegion && item.groupName == selectedPeriod {
                        value = item.value ?? ""
                    }
                    if item.groupName == selectedPeriod && selectedPeriod == "Пополнение" {
                        value = item.value ?? ""
                    }
                }
            }
            dc.operatorData = operatorData
            dc.selectedValue = value
        }
    }
    
    func updateRegionUI() {
        switch (selectedRegion) {
        case dicMosGroups["0"]?["text"] :
            imgCheck1.image = UIImage(named: "radio_checked")
            imgCheck2.image = UIImage(named: "radio_unchecked")
            imgCheck3.image = UIImage(named: "radio_unchecked")
            imgMapMoscow.image = dicMosGroups["0"]?["img"]?.convertSVGStringToImage()
            break
        case dicMosGroups["1"]?["text"] :
            imgCheck1.image = UIImage(named: "radio_unchecked")
            imgCheck2.image = UIImage(named: "radio_checked")
            imgCheck3.image = UIImage(named: "radio_unchecked")
            imgMapMoscow.image = dicMosGroups["1"]?["img"]?.convertSVGStringToImage()
            break
        case dicMosGroups["2"]?["text"] :
            imgCheck1.image = UIImage(named: "radio_unchecked")
            imgCheck2.image = UIImage(named: "radio_unchecked")
            imgCheck3.image = UIImage(named: "radio_checked")
            imgMapMoscow.image = dicMosGroups["2"]?["img"]?.convertSVGStringToImage()
            break
        default:
            imgCheck1.image = UIImage(named: "radio_unchecked")
            imgCheck2.image = UIImage(named: "radio_unchecked")
            imgCheck3.image = UIImage(named: "radio_unchecked")
            imgMapMoscow.image = dicMosGroups["0"]?["img"]?.convertSVGStringToImage()
            break
        }
    }

    func updatePeriodUI() {
        switch (selectedPeriod) {
        case "Месячная":
            btnMounthOutlet.backgroundColor = UIColor.white
            btnYearOutlet.backgroundColor = UIColor.clear
            btnTopUpOutlet.backgroundColor = UIColor.clear
            break
        case "Годовая":
            btnMounthOutlet.backgroundColor = UIColor.clear
            btnYearOutlet.backgroundColor = UIColor.white
            btnTopUpOutlet.backgroundColor = UIColor.clear
            break
        case "Пополнение":
            btnMounthOutlet.backgroundColor = UIColor.clear
            btnYearOutlet.backgroundColor = UIColor.clear
            btnTopUpOutlet.backgroundColor = UIColor.white
            break
        default:
            btnMounthOutlet.backgroundColor = UIColor.clear
            btnYearOutlet.backgroundColor = UIColor.clear
            btnTopUpOutlet.backgroundColor = UIColor.clear
            break
        }
    }

    func handleMsg(what: Int) {
        var defaultRegion = ""
        if let list = MosParkingViewController.mosParkingList?.mosParkingList {
            var i = 0
            for item in list {
                if item.mosParkingListDefault == true {
                    imgMapMoscow.image = item.svgImage?.convertSVGStringToImage()
                    selectedPeriod = item.groupName ?? "Годовая"
                    defaultRegion = item.text ?? ""
                }
                var dic = ["img": item.svgImage ?? ""]
                dic["default"] = String(describing: item.mosParkingListDefault)
                dic["text"] = item.text ?? ""
                dicMosGroups[String(describing: i)] = dic
                i+=1
            }
        }
        if dicMosGroups.count > 2 {
            selectedRegion = defaultRegion
            label1.attributedText = dicMosGroups["0"]?["text"]?.htmlToAttributedString
            label2.attributedText = dicMosGroups["1"]?["text"]?.htmlToAttributedString
            label3.attributedText = dicMosGroups["2"]?["text"]?.htmlToAttributedString
        }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
