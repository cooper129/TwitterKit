//
//  TwitterAPIManager.swift
//  SharingSocialNets
//
//  Created by Vyacheslav Khorkov on 20/03/2017.
//  Copyright © 2017 Vyacheslav Khorkov. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterAPIManager: NSObject {

    // MARK: - Login
    
    public static func loginIfNeeded(completion: @escaping (_ error: Error?) -> Void) {
        if Twitter.sharedInstance().sessionStore.session() != nil {
            completion(nil)
            return
        }
        
        
        /*
        Twitter.sharedInstance().logIn(withMethods: .systemAccounts) { (session, error) in
            completion(error)
        }
        */
        
        Twitter.sharedInstance().logIn(completion:){ (session, error) in
            
            if (session != nil){
                print("Twitter long SESSION")
            }
            completion(error)
            
        }
        
    }
    
    public static func logOut() {
        guard let session = Twitter.sharedInstance().sessionStore.session() else {
            return
        }
        
        Twitter.sharedInstance().sessionStore.logOutUserID(session.userID)
    }
    
    // MARK: - User
    
    public static func fetchTwitterUser(completion: @escaping (_ user: TWTRUser?, _ error: Error?) -> Void) {
        guard let session = Twitter.sharedInstance().sessionStore.session() else {
            completion(nil, nil)
            return
        }
        
        let client = TWTRAPIClient.withCurrentUser()
        client.loadUser(withID: session.userID) { (user, error) in
            completion(user, nil)
        }
    }
    
    // MARK: - Follow
    
    public static func isUserFollowedUserWithScreenName(_ screenName: String,
                                                        completion: @escaping (_ followed: Bool?, _ error: Error?) -> Void) {
        let client = TWTRAPIClient.withCurrentUser()
        let url = "https://api.twitter.com/1.1/friendships/lookup.json"
        var requestError: NSError?
        let request = client.urlRequest(withMethod: "GET",
                                        url: url,
                                        parameters: ["screen_name": screenName],
                                        error: &requestError)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let json = self.nsdataToJSON(data: data) else {
                completion(nil, nil)
                return
            }
            
            guard let array = json as? Array<Dictionary<String, Any>> else {
                completion(false, nil)
                return
            }
            
            guard let userDict = array.first else {
                completion(false, nil)
                return
            }
            
            guard let connections = userDict["connections"] as? Array<String> else {
                completion(false, nil)
                return
            }
            
            let followed = connections.contains("following")
            completion(followed, nil)
        }
    }
    
    public static func followUserWithScreenName(follow: Bool,
                                                screenName: String,
                                                completion: @escaping (_ success: Bool, _ error: Error?) -> Swift.Void) {
        let client = TWTRAPIClient.withCurrentUser()
        let url = "https://api.twitter.com/1.1/friendships/create.json"
        var requestError: NSError?
        let request = client.urlRequest(withMethod: "POST",
                                        url: url,
                                        parameters: ["screen_name": screenName,
                                                     "follow": follow ? "true" : "false"],
                                        error: &requestError)
        
        client.sendTwitterRequest(request) { (response, data, error) in
            if error != nil {
                completion(false, error)
                return
            }
            
            completion(true, nil)
        }
    }
    
    // MARK: - Share
    
    public static func share(text: String, image: UIImage, completion: @escaping (_ success: Bool, _ error: Error?) -> Swift.Void) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        guard let imageString = imageData?.base64EncodedString() else {
            completion(false, nil)
            return
        }
        
        let client = TWTRAPIClient.withCurrentUser()
        let mediaURL = "https://upload.twitter.com/1.1/media/upload.json"
        let tweetUrl = "https://api.twitter.com/1.1/statuses/update.json"
        
        var requestError: NSError?
        let mediaRequest = client.urlRequest(withMethod: "POST",
                                             url: mediaURL,
                                             parameters: ["media": imageString],
                                             error: &requestError)
        if requestError != nil {
            completion(false, requestError)
            return
        }
        
        client.sendTwitterRequest(mediaRequest, completion: { (response, data, error) in
            if error != nil {
                completion(false, error)
                return
            }
            
            guard let mediaJSON = self.nsdataToJSON(data: data) else {
                completion(false, nil)
                return
            }
            
            guard let mediaDict: Dictionary<String, Any> = mediaJSON as? Dictionary<String, Any> else {
                completion(false, nil)
                return
            }
            
            
            guard let mediaId: String = mediaDict["media_id_string"] as? String else {
                completion(false, nil)
                return
            }
            
            let request = client.urlRequest(withMethod: "POST",
                                            url: tweetUrl,
                                            parameters: ["status": text, "media_ids": mediaId],
                                            error: nil)
            client.sendTwitterRequest(request, completion: { (response, data, error) in
                if error != nil {
                    completion(false, error)
                    return
                }
                
                completion(true, nil)
            })
        })
    }
    
    // MARK: - Utils
    
    private static func nsdataToJSON(data: Data?) -> Any? {
        if (data == nil) {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
}
