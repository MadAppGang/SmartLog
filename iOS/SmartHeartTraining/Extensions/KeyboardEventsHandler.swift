//
//  KeyboardEventsHandler.swift
//  iamfilm
//
//  Created by Ievgen Rudenko on 2/23/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

protocol KeyboardEventsHandler {
    func startHandlingKeyboardEvents()
    func stopHandlingKeyboardEvents()
    func keyboardWillShowWithRect(keyboardRect: CGRect, animationDuration: NSTimeInterval)
    func keyboardWillHideFromRect(keyboardRect: CGRect, animationDuration: NSTimeInterval)
}

private struct KeyboardEventsHandlerAssosiatedKey {
    static var observersMap = "NotificationObservers"
}

extension KeyboardEventsHandler where Self: UIViewController {
    
    func startHandlingKeyboardEvents() {
        var observer = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (n) -> Void in
            self?.keybardWillShow(n)
        }
        self.addObserverForKey(UIKeyboardWillShowNotification, observer: observer)
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (n) -> Void in
            self?.keyboardWillHide(n)
        }
        self.addObserverForKey(UIKeyboardWillHideNotification, observer: observer)
    }
    
    func stopHandlingKeyboardEvents() {
        if let observer = self.removeObserverForKey(UIKeyboardWillShowNotification) {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = self.removeObserverForKey(UIKeyboardWillHideNotification) {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    
    private func keybardWillShow(n: NSNotification) {
        let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect.zero
        let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillShowWithRect(rect, animationDuration: duration)
    }
    
    private func keyboardWillHide(n: NSNotification) {
        let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect.zero
        let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillHideFromRect(rect, animationDuration: duration)
    }
    
    private func addObserverForKey(key: String, observer: NSObjectProtocol) {
        var newObservers = [String: NSObjectProtocol]()
        if let observers = self.observers {
            for (k, v) in observers {
                newObservers[k] = v
            }
        }
        newObservers[key] = observer
        self.observers = newObservers
    }
    
    private func removeObserverForKey(key: String) -> NSObjectProtocol? {
        if var observers = self.observers {
            let value = observers[key]
            observers.removeValueForKey(key)
            self.observers = observers
            return value
        }
        return nil
    }
    
}

extension UIViewController {
    
    private var observers: [String: NSObjectProtocol]?  {
        get {
            return objc_getAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap) as? [String: NSObjectProtocol]
        }
        set(value) {
            objc_setAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}