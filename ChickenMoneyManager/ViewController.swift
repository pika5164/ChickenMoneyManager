//
//  ViewController.swift
//  ChickenMoneyManager
//
//  Created by Mac on 2018/12/23.
//  Copyright © 2018年 CYCU. All rights reserved.
//

import UIKit
import SQLite
import AVFoundation

class ViewController: UIViewController {
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
    
    // database
    var isTap = false
    @IBOutlet var pRootView: UIView!
    @IBOutlet var GrassBackGround: UIImageView!
    
    @IBOutlet var ChickenButton: UIButton!
    @IBOutlet var OurChicken: UIImageView!
    @IBOutlet var ChickenSays: UIImageView!
    @IBOutlet var say_word: UILabel!
    
    @IBOutlet var Money: UILabel!
    @IBOutlet var coin: UIImageView!
    @IBOutlet var fries: UIImageView!
    @IBOutlet var hunger: UILabel!
    @IBOutlet var level: UIImageView!
    @IBOutlet var levelup: UILabel!
    
    @IBOutlet var GiveFood: UIButton!
    @IBOutlet var LevelUpbutton: UIButton!
    @IBOutlet var ShopButton: UIButton!
    @IBOutlet var SoundOnandOffButton: UIButton!
    
    @IBOutlet var ShopView: UIView!
    @IBOutlet var FoodLevelupButton: UIButton!
    @IBOutlet var PowerLevelUpButton: UIButton!
    @IBOutlet var MoneyLevelUpButton: UIButton!
    @IBOutlet var CancelButton: UIButton!
    @IBOutlet var chickinshop: UIImageView!
    @IBOutlet var stickpaste1: UIImageView!
    @IBOutlet var stickpaste2: UIImageView!
    @IBOutlet var stickpaste3: UIImageView!
    
    @IBOutlet var HiddenEvolutionView: UIView!
    @IBOutlet var YesEvolution: UIButton!
    @IBOutlet var NoEvolution: UIButton!
    @IBOutlet var warninglabel: UILabel!
    @IBAction func SwitchChicken(_ sender: Any) {
    }
    var nowMoney:Int = 0
    var nowHungry:Int = 0
    var nowLevel:Int = 0
    var nowState:Int = 0
    var money_increase:Int = 0
    var hungry_increase:Int = 0
    var levelup_increase:Int = 0
    
    static var ChickenBGMMusic: AVAudioPlayer?
    static var EatMusic: AVAudioPlayer?
    static var LevelUpMusic: AVAudioPlayer?
    static var isPlayingMusic = true
    
    let saying_words = ["我好餓喔🍗", "今天心情還好嗎？", "能夠吃東西就很開心❤️",
                        "今天也要好好加油哦😊", "心情不好可以去看看電影", "天氣涼了記得多穿衣服",
                        "沒事就看看書吧！", "商店有升級的選項可以購買哦~", "今天記帳了嗎？",
                        "要確實記錄唷！", "假日可以多出門走走！", "今日事今日畢！把握每一天",
                        "在非洲每過60秒，就有一分鐘過去", "有人打你右臉，那就左臉也讓他打",
                        "今天喝水了嗎？記得多喝水哦", "三年不見，如隔三秋",
                        "一人做事一人當，小叮做事小叮噹", "開心是一天，悲傷也是一天，這樣就兩天了"]
    
    func ChangeSaying(_words: String ) {
        let saying: UIImage = UIImage.init(named: "對話框.png")!
        ChickenSays.frame = CGRect.init( x: ChickenSays.frame.origin.x, y:   ChickenSays.frame.origin.y, width: 240.0, height: 240.0)
        ChickenSays.image = saying
        if ( nowState == 0 ) {
            say_word.text = "..."
        } // if
        else {
            say_word.text = _words
        } // else
        isTap = true
    }
    
