//
//  GuessViewController.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/6/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import UIKit
import Parse

class GuessViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempPicker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    
    var gameObjectID : String?
    var playerID : String?
    var guessesArray = [Int]()
    var selectedTemp : Int?
    let pickerTempArray = [Int](-50...100)
    var index = 0
    var gameIsReady = false
    var otherPlayerFinishedStatus = false
    var playerType : String?
    var randomCities : [String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "sky.jpg")!)
        self.view.backgroundColor = UIColor.flatWhiteColorDark()

        var city = randomCities?[index]
        cityLabel.text = city
        
        tempPicker.selectRow(100, inComponent: 0, animated: true)
        selectedTemp = tempPicker.selectedRowInComponent(0)
        
        self.nextButton.enabled  = false
        
        //set channel to be notified when other player is finished
        var channel : String?
        if playerType == "first" {
            channel = "firstPlayer\(self.gameObjectID!)"
        } else {
            channel = "secondPlayer\(self.gameObjectID!)"
        }
        PFPush.subscribeToChannelInBackground(channel)
        
        //add a listener for notification to advance to scoreVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateOtherPlayerFinishedStatus", name: "startGame", object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Picker delegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTempArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(pickerTempArray[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case -50...150:
            selectedTemp = row - 50
            guessesArray.insert(selectedTemp!, atIndex: index)
            if guessesArray.count > index + 1 {
                guessesArray.removeLast()
            }
            self.nextButton.enabled = true
        default:
            selectedTemp = nil
            self.nextButton.enabled = false
        }
    }
    
    func updateOtherPlayerFinishedStatus(){
        println("other player finished")
        otherPlayerFinishedStatus = true
        
        //if user was already waiting force next scene
        if guessesArray.count == randomCities!.count {
            performSegueWithIdentifier("showScoreViewController", sender: self)
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextScene : ScoreViewController = segue.destinationViewController as! ScoreViewController
        nextScene.gameObjectID = self.gameObjectID
        nextScene.playerID = self.playerID
        nextScene.randomCities = self.randomCities!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (guessesArray.count == randomCities!.count && otherPlayerFinishedStatus ){
            return true
        } else {
            return false
        }
    }

    
    // MARK: - IBActions
    
    @IBAction func advanceNextScene(sender: AnyObject) {
        
        if selectedTemp == nil {
            self.nextButton.enabled = false
        } else if guessesArray.count < randomCities!.count {
            index++
            var city = randomCities?[index]
            cityLabel.text = city
            
            tempPicker.selectRow(100, inComponent: 0, animated: true)
            
            var game = PFQuery(className: "Game")
            game.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
                if self.playerID! == game?.objectForKey("firstPlayer") as! String {
                    game!.setValue(self.guessesArray, forKey: "firstPlayerGuessesArray")
                } else {
                    game!.setValue(self.guessesArray, forKey: "secondPlayerGuessesArray")
                }
                game!.saveInBackground()
            }
            
            selectedTemp = tempPicker.selectedRowInComponent(0)
            self.nextButton.enabled = false
        } else if guessesArray.count == randomCities!.count && !otherPlayerFinishedStatus {
            
            var game = PFQuery(className: "Game")
            game.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
                if self.playerID! == game?.objectForKey("firstPlayer") as! String {
                    game!.setValue(self.guessesArray, forKey: "firstPlayerGuessesArray")
                } else {
                    game!.setValue(self.guessesArray, forKey: "secondPlayerGuessesArray")
                }
                game!.saveInBackground()
            }
            
            //send notification to other player that you are ready
            if playerType == "first" {
                var push : PFPush = PFPush()
                var data : NSDictionary = ["content-available":"2", "sound":"halfsec.mp3"]
                push.setChannel("secondPlayer\(self.gameObjectID!)")
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
            } else if playerType == "second" {
                var push : PFPush = PFPush()
                var data : NSDictionary = ["content-available":"2", "sound":"halfsec.mp3"]
                push.setChannel("firstPlayer\(self.gameObjectID!)")
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
            }
            
            //show waiting animation until other player notifies they are finished
            if !otherPlayerFinishedStatus {
                    let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    progressHUD.labelText = "Waiting for other player"
                    progressHUD.mode = MBProgressHUDMode.Indeterminate
            }
        } else if guessesArray.count == randomCities!.count && otherPlayerFinishedStatus {
            
            var game = PFQuery(className: "Game")
            game.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
                if self.playerID! == game?.objectForKey("firstPlayer") as! String {
                    game!.setValue(self.guessesArray, forKey: "firstPlayerGuessesArray")
                } else {
                    game!.setValue(self.guessesArray, forKey: "secondPlayerGuessesArray")
                }
                game!.saveInBackground()
            }
            
            //send notification to other player that you are ready
            if playerType == "first" {
                var push : PFPush = PFPush()
                var data : NSDictionary = ["content-available":"2", "sound":"halfsec.mp3"]
                push.setChannel("secondPlayer\(self.gameObjectID!)")
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
            } else if playerType == "second" {
                var push : PFPush = PFPush()
                var data : NSDictionary = ["content-available":"2", "sound":"halfsec.mp3"]
                push.setChannel("firstPlayer\(self.gameObjectID!)")
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackground()
            }
            
            
            performSegueWithIdentifier("showScoreViewController", sender: self)
            //MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
        }
    }


}// last brace
