import Foundation
import RealmSwift
import UIKit

class InternetTVLatestOperationsModel: Object {
    @objc dynamic var paymentDate: String?
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var puref: String?

    var additionalList  = List<AdditionalListModel>()
}


