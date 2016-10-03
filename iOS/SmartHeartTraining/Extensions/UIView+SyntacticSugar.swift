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
    
    private static func loadViewFromNib<View: UIView>() -> View {
        let nibContent = Bundle.main.loadNibNamed(className(), owner: nil, options: nil)
        var viewToReturn: View!
        for objectFromNib in nibContent! {
            guard let objectFromNib = objectFromNib as? View else { continue }
            
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
    
    func createViewController<ViewController: UIViewController>(_ vc: ViewController.Type) -> ViewController {
        return instantiateViewController(withIdentifier: vc.storyboardID()) as! ViewController
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
    
    func register<View: UITableViewHeaderFooterView>(nibOfReusableView view: View.Type) {
        let nib = UINib(nibName: view.className(), bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: view.viewID())
    }
    
    func register<Cell: UITableViewCell>(nibOfCell cell: Cell.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellReuseIdentifier: cell.cellID())
    }
    
    func register<Cell: UITableViewCell>(cell: Cell.Type) {
        register(cell, forCellReuseIdentifier: cell.cellID())
    }
    
    func dequeueCell<Cell: UITableViewCell>(_ cell: Cell.Type = Cell.self) -> Cell {
        let cell = dequeueReusableCell(withIdentifier: cell.cellID()) as? Cell
        return cell!
    }
    
    func dequeueCell<Cell: UITableViewCell>(at indexPath: IndexPath, cell: Cell.Type = Cell.self) -> Cell {
        let cell = dequeueReusableCell(withIdentifier: cell.cellID(), for: indexPath) as? Cell
        return cell!
    }
    
    func dequeueView<View: UITableViewHeaderFooterView>(_ view: View.Type = View.self) -> View {
        return dequeueReusableHeaderFooterView(withIdentifier: view.viewID()) as! View
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
    
    func register<Cell: UICollectionViewCell>(nibOfCell cell: Cell.Type) {
        let nib = UINib(nibName: cell.className(), bundle: nil)
        register(nib, forCellWithReuseIdentifier: cell.cellID())
    }
    
    func register<View: UICollectionReusableView>(nibOfHeader header: View.Type) {
        let nib = UINib(nibName: header.className(), bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header.viewID())
    }
    
    func dequeueCell<Cell: UICollectionViewCell>(at indexPath: IndexPath, cell: Cell.Type = Cell.self) -> Cell {
        let cell = dequeueReusableCell(withReuseIdentifier: cell.cellID(), for: indexPath) as? Cell
        return cell!
    }
    
    func dequeueView<View: UICollectionReusableView>(at indexPath: IndexPath, of kind: String = UICollectionElementKindSectionHeader, view: View.Type = View.self) -> View {
        let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: view.viewID(), for: indexPath) as? View
        return cell!
    }
}
