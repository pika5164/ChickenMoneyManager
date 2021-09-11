//
//  RecordAPayViewController.swift
//  ChickenMoneyManager
//
//  Created by Mac on 2019/1/1.
//  Copyright © 2019年 CYCU. All rights reserved.
//

import UIKit
import AVFoundation

protocol ReDelegate: class {
    func getData(date: String, pay: String, item: String, name: String, money: String)
}

class RecordAPayViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    
    var delegate: ReDelegate?
    @IBOutlet var DateButton: UIButton!
    @IBOutlet var PaySelect: UISegmentedControl!
    @IBOutlet var itemSelect: UISegmentedControl!
    @IBOutlet var APayView: UIView!
    @IBOutlet var APaytitle: UILabel!
    @IBOutlet var Name_textField: UITextField!
    @IBOutlet var Money_textField: UITextField!
    @IBOutlet var returnButton: UIButton!
    @IBOutlet var CancelButton: UIButton!
    
    @IBOutlet var Line1: UIImageView!
    @IBOutlet var Line2: UIImageView!
    @IBOutlet var Line3: UIImageView!
    @IBOutlet var Line4: UIImageView!
    
    @IBOutlet var date: UIImageView!
    @IBOutlet var Payorincome: UIImageView!
    @IBOutlet var attribute: UIImageView!
    @IBOutlet var item: UIImageView!
    @IBOutlet var money: UIImageView!
    var musicControl:Bool = true
    static var AddItemMusic: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定時間格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let nowTimeStr = dateFormatter.string(from: Date())
        // DateButton
        DateButton.setTitle(nowTimeStr, for: .normal)
        DateButton.setTitleColor(UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0), for: .normal)
        // PaySelect
        PaySelect.setTitle("支出", forSegmentAt: 0)
        PaySelect.setTitle("收入", forSegmentAt: 1)
        PaySelect.setTitleTextAttributes([kCTFontAttributeName:UIFont.systemFont(ofSize: 32)], for: .normal)
        PaySelect.tintColor = UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0)
        // itemSelect
        itemSelect.setTitle("餐飲", forSegmentAt: 0)
        itemSelect.setTitle("服飾", forSegmentAt: 1)
        itemSelect.insertSegment(withTitle: "生活", at: 2, animated: false)
        itemSelect.insertSegment(withTitle: "交通", at: 3, animated: false)
        itemSelect.insertSegment(withTitle: "教育", at: 4, animated: false)
        itemSelect.insertSegment(withTitle: "娛樂", at: 5, animated: false)
        itemSelect.tintColor = UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0)
   
        itemSelect.setTitleTextAttributes([kCTFontAttributeName:UIFont.systemFont(ofSize: 32)], for: .normal)

        // APayView
        self.APayView.backgroundColor = UIColor(red:0.95, green:1.00, blue:0.97, alpha:1.0)
        // APaytitle
        APaytitle.textColor = UIColor.white
        APaytitle.backgroundColor = UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0)
        // textField
        Name_textField.delegate = self
        Name_textField.clearButtonMode = .unlessEditing
        Name_textField.keyboardType = UIKeyboardType.default
        Name_textField.returnKeyType = UIReturnKeyType.done
        Money_textField.delegate = self
        Money_textField.clearButtonMode = .unlessEditing
        Money_textField.keyboardType = UIKeyboardType.numberPad
        Money_textField.returnKeyType = UIReturnKeyType.done
        // Button
        returnButton.setTitleColor(UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0), for: .normal)
        CancelButton.setTitleColor(UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0), for: .normal)
        
        let Lineimage: UIImage = UIImage.init(named: "分隔線.png")!
        Line1.frame = CGRect.init( x: Line1.frame.origin.x, y:   Line1.frame.origin.y, width: 648.0, height: 35.0)
        Line1.image = Lineimage
        Line2.frame = CGRect.init( x: Line2.frame.origin.x, y:   Line2.frame.origin.y, width: 648.0, height: 35.0)
        Line2.image = Lineimage
        Line3.frame = CGRect.init( x: Line3.frame.origin.x, y:   Line3.frame.origin.y, width: 648.0, height: 35.0)
        Line3.image = Lineimage
        Line4.frame = CGRect.init( x: Line4.frame.origin.x, y:   Line4.frame.origin.y, width: 648.0, height: 35.0)
        Line4.image = Lineimage
        
        let dateicon: UIImage = UIImage.init(named: "calendar.png")!
        date.frame = CGRect.init( x: date.frame.origin.x, y:   date.frame.origin.y, width: 65.0, height: 65.0)
        date.image = dateicon
        
        let payorincomeicon: UIImage = UIImage.init(named: "payorincome.png")!
        Payorincome.frame = CGRect.init( x: Payorincome.frame.origin.x, y:   Payorincome.frame.origin.y, width: 65.0, height: 65.0)
        Payorincome.image = payorincomeicon
        
        let attributeicon: UIImage = UIImage.init(named: "attribute.png")!
        attribute.frame = CGRect.init( x: attribute.frame.origin.x, y:   attribute.frame.origin.y, width: 65.0, height: 65.0)
        attribute.image = attributeicon
        
        let itemicon: UIImage = UIImage.init(named: "item.png")!
        item.frame = CGRect.init( x: item.frame.origin.x, y:   item.frame.origin.y, width: 65.0, height: 65.0)
        item.image = itemicon
        
        let moneyicon: UIImage = UIImage.init(named: "money-bag.png")!
        money.frame = CGRect.init( x: money.frame.origin.x, y:   money.frame.origin.y, width: 65.0, height: 65.0)
        money.image = moneyicon
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
 
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.y = keyboardFrame.minY - self.view.frame.height
                self.view.frame = frame
            })
        }
    }
    
    @IBAction func returnData(_ sender: Any?) {
        if (Name_textField.text! != "" && Money_textField.text! != "") {
            if (delegate != nil) {
                if (musicControl) { // play music
                    RecordAPayViewController.AddItemMusic?.stop()
                    RecordAPayViewController.AddItemMusic?.currentTime = 0.0
                    RecordAPayViewController.AddItemMusic?.play()
                }
                delegate?.getData(date: (DateButton.titleLabel?.text)!, pay: PaySelect.titleForSegment(at: PaySelect.selectedSegmentIndex)!, item: itemSelect.titleForSegment(at: itemSelect.selectedSegmentIndex)!, name: Name_textField.text!, money: Money_textField.text!)
            }
            self.dismiss(animated: true, completion: nil)
        } // if
    }
    
    @IBAction func returnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateSelect" {
            if sender is UIView {
                segue.destination.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
            }
            segue.destination.popoverPresentationController?.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    // 讓鍵盤按完成後可以消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 讓日期選擇器按確定後可以消失
    @IBAction func unwind(for segue: UIStoryboardSegue) {
    }

}
