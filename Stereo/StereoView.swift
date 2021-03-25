//
//  StereoView.swift
//  Stereo
//
//  Created by Phil Stern on 3/25/21.
//

import UIKit

struct Dimension {
    static let pointsPerInch: CGFloat = 163  // iPhone 6S (each device is different)
    static let noseToEye: CGFloat = 1.2 * Dimension.pointsPerInch  // points
    static let noseToPhone: CGFloat = 8 * Dimension.pointsPerInch  // points
}

struct Shape {
    static let width: CGFloat = 200
    static let height: CGFloat = 200
    static let depth: CGFloat = 800
}

class StereoView: UIView {
    
    var rotation: CGFloat = 0 { didSet { setNeedsDisplay() } }  // degrees
    
    // origin at screen center
    let shape2D = [
        CGPoint(x: -Shape.width / 2, y: -Shape.height / 2),
        CGPoint(x: Shape.width / 2, y: -Shape.height / 2),
        CGPoint(x: Shape.width / 2, y: Shape.height / 2),
        CGPoint(x: -Shape.width / 2, y: Shape.height / 2),
    ]

    override func draw(_ rect: CGRect) {
        let shape3D = make3D(points2D: shape2D, z: Shape.depth, angle: rotation * CGFloat.pi / 180)
        let stereo = createStereoFrom(shape3D)
        drawShapeFrom(points: stereo.leftEye)
        drawShapeFrom(points: stereo.rightEye)
    }
    
    // apply rotation to create 3D coordinates (origin in center of display)
    private func make3D(points2D: [CGPoint], z: CGFloat, angle: CGFloat) -> [(x: CGFloat, y: CGFloat, z: CGFloat)] {
        var points3D = [(x: CGFloat, y: CGFloat, z: CGFloat)]()
        for i in 0..<points2D.count {
            points3D.append((x: points2D[i].x * cos(angle),
                             y: points2D[i].y,
                             z: z - points2D[i].x * sin(angle)))
        }
        return points3D
    }
    
    // apply perspective to creata 2D image for left or right eye (origin in upper left corner of display)
    private func createStereoFrom(_ points3D: [(x: CGFloat, y: CGFloat, z: CGFloat)]) -> (leftEye: [CGPoint], rightEye: [CGPoint]) {
        let midPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        var leftEye = [CGPoint]()
        var rightEye = [CGPoint]()
        for point3D in points3D {
            let leftPoint = CGPoint(x: point3D.x - point3D.z * (Dimension.noseToEye + point3D.x) / (Dimension.noseToPhone + point3D.z),
                                    y: point3D.y * Dimension.noseToPhone / (Dimension.noseToPhone + point3D.z))
            let rightPoint = CGPoint(x: point3D.x + point3D.z * (Dimension.noseToEye - point3D.x) / (Dimension.noseToPhone + point3D.z),
                                     y: leftPoint.y)
            leftEye.append(leftPoint + midPoint)  // make points relative to upper left corner of screen
            rightEye.append(rightPoint + midPoint)
        }
        return (leftEye, rightEye)
    }
    
    private func drawShapeFrom(points: [CGPoint]) {
        let shape = UIBezierPath()
        shape.move(to: points[0])
        for i in 1..<points.count {
            shape.addLine(to: points[i])
        }
        shape.close()
        shape.lineWidth = 2
        shape.stroke()
    }
}
