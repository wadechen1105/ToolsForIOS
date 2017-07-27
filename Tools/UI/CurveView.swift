import Foundation
import UIKit
import CoreGraphics

class CurveView: UIView {
    override func awakeFromNib() {
        Log.d("awakeFromNib")
    }

    override func draw(_ rect: CGRect) {
        // Create an oval shape to draw.
        let aPath = UIBezierPath(rect: CGRect(x: 0,
                                              y: 200,
                                              width: 200,
                                              height: 100))

        //Set the render colors.
        UIColor.black.setStroke()
        UIColor.cyan.setFill()

        let aRef = UIGraphicsGetCurrentContext()

        // If you have content to draw after the shape,
        // save the current state before changing the transform.
        //CGContextSaveGState(aRef);

        // Adjust the view's origin temporarily. The oval is
        // now drawn relative to the new origin point.
        aRef?.translateBy(x: 50, y: 50)

        // Adjust the drawing options as needed.
        aPath.lineWidth = 5

        // Fill the path before stroking it so that the fill
        // color does not obscure the stroked line.
        aPath.fill()
        aPath.stroke()

        // Restore the graphics state before drawing any other content.
        //CGContextRestoreGState(aRef);

    }
}
