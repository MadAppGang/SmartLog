//
//  UIView+SyntacticSugar.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension UIView {
    
    static func loadFromNib() -> Self {
        return loadViewFromNib()
    }
    
    private static func loadViewFromNib<T: UIView>() -> T {
        let nibContent = Bundle.main.loadNibNamed(className(), owner: nil, options: nil)
        var viewToReturn: T!
        for objectFromNib in nibContent! {
            guard let objectFromNib = objectFromNib as? T else { continue }
            
            viewToReturn = objectFromNib
            break
        }
        return viewToReturn
    }
}

extension NSObject {
    
    static func className() -> String {
        let objectClass: AnyClass = self
        let objectClassName = NSStringFromClass(objectClass)
        let objectClassNameComponents = objectClassName.components(separatedBy: ".")
        return objectClassNameComponents.last!
    }
}

extension UIStoryboard {
    
    func createViewController<T: UIViewController>(_ vc: T.Type) -> T {
        return instantiateViewController(withIdentifier: vc.storyboardID()) as! T
    }
}

extension UIViewController {
    
    static func storyboardID() -> String {
        return className()
    }
}

extension UITableViewCell {
    
    static func cellID() -> String {
        return className()
    }
}

extension UITableViewHeaderFooterView {
    
    static func viewID() -> String {
        return className()
    }
}

extension UITableView {
    
    func register<T: UITableViewHeaderFooterView>(nibOfReusableView view: T.Type) {
        let nib = UINib(nibName: view.className(), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: view.viewID())
    }
    
    func register<T: UITableViewCell>(nibOfCell cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellReuseIdentifier: cell.cellID())
    }
    
    func register<T: UITableViewCell>(cell: T.Type) {
        register(cell, forCellReuseIdentifier: cell.cellID())
    }
    
    func dequeueCell<T: UITableViewCell>(_ cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCell(withIdentifier: cell.cellID()) as? T
        return cell!
    }
    
    func dequeueCell<T: UITableViewCell>(at indexPath: IndexPath, cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCell(withIdentifier: cell.cellID(), for: indexPath) as? T
        return cell!
    }
    
    func dequeueView<T: UITableViewHeaderFooterView>(_ view: T.Type = T.self) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: view.viewID()) as! T
    }
}

extension UICollectionViewCell {
    
    static func cellID() -> String {
        return className()
    }
}

extension UICollectionReusableView {
    
    static func viewID() -> String {
        return className()
    }
}


extension UICollectionView {
    
    func register<T: UICollectionViewCell>(nibOfCell cell: T.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.cellID())
    }
    
    func register<T: UICollectionReusableView>(nibOfHeader header: T.Type) {
        let nib = UINib(nibName: header.className(), bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.viewID())
    }
    
    func dequeueCell<T: UICollectionViewCell>(at indexPath: IndexPath, cell: T.Type = T.self) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: cell.cellID(), for: indexPath) as? T
        return cell!
    }
    
    func dequeueView<T: UICollectionReusableView>(at indexPath: IndexPath, of kind: String = UICollectionElementKindSectionHeader, view: T.Type = T.self) -> T {
        let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.viewID(), for: indexPath) as? T
        return cell!
    }
}
