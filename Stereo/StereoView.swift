//
//  StereoView.swift
//  Stereo
//
//  Created by Phil Stern on 3/25/21.
//

import UIKit

struct Geometry {
    static let pointsPerInch: CGFloat = 163  // iPhone 8 (each device is different)
    static let noseToEye: CGFloat = 1.2 * Geometry.pointsPerInch  // points
    static let noseToPhone: CGFloat = 8 * Geometry.pointsPerInch  // points
}

struct Shape {
    static let width: CGFloat = 200
    static let height: CGFloat = 200
    static let averageDepth: CGFloat = 800
    static let depthAmplitude: CGFloat = 100  // for sinusoidal depths
}

class StereoView: UIView {
    
    var rotation: CGFloat = 0 { didSet { setNeedsDisplay() } }  // degrees
    
    // origin at screen center
    let shape2D = [
        (x: -Shape.width / 2, y: -Shape.height / 2, z: Shape.averageDepth),
        (x: Shape.width / 2, y: -Shape.height / 2, z: Shape.averageDepth),
        (x: Shape.width / 2, y: Shape.height / 2, z: Shape.averageDepth),
        (x: -Shape.width / 2, y: Shape.height / 2, z: Shape.averageDepth)
    ]

    var points2D: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [
        (x: -Shape.width / 5, y: -Shape.height / 5, z: 0),
        (x: Shape.width / 5, y: -Shape.height / 5, z: 0),
        (x: Shape.width / 5, y: Shape.height / 5, z: 0),
        (x: -Shape.width / 5, y: Shape.height / 5, z: 0),
    ]

    override func draw(_ rect: CGRect) {
        // fixed frame
        let fixedShape = make3D(points2D: shape2D, angle: 0)
        let fixedStereo = createStereoPointsFrom(fixedShape)
        drawShapeFrom(points: fixedStereo.leftEye, lineColor: .red, fillColor: .clear)
        drawShapeFrom(points: fixedStereo.rightEye, lineColor: .red, fillColor: .clear)
        
//        // rotating wall
//        let rotatingShape = make3D(points2D: shape2D, angle: rotation * CGFloat.pi / 180)
//        let rotatingStereo = createStereoPointsFrom(rotatingShape)
//        drawShapeFrom(points: rotatingStereo.leftEye, lineColor: .clear, fillColor: .blue)
//        drawShapeFrom(points: rotatingStereo.rightEye, lineColor: .clear, fillColor: .blue)
        
        // circles moving in and out (90 degrees out of phase with each other)
//        points2D.indices.forEach { points2D[$0].z = Shape.averageDepth + Shape.depthAmplitude * sin((rotation - 90 * CGFloat($0)) * CGFloat.pi / 180) }
        // circles moving in and out in phase, but with different amplitudes
        points2D.indices.forEach { points2D[$0].z = Shape.averageDepth + Shape.depthAmplitude * (1 + 0.25 * CGFloat($0)) * sin(rotation * CGFloat.pi / 180) }
        let points3D = make3D(points2D: points2D, angle: 0)
        let stereoPoints = createStereoPointsFrom(points3D)
        drawCirclesWith(centers: stereoPoints.leftEye, color: .black)
        drawCirclesWith(centers: stereoPoints.rightEye, color: .black)
    }
    
    // apply rotation to create 3D coordinates (origin in center of display)
    private func make3D(points2D: [(x: CGFloat, y: CGFloat, z: CGFloat)], angle: CGFloat) -> [(x: CGFloat, y: CGFloat, z: CGFloat)] {
        var points3D = [(x: CGFloat, y: CGFloat, z: CGFloat)]()
        for i in 0..<points2D.count {
            points3D.append((x: points2D[i].x * cos(angle),
                             y: points2D[i].y,
                             z: points2D[i].z - points2D[i].x * sin(angle)))
        }
        return points3D
    }

    // apply perspective to create a 2D image for left or right eye (origin in upper left corner of display)
    private func createStereoPointsFrom(_ points3D: [(x: CGFloat, y: CGFloat, z: CGFloat)]) -> (leftEye: [CGPoint], rightEye: [CGPoint]) {
        let midPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        var leftEye = [CGPoint]()
        var rightEye = [CGPoint]()
        for point3D in points3D {
            let leftPoint = CGPoint(x: point3D.x - point3D.z * (Geometry.noseToEye + point3D.x) / (Geometry.noseToPhone + point3D.z),
                                    y: point3D.y * Geometry.noseToPhone / (Geometry.noseToPhone + point3D.z))
            let rightPoint = CGPoint(x: point3D.x + point3D.z * (Geometry.noseToEye - point3D.x) / (Geometry.noseToPhone + point3D.z),
                                     y: leftPoint.y)
            leftEye.append(leftPoint + midPoint)  // make points relative to upper left corner of screen
            rightEye.append(rightPoint + midPoint)
        }
        return (leftEye, rightEye)
    }
    
    private func drawShapeFrom(points: [CGPoint], lineColor: UIColor, fillColor: UIColor) {
        let shape = UIBezierPath()
        shape.move(to: points[0])
        for i in 1..<points.count {
            shape.addLine(to: points[i])
        }
        shape.close()
        fillColor.setFill()
        shape.fill()
        shape.lineWidth = 2
        lineColor.setStroke()
        shape.stroke()
    }
    
    private func drawCirclesWith(centers: [CGPoint], color: UIColor) {
        for center in centers {
            let circle = UIBezierPath(arcCenter: center, radius: 6, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            color.setFill()
            circle.fill()
        }
    }
}
