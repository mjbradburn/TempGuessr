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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var city = CityList.city[index]
        cityLabel.text = city
        
        tempPicker.selectRow(100, inComponent: 0, animated: true)
        selectedTemp = tempPicker.selectedRowInComponent(0)
        
        self.nextButton.enabled  = false

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


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextScene : ScoreViewController = segue.destinationViewController as! ScoreViewController
        nextScene.gameObjectID = self.gameObjectID
        nextScene.playerID = self.playerID
        
        //Send guesses to Parse
        var game = PFQuery(className: "Game")
        game.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
            //if self.playerID! == game?.objectForKey("firstPlayer") as! String {
                game!.setValue(self.guessesArray, forKey: "firstPlayerGuessesArray")
            //} else {
                game!.setValue(self.guessesArray, forKey: "secondPlayerGuessesArray")
            //}
            game!.saveInBackground()
            println("scores added \(error)")
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (guessesArray.count == CityList.city.count){
            return true
        }
        return false
    }

    
    // MARK: - IBActions
    
    @IBAction func advanceNextScene(sender: AnyObject) {
        
        if selectedTemp == nil {
            self.nextButton.enabled = false
        } else {
            if guessesArray.count < CityList.city.count {
                index++
                var city = CityList.city[index]
                cityLabel.text = city
                
                tempPicker.selectRow(100, inComponent: 0, animated: true)
                selectedTemp = tempPicker.selectedRowInComponent(0)
                self.nextButton.enabled = false
            }
        }
    }

}// last brace
