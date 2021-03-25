//
//  CGPoint+add.swift
//  Stereo
//
//  Created by Phil Stern on 3/25/21.
//

import UIKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