    @IBAction func tap(_ sender: Any) {
        let saying_num = Int(arc4random_uniform(17))
        if ( isTap == true ) {
            ChickenSays.image = UIImage.init()
            say_word.text = ""
            isTap = false
        } // if
        else if ( isTap == false && hunger.text != "  🍗🍗🍗🍗🍗"){
            ChangeSaying(_words: saying_words[saying_num])
        } // else if
        else {
            ChangeSaying(_words: "我已經吃飽了！")
        } // else
    }
    
    @IBAction func ClickGiveFoodButton(_ sender: Any) {
        if ( hunger.text == "  🍗🍗🍗🍗🍗") {
            ChangeSaying(_words: "我已經吃飽了！")
        } // if
        else if ( nowMoney >= (500-100*hungry_increase) ) {
            ChangeSaying(_words: "謝謝你的食物❤️")
            if ( ViewController.isPlayingMusic ) {
                ViewController.EatMusic?.stop()
                ViewController.EatMusic?.currentTime = 0.0
                ViewController.EatMusic?.play()
            } // if
            self.GiveFoodAction()
        } // else if
        else {
            ChangeSaying(_words: "錢不夠呢，再多花一點錢吧")
        } // else
    }
    
    @IBAction func ClickLevelUpButton(_ sender: Any) {
        if ( hunger.text != "  🍗🍗🍗🍗🍗") {
            ChangeSaying(_words: "我要再多吃一點才能長大！")
        } // if
        else if ( nowMoney >= (1000-100*levelup_increase) ) {
            if ( ViewController.isPlayingMusic ) {
                ViewController.LevelUpMusic?.stop()
                ViewController.LevelUpMusic?.currentTime = 0.0
                ViewController.LevelUpMusic?.play()
            } // if
            self.LevelUpAction()
        } // else if
        else { // 錢不夠升等
            ChangeSaying(_words: "錢不夠呢，再多花一點錢吧")
        } // else
    }
    
    func GiveFoodAction() {
        if (nowHungry < 5 && nowMoney >= (500-100*hungry_increase)) {
            nowMoney = nowMoney - (500-100*hungry_increase)
            Money.text = String(nowMoney)
            updateChickenState(dataID: 0, dataNum:1) // 更新database
            nowHungry = nowHungry + 1
            hunger.text = hunger.text!+"🍗"
            updateChickenState(dataID: 0, dataNum:2) // 更新database
        }
    }
    
