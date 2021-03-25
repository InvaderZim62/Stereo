//
//  StereoView.swift
//  Stereo
//
//  Created by Phil Stern on 3/25/21.
//

import UIKit

struct Geometry {
    static let pointsPerInch: CGFloat = 163  // iPhone 6S (each device is different)
    static let noseToEye: CGFloat = 1.2 * Geometry.pointsPerInch  // points
    static let noseToPhone: CGFloat = 8 * Geometry.pointsPerInch  // points
}

struct Rectangle {
    static let width: CGFloat = 200
    static let height: CGFloat = 200
    static let depth: CGFloat = 800
}

class StereoView: UIView {
    
    var rotation: CGFloat = 0 { didSet { setNeedsDisplay() } }  // degrees
    
    // origin at screen center
    let pointX2D = [-Rectangle.width / 2, Rectangle.width / 2, Rectangle.width / 2, -Rectangle.width / 2]
    let pointY2D = [-Rectangle.height / 2, -Rectangle.height / 2, Rectangle.height / 2, Rectangle.height / 2]

    override func draw(_ rect: CGRect) {
        let (pointX3D, pointY3D, pointZ3D) = make3D(x: pointX2D, y: pointY2D, z: Rectangle.depth, angle: rotation * CGFloat.pi / 180)
        let (leftEyeX, leftEyeY) = makeStereo(x: pointX3D, y: pointY3D, z: pointZ3D, isLeft: true)
        drawImage(x: leftEyeX, y: leftEyeY)
        let (rightEyeX, rightEyeY) = makeStereo(x: pointX3D, y: pointY3D, z: pointZ3D, isLeft: false)
        drawImage(x: rightEyeX, y: rightEyeY)
    }
    
    private func drawImage(x: [CGFloat], y: [CGFloat]) {
        let rect = UIBezierPath()
        rect.move(to: makePoint(x: x[0], y: y[0]))
        for i in 1..<pointX2D.count {
            rect.addLine(to: makePoint(x: x[i], y: y[i]))
        }
        rect.close()
        rect.lineWidth = 2
        rect.stroke()
    }
    
    // convert origin from screen center to upper left corner
    private func makePoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return(CGPoint(x: bounds.midX + x, y: bounds.midY + y))
    }
    
    // apply rotation to create 3D coordinates (origin in center of display)
    private func make3D(x: [CGFloat], y: [CGFloat], z: CGFloat, angle: CGFloat) -> ([CGFloat], [CGFloat], [CGFloat]) {
        precondition(x.count == y.count, "(3DView.make3D) Arrays must be same size")
        var x3D = [CGFloat]()
        var y3D = [CGFloat]()
        var z3D = [CGFloat]()
        for i in 0..<x.count {
            x3D.append(x[i] * cos(angle))
            y3D.append(y[i])
            z3D.append(z - x[i] * sin(angle))
        }
        return (x3D, y3D, z3D)
    }
    
    // apply perspective to creata 2D image for each eye (origin in center of display)
    private func makeStereo(x: [CGFloat], y: [CGFloat], z: [CGFloat], isLeft: Bool) -> ([CGFloat], [CGFloat]) {
        var eyeX = [CGFloat]()
        var eyeY = [CGFloat]()
        for i in 0..<x.count {
            if isLeft {
                eyeX.append(x[i] - z[i] * (Geometry.noseToEye + x[i]) / (Geometry.noseToPhone + z[i]))
            } else {
                eyeX.append(x[i] + z[i] * (Geometry.noseToEye - x[i]) / (Geometry.noseToPhone + z[i]))
            }
            eyeY.append(y[i] * Geometry.noseToPhone / (Geometry.noseToPhone + z[i]))
        }
        return (eyeX, eyeY)
    }
}
