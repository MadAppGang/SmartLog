//
//  KeyboardEventsHandler.swift
//  iamfilm
//
//  Created by Ievgen Rudenko on 2/23/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

private struct KeyboardEventsHandlerAssosiatedKey {
    static var observersMap = "NotificationObservers"
}

protocol KeyboardEventsHandler: class {
    func startKeyboardEventsHandling()
    func stopKeyboardEventsHandling()
    func keyboardWillShow(in rect: CGRect, animationDuration: TimeInterval)
    func keyboardWillHide(from rect: CGRect, animationDuration: TimeInterval)
}

extension KeyboardEventsHandler where Self: UIViewController {
    
    private var observers: [NSNotification.Name: NSObjectProtocol]?  {
        get {
            return objc_getAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap) as? [NSNotification.Name: NSObjectProtocol]
        }
        set(value) {
            objc_setAssociatedObject(self, &KeyboardEventsHandlerAssosiatedKey.observersMap, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func startKeyboardEventsHandling() {
        var observer = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: .main) { [weak self] n in
            self?.keybardWillShow(n)
        }
        addObserver(forName: .UIKeyboardWillShow, observer: observer)
        
        observer = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main) { [weak self] n in
            self?.keyboardWillHide(n)
        }
        addObserver(forName: .UIKeyboardWillHide, observer: observer)
    }
    
    func stopKeyboardEventsHandling() {
        if let observer = removeObserver(forName: .UIKeyboardWillShow) {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = removeObserver(forName: .UIKeyboardWillHide) {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func keybardWillShow(_ n: Notification) {
        let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillShow(in: rect, animationDuration: duration)
    }
    
    private func keyboardWillHide(_ n: Notification) {
        let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        keyboardWillHide(from: rect, animationDuration: duration)
    }
    
    private func addObserver(forName name: NSNotification.Name, observer: NSObjectProtocol) {
        var newObservers: [NSNotification.Name: NSObjectProtocol] = [:]
        
        if let observers = self.observers {
            newObservers = observers
        }
        
        newObservers[name] = observer
        observers = newObservers
    }
    
    private func removeObserver(forName name: NSNotification.Name) -> NSObjectProtocol? {
        return observers?.removeValue(forKey: name)
    }

}
