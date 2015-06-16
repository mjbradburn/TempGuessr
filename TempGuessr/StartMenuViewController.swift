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
import FBSDKLoginKit
import FBSDKShareKit

class StartMenuViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet weak var playerIDLabel: UILabel!
    
    var cityArray : [String] = [
        "New York City, New York",
        "Tokyo, Japan",
        "Rio De Janeiro, Brazil",
        "Jakarta, Indonesia",
        "London, United Kingdom",
        "Seoul, South Korea",
        "Dehli, India",
        "Shanghai, China",
        "Manila, Philippines",
        "Karachi, Pakistan",
        "Mexico City, Mexico",
        "Cairo, Egypt",
        "Beijing, China",
        "Mumbai, India",
        "Moscow, Russia",
        "Los Angeles, CA",
        "Istanbul, Turkey",
        "Lagos, Nigeria",
        "Paris, France",
        "Lima, Peru",
        "Chicago, IL",
        "Johannesburg, South Africa",
        "Tehran, Iran",
        "Toronto, Canada",
        "San Fransisco, CA",
        "Milan, Italy",
        "Miami, FL",
        "Detroit, MI"
    ]
    
    var playerID : String?
    var gameObjectID : String?
    var gameIsReady : Bool = false
    var playerIsGuest : Bool = false
    //var cites : PFObject?
    var randomCities : [String]?
    var playerType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        if PFUser.currentUser() == nil {
//            var loginVC = PFLogInViewController()
//            loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.Facebook | PFLogInFields.SignUpButton 
//            loginVC.facebookPermissions = ["friends_about_me"]
//            loginVC.delegate = self
//            
//            var signupVC = PFSignUpViewController()
//            signupVC.delegate = self
//            loginVC.signUpController = signupVC
//            
//            self.presentViewController(loginVC, animated: true, completion: nil)
//        } else {
//            self.playerID = PFUser.currentUser()?.username
//            self.playerIDLabel.text = playerID!
//        }
//
//        
//        //check for updates to parse game object
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNextScene", name: "startGame", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
//        if PFUser.currentUser() == nil {
//            var loginVC = PFLogInViewController()
//            loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.Facebook
//            loginVC.facebookPermissions = ["friends_about_me"]
//            loginVC.delegate = self
//            
//            var signupVC = PFSignUpViewController()
//            signupVC.delegate = self
//            loginVC.signUpController = signupVC
//            
//            self.presentViewController(loginVC, animated: true, completion: nil)
//        } else {
//            self.playerID = PFUser.currentUser()?.username
//            self.playerIDLabel.text = playerID!
//        }
//        
//        
//        //check for updates to parse game object
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNextScene", name: "startGame", object: nil)
    }
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() == nil {
            var loginVC = PFLogInViewController()
            loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.Facebook | PFLogInFields.Twitter
            loginVC.delegate = self
            
            loginVC.facebookPermissions = ["basic_info"]
            
            var signupVC = PFSignUpViewController()
            signupVC.delegate = self
            loginVC.signUpController = signupVC
            
            self.presentViewController(loginVC, animated: true, completion: nil)
        } else {
            self.playerID = PFUser.currentUser()?.username
            self.playerIDLabel.text = playerID!
        }
        
        
        //check for updates to parse game object
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNextScene", name: "startGame", object: nil)
        
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
        if (PFTwitterUtils.isLinkedWithUser(user)) {
            var twitterUsername = PFTwitterUtils.twitter()?.screenName
            PFUser.currentUser()?.username = twitterUsername
            PFUser.currentUser()?.saveEventually(nil)
        } else if (PFFacebookUtils.isLinkedWithUser(user)) {
            println("logged in via FB")
            let profileRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            profileRequest.startWithCompletionHandler({(connection, result, error: NSError!) -> Void in
                if error == nil {
                    println(result.objectForKey("first_name"))
                    PFUser.currentUser()?.username = result.objectForKey("first_name") as? String
                    PFUser.currentUser()?.saveEventually(nil)
                } else {
                    println("\(error)")
                }
            })

        }
        
        self.playerID = PFUser.currentUser()?.username
        self.playerIDLabel.text = self.playerID!
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println(error)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        println("user cancelled login")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        //set playerID and display username
        self.playerID = PFUser.currentUser()?.username
        self.playerIDLabel.text = self.playerID!
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
                
                //add random cities
                self.cityArray.shuffled()
                self.randomCities = self.cityArray.choose(2)
                newGame["citiesArray"] = self.randomCities
                
                newGame.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                    if (success){
                        self.gameObjectID =  newGame.objectId
                        request["gameObjectID"] = newGame.objectId
                        request.saveInBackground()
                        println("game added \(self.gameObjectID)")
                        
                        //set channel to be notified when game is fulfilled
                        var channel : String = "\(self.playerID!)\(self.gameObjectID!)"
                        println("channel is: \(channel)")
                        PFPush.subscribeToChannelInBackground(channel)
                        var alert = UIAlertView(title: "TempGuessr", message: "Finding a match...we'll notify you", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                        self.gameIsReady = false
                        self.playerType = "first"
                    }
                }
            } else {
                //make a match
                self.gameObjectID = object?.objectForKey("gameObjectID") as? String
                object?.deleteInBackground()
                var newGame = PFQuery(className: "Game")
                newGame.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
                    game!.setValue(self.playerID, forKey: "secondPlayer")
                    game!.saveInBackground()
                    
                    //push notification to host
                    var host = game!.objectForKey("firstPlayer") as? String
                    var push : PFPush = PFPush()
                    var data : NSDictionary = ["alert":"Your game is on!", "badge":"0", "content-available":"1", "sound":""]
                    push.setChannel("\(host!)\(self.gameObjectID!)")
                    //push.setMessage("Your game is on!")
                    push.setData(data as [NSObject : AnyObject])
                    push.sendPushInBackground()
                    println("send game is on push")
                    self.playerType = "second"
                    //segue to guess scene
                    self.showNextScene()
                }
            }
        }
    }

    func showNextScene(){
        gameIsReady = true
        performSegueWithIdentifier("showGuessViewController", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var nextScene : GuessViewController = segue.destinationViewController as! GuessViewController
        nextScene.gameObjectID = self.gameObjectID
        nextScene.playerID = self.playerID
        nextScene.playerType = self.playerType
        
        //get city array from Parse
        var game = PFQuery(className: "Game")
//        game.getObjectInBackgroundWithId(self.gameObjectID!) {(game: PFObject?, error: NSError?) -> Void in
//            self.randomCities = game?.objectForKey("citiesArray") as? Array
//            nextScene.randomCities = self.randomCities!
//        }
        
        var thisGame = game.getObjectWithId(self.gameObjectID!)
        self.randomCities = thisGame!.objectForKey("citiesArray") as? Array
        nextScene.randomCities = self.randomCities!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return gameIsReady ? true : false
    }
    
    // - MARK - IBActions
    
    @IBAction func logOut(sender: AnyObject) {
        var loginVC = PFLogInViewController()
        loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.Facebook | PFLogInFields.Twitter
        //loginVC.facebookPermissions = ["basic_info"]
        loginVC.delegate = self
        
        var signupVC = PFSignUpViewController()
        signupVC.delegate = self
        loginVC.signUpController = signupVC
        
        self.presentViewController(loginVC, animated: true, completion: nil)
        PFUser.logOutInBackground()
//        var loginVC = PFLogInViewController()
//        loginVC.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton
//        loginVC.delegate = self
//        
//        var signupVC = PFSignUpViewController()
//        signupVC.delegate = self
//        loginVC.signUpController = signupVC
//        
//        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func quitGame(sender: AnyObject) {
        
    }
    
    
    
    
    
    
    
    
} //class closing brace

