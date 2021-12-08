import UIKit
import RealmSwift

class InternetTVCitySearchController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    static let ALL_REGION = "Все регионы"

    var operatorsList: Results<GKHOperatorsModel>? = nil
    var searchText = ""

    var regionsArr = [String]()
    var allRegionsArr = [String]()
    var searching = false
    lazy var realm = try? Realm()

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        getRegions()
        textField.delegate = self
    }

    private func getRegions() {
        regionsArr.removeAll()
        allRegionsArr.append(InternetTVCitySearchController.ALL_REGION)
        operatorsList?.forEach { op in
            if op.parentCode?.contains(InternetTVMainViewModel.filter) ?? false {
                print("region5555 \(op.region) + \(op.name)")
                let arrRegion = (op.region ?? "").split(separator: ",")
                for item in arrRegion {
                    regionsArr.append(item.description.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        regionsArr = regionsArr.filter { !$0.contains("Все регионы")}
        regionsArr = regionsArr.uniqued()
        regionsArr.sort {
            $0 < $1
        }
        allRegionsArr.removeAll()
        allRegionsArr.append(contentsOf: regionsArr)
        regionsArr.removeAll()
        regionsArr.append(InternetTVCitySearchController.ALL_REGION)
        regionsArr.append(contentsOf: allRegionsArr)

        tableView.reloadData()
    }

    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            if self.searching {
                NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key": self.searchText])
            } else {
                if self.searchText != "" {
                    NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key": self.searchText])
                }
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regionsArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = regionsArr[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchText = regionsArr[indexPath.row]
        dismiss(animated: true, completion: {
            if self.searching {
                NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key": self.searchText])
            } else {
                if self.searchText != "" {
                    NotificationCenter.default.post(name: .city, object: nil, userInfo: ["key": self.searchText])
                }
            }
        })
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            regionsArr = allRegionsArr.filter {
                $0.lowercased().contains(updatedText.lowercased())
            }
            searchText = updatedText
        }
        if string == "" {
            regionsArr = allRegionsArr
        }
        tableView.reloadData()
        return true
    }
}
