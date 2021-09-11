//
//  SelectDate.swift
//  ChickenMoneyManager
//
//  Created by Mac on 2019/1/1.
//  Copyright © 2019年 CYCU. All rights reserved.
//

import UIKit

class SelectDate: UIViewController {
    var pickDateStr = ""
    
    @IBOutlet var SelectButton: UIButton!
    @IBOutlet var myDatePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        SelectButton.setTitleColor(UIColor(red:0.48, green:0.78, blue:0.58, alpha:1.0), for: .normal)
        // Do any additional setup after loading the view.
    }

    @IBAction func myDatePickerAction(_ sender: UIDatePicker) {
        let date_formater = DateFormatter()
        date_formater.dateFormat = "yyyy/MM/dd"
        pickDateStr = date_formater.string(from: myDatePicker.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let nowTimeStr = dateFormatter.string(from: Date())
        let RecordVC = segue.destination as! RecordAPayViewController
        if (pickDateStr == "") {
            RecordVC.DateButton.setTitle(nowTimeStr, for: .normal)
        } // if
        else {
            RecordVC.DateButton.setTitle(pickDateStr, for: .normal)
        } // else
    }

}
