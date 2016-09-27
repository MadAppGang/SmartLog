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
    func keyboardWillShowWithRect(_ keyboardRect: CGRect, animationDuration: TimeInterval)
    func keyboardWillHideFromRect(_ keyboardRect: CGRect, animationDuration: TimeInterval)
}

private struct KeyboardEventsHandlerAssosiatedKey {
    static var observersMap = "NotificationObservers"
}

extension KeyboardEventsHandler where Self: UIViewController {
    
    func startHandlingKeyboardEvents() {
        var observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self] (n) -> Void in
            self?.keybardWillShow(n)
        }
        self.addObserverForKey(NSNotification.Name.UIKeyboardWillShow.rawValue, observer: observer)
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self] (n) -> Void in
            self?.keyboardWillHide(n)
        }
        self.addObserverForKey(NSNotification.Name.UIKeyboardWillHide.rawValue, observer: observer)
    }
    
    func stopHandlingKeyboardEvents() {
        if let observer = self.removeObserverForKey(NSNotification.Name.UIKeyboardWillShow.rawValue) {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.removeObserverForKey(NSNotification.Name.UIKeyboardWillHide.rawValue) {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    fileprivate func keybardWillShow(_ n: Notification) {
        let rect = ((n as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration = ((n as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillShowWithRect(rect, animationDuration: duration)
    }
    
    fileprivate func keyboardWillHide(_ n: Notification) {
        let rect = ((n as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration = ((n as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillHideFromRect(rect, animationDuration: duration)
    }
    
    fileprivate func addObserverForKey(_ key: String, observer: NSObjectProtocol) {
        var newObservers = [String: NSObjectProtocol]()
        if let observers = self.observers {
            for (k, v) in observers {
                newObservers[k] = v
            }
        }
        newObservers[key] = observer
        self.observers = newObservers
    }
    
    fileprivate func removeObserverForKey(_ key: String) -> NSObjectProtocol? {
        if var observers = self.observers {
            let value = observers[key]
            observers.removeValue(forKey: key)
            self.observers = observers
            return value
        }
        return nil
    }
    
}

extension UIViewController {
    
    fileprivate var observers: [String: NSObjectProtocol]?  {
        get {
            return objc_getAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap) as? [String: NSObjectProtocol]
        }
        set(value) {
            objc_setAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
