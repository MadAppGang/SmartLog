//
//  Dmytro's Playground.playground
//  SmartHeartTraining
//

import UIKit
import XCPlayground

let frame = CGRect(x: 0, y: 0, width: 800, height: 270)
let container = UIView(frame: frame)
container.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1.0)

var count = 9020
var gap = count / 500
var c = count / gap

var a = 0
for index in 0..<count {
    let indexModulo = index % gap
    
    if indexModulo == 0 {
        a += 1
    }
}

print(a)

XCPlaygroundPage.currentPage.liveView = container
