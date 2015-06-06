//
//  StartMenuViewController.swift
//  TempGuessr
//
//  Created by Mark J Bradburn on 6/5/15.
//  Copyright (c) 2015 Mark J Bradburn. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class StartMenuViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet weak var playerIDLabel: UILabel!
    
    var playerID : String?
    var gameObjectID : String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check for updates to parse game object
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "reloadTimeLine", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PFUser.currentUser() == nil {
            var loginVC = PFLogInViewController()
            loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton
            loginVC.delegate = self
            
            var signupVC = PFSignUpViewController()
            signupVC.delegate = self
            loginVC.signUpController = signupVC
            
            self.presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        //called when user enters
        if count(username) > 0 && count(password) > 0{
            return true
        } else {
            var alert = UIAlertView(title: "Missing info", message: "Fields cannot be blank", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        //when user logs in dismiss login view controller
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //set playerID and display username
        self.playerID = PFUser.currentUser()?.username
        self.playerIDLabel.text = self.playerID!
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //set playerID and display username
        self.playerID = PFUser.currentUser()?.username
        self.playerIDLabel.text = self.playerID!
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        
        var alert = UIAlertView(title: "Sign Up Failed", message: "\(error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    
    // - MARK - IBActions
    
    @IBAction func requestMatch(sender: UIButton) {
        var matchQuery = PFQuery(className: "Request")
        matchQuery.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
        if (error?.code == 101){
            //add a request with 1/2 game to queue
            let request = PFObject(className: "Request")
            request["hostUsername"] = self.playerID
            var newGame = PFObject(className: "Game")
            newGame["firstPlayer"] = self.playerID
            newGame["secondPlayer"] = ""
            newGame["firstPlayerScore"] = 0
            newGame["secondPlayerScore"] = 0
            newGame.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                if (success){
                    self.gameObjectID =  newGame.objectId
                    request["gameObjectID"] = newGame.objectId
                    request.saveInBackground()
                    println("game added \(self.gameObjectID)")
                    
                    //set channel to be notified when game is fulfilled
                    var channel : String = "\(self.playerID!)\(self.gameObjectID!)"
                    println(channel)
                    PFPush.subscribeToChannelInBackground(channel)
                    var push : PFPush = PFPush()
                    push.setChannel(channel)
                    push.setMessage("No game yet...we'll notify you")
                    push.sendPushInBackground()

                }
            }
        } else {
            //make a match
            self.gameObjectID = object?.objectForKey("gameObjectID") as? String
            object?.deleteEventually()
            var newGame = PFQuery(className: "Game")
            newGame.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
                game!.setValue(self.playerID, forKey: "secondPlayer")
                game!.saveInBackground()
                
                //push notification to host
                var host = game!.objectForKey("firstPlayer") as? String
                var push : PFPush = PFPush()
                push.setChannel("\(host!)\(self.gameObjectID!)")
                push.setMessage("Your game is on!")
                push.sendPushInBackground()
            }
            }
        
        
        }
    }
    
//        var matchQuery = PFQuery(className: "Request")
//        matchQuery.getFirstObjectInBackgroundWithBlock{(object: PFObject?, error: NSError?) -> Void in
//            if (error?.code == 101){
//                //add a request with 1/2 game to queue
//                let request = PFObject(className: "Request")
//                request["hostUserName"] = self.playerID
//                var newGame = PFObject(className: "Game")
//                newGame["firstPlayer"] = self.playerID
//                newGame["secondPlayer"] = ""
//                newGame["firstPlayerScore"] = 0
//                newGame["secondPlayerScore"] = 0
//                newGame.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
//                    if success{
//                        self.gameObjectID =  newGame.objectId
//                        request["gameObjectID"] = newGame.objectId
//                        request.saveInBackground()
//                        println("game added \(self.gameObjectID)")
//                    }
//                }
    
//
//    }
//    
//                
//            } else {
//                //make a match
//                self.gameObjectID = object?.objectForKey("gameObjectID") as? String
//                object?.deleteEventually()
//                var newGame = PFQuery(className: "Game")
//                newGame.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
//                    game!.setValue(self.playerID, forKey: "secondPlayer")
//                    game!.saveInBackground()
//                    
//                    //push notification to host
//                    var host = game!.objectForKey("hostUsername") as? String
//                    var push : PFPush = PFPush()
//                    push.setChannel(host! + self.gameObjectID!)
//                    push.sendPushInBackground()
//                }
//            }
//        }
//    }
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackground()
        var loginVC = PFLogInViewController()
        loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton
        loginVC.delegate = self
        
        var signupVC = PFSignUpViewController()
        signupVC.delegate = self
        loginVC.signUpController = signupVC
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func quitGame(sender: AnyObject) {
        
    }
    
    
    
    
    
    
    
    
    
}

