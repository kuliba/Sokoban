import UIKit

class DataItem : Equatable {
    
    var indexes: String
    var textLabel: String
    var images: UIImage

    init(_ indexes: String,_ textLabel:String, _ images: UIImage ) {
        self.indexes    = indexes
        self.textLabel = textLabel
        self.images = images
    }
    
    static func ==(lhs: DataItem, rhs: DataItem) -> Bool {
        return lhs.indexes == rhs.indexes
    }
}


class ViewController: UIViewController, KDDragAndDropCollectionViewDataSource, UICollectionViewDelegate {
   
    
    @IBOutlet weak var firstCollectionView: KDDragAndDropCollectionView!
    @IBOutlet weak var secondCollectionView: KDDragAndDropCollectionView!
    @IBOutlet weak var thirdCollectionView: KDDragAndDropCollectionView!
    
    var items: [Any] = ICollectionViewCell.getArray()
    var images: [String] = [
        "phone", "transfer", "history", "account"
    ]
    var labeltext: [String] = [
          "Перевод по номеру телефона", "Перевод по номеру карты", "История", "Перевод между своими счетами"
      ]

    
    var data : [[DataItem]] = [[DataItem]]()
    
    var dragAndDropManager : KDDragAndDropManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
          // generate some mock data (change in real world project)
        firstCollectionView.collectionViewLayout.invalidateLayout()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "mainscreen-1")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        var j: Int
        self.data =  [(0...3).map({ j in DataItem("\(String(j))","\(labeltext[j])", (UIImage(named: images[j])!))})]
     
        self.dragAndDropManager = KDDragAndDropManager(
            canvas: self.view,
            collectionViews: [firstCollectionView]
        )
    
        
    }

    
    // MARK : UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let paymentDetailsVC = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentDetailsViewController") as? PaymentsDetailsViewController else {
                return
            }
        guard let histroyDetail = UIStoryboard(name: "Deposits", bundle: nil).instantiateViewController(withIdentifier: "deposits4") as? DepositsHistoryViewController else {
                       return
                   }

            let sourceProvider = PaymentOptionCellProvider()
            let destinationProvider = PaymentOptionCellProvider()
            let destinationProviderCardNumber = CardNumberCellProvider()
            let destinationProviderAccountNumber = AccountNumberCellProvider()
            let destinationProviderPhoneNumber = PhoneNumberCellProvider()

            paymentDetailsVC.sourceConfigurations = [
                PaymentOptionsPagerItem(provider: sourceProvider)
            ]

        
        var dataName = (0...3).map({ i in (0...3).map({ j in DataItem("\(String(i)):\(String(j))","\(labeltext[j])", (UIImage(named: images[j])!))})})
        
        
        
        switch data[0][indexPath.row].textLabel{
            case "Перевод по номеру телефона":
                paymentDetailsVC.destinationConfigurations = [
                                   PhoneNumberPagerItem(provider: destinationProviderPhoneNumber)
                               ]
               
                break
            case "Перевод по номеру карты":
                paymentDetailsVC.destinationConfigurations = [
                    CardNumberPagerItem(provider: destinationProviderCardNumber),
                    AccountNumberPagerItem(provider: destinationProviderAccountNumber),
                ]
                break
            case "Перевод между своими счетами":
                 paymentDetailsVC.destinationConfigurations = [
                                   PaymentOptionsPagerItem(provider: destinationProvider)
                               ]
                break
            case "История":
             let storyBoard : UIStoryboard = UIStoryboard(name: "Deposits", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "deposits4") as! DepositsHistoryViewController
                self.present(nextViewController, animated:true, completion:nil)

                
            break
            default:
                break
            }

            let rootVC = collectionView.parentContainerViewController()
            rootVC?.present(paymentDetailsVC, animated: true, completion: nil)
        

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].count
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = images[sourceIndexPath.item]
        images.remove(at: sourceIndexPath.item)
        images.insert(item, at: destinationIndexPath.item)
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
        
        let dataItem = data[collectionView.tag][indexPath.item]
        
        
        cell.imageView.image = dataItem.images
        cell.label.text = dataItem.textLabel
     
      

        cell.isHidden = false
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.isHidden = true
                    
                }
            }
        }
        
        return cell
    }

    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        return data[collectionView.tag][indexPath.item]
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? DataItem {
            data[collectionView.tag].insert(di, at: indexPath.item)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {
        data[collectionView.tag].remove(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        let fromDataItem: DataItem = data[collectionView.tag][from.item]
        data[collectionView.tag].remove(at: from.item)
        data[collectionView.tag].insert(fromDataItem, at: to.item)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        guard let candidate = dataItem as? DataItem else { return nil }
        
        for (i,item) in data[collectionView.tag].enumerated() {
            if candidate != item { continue }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
        
    }
    

}





