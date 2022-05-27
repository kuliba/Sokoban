//
//  ProductViewControllerHistoryTableView.swift
//  ForaBank
//
//  Created by Дмитрий on 24.03.2022.
//

import Foundation
import UIKit
import SkeletonView

extension ProductViewController: UITableViewDelegate, UITableViewDataSource, SkeletonTableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch  product?.productType{
        case "ACCOUNT":
            return sortedAccount.count
        case "DEPOSIT":
            return sortedDeposit.count
        case "CARD":
            return sorted.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch product?.productType {
        case "ACCOUNT":
            var countSection = Array<Any>()
            
            sortedAccount.map({
                countSection.append(($0.value as AnyObject).count ?? 0)
            })
            return sortedAccount[section].value.count
        case "DEPOSIT":
            var countSection = Array<Any>()
            
            sortedDeposit.map({
                countSection.append(($0.value as AnyObject).count ?? 0)
            })
            return sortedDeposit[section].value.count
        default:
            var countSection = Array<Any>()
            
            sorted.map({
                countSection.append(($0.value as AnyObject).count ?? 0)
            })
            return sorted[section].value.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch product?.productType {
        case "DEPOSIT":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }
            
            cell.operation = nil
            cell.accountOperation = nil
            
            cell.titleLable.hideSkeleton()
            cell.amountLabel.hideSkeleton()
            cell.subTitleLabel.hideSkeleton()
            cell.logoImageView.hideSkeleton()
            
            let bank = Dict.shared.currencyList?.first(where: {$0.codeNumeric == sortedDeposit[indexPath.section].value[indexPath.row].currencyCodeNumeric})
            cell.depositOperation = sortedDeposit[indexPath.section].value[indexPath.row]
            
            if let currency = bank?.code {
                cell.configure(currency: currency)
            }
            cell.selectionStyle = .none
            return cell
        case "ACCOUNT":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }

            cell.operation = nil
            cell.depositOperation = nil
            
            cell.titleLable.hideSkeleton()
            cell.amountLabel.hideSkeleton()
            cell.subTitleLabel.hideSkeleton()
            cell.logoImageView.hideSkeleton()
            
            let bank =  Dict.shared.currencyList?.first(where: {$0.codeNumeric == sortedAccount[indexPath.section].value[indexPath.row].currencyCodeNumeric})
            cell.accountOperation = sortedAccount[indexPath.section].value[indexPath.row]
            cell.configure(currency: bank?.code ?? "RUB")
            
