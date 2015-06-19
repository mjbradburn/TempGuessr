//
//  GameOverViewController.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/6/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import UIKit
import Parse

class GameOverViewController: UIViewController {
    
    var gameObjectID : String?
    var playerID : String?
    var firstPlayerScore : Int?
    var secondPlayerScore : Int?
    var firstPlayerID : String?
    var secondPlayerID : String?
    var message = ""
    var firstPlayerWins = false
    var secondPlayerWins = false
    
    @IBOutlet weak var winnerMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.view.backgroundColor = UIColor.flatWhiteColorDark()
        
        var game = PFQuery(className: "Game")
        game.getObjectInBackgroundWithId(gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
            
            game!.setValue(self.firstPlayerScore!, forKey: "firstPlayerScore")
            game!.setValue(self.secondPlayerScore!, forKey: "secondPlayerScore")
            game!.saveInBackground()
            
            self.firstPlayerID = (game!.objectForKey("firstPlayer") as? String)
            self.secondPlayerID = (game!.objectForKey("secondPlayer") as? String)
            
            if self.firstPlayerScore < self.secondPlayerScore {
                self.message = "\(self.firstPlayerID!) wins!"
                self.winnerMessage.text = self.message
                self.firstPlayerWins = true
            } else if self.secondPlayerScore < self.firstPlayerScore {
                self.message = "\(self.secondPlayerID!) wins!"
                self.winnerMessage.text = self.message
                self.secondPlayerWins = true
            } else {
                self.winnerMessage.text = "It's a dead heat!"
            }
            
            //send data to Today Extension
            var defaults = NSUserDefaults(suiteName: "group.bradburn.bradburn.com.TempGuessr")
            var todayMessage : String = ""
            
            
            if self.playerID == self.firstPlayerID  {
                if self.firstPlayerWins {
                    todayMessage = "You defeated \(self.secondPlayerID!)"
                } else if self.secondPlayerWins {
                    todayMessage = "You lost to \(self.secondPlayerID!)"
                }
            } else if self.playerID  == self.secondPlayerID {
                if self.firstPlayerWins {
                    todayMessage = "You lost to \(self.firstPlayerID!)"
                } else if self.secondPlayerWins {
                    todayMessage = "You defeated \(self.firstPlayerID!)"
                }
            }
            defaults?.setValue(todayMessage, forKey: "today")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
