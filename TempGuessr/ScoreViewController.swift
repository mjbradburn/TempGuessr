//
//  ScoreViewController.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/6/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import UIKit
import Parse

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var firstPlayerIDLabel: UILabel!
    @IBOutlet weak var secondPlayerIDLabel: UILabel!
    @IBOutlet weak var firstPlayerGuessLabel: UILabel!
    @IBOutlet weak var secondPlayerGuessLabel: UILabel!
    @IBOutlet weak var firstPlayerScoreLabel: UILabel!
    @IBOutlet weak var secondPlayerScoreLabel: UILabel!
    
    var gameObjectID : String?
    var playerID : String?
    var currentTempArray = [Int]()
    var firstPlayerGuessesArray = [Int]()
    var secondPlayerGuessesArray = [Int]()
    var firstPlayerScore : Int?
    var secondPlayerScore : Int?
    var randomCities = [String]()
    var index = 0
    var currentTemp : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.flatWhiteColorDark()
        
        var city = randomCities[index]
        cityLabel.text = city

        //get current temps from wunderground
        for city in randomCities {
            let dirtyUrl : String = "http://api.wunderground.com/api/367213135b73458e/conditions/q/\(city).json"
            let cleanUrl = dirtyUrl.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let url = NSURL(string: cleanUrl)
            let session = NSURLSession.sharedSession()
            var parseError : NSError?
            let task = session.downloadTaskWithURL(url!) {
                (loc:NSURL!, response:NSURLResponse!, error:NSError!) in
                let d = NSData(contentsOfURL: loc)!
                let parsedObject: AnyObject?  =
                NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.AllowFragments, error: &parseError)
                if let topLevelObject = parsedObject as? NSDictionary {
                    if let currentObservation = topLevelObject.objectForKey("current_observation") as? NSDictionary {
                        self.currentTemp = currentObservation.objectForKey("temp_f") as? Int
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.currentTempArray.append(self.currentTemp!)
                    }
                }
            }
            task.resume()
        }
        //get player's guesses
        var query = PFQuery(className: "Game")
        query.getObjectInBackgroundWithId(gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
            
            self.firstPlayerIDLabel.text = (game!.objectForKey("firstPlayer") as? String)
            self.firstPlayerGuessesArray = game!.objectForKey("firstPlayerGuessesArray") as! [Int]
            self.firstPlayerGuessLabel.text = String(self.firstPlayerGuessesArray[self.index])
            self.firstPlayerScore = (game!.objectForKey("firstPlayerScore") as? Int)
            
            self.secondPlayerIDLabel.text = (game!.objectForKey("secondPlayer") as? String)
            self.secondPlayerGuessesArray = game!.objectForKey("secondPlayerGuessesArray") as! [Int]
            self.secondPlayerGuessLabel.text = String(self.secondPlayerGuessesArray[self.index])
            self.secondPlayerScore = (game!.objectForKey("secondPlayerScore") as? Int)
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.currentTempLabel.text = toString(self.currentTempArray[index])
        firstPlayerScore = abs(currentTempArray[index] - firstPlayerGuessesArray[index]) + firstPlayerScore!
        firstPlayerScoreLabel.text = toString(firstPlayerScore!)
        secondPlayerScore = abs(currentTempArray[index] - secondPlayerGuessesArray[index]) + secondPlayerScore!
        secondPlayerScoreLabel.text = toString(secondPlayerScore!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextScene : GameOverViewController = segue.destinationViewController as! GameOverViewController
        nextScene.gameObjectID = self.gameObjectID
        nextScene.playerID = self.playerID
        nextScene.firstPlayerScore = self.firstPlayerScore
        nextScene.secondPlayerScore = self.secondPlayerScore
    }
    
    // MARK: - IBActions
    
    @IBAction func advanceNextScene(sender: AnyObject) {
        index++
        if index < randomCities.count {
            var city = randomCities[index]
            cityLabel.text = city
            self.currentTempLabel.text = toString(self.currentTempArray[index])
            
            self.firstPlayerGuessLabel.text = String(self.firstPlayerGuessesArray[self.index])
            self.secondPlayerGuessLabel.text = String(self.secondPlayerGuessesArray[self.index])
            firstPlayerScore = abs(currentTempArray[index] - firstPlayerGuessesArray[index]) + firstPlayerScore!
            firstPlayerScoreLabel.text = toString(firstPlayerScore!)
            secondPlayerScore = abs(currentTempArray[index] - secondPlayerGuessesArray[index]) + secondPlayerScore!
            secondPlayerScoreLabel.text = toString(secondPlayerScore!)
        } else {
            //perform segue to game over
            performSegueWithIdentifier("showGameOverViewController", sender: self)
        }
    }
    

}
