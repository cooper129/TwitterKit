//
//  ViewController.swift
//  TwitProj
//
//  Created by Yasir on 1/1/18.
//  Copyright © 2018 Yacir. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore

class ViewController: UIViewController, TWTRComposerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func btnLoginPressed(_ sender: UIButton) {
        
     
        TwitterAPIManager.loginIfNeeded { (error) in
        
            if (error != nil) {
                print("some error occured == \(String(describing: error?.localizedDescription))")
            }else{
                print("no error occured, LOGIN complete")
            }
            
        }
    }
    */
    
    @IBAction func btnTwitterSharePressed(_ sender: UIButton) {
        
        if (Twitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
           
            guard let shareImg2 = UIImage.init(named: "uk") else{
                print("failed init share img")
                return
            }
            //let shareImg = UIImage.init(named: "mountain")!
            let composer = TWTRComposerViewController.init(initialText: "UK flag picture will be tweeted", image: shareImg2, videoURL: nil)
            composer.delegate = self
            present(composer, animated: true, completion: nil)
            
        } else {
            // Log in, and then check again
            Twitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    
                    guard let shareImg2 = UIImage.init(named: "usa") else{
                        print("failed init share img")
                        return
                    }
                    //let shareImg = UIImage.init(named: "mountain")!
                    let composer = TWTRComposerViewController.init(initialText: "USA flag picture will be tweeted", image: shareImg2, videoURL: nil)
                    composer.delegate = self
                    self.present(composer, animated: true, completion: nil)
                    
                    
                    
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        
    }
    
    //MARK:- TWTRComposerViewControllerDelegate
    
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        print("composerDidCancel, composer cancelled tweet")
    }
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        print("composerDidSucceed tweet published")
    }
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        print("composerDidFail, tweet publish failed == \(error.localizedDescription)")
    }
    

}

