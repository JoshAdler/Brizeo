//
//  LayerManager.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/19/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import Foundation
import LayerKit
import Parse
import Crashlytics

class LayerManager: NSObject {

    fileprivate struct LayerParameterKey {
        static let UserIdKey = "userId"
        static let NonceKey = "nonce"
    }
    
    var layerClient: LYRClient!
    static let sharedManager = LayerManager()
    
    override init() {
        super.init()
        
        let appID = URL(string: LayerKey.LQSLayerAppID)!
        layerClient = LYRClient(appID: appID, delegate: self, options: nil)
        layerClient.autodownloadMaximumContentSize = 1024 * 100
        layerClient.autodownloadMIMETypes = NSSet(objects: "image/jpeg", "image/jpeg+preview", "image/gif+preview", "image/png") as? Set<String>
        
        saveUserInInstallation()
    }
    
    func loginLayer() {
        
        layerClient.connect { success, error in
            
            print(error)
            if (success) {
                if(User.current() != nil) {
                    
                    let userID: String = User.current()!.objectId!
                    self.authenticateLayerWithUserID(userID as NSString, completion: { success, error in
                        print(error ?? "")
                    })
                }
            }
        }
    }
    
    func authenticateLayerWithUserID(_ userID: NSString, completion: @escaping ((_ success: Bool , _ error: NSError?) -> Void)) {
        
        if let currentUserId = layerClient.authenticatedUser?.userID {
            if currentUserId == userID as String {
                completion(true, nil)
            } else {
                //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
                layerClient.deauthenticate { (success: Bool, error: Error?) in
                    if error == nil {
                        self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
                            completion(success, error as NSError?)
                        })
                    } else {
                        completion(success, error as NSError?)
                    }
                }
            }
        } else {
            // If the layerClient isn't already authenticated, then authenticate.
            authenticationTokenWithUserId(userID, completion: completion)
        }
    }
}

//MARK: - Private
extension LayerManager {

    fileprivate func saveUserInInstallation() {
        return
        //TODO
        let installation = PFInstallation.current()
        
        if let user = User.current() {
            installation?["user"] = user
            installation?.saveInBackground()
        }
    }
    
    fileprivate func authenticationTokenWithUserId(_ userID: NSString, completion:@escaping ((_ success: Bool, _ error: NSError?) -> Void)) {
        //Request an authentication Nonce from Layer
        layerClient.requestAuthenticationNonce { (nonce: String?, error: Error?) in
            if (nonce!.isEmpty) {
                completion(false, error as NSError?)
            } else {
                self.requestIdentityTokenForUserID(userID as String, appID: LayerKey.LQSLayerAppID, nonce: nonce!) { ( identityToken, error) in
                    
                    print(identityToken)
                    
                    if let identityToken = identityToken {
                        
                        self.layerClient.authenticate(withIdentityToken: identityToken, completion: {(authenticatedUserID, error) in
                            if let _ = authenticatedUserID{
                                completion(true, nil);
                            } else {
                                completion(false, error as NSError?);
                            }
                        })
                    } else {
                        completion(false, error);
                    }
                }
            }
        }
    }
    
    fileprivate func requestIdentityTokenForUserID(_ userID: String, appID: String, nonce: String, completion : @escaping (_ identityToken: String?, _ error: NSError?) -> Void) {
        
        let params = [LayerParameterKey.UserIdKey: userID, LayerParameterKey.NonceKey: nonce] as Dictionary<String, String>
        PFCloud.callFunction(inBackground: ParseFunction.LayerToken.name, withParameters: params) { (result, error) in
            print(result)
            if let identityString = result {
                print(identityString)
                completion(identityString as? String, error as NSError?)
            }
            
        }
    }
}

extension LayerManager: LYRClientDelegate {

    func layerClient(_ client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        print("Layer Client did recieve authentication challenge with nonce: \(nonce)")
    }
    
    func layerClient(_ client: LYRClient, didAuthenticateAsUserID userID: String) {
        print("Layer Client did recieve authentication nonce");
    }
    
    func layerClientDidDeauthenticate(_ client: LYRClient) {
        print("Layer Client did deauthenticate")
    }
    
    func layerClient(_ client: LYRClient, willAttemptToConnect attemptNumber: UInt, afterDelay delayInterval: TimeInterval, maximumNumberOfAttempts attemptLimit: UInt) {
        print("Layer Client will attempt to connect")
    }
    
    func layerClientDidConnect(_ client: LYRClient) {
        print("Layer Client did connect");
    }
    
    func layerClient(_ client: LYRClient, didLoseConnectionWithError error: Error) {
        print("Layer Client did lose connection with error: \(error)");
    }
    
    func layerClientDidDisconnect(_ client: LYRClient) {
        print("Layer Client did disconnect with error");
    }
}

extension LayerManager {
    
    static func conversationBetweenUser(_ userId: String, andUserId: String, message: String?) -> LYRConversation? {
        
        if let conversation = checkConversationAlreadyExists(userId, andUserId: andUserId) {
            return conversation
        }
        
        return createConversationBetweenUser(userId, andUserId: andUserId, message: message)
    }
    
    fileprivate static func checkConversationAlreadyExists(_ userId: String, andUserId: String) -> LYRConversation? {
        
        let query = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.isEqualTo, value: [userId, andUserId])

        let layerClient = LayerManager.sharedManager.layerClient
        do {
            return try layerClient?.execute(query).firstObject as? LYRConversation
        } catch {
            CLSLogv("Error executing layer query", getVaList([]))
        }
        
        return nil
    }
    
    fileprivate static func createConversationBetweenUser(_ userId: String, andUserId: String, message: String?) -> LYRConversation? {
        
        do {
            let layerClient = LayerManager.sharedManager.layerClient
 //           let options = [LYRConversationOptionsDistinctByParticipantsKey : true]
            let userIdSet: Set = [userId, andUserId]
            let conversation = try layerClient?.newConversation(withParticipants: userIdSet, options: nil)
            
            if let message = message {
                
                let messagePart = LYRMessagePart(text: message)
                
                do {
                    let message = try layerClient?.newMessage(with: [messagePart], options: nil)

                    // Sends the specified message
                    do {
                        try conversation?.send(message!)
                        print(message?.sender)
                        return conversation
                    } catch let error as NSError {
                        CLSLogv("%@", getVaList([error]))
                    } catch {
                        CLSLogv("Unknown Error trying to send Layer Message", getVaList([]))
                    }
                } catch {
                    CLSLogv("Unknown Error trying to create Layer message", getVaList([]))
                }
            } else {
                
                return conversation
            }
            
        } catch let error as NSError {
            CLSNSLogv("%@", getVaList([error]))
            
            if let userInfo = error.userInfo as? [String: AnyObject] {
                
                return userInfo[LYRExistingDistinctConversationKey] as? LYRConversation;
            }
            
        } catch {
            CLSLogv("Unknown Error trying to start Layer Conversation", getVaList([]))
        }
        return nil
    }
}
