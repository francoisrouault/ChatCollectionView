//
//  User.swift
//  ChatCollectionView
//
//  Created by François Rouault on 09/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation

class User {
    
    private static var instance: User!
    private static let kKey = "is-logged4"
    
    static var current: User! {
        if instance != nil {
            return instance
        }
        if UserDefaults.standard.bool(forKey: kKey) {
            instance = User()
            return instance
        }
        return nil
    }
    
    static func logIn() {
        UserDefaults.standard.set(true, forKey: kKey)
    }
    
    static func logOut() {
        instance = nil
        UserDefaults.standard.set(false, forKey: kKey)
    }
    
}
