//
//  MoneyViewController.swift
//  ChickenMoneyManager
//
//  Created by Mac on 2018/12/24.
//  Copyright © 2018年 CYCU. All rights reserved.
//

import UIKit
import SQLite

class MoneyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ReDelegate {
    func getData(date: String, pay: String, item: String, name: String, money: String){
        let addNewItem = self.moneyTable.insert(self.date <- date,  self.pay_or_income <- pay, self.item <- item, self.name <- name, self.money <- Int(money)!)
        do {
            try self.db.run(addNewItem)
            print("Finish Add")
        } catch {
            print(error)
        }
        // 更新database
        // 找到紀錄狀態那筆資料
        var increase:Int = 0
        let id = self.moneyTable.filter(self.dataID == 0)
        do {
            let datas = try self.db.prepare(self.moneyTable)
            for i in datas {
                if (i[self.dataID] == 0) {
                    increase = i[self.money_Increase]!
                } // if
            }
        } catch {
            print(error)
        }
        // 新紀錄的金額加進可使用的金額
        let moneyNum:Int = Int(Double(Int(money)!) * (1 + 0.2 * Double(increase)))
        let updateData = id.update(self.nowAllMoney <- (moneyNum + id[self.nowAllMoney]))
        do {
            try self.db.run(updateData)
        } catch {
            print(error)
        }
        
        self.updateTableView()
    }
    var showlist = [String]()
    var add_data = false
    
    @IBOutlet var MoneyButton: UIButton!
    @IBAction func SwitchMoney(_ sender: Any) {
    }
    
    @IBOutlet var showTable: UITableView!
    @IBOutlet var CreateButton: UIButton!
    @IBOutlet var TrashButton: UIButton!
    var delete_item:String = ""
    var delete_money:String = ""
    
    
    var db: Connection!
    let moneyTable = Table("MoneyManager")
    let date = Expression<String?>("date")
    let pay_or_income = Expression<String?>("pay_or_income")
    let item = Expression<String?>("item")
    let name = Expression<String?>("name")
    let money = Expression<Int?>("money")
    let nowAllMoney = Expression<Int?>("nowAllMoney")
    let nowhungry = Expression<Int?>("nowhungry")
    let nowlevel = Expression<Int?>("nowlevel")
    let nowstate = Expression<Int?>("nowstate")
    let dataID = Expression<Int?>("dataID")
    let money_Increase = Expression<Int?>("money_Increase")
    let hungry_Increase = Expression<Int?>("hungry_Increase")
    let levelup_Increase = Expression<Int?>("levelup_Increase")
    