    func LevelUpAction() {
        if (nowHungry == 5 && nowMoney >= (1000-100*levelup_increase)) {
            nowMoney = nowMoney - (1000-100*levelup_increase)
            Money.text = String(nowMoney)
            updateChickenState(dataID: 0, dataNum:1) // 更新database
            nowHungry = 0
            hunger.text = "  "
            updateChickenState(dataID: 0, dataNum:2) // 更新database
            nowLevel = nowLevel + 1
            levelup.text = String(nowLevel)
            updateChickenState(dataID: 0, dataNum:3) // 更新database
            ChangeSaying(_words: "升等！")
            // 這裡判斷小雞的等級 然後要做進化
            if ( nowLevel == 5 ) {
                nowState = 1
                ChangeSaying(_words: "喔YA！")
            } // if
            else if ( nowLevel == 15 ) {
                nowState = 2
                ChangeSaying(_words: "變身！")
            } // else if
            else if ( nowLevel == 30 ) {
                nowState = 3
                ChangeSaying(_words: "我長大囉")
            } // else if
            else if ( nowState == 3 && nowLevel > 30 && nowLevel % 5 == 0 &&
                      money_increase == 5 && hungry_increase == 4 && levelup_increase == 5) {
                // 計算總餐飲金額
                var sum:Int = 0
                do {
                    let eats = try self.db.prepare(self.moneyTable)
                    for eat in eats {
                        if (eat[self.item] == "餐飲") {
                            sum = sum + eat[self.money]!
                        }
                    }
                } catch {
                    print(error)
                }
                if (sum >= 100000) {
                    // 詢問隱藏進化
                    ChangeSaying(_words: "覺得身體怪怪的...吃太多東西了嗎")
                    for Hidden_constant in view.constraints {
                        if ( Hidden_constant.identifier == "hiddenbottom" ){
                            Hidden_constant.constant = -125
                            break
                        }
                    }
                    
                    UIView.animate(withDuration: 0.5) {
                        self.view.layoutIfNeeded()
                    }
                }
            } // else if
            
            updateChickenState(dataID: 0, dataNum:4) // 更新database
            
            var chicken: UIImage = UIImage.init()
            if ( nowState == 0) {
                chicken = UIImage.init(named: "egg.png")!
                OurChicken.frame = CGRect.init( x: OurChicken.frame.origin.x, y:   OurChicken.frame.origin.y, width: 273.0, height: 301.0)
            } // if
            else if ( nowState == 1 ) {
                chicken = UIImage.init(named: "破殼小雞.png")!
                OurChicken.frame = CGRect.init( x: 280, y: 355, width: 400.0, height: 400.0)
            } // else if
            else if ( nowState == 2 ) {
                chicken = UIImage.init(named: "小雞.png")!
                OurChicken.frame = CGRect.init( x: 250, y: 310, width: 400.0, height: 550.0)
            } // else if
            else if ( nowState == 3 ) {
                chicken = UIImage.init(named: "big_chicken.png")!
                OurChicken.frame = CGRect.init( x: 120, y: 200, width: 625.0, height: 625.0)
            } // else if
            else if ( nowState == 4 ) {
                chicken = UIImage.init(named: "火雉雞.png")!
                OurChicken.frame = CGRect.init( x: 300, y: 300, width: 350, height: 530.0)
            } // else if
            
            OurChicken.image = chicken // 更新小雞雞的圖片
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(ShopView)
        ShopView.translatesAutoresizingMaskIntoConstraints = false
        ShopView.heightAnchor.constraint(equalToConstant: 330).isActive = true
        ShopView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:50).isActive = true
        ShopView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-50).isActive = true
        let c = ShopView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:330)
        c.identifier = "bottom"
        c.isActive = true
        ShopView.layer.cornerRadius = 10
        
        // 商店裡
        ShopView.backgroundColor = UIColor(patternImage: UIImage(named:"木桌.png")!)
        let shopchick:UIImage = UIImage(named: "商店小雞.png")!
        chickinshop.frame = CGRect.init( x: chickinshop.frame.origin.x, y:   chickinshop.frame.origin.y, width: 280, height: 80.0)
        chickinshop.image = shopchick
        
        let sticky:UIImage = UIImage(named: "便利貼.png")!
        stickpaste1.frame = CGRect.init( x: stickpaste1.frame.origin.x, y:   stickpaste1.frame.origin.y, width: 180.0, height: 115.0)
        stickpaste2.frame = CGRect.init( x: stickpaste2.frame.origin.x, y:   stickpaste2.frame.origin.y, width: 180.0, height: 115.0)
        stickpaste3.frame = CGRect.init( x: stickpaste3.frame.origin.x, y:   stickpaste3.frame.origin.y, width: 180.0, height: 115.0)
        stickpaste1.image = sticky
        stickpaste2.image = sticky
        stickpaste3.image = sticky
        // 商店裡
        
        view.addSubview(HiddenEvolutionView)
        HiddenEvolutionView.translatesAutoresizingMaskIntoConstraints = false
        HiddenEvolutionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        HiddenEvolutionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:200).isActive = true
        HiddenEvolutionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-200).isActive = true
        let Hidden_constant = HiddenEvolutionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:200)
        Hidden_constant.identifier = "hiddenbottom"
        Hidden_constant.isActive = true
        HiddenEvolutionView.layer.cornerRadius = 10
        warninglabel.text = "你已達成條件\n是否讓小雞進入下個階段?"
        
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func ClickShopButton(_ sender: Any) {
        for c in view.constraints {
            if ( c.identifier == "bottom" ){
                c.constant = -175
                break
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBOutlet var levelup_description: UILabel!
    @IBOutlet var levelup_useTime: UILabel!
    @IBAction func ClickPowerUpButton(_ sender: Any) {
        if (nowMoney >= 5000) {
            if (levelup_increase < 5) {
                nowMoney = nowMoney - 5000
                Money.text = String(nowMoney)
                self.updateChickenState(dataID: 0, dataNum: 1)
                levelup_increase = levelup_increase + 1
                self.updateChickenState(dataID: 0, dataNum: 7)
                if (levelup_increase < 5) {
                    levelup_useTime.text = "已使用次數： " + String(levelup_increase)
                } // if
                else{
                    levelup_useTime.text = "已到達上限"
                } // else
                LevelUpbutton.setTitle("升等\n-"+String(1000-100*levelup_increase), for:.normal )
            } // if
            else{
                ChangeSaying(_words: "你已經升級上限囉")
            } // else
        } // if
        else {
            ChangeSaying(_words: "錢不夠呢，再多花一點錢吧")
        } // else
        
    }
    
    @IBOutlet var hungry_description: UILabel!
    @IBOutlet var hungry_useTime: UILabel!
    @IBAction func ClickFoodLevelUpButton(_ sender: Any) {
        if (nowMoney >= 5000) {
            if (hungry_increase < 4) {
                nowMoney = nowMoney - 5000
                Money.text = String(nowMoney)
                self.updateChickenState(dataID: 0, dataNum: 1)
                hungry_increase = hungry_increase + 1
                self.updateChickenState(dataID: 0, dataNum: 6)
                if (hungry_increase < 4) {
                    hungry_useTime.text = "已使用次數： " + String(hungry_increase)
                } // if
                else{
                    hungry_useTime.text = "已到達上限"
                } // else
                GiveFood.setTitle("吃飯\n-"+String(500-100*hungry_increase), for:.normal )
            } // if
            else {
                ChangeSaying(_words: "我的食物已經是最便宜了")
            } // else
        } // if
        else {
            ChangeSaying(_words: "錢不夠呢，再多花一點錢吧")
        } // else
        
    }
    
    @IBOutlet var money_description: UILabel!
    @IBOutlet var moneyLevelup_useTime: UILabel!
    @IBAction func ClickMoneyLevelUpButton(_ sender: Any) {
        if (nowMoney >= 5000) {
            if (money_increase < 5) {
                nowMoney = nowMoney - 5000
                Money.text = String(nowMoney)
                self.updateChickenState(dataID: 0, dataNum: 1)
                money_increase = money_increase + 1
                self.updateChickenState(dataID: 0, dataNum: 5)
                if (money_increase < 5) {
                    moneyLevelup_useTime.text = "已使用次數： " + String(money_increase)
                } // if
                else{
                    moneyLevelup_useTime.text = "已到達上限"
                } // else
            } // if
            else {
                ChangeSaying(_words: "金錢提升最高就是2倍，不要貪心哦")
            } // else
        } // if
        else {
            ChangeSaying(_words: "錢不夠呢，再多花一點錢吧")
        } // else
        
    }
    
    @IBAction func ClickCancelButton(_ sender: Any) {
        for c in view.constraints {
            if ( c.identifier == "bottom" ){
                c.constant = 330
                break
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func ClickNoEvolutionButton(_ sender: Any) {
        for Hidden_constant in view.constraints {
            if ( Hidden_constant.identifier == "hiddenbottom" ){
                Hidden_constant.constant = 200
                break
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func ClickYesEvolutionButton(_ sender: Any) {
        nowState = 4
        self.updateChickenState(dataID: 0, dataNum: 4)
        let firechicken = UIImage.init(named: "火雉雞.png")!
        OurChicken.frame = CGRect.init( x: 300, y: 300, width: 350, height: 530.0)
        OurChicken.image = firechicken
        
        for Hidden_constant in view.constraints {
            if ( Hidden_constant.identifier == "hiddenbottom" ){
                Hidden_constant.constant = 200
                break
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        ChangeSaying(_words: "恭喜進化成火稚雞！")
    }
    
    func PlayMusic() {
        // 取得聲音檔的完整路徑
        do {
            ViewController.ChickenBGMMusic = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "小雞bgm", ofType: "mp3")!))
            ViewController.EatMusic = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "吃東西", ofType: "mp3")!))
            
            ViewController.LevelUpMusic = try AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "升等", ofType: "mp3")!))
        } catch {
            print("Setting fileURLWithPath to AVAudioPlayer failed.")
        }
        ViewController.ChickenBGMMusic?.prepareToPlay()
        ViewController.ChickenBGMMusic?.numberOfLoops = -1
        ViewController.ChickenBGMMusic?.volume = 0.5
        ViewController.ChickenBGMMusic?.play()
        ViewController.EatMusic?.prepareToPlay()
        ViewController.EatMusic?.numberOfLoops = 0
        ViewController.EatMusic?.volume = 1.0
        ViewController.LevelUpMusic?.prepareToPlay()
        ViewController.LevelUpMusic?.numberOfLoops = 0
        ViewController.LevelUpMusic?.volume = 1.0
        // 啟動Audio Session使這個App擁有播音的能力
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

    }
    
    @IBAction func SoundOnandOff(_ sender: Any?) {
        var soundonandofficon:UIImage
        //let RecordVC = segue.destination as! RecordAPayViewController
        
        if ( !(ViewController.ChickenBGMMusic?.isPlaying)! ) {
            soundonandofficon = UIImage(named: "speaker.png")!
            ViewController.ChickenBGMMusic?.play()
            ViewController.isPlayingMusic = true
            //RecordVC.musicControl = true
        } // if
        else {
            soundonandofficon = UIImage(named: "speaker_no.png")!
            ViewController.ChickenBGMMusic?.stop()
            ViewController.isPlayingMusic = false
            //RecordVC.musicControl = false
        } // else
        
        // forRecordmusic = ViewController.isPlayingMusic
        SoundOnandOffButton.setImage(soundonandofficon, for: .normal)
        self.view.addSubview(SoundOnandOffButton)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 準備播音樂
        SoundOnandOffButton.layer.cornerRadius = 40
        if (ViewController.ChickenBGMMusic == nil) {
            self.PlayMusic()
            ViewController.ChickenBGMMusic?.play()
        } // if
        
        // create database
        self.CreateTable(tableName: "finish2") // create DataBase

        // showData
        do {
            let datas = try self.db.prepare(self.moneyTable)
            for i in datas {
                if (i[self.dataID] == 0) {
                    nowMoney = i[self.nowAllMoney]!
                    nowHungry = i[self.nowhungry]!
                    nowLevel = i[self.nowlevel]!
                    nowState = i[self.nowstate]!
                    money_increase = i[self.money_Increase]!
                    hungry_increase = i[self.hungry_Increase]!
                    levelup_increase = i[self.levelup_Increase]!
                    break
                } // if
            }
        } catch {
            print(error)
        }
        
        Money.text = String(nowMoney)
        levelup.text = String(nowLevel)
        hunger.text = "  "
        var idx = 0
        while (idx < nowHungry) {
            hunger.text = hunger.text! + "🍗"
            idx = idx + 1
        }
        
        let chickicon = UIImage(named: "chick.png")!
        ChickenButton.setImage(chickicon, for: .normal)
        ChickenButton.imageView?.contentMode = .scaleAspectFit
        ChickenButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -80,bottom: 0,right: 0)
        ChickenButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0 )
        self.view.addSubview(ChickenButton)
        
        let background: UIImage = UIImage.init(named: "草地.png")!
        GrassBackGround.frame = CGRect.init( x: GrassBackGround.frame.origin.x, y:   GrassBackGround.frame.origin.y, width: 768.0, height: 925.0)
        GrassBackGround.image = background
 
        var chicken: UIImage = UIImage.init()
        if ( nowState == 0) {
            chicken = UIImage.init(named: "egg.png")!
            OurChicken.frame = CGRect.init( x: OurChicken.frame.origin.x+100, y:   OurChicken.frame.origin.y+100, width: 273.0, height: 301.0)
        } // if
        else if ( nowState == 1 ) {
            chicken = UIImage.init(named: "破殼小雞.png")!
            OurChicken.frame = CGRect.init( x: 280, y: 355, width: 400.0, height: 400)
        } // else if
        else if ( nowState == 2 ) {
            chicken = UIImage.init(named: "小雞.png")!
            OurChicken.frame = CGRect.init( x: 250, y: 310, width: 400.0, height: 550.0)
        } // else if
        else if ( nowState == 3 ) {
            chicken = UIImage.init(named: "big_chicken.png")!
            OurChicken.frame = CGRect.init( x: 120, y: 200, width: 625.0, height: 625)
        } // else if
        else if ( nowState == 4 ) {
            chicken = UIImage.init(named: "火雉雞.png")!
            OurChicken.frame = CGRect.init( x: 300, y: 300, width: 350, height: 530.0)
        } // else if
        
        OurChicken.image = chicken
        
        // 金錢欄
        Money.layer.borderWidth = 1
        Money.layer.borderColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        Money.layer.backgroundColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        Money.layer.cornerRadius = 20
        let coinicon: UIImage = UIImage.init(named: "coin.png")!
        coin.frame = CGRect.init( x: coin.frame.origin.x, y:   coin.frame.origin.y, width: 85.0, height: 85.0)
        coin.image = coinicon
        // 金錢欄
        
        // 飽食度欄
        hunger.layer.borderWidth = 1
        hunger.layer.borderColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        hunger.layer.backgroundColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        hunger.layer.cornerRadius = 20
        let friesicon: UIImage = UIImage.init(named: "fries.png")!
        fries.frame = CGRect.init( x: fries.frame.origin.x, y:   fries.frame.origin.y, width: 85.0, height: 85.0)
        fries.image = friesicon
        // 飽食度欄
        
        // 等級欄
        levelup.layer.borderWidth = 1
        levelup.layer.borderColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        levelup.layer.backgroundColor = UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0).cgColor
        levelup.layer.cornerRadius = 20
        let levelicon: UIImage = UIImage.init(named: "medal.png")!
        level.frame = CGRect.init( x: level.frame.origin.x, y:   level.frame.origin.y, width: 85.0, height: 85.0)
        level.image = levelicon
        // 等級欄
        
        // 餵食按鈕
        GiveFood.layer.borderWidth = 1
        GiveFood.layer.borderColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        GiveFood.layer.cornerRadius = 75
        GiveFood.titleLabel?.numberOfLines = 0
        GiveFood.layer.backgroundColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        GiveFood.setTitle("吃飯\n-"+String(500-100*hungry_increase), for:.normal )
        GiveFood.titleLabel?.textAlignment = NSTextAlignment.center
        let pizzaicon = UIImage(named: "pizza.png")!
        GiveFood.setImage(pizzaicon, for: .normal)
        GiveFood.imageView?.contentMode = .scaleAspectFit
        GiveFood.imageEdgeInsets = UIEdgeInsets(top: -pizzaicon.size.height, left: pizzaicon.size.width-26,bottom: 0,right: 0)
        GiveFood.titleEdgeInsets = UIEdgeInsets(top: pizzaicon.size.height,left: -pizzaicon.size.width,bottom: 0,right: 0 )
        self.view.addSubview(GiveFood)
        // 餵食按鈕
        
        // 升等按鈕
        LevelUpbutton.layer.borderWidth = 1
        LevelUpbutton.layer.borderColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        LevelUpbutton.layer.cornerRadius = 75
        LevelUpbutton.titleLabel?.numberOfLines = 0
        LevelUpbutton.layer.backgroundColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        LevelUpbutton.setTitle("升等\n-"+String(1000-100*levelup_increase), for:.normal )
        LevelUpbutton.titleLabel?.textAlignment = NSTextAlignment.center
        let strongicon = UIImage(named: "strong.png")!
        LevelUpbutton.setImage(strongicon, for: .normal)
        LevelUpbutton.imageView?.contentMode = .scaleAspectFit
        LevelUpbutton.imageEdgeInsets = UIEdgeInsets(top: -strongicon.size.height, left: strongicon.size.width-26,bottom: 0,right: 0)
        LevelUpbutton.titleEdgeInsets = UIEdgeInsets(top: strongicon.size.height,left: -strongicon.size.width,bottom: 0,right: 0 )
        self.view.addSubview(LevelUpbutton)
        // 升等按鈕
        
        // 商店
        ShopButton.layer.borderWidth = 1
        ShopButton.layer.borderColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        ShopButton.layer.cornerRadius = 75
        ShopButton.titleLabel?.numberOfLines = 0
        ShopButton.layer.backgroundColor = UIColor(red:0.81, green:0.71, blue:0.4, alpha:1.0).cgColor
        ShopButton.setTitle("進入\n商店", for:.normal )
        ShopButton.titleLabel?.textAlignment = NSTextAlignment.center
        let carticon = UIImage(named: "cart.png")!
        ShopButton.setImage(carticon, for: .normal)
        ShopButton.imageView?.contentMode = .scaleAspectFit
        ShopButton.imageEdgeInsets = UIEdgeInsets(top: -55, left: 0,bottom: 0,right: -40)
        ShopButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: -65,bottom: -60,right: 0 )
        self.view.addSubview(ShopButton)
        // 商店
        PowerLevelUpButton.titleLabel?.textAlignment = NSTextAlignment.center
        PowerLevelUpButton.titleLabel?.numberOfLines = 0
        PowerLevelUpButton.setTitle("力量升級\n-5000", for: .normal)
        PowerLevelUpButton.titleEdgeInsets = UIEdgeInsets(top: 20, left:0,bottom: 0,right: 0)
        levelup_description.text = "升級所需金錢減少100，最多購買五次"
        if (levelup_increase < 5) {
            levelup_useTime.text = "已使用次數： " + String(levelup_increase)
        } // if
        else{
            levelup_useTime.text = "已到達上限"
        } // else
        FoodLevelupButton.titleLabel?.textAlignment = NSTextAlignment.center
        FoodLevelupButton.titleLabel?.numberOfLines = 0
        FoodLevelupButton.setTitle("食物升級\n-5000", for: .normal)
        FoodLevelupButton.titleEdgeInsets = UIEdgeInsets(top: 20, left:0,bottom: 0,right: 0)
        hungry_description.text = "吃飯所需金錢減少100，最多購買四次"
        if (hungry_increase < 4) {
            hungry_useTime.text = "已使用次數： " + String(hungry_increase)
        } // if
        else{
            hungry_useTime.text = "已到達上限"
        } // else
        MoneyLevelUpButton.titleLabel?.textAlignment = NSTextAlignment.center
        MoneyLevelUpButton.titleLabel?.numberOfLines = 0
        MoneyLevelUpButton.setTitle("金錢升級\n-5000", for: .normal)
        MoneyLevelUpButton.titleEdgeInsets = UIEdgeInsets(top: 20, left:0,bottom: 0,right: 0)
        money_description.text = "金錢轉換率增加20%，最多購買五次"
        if (money_increase < 5) {
            moneyLevelup_useTime.text = "已使用次數： " + String(money_increase)
        } // if
        else{
            moneyLevelup_useTime.text = "已到達上限"
        } // else
        
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateChickenState(dataID: Int, dataNum:Int) {
        let id = self.moneyTable.filter(self.dataID == dataID)
        if (dataNum == 1) {
            let updateData = id.update(self.nowAllMoney <- nowMoney)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // if
        else if (dataNum == 2) {
            let updateData = id.update(self.nowhungry <- nowHungry)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
        else if (dataNum == 3) {
            let updateData = id.update(self.nowlevel <- nowLevel)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
        else if (dataNum == 4) {
            let updateData = id.update(self.nowstate <- nowState)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
        else if (dataNum == 5) {
            let updateData = id.update(self.money_Increase <- money_increase)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
        else if (dataNum == 6) {
            let updateData = id.update(self.hungry_Increase <- hungry_increase)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
        else if (dataNum == 7) {
            let updateData = id.update(self.levelup_Increase <- levelup_increase)
            do {
                try self.db.run(updateData)
            } catch {
                print(error)
            }
        } // else if
    }
}