            cell.selectionStyle = .none
            return cell
        case "CARD":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }

            cell.depositOperation = nil
            cell.accountOperation = nil
            cell.operation = sorted[indexPath.section].value[indexPath.row]
            
            cell.titleLable.hideSkeleton()
            cell.amountLabel.hideSkeleton()
            cell.subTitleLabel.hideSkeleton()
            cell.logoImageView.hideSkeleton()
            
            let bank = Dict.shared.currencyList?.first(where: {$0.codeNumeric == sorted[indexPath.section].value[indexPath.row].currencyCodeNumeric})
            cell.configure(currency: bank?.code ?? "RUB")
            cell.selectionStyle = .none
            return cell
        case .none:
            print("none case")
            return UITableViewCell()
        case .some(_):
            print("some case")
            return UITableViewCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let operationDetailViewModel = operationDetailViewModel(for: indexPath) else {
            return
        }
        
    }
    
    private func operationDetailViewModel(for indexPath: IndexPath) -> OperationDetailViewModel? {
        
        guard let product = product, let currency = product.currency else {
            return nil
        }
        
        switch product.productTypeEnum {
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        switch product?.productType {
        case "ACCOUNT":
            if self.sortedAccount.count != 0{
                guard let tranDate = self.sortedAccount[section].value[0].tranDate  else {
                    return
                }
                let label = longIntToDateString(longInt: tranDate/1000)
                
                if let month = label?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") {
                    statusBarLabel.text = "Траты за \(getMonthFromLognInt(longInt: tranDate/1000))"

                    
                    let monthSort = historyArrayAccount.filter({longIntToDateString(longInt: $0.date!/1000)?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") ?? "" == month.replacingOccurrences(of: " ", with: "")})
                    let monthDebit = monthSort.filter({$0.operationType == "DEBIT"})
                    let sumSalary = monthDebit.reduce(0.0, {
                        if let documentAmount = $1.documentAmount{
                            let sum = $0 + documentAmount
                            return sum
                        } else {
                            return +$1.amount!
                        }
                    })
                    
                    amounPeriodLabel.text = "- \(sumSalary.currencyFormatter(symbol: "RUB"))"
                }
                
            }
        case "DEPOSIT":
            if self.sortedDeposit.count != 0{
                guard let tranDate = self.sortedDeposit[section].value[0].tranDate  else {
                    return
                }
                let label = longIntToDateString(longInt: tranDate/1000)
                
                if let month = label?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") {
                    statusBarLabel.text = "Траты за \(getMonthFromLognInt(longInt: tranDate/1000))"
                    
                    let monthSort = historyArrayDeposit.filter({longIntToDateString(longInt: $0.date!/1000)?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") ?? "" == month.replacingOccurrences(of: " ", with: "")})
                    let monthDebit = monthSort.filter({$0.operationType == "DEBIT"})
                    let sumSalary = monthDebit.reduce(0.0, {
                        if let documentAmount = $1.documentAmount{
                            let sum = $0 + documentAmount
                            return sum
                        } else {
                            return +$1.amount!
                        }
                    })
                    
                    amounPeriodLabel.text = "- \(sumSalary.currencyFormatter(symbol: "RUB"))"
                }
                
            }
        case "CARD":
            if self.sorted.count != 0{
                guard let tranDate = self.sorted[section].value[0].tranDate  else {
                    return
                }
                
                let label = longIntToDateString(longInt: tranDate/1000)
                
                if let month = label?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") {
                    statusBarLabel.text = "Траты за \(getMonthFromLognInt(longInt: tranDate/1000))"
                    
                    let monthSort = historyArray.filter({longIntToDateString(longInt: $0.date!/1000)?.dropFirst(2).dropLast(5).replacingOccurrences(of: " ", with: "") ?? "" == month.replacingOccurrences(of: " ", with: "")})
                    let monthDebit = monthSort.filter({$0.operationType == "DEBIT"})
                    
                    let sumSalary = monthDebit.reduce(0.0, {
                        if let documentAmount = $1.documentAmount{
                            let sum = $0 + documentAmount
                            return sum
                        } else {
                            return +$1.amount!
                        }
                    })
                    
                    amounPeriodLabel.text = "- \(sumSalary.currencyFormatter(symbol: "RUB"))"
                }
                
                
            }
        default:
            print("default")
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        headerView.backgroundColor = .white
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height)
        
        switch product?.productType {
        case "ACCOUNT":
            if self.sortedAccount.count != 0 {
                guard let tranDate = self.sortedAccount[section].value.first?.tranDate  else {
                    label.text = longIntToDateString(longInt: self.sortedAccount[section].value[0].date!/1000)
                    headerView.addSubview(label)
                    label.centerY(inView: headerView)
                    return headerView
                }
                label.text = longIntToDateString(longInt: tranDate/1000)
                
            }
        case "DEPOSIT":
            if self.sortedDeposit.count != 0 {
                guard let tranDate = self.sortedDeposit[section].value.first?.tranDate  else {
                    label.text = longIntToDateString(longInt: self.sortedDeposit[section].value[0].date!/1000)
                    headerView.addSubview(label)
                    label.centerY(inView: headerView)
                    return headerView
                }
                label.text = longIntToDateString(longInt: tranDate/1000)
                
            }
        case "CARD":
            if self.sorted.count != 0 {
                guard let tranDate = self.sorted[section].value[0].tranDate  else {
                    label.text = longIntToDateString(longInt: self.sorted[section].value[0].date!/1000)
                    headerView.addSubview(label)
                    label.centerY(inView: headerView)
                    return headerView
                }
                
                label.text = longIntToDateString(longInt: tranDate/1000)
                
            }
        default:
            break
            
        }
        
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor =  UIColor(hexString: "1C1C1C")
        headerView.addSubview(label)
        label.centerY(inView: headerView)
        return headerView
    }
    
    func longIntToDateString(longInt: Int) -> String?{
        
        let date = Date(timeIntervalSince1970: TimeInterval(longInt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none//Set time style
        dateFormatter.dateStyle = DateFormatter.Style.long //Set date style
        
        dateFormatter.dateFormat =  "d MMMM, E"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }
        
        cell.subTitleLabel.isHidden = false
        cell.titleLable.isSkeletonable = true
//        cell.titleLable.text = "Placeholder"
        cell.titleLable.showAnimatedGradientSkeleton()
//        cell.amountLabel.text = "Placeholder"
        cell.amountLabel.showAnimatedGradientSkeleton()
//        cell.subTitleLabel.text = "Placeholder"
        cell.subTitleLabel.showAnimatedGradientSkeleton()
        cell.logoImageView.showAnimatedGradientSkeleton()
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return HistoryTableViewCell.identifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, identifierForHeaderInSection section: Int) -> ReusableHeaderFooterIdentifier? {
           return "HeaderIdentifier"
       }
    
    func getMonthFromLognInt(longInt: Int) -> String{
        
            let date = Date(timeIntervalSince1970: TimeInterval(longInt))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.dateStyle = DateFormatter.Style.long
            
            dateFormatter.dateFormat = "LLLL"
            dateFormatter.timeZone = .current
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let localDate = dateFormatter.string(from: date)
        
        return localDate
    }
}