    @IBOutlet var Backgroundview: UIView!
    /*
     金錢，飽食度，等級，狀態是什麼雞，
     收入or支出，日期，項目，金錢
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CreateTable(tableName: "finish2") // create DataBase
        // Do any additional setup after loading the view.
        let pigicon = UIImage(named: "piggy-bank.png")!
        MoneyButton.setImage(pigicon, for: .normal)
        MoneyButton.imageView?.contentMode = .scaleAspectFit
        MoneyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -80,bottom: 0,right: 0)
        MoneyButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0 )
        self.view.addSubview(MoneyButton)
        // Button setting
        CreateButton.layer.cornerRadius = 50
        CreateButton.setTitle("+", for:.normal )
        CreateButton.setTitleColor(UIColor.white, for: .normal)
        CreateButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.view.addSubview(CreateButton)
        TrashButton.layer.cornerRadius = 50
        TrashButton.isHidden = true
        TrashButton.isEnabled = false
        
        Backgroundview.backgroundColor = UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0)
        
        self.updateTableView() // 做一次更新tableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if ( showlist[indexPath.row] == "" ) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "spaceCell", for: indexPath)
            cell.backgroundColor = UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } // if
        else {
            var itemStr:String = ""
            let cell = tableView.dequeueReusableCell(withIdentifier: "MaindataCell", for: indexPath) as! showDataCell
            cell.awakeFromNib()
            cell.textLabel?.text = ""
            cell.imageView?.image = UIImage.init()
            if ( !showlist[indexPath.row].contains("/") ) {
                if ( showlist[indexPath.row].contains("餐飲") ) {
                    cell.imageView?.image = UIImage(named: "fast-food.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "餐飲 ", with: "")
                } // if
                else if( showlist[indexPath.row].contains("服飾") ) {
                    cell.imageView?.image = UIImage(named: "christmas-sock.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "服飾 ", with: "")
                } // else if
                else if( showlist[indexPath.row].contains("生活") ) {
                    cell.imageView?.image = UIImage(named: "house.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "生活 ", with: "")
                } // else if
                else if( showlist[indexPath.row].contains("交通") ) {
                    cell.imageView?.image = UIImage(named: "car.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "交通 ", with: "")
                } // else if
                else if( showlist[indexPath.row].contains("教育") ) {
                    cell.imageView?.image = UIImage(named: "open-book.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "教育 ", with: "")
                } // else if
                else if( showlist[indexPath.row].contains("娛樂") )  {
                    cell.imageView?.image = UIImage(named: "game-controller.png")
                    itemStr = showlist[indexPath.row].replacingOccurrences(of: "娛樂 ", with: "")
                } // else
                
                //cell.textLabel?.text = itemStr
                let itemText:String = itemStr.components(separatedBy: " ")[0]
                let moneyText:String = itemStr.components(separatedBy: " ")[1]
                cell.itemLabel.text = itemText
                cell.moneyLabel.text = moneyText
            } // if
            else {
                cell.textLabel?.text = showlist[indexPath.row]
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
            
            cell.layer.borderColor = UIColor(red:0.95, green:1.00, blue:0.97, alpha:1.0).cgColor
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            cell.backgroundColor = UIColor(red:0.95, green:1.00, blue:0.97, alpha:1.0)
            return cell
        } // else
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showlist[indexPath.row].contains("/") {
            return 40
        } // if
        else if( showlist[indexPath.row] == "" ){
            return 10
        } // else if
        else {
            return 60
        } // else
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (showlist[indexPath.row] != "") {
            let cell = tableView.cellForRow(at: indexPath) as! showDataCell
            if (!(cell.textLabel?.text?.contains("/"))!) {
                delete_item = cell.itemLabel.text!
                delete_money = cell.moneyLabel.text!
                TrashButton.isEnabled = true
                TrashButton.isHidden = false
            } // if
            else {
                TrashButton.isEnabled = false
                TrashButton.isHidden = true
            } // else
        } // if
    }
    
    func CreateTable(tableName:String){
        // DataBase
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent(tableName).appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.db = db
        } catch {
            print(error)
        }
        // Create table
        let createTable = self.moneyTable.create { (table) in
            table.column(self.date)
            table.column(self.pay_or_income)
            table.column(self.item)
            table.column(self.name)
            table.column(self.money)
            table.column(self.dataID) // dataID 0
            table.column(self.nowAllMoney) //  1
            table.column(self.nowhungry) //  2
            table.column(self.nowlevel) //  3
            table.column(self.nowstate) //  4
            table.column(self.money_Increase) //  5
            table.column(self.hungry_Increase) //  6
            table.column(self.levelup_Increase) //  7
        }
        do {
            try self.db.run(createTable)
            print("We create the table.")
            let add_data = self.moneyTable.insert(self.dataID <- 0,  self.nowAllMoney <- 0, self.nowhungry <- 0, self.nowlevel <- 1, self.nowstate <- 0, self.money_Increase <- 0, self.hungry_Increase <- 0, self.levelup_Increase <- 0)
            try self.db.run(add_data)
            print("Initialization finished.")
        } catch {
            print(error)
        }
    }
    
    @IBAction func addItem(_ sender: Any) {
        add_data = true
    }
    
    @IBAction func deleteItem(_ sender: Any) {
        add_data = false
        let data = self.moneyTable.filter(self.name == delete_item)
        do {
            try self.db.run(data.delete())
        } catch {
            print(error)
        }
        
        self.updateTableView()
        
        // 找到紀錄狀態那筆資料
        var increase:Int = 0
        let id = self.moneyTable.filter(self.dataID == 0)
        do {
            let datas = try self.db.prepare(self.moneyTable)
            for i in datas {
                if (i[self.dataID] == 0) {
                    increase = i[self.money_Increase]!
                } // if
            }
        } catch {
            print(error)
        }
        // 新紀錄的金額加進可使用的金額
        var newDeleteMoney:Int
        if (Int(delete_money)! < 0) {
            newDeleteMoney = Int(delete_money)! * -1
        }
        else {
            newDeleteMoney = Int(delete_money)!
        }
        
        let moneyNum:Int = Int(Double(newDeleteMoney) * (1 + 0.2 * Double(increase)))
        let updateData = id.update(self.nowAllMoney <- (id[self.nowAllMoney] - moneyNum))
        do {
            try self.db.run(updateData)
        } catch {
            print(error)
        }
        
        
    }
    
    func updateTableView(){
        showlist.removeAll()
        var put_in:String? = ""
        do {
            let datas = try self.db.prepare(self.moneyTable)
            for i in datas {
                put_in = ""
                if (i[self.date] != nil) {
                    showlist.append(i[self.date]!)
                } // if
                if (i[self.item] != nil) {
                    put_in = put_in! + i[self.item]! + " "
                }
                if (i[self.name] != nil) {
                    put_in = put_in! + i[self.name]! + " "
                }
                if (i[self.money] != nil) {
                    if i[self.pay_or_income]! == "支出" {
                        put_in = put_in! + "-"
                    } // if
                    put_in = put_in! + String(i[self.money]!)
                }
                if (put_in != "") {
                    showlist.append(put_in!)
                }
            } // for
            
            // Sort
            var temp = showlist
            var i:Int = 0
            var j:Int = 0
            let showlist_count = showlist.count
            while i < showlist_count {
                j = 0
                while j < showlist_count - i - 2 {
                    if temp[j] < temp[j+2] {
                        let tempDate = temp[j]
                        let tempData = temp[j+1]
                        temp[j] = temp[j+2]
                        temp[j+1] = temp[j+3]
                        temp[j+2] = tempDate
                        temp[j+3] = tempData
                    } // if
                    j = j + 2
                } // while
                i = i + 2
            } // while
            showlist = temp
            
            // delete 多餘的日期
            var newDate:String = ""
            var idx:Int = 0
            for data in showlist {
                if (data.contains("/") && data != newDate) {
                    newDate = data
                } // if
                else if (data.contains("/") && data == newDate) {
                    showlist.remove(at: idx)
                    idx = idx - 1
                } // else if
                idx = idx + 1
            } // for
            
            // insert 空白分隔不同日期
            if showlist.count > 0 {
                newDate = showlist[0]
            } // if
            for data in showlist {
                if (data.contains("/") && data != newDate) {
                    if let idx = showlist.index(of: data) {
                        showlist.insert("", at: idx)
                    }
                    newDate = data
                } // if
            } // for
            
        } catch {
            print(error)
        }
 
        showTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if add_data == true {
            let RecordVC = segue.destination as! RecordAPayViewController
            RecordVC.delegate = self
        }
        add_data = false
    }

}
