//
//  CropView.swift
//  FunHer
//
//  Created by GLA on 2023/8/16.
//

import Foundation
import UIKit
@objc
public protocol CropViewDelegate:NSObjectProtocol{
    func panChangePoint(_ point:CGPoint)
    func panChangePointEnd()
}
public class CropView: UIView, UIGestureRecognizerDelegate {
    //MARK:Public Variables
    public var rectangleBorderColor = UIColor(red: 76/255.0, green: 134/255.0, blue: 255/255.0, alpha: 1.0)
    public var rectangleFillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    public var circleBorderColor =  UIColor(red: 76/255.0, green: 134/255.0, blue: 255/255.0, alpha: 1.0)
    public var circleBackgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    public var selectedCircleBorderColor = UIColor.clear//UIColor(red: 61/255.0, green: 131/255.0, blue: 215/255.0, alpha: 1.0)
    public var selectedCircleBackgroundColor = UIColor.clear//UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.3)
    
    public var rectangleBorderWidth:CGFloat = 1.5
    public var circleBorderWidth:CGFloat = 1.0
    
    public var circleBorderRadius:CGFloat = 9
    public var circleAlpha:CGFloat = 1
    public var rectangleAlpha:CGFloat = 1
    public var cropImgW:CGFloat = 1
    public var cropImgH:CGFloat = 1
    public var cropImgX:CGFloat = 1
    public var cropImgY:CGFloat = 1

    @objc
    public weak var cropViewDelegate:CropViewDelegate?
    @objc
    public var originalImage:UIImage?
    //MARK:Local Variables
    var cropPoints = [CGPoint]()
    var cropCircles = [UIView]()
    var cropFrame: CGRect!
    var selectedCircle : UIView? = nil
    var selectedIndex : Int?
    var m:Double = 0
    let border = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    var oldPoint = CGPoint(x: 0, y: 0)
    var isAutoMax : Bool = true
    
    
    @objc
    public var isQuadrilateral:Bool = true
    @objc
    public var touchRange:CGFloat = 0.0
    @objc
    public var defaultPoints = [NSValue]()
    @objc
    public var autoCropPoints = [NSValue]()//自动裁剪的点
    @objc
    public var cropImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    //MARK: Public Methods
    /**
     The entry point function to set up the crop frame and gesture recoginisers for the crop points.
     The crop frame has 8 points - 4 corner and 4 edge.
     - parameters:
         - image: The UIImage you want in the crop frame
     */
    //MARK: 入口函数设置剪裁手势和点 一个8个点分别代表4个角和4个边
    @objc
    public func setUpImage(image : UIImage,isAutomatic:Bool){
        if (image.size.width > 0 && image.size.height > 0){
//            circleBorderColor = ScanerShare.cropViewStrokeColor()
//            rectangleBorderColor = ScanerShare.cropViewStrokeColor()
            isAutoMax = isAutomatic
            if(!self.subviews.contains(cropImageView)){
                cropImageView = UIImageView(image: normalizedImage(image: image))
                cropImageView.contentMode = .scaleAspectFit
                cropImageView.frame = adaptiveImageFrame(image: image)
                self.addSubview(cropImageView)
                cropFrame = cropImageView.frame
                setUpCropRegion()
                setUpGestureRecognizer()
            } else {
                //删除当前的试图
                for cropCircle in cropCircles {
                    cropCircle.removeFromSuperview()
                }
                cropCircles.removeAll()
                cropImageView.image = self.normalizedImage(image: image)
                cropImageView.frame = adaptiveImageFrame(image: image)
                cropFrame = cropImageView.frame
                setUpCropRegion()
            }
        }
    }
    
    
    /**
     Crops the region inside the crop points and trasforms it into a rectangle.
     - parameter completionHandler: A completion Handler that takes the transformed image
     */
    //MARK:输出裁剪后的图片
    @objc
    public func cropAndTransform() ->UIImage{
        /*
        0 -- 1
        |    |
        3 -- 2
        */
        reorderEndPoints()
               
        var corners = [CGPoint]()
        for i in stride(from: 0, to:7 , by: 2) {
            corners.append(cropCircles[i].center)
        }
        
        let topWidth = distanceBetweenPoints(point1: corners[0], point2: corners[1])
        let bottomWidth = distanceBetweenPoints(point1: corners[3], point2: corners[2])
        let leftHeight = distanceBetweenPoints(point1: corners[0], point2: corners[3])
        let rightHeight = distanceBetweenPoints(point1: corners[1], point2: corners[2])
        let newWidth = max(topWidth, bottomWidth)
        let newHeight = max(leftHeight, rightHeight)
        let widthScale = originalImage!.size.width/cropImageView.frame.size.width
        let heightScale = originalImage!.size.height/cropImageView.frame.size.height
        var corners2 = [CGPoint]()
        for i in stride(from: 0, to:7 , by: 2) {
            let point = CGPoint(x: (cropCircles[i].center.x - cropImageView.frame.origin.x)  * widthScale, y: (cropCircles[i].center.y - cropImageView.frame.origin.y) * heightScale)
            corners2.append(point)
        }
        let newImage = OpenCVWrapper.getTransformedImage(newWidth*widthScale, newHeight*heightScale, originalImage, &corners2, (originalImage!.size))
        if newImage == nil {
            return originalImage!
        }
        return newImage!
    }
    
    //MARK: Setup functions
    
    /**
     Sets up the crop region - the rectangle and the crop points, their appearance.
     */
    private func setUpCropRegion(){
        border.removeFromSuperlayer()
        maskLayer.removeFromSuperlayer()
        
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.frame = cropImageView.bounds
        maskLayer.fillColor = rectangleFillColor.cgColor
        maskLayer.lineWidth = rectangleBorderWidth / 2.0
        maskLayer.strokeColor = UIColor.clear.cgColor
        self.layer.addSublayer(maskLayer)
        
        //Add border rectangle layer
        border.fillRule = CAShapeLayerFillRule.evenOdd
        border.frame = cropImageView.bounds
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = rectangleBorderWidth
        border.strokeColor = rectangleBorderColor.withAlphaComponent(rectangleAlpha).cgColor
        self.layer.addSublayer(border)
        
        
    
        if cropImageView.frame.width>0.0&&cropImageView.frame.height>0.0 {
            cropImgW = cropImageView.frame.width
            cropImgH = cropImageView.frame.height
            cropImgX = cropImageView.frame.origin.x
            cropImgY = cropImageView.frame.origin.y
        }

        //Get crop rectangle
        var i = 1
        let x = cropImageView.frame.origin.x
        let y = cropImageView.frame.origin.y
        let width = cropImageView.frame.width
        let height = cropImageView.frame.height
        var endPoints = [CGPoint]()

        if (defaultPoints.count != 0) {//起始点转换为cropview的，因为裁剪点拖拽手势是在cropview上的，
            for i in (0...3) {
                let newPoint = defaultPoints[i]
                let ppt:CGPoint = newPoint.cgPointValue
                endPoints.append(CGPoint(x: ppt.x + x, y: ppt.y + y))
            }
        }else{
            if (autoCropPoints.count > 0) {
                for ptVal:NSValue in autoCropPoints {
                    let ppt:CGPoint = ptVal.cgPointValue
                    endPoints.append(CGPoint(x: ppt.x + x, y: ppt.y + y))
                }
            } else {
                let points = OpenCVWrapper.getLargestSquarePoints(cropImageView.image, cropImageView.frame.size,isAutoMax)
                //Add crop points and circles
                if let points = points{
                    for i in (0...3) {
                        let newPoint = points[i] as! CGPoint
                        endPoints.append(CGPoint(x: newPoint.x + x, y: newPoint.y+y))
                        autoCropPoints.append(NSValue.init(cgPoint: newPoint))
                    }
                }else{
                    endPoints.append(CGPoint(x: x, y: y))
                    endPoints.append(CGPoint(x: x+width, y: y))
                    endPoints.append(CGPoint(x: x+width, y: y+height))
                    endPoints.append(CGPoint(x: x, y: y+height))
                    
                    autoCropPoints.append(NSValue.init(cgPoint: CGPoint(x: 0, y: 0)))
                    autoCropPoints.append(NSValue.init(cgPoint: CGPoint(x: width, y: 0)))
                    autoCropPoints.append(NSValue.init(cgPoint: CGPoint(x: width, y: height)))
                    autoCropPoints.append(NSValue.init(cgPoint: CGPoint(x: 0, y: height)))
                }
            }
        }
        
        while(i<=8){
            let cropCircle = UIView()
            cropCircle.backgroundColor = UIColor.clear
            /*
             1----2----3
             |         |
             8         4
             |         |
             7----6----5
             */
            switch i{
            case 1,3,5,7:
                // 圆形shape
                let circleBezierPath = UIBezierPath(arcCenter: CGPoint(x: circleBorderRadius, y: circleBorderRadius), radius: circleBorderRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
                let circleLayer = CAShapeLayer()
                circleLayer.fillRule = CAShapeLayerFillRule.evenOdd
                circleLayer.path = circleBezierPath.cgPath
                circleLayer.fillColor = circleBackgroundColor.cgColor
                circleLayer.lineWidth = circleBorderWidth
                circleLayer.strokeColor = circleBorderColor.cgColor
                circleLayer.backgroundColor = UIColor.clear.cgColor
                
                cropCircle.alpha = circleAlpha
                cropCircle.frame.size = CGSize(width: circleBorderRadius*2, height: circleBorderRadius*2)
                cropCircle.center = endPoints[(i-1)/2]
                circleLayer.frame = cropCircle.bounds
                cropCircle.layer.addSublayer(circleLayer)
                
                
            case 2,4,6,8:
                // 圆角矩形shape
                let shapeSize = (i == 2 || i == 6) ? CGSize(width: circleBorderRadius*4.0, height: circleBorderRadius*1.3) : CGSize(width: circleBorderRadius*1.3, height: circleBorderRadius*4)
                let circleBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: shapeSize.width, height: shapeSize.height), cornerRadius: circleBorderRadius * 1.3 / 2.0)
                let circleLayer = CAShapeLayer()
                circleLayer.fillRule = CAShapeLayerFillRule.evenOdd
                circleLayer.path = circleBezierPath.cgPath
                circleLayer.fillColor = circleBackgroundColor.cgColor
                circleLayer.lineWidth = circleBorderWidth
                circleLayer.strokeColor = circleBorderColor.cgColor
                circleLayer.backgroundColor = UIColor.clear.cgColor
                
                cropCircle.alpha = circleAlpha
                cropCircle.frame.size = shapeSize
                cropCircle.center = centerOf(firstPoint: endPoints[(i/2)-1], secondPoint: endPoints[i == 8 ? 0 : i/2])
                cropCircle.layer.addSublayer(circleLayer)
                
            default:
                break
            }
            cropCircles.append(cropCircle)
            self.addSubview(cropCircle)
            i = i+1
        }
        
        adjustCornerPointsAngle()
        redrawBorderRectangle()
    }
    
    /**
     Draw/Redraw the crop rectangle such that it passes through the corner points
     */
    private func redrawBorderRectangle(){
        //剪裁区
        let beizierPath = UIBezierPath()
        beizierPath.move(to: cropCircles[0].center)
        for i in stride(from: 2, to:9 , by: 2) {
            beizierPath.addLine(to: cropCircles[i % 8].center)
        }
        beizierPath.close()
        border.path = beizierPath.cgPath
        
        //空心蒙层
        let cropPath = UIBezierPath()
        cropPath.move(to: cropCircles[0].center)
        for i in stride(from: 2, to:9 , by: 2) {
            cropPath.addLine(to: cropCircles[i % 8].center)
        }
        //最大外边框
        let tempBezierPath = UIBezierPath(rect: cropFrame)
        cropPath.append(tempBezierPath)
        maskLayer.path = cropPath.cgPath
    }

    
    /**
     Sets up pan gesture reconginzers for all 8 crop points on the crop rectangle.
     When the 4 corner points or moved, the size and angles in the rectangle varry accordingly.
     When the 4 edge points are moved, the corresponding edge moves parallel to the gesture.
 */
    private func setUpGestureRecognizer(){
        let gestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(CropView.panGesture))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: 触发第一个点的移动
    @objc
    public func updateCropLineColor(color: UIColor) {
        circleBorderColor = color
        rectangleBorderColor = color
        self.border.strokeColor = rectangleBorderColor.cgColor
        if cropCircles.count < 8 {return}
        for i in 0...7 {
            let shape = cropCircles[i].layer.sublayers?[0] as! CAShapeLayer
            shape.strokeColor = circleBorderColor.cgColor
        }
    }
    
    //MARK: 触发第一个点的移动
    @objc
    public func touchMoveStartPoint(isTouch: Bool) {
        self.selectedIndex = 0
        if (cropCircles[selectedIndex!].layer.sublayers?.count != 0) {
            let shape = cropCircles[selectedIndex!].layer.sublayers?[0] as! CAShapeLayer
            shape.fillColor = isTouch ? selectedCircleBackgroundColor.cgColor : circleBackgroundColor.cgColor
            shape.strokeColor = isTouch ? selectedCircleBorderColor.cgColor : circleBorderColor.cgColor
            let shape2 = cropCircles[selectedIndex! + 2].layer.sublayers?[0] as! CAShapeLayer
            shape2.fillColor = isTouch ? selectedCircleBackgroundColor.cgColor : circleBackgroundColor.cgColor
            shape2.strokeColor = isTouch ? selectedCircleBorderColor.cgColor : circleBorderColor.cgColor
            
            if isTouch {
                self.cropViewDelegate?.panChangePoint(CGPoint.zero)
            } else {
                self.cropViewDelegate?.panChangePointEnd()
            }
        }
    }
    
    
    //MARK: 控制手势是否触发 解决手势冲突问题
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        let index = getClosestCorner(point: point)
        if index == -1 {
            return false
        }
        return true
    }
    
    @objc internal func panGesture(gesture : UIPanGestureRecognizer){
        let point = gesture.location(in: self)
        if(gesture.state == UIGestureRecognizer.State.began){
            selectedIndex = getClosestCorner(point: point)
            if selectedIndex == -1 {
                return
            }
            oldPoint = point
            if (cropCircles[selectedIndex!].layer.sublayers?.count != 0) {
                let shape = cropCircles[selectedIndex!].layer.sublayers?[0] as! CAShapeLayer
                shape.fillColor = selectedCircleBackgroundColor.cgColor
                shape.strokeColor = selectedCircleBorderColor.cgColor
            }
            
        }
        if gesture.state == UIGestureRecognizer.State.changed {
            if selectedIndex == -1 {
                return
            }
            if let selectedIndex = selectedIndex {
                if((selectedIndex) % 2 != 0){//通过手势平移边缘点-移动对应的边缘平行于它的旧位置
                    //Do complex stuff
                    let pt1 = cropCircles[selectedIndex - 1]
                    let pt2 = cropCircles[(selectedIndex == 7 ? 0 : selectedIndex + 1)]
                    var pt1New = pt1.center//getNewPoint(pt1: pt1.center,pt2: pt2.center,point: point,m: m)
                    var pt2New = pt2.center//getNewPoint(pt1: pt2.center, pt2: pt1.center, point: point,m: m)
                    
                    let disX = point.x - oldPoint.x //水平偏移量
                    let disY = point.y - oldPoint.y;//垂直偏移量
                
                    if (selectedIndex == 1 || selectedIndex == 5) {//Y轴平移
                        pt1New = CGPoint(x: pt1.center.x, y: pt1.center.y + disY)
                        pt2New = CGPoint(x: pt2.center.x, y: pt2.center.y + disY)
                    }
                    if (selectedIndex == 3 || selectedIndex == 7) {//x轴平移
                        pt1New = CGPoint(x: pt1.center.x + disX, y: pt1.center.y)
                        pt2New = CGPoint(x: pt2.center.x + disX, y: pt2.center.y)
                    }
                    
                    if(isInsideFrame(pt: pt1New)){
                        pt1.center = pt1New
                    }
                    if isInsideFrame(pt: pt2New) {
                        pt2.center = pt2New
                    }
                    let edge = cropCircles[selectedIndex].center
                    let newPoint = CGPoint(x: edge.x + (point.x - oldPoint.x) , y: edge.y + (point.y - oldPoint.y) )
                    oldPoint = point
//                    print("pt1New=", pt1New, "pt2New=", pt2New, cropImageView.frame.origin.x)
                    self.cropViewDelegate?.panChangePoint(newPoint)
                }else{// Pan gesure for edge points - move the corresponding edge parallel to its old position and passing through the gesture point
                    let edge = cropCircles[selectedIndex].center
                    let newPoint = CGPoint(x: edge.x + (point.x - oldPoint.x) , y: edge.y + (point.y - oldPoint.y) )
                    oldPoint = point
                    let boundedX = min(max(newPoint.x, cropImageView.frame.origin.x),(cropImageView.frame.origin.x+cropImageView.frame.size.width))
                    let boundedY = min(max(newPoint.y, cropImageView.frame.origin.y),(cropImageView.frame.origin.y+cropImageView.frame.size.height))
                    let finalPoint = CGPoint(x: boundedX, y: boundedY)
                    cropCircles[selectedIndex].center = finalPoint
                    self.cropViewDelegate?.panChangePoint(finalPoint)
                }
                moveNonCornerPoints()
                adjustCornerPointsAngle()
                redrawBorderRectangle()
            }
        }
        
        
        if(gesture.state == UIGestureRecognizer.State.ended){
            if selectedIndex == -1 {
                return
            }
            if let selectedIndex = selectedIndex{
                if (cropCircles[selectedIndex].layer.sublayers?.count != 0) {
                    let shape = cropCircles[selectedIndex].layer.sublayers?[0] as! CAShapeLayer
                    shape.fillColor = circleBackgroundColor.cgColor
                    shape.strokeColor = circleBorderColor.cgColor
                }
            }
            self.cropViewDelegate?.panChangePointEnd()
            selectedIndex = nil
            
            //Check if the quadrilateral is concave/convex/complex
            checkQuadrilateral()
            
        }
    }
    
    /**
     Updates the metaData of the image if its orientation is landscape
     */
    private func normalizedImage(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImage.Orientation.up) {
            return image;
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    //MARK: 根据图片大小进行适配--保持原图比例
    private func adaptiveImageFrame(image: UIImage) -> CGRect {
        let fatherWidth :CGFloat = self.bounds.width
        let fatherHeight :CGFloat = self.bounds.height
        var imgWidth :CGFloat = 0
        var imgHeight :CGFloat = 0
        if  (image.size.width/image.size.height >= fatherWidth/fatherHeight) {
            imgWidth = fatherWidth
            imgHeight = imgWidth / image.size.width * image.size.height
        } else {
            imgHeight = fatherHeight
            imgWidth = imgHeight / image.size.height * image.size.width
        }
        let imgX :CGFloat = (fatherWidth - imgWidth)/2
        let imgY :CGFloat = (fatherHeight - imgHeight)/2
        let rect = CGRect(x: imgX, y: imgY, width: imgWidth, height: imgHeight)
        return rect
    }
    
    //MARK: Post setup methods
    /**
     Reorder the points that form a complex quadrilateral to a convex one.
     */
    private func reorderEndPoints(){
        let endPoints = [cropCircles[0].center, cropCircles[2].center, cropCircles[4].center, cropCircles[6].center]
        var low = cropCircles[0].center
        var high = low;
        for point in endPoints{
            low.x = min(point.x, low.x);
            low.y = min(point.y, low.y);
            high.x = max(point.x, high.x);
            high.y = max(point.y, high.y);
        }
        
        let center = CGPoint(x: (low.x + high.x)/2,y: (low.y + high.y)/2)
        
        func angleFromPoint(point: CGPoint) -> Float{
            let theta = (Double)(atan2f((Float)(point.y - center.y), (Float)(point.x - center.x)))
            return fmodf((Float)(Double.pi - Double.pi/4 + theta), (Float)(2.0 * Double.pi))
        }
        
        let sortedArray = endPoints.sorted(by: {  (p1, p2)  in
            return angleFromPoint(point: p1) < angleFromPoint(point: p2)
        })
        
        for i in 0...3 {
            cropCircles[i*2].center = sortedArray[i]
        }
        moveNonCornerPoints()
        adjustCornerPointsAngle()
        redrawBorderRectangle()
    }
    
    /**
     If the pan gesture doesnt happen on one of the crop circles, fetch the closest corner (only corners).
     */
    private func getClosestCorner(point: CGPoint) -> Int{
        var index = -1
        var minDistance = self.touchRange > 0 ? self.touchRange : CGFloat.greatestFiniteMagnitude
        for i in stride(from: 0, to: 8, by: 1){
            let distance = distanceBetweenPoints(point1: point, point2: cropCircles[i].center)
            if(distance < minDistance){
                minDistance = distance
                index = i
            }
        }
        return index;
    }
    
    ///Assign edge points as the center of the corners
    private func moveNonCornerPoints(){
        for i in stride(from: 1, to: 8, by: 2){
            let prev = i-1
            let next = (i == 7 ? 0 : i+1)
            cropCircles[i].center = CGPoint(x: (cropCircles[prev].center.x + cropCircles[next].center.x)/2, y: (cropCircles[prev].center.y + cropCircles[next].center.y)/2)
        }
    }
    
    //MARK: 调整中间点的角度和变形平行
    private func adjustCornerPointsAngle() {
        for i in stride(from: 1, to: 8, by: 2){
            let prev = i-1
            let next = (i == 7 ? 0 : i+1)
            switch i{
            case 1,5:
                let rad = angleBetweenPoints(point1: cropCircles[prev].center, point2: cropCircles[next].center)
                cropCircles[i].transform = CGAffineTransform(rotationAngle: rad)
            case 3,7:
                let rad = angleBetweenPoints(point1: cropCircles[prev].center, point2: cropCircles[next].center)
                cropCircles[i].transform = CGAffineTransform(rotationAngle: rad - .pi/2)
            default:
                break
            }
        }
    }
    
    
    ///Before moving to a new location, check if the new point inside the cropView
    private func isInsideFrame(pt: CGPoint) -> Bool{
        if(lroundf(Float(pt.x)) < lroundf(Float(cropImageView.frame.origin.x)) || lroundf(Float(pt.x)) > lroundf(Float((cropImageView.frame.origin.x+cropImageView.frame.size.width))) ){
            return false
        }
        if(lroundf(Float(pt.y)) < lroundf(Float(cropImageView.frame.origin.y))  || lroundf(Float(pt.y)) > lroundf(Float((cropImageView.frame.origin.y+cropImageView.frame.size.height))) ){
            return false
        }
        return true
        
    }
    
    // MARK: Geometry Helpers
    ///Check if two points are on opposite sides of a line
    private func checkIfOppositeSides(p1:CGPoint, p2: CGPoint, l1: CGPoint, l2:CGPoint) -> Bool{
        let part1 = (l1.y-l2.y)*(p1.x-l1.x) + (l2.x-l1.x)*(p1.y-l1.y)
        let part2 = (l1.y-l2.y)*(p2.x-l1.x) + (l2.x-l1.x)*(p2.y-l1.y)
        if((part1*part2) < 0){
            return true
        }else{
            return false
        }
    }
    
    /// Checks if the points form a convex/concave/complex quadrilateral
    private func checkQuadrilateral(){
        let A = cropCircles[0].center
        let B = cropCircles[2].center
        let C = cropCircles[4].center
        let D = cropCircles[6].center
        
        isQuadrilateral = true
        if(checkIfOppositeSides(p1: B,p2: D,l1: A,l2: C) && checkIfOppositeSides(p1: A,p2: C,l1: B,l2: D)){//Convex
            border.strokeColor = rectangleBorderColor.cgColor
        }else if(!checkIfOppositeSides(p1: B,p2: D,l1: A,l2: C) && !checkIfOppositeSides(p1: A,p2: C,l1: B,l2: D)){//Complex
            border.strokeColor = rectangleBorderColor.cgColor
            reorderEndPoints()
        } else{//Concave
            border.strokeColor = UIColor.red.cgColor
            isQuadrilateral = false
        }
    }
    
    ///Returns the distance between two CGPoints
    private func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat{
        let xPow = pow((point1.x - point2.x), 2)
        let yPow = pow((point1.y - point2.y), 2)
        return CGFloat(sqrtf(Float(xPow + yPow)))
        
    }
    
    ///Returns the center of two CGPoints
    private func centerOf(firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint{
        return CGPoint(x: (firstPoint.x+secondPoint.x)/2, y: (firstPoint.y + secondPoint.y)/2)
    }
    
    ///Returns the center of two CGPoints
    private func angleBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat{
        //两个直角边
        let height = point2.y - point1.y
        let width  = point2.x - point1.x
        let rads = atan(height/width)
        return rads
    }
    
    //获取自动裁剪的坐标点
    @objc
    public func autoOriginalImagePoints() ->[String] {
        var returnArray = [String]();
        var corners = [CGPoint]()
        if (self.autoCropPoints.count != 0) {
            for newPoint:NSValue in self.autoCropPoints {
                corners.append(newPoint.cgPointValue)
            }
        } else {
            let points = OpenCVWrapper.getLargestSquarePoints(cropImageView.image, cropImageView.frame.size,isAutoMax)
            //Add crop points and circles
            if let points = points{
                for i in (0...3) {
                    let newPoint = points[i] as! CGPoint
                    corners.append(newPoint)
                }
            } else {
                let width = cropImageView.frame.width
                let height = cropImageView.frame.height
                corners.append(CGPoint(x: 0, y: 0))
                corners.append(CGPoint(x: width, y: 0))
                corners.append(CGPoint(x: width, y: height))
                corners.append(CGPoint(x: 0, y: height))
            }
        }

        let topWidth = distanceBetweenPoints(point1: corners[0], point2: corners[1])
        let bottomWidth = distanceBetweenPoints(point1: corners[3], point2: corners[2])
        let leftHeight = distanceBetweenPoints(point1: corners[0], point2: corners[3])
        let rightHeight = distanceBetweenPoints(point1: corners[1], point2: corners[2])
        let newWidth = max(topWidth, bottomWidth)
        let newHeight = max(leftHeight, rightHeight)
        let widthScale = originalImage!.size.width/cropImgW
        let heightScale = originalImage!.size.height/cropImgH
        
        let size = NSCoder.string(for: CGPoint(x: newWidth * widthScale, y: newHeight * heightScale))
        returnArray.append(size) //保存图片大小
    
        for i in (0...3) {
            let point = CGPoint(x: corners[i].x * widthScale, y: corners[i].y * heightScale)
            let ssp = NSCoder.string(for: point)
            returnArray.append(ssp) //保存图片坐标
        }
        return returnArray;
    }
    
    //获取裁剪的坐标点
    @objc
    public func cropOriginalImagePoints() ->[String] {
        var returnArray = [String]();
        reorderEndPoints()
        var corners = [CGPoint]()
        for i in stride(from: 0, to:7 , by: 2) {
            corners.append(cropCircles[i].center)
        }

        let topWidth = distanceBetweenPoints(point1: corners[0], point2: corners[1])
        let bottomWidth = distanceBetweenPoints(point1: corners[3], point2: corners[2])
        let leftHeight = distanceBetweenPoints(point1: corners[0], point2: corners[3])
        let rightHeight = distanceBetweenPoints(point1: corners[1], point2: corners[2])
        let newWidth = max(topWidth, bottomWidth)
        let newHeight = max(leftHeight, rightHeight)
        let widthScale = originalImage!.size.width/cropImgW
        let heightScale = originalImage!.size.height/cropImgH
        
        let size = NSCoder.string(for: CGPoint(x: newWidth * widthScale, y: newHeight * heightScale))
        returnArray.append(size) //保存图片大小
    
        for i in stride(from: 0, to:7 , by: 2) {
            let point = CGPoint(x: (cropCircles[i].center.x - cropImgX)  * widthScale, y: (cropCircles[i].center.y - cropImgY) * heightScale)
            let ssp = NSCoder.string(for: point)
            returnArray.append(ssp) //保存图片坐标
        }
        return returnArray;
    }
    
    @objc
    public func saveChangeEndPointArray() ->[NSValue]{
        var returnArray = [NSValue]()
        reorderEndPoints()
        for i in stride(from: 0, to:7 , by: 2) {
            let point = CGPoint(x: (cropCircles[i].center.x - cropImgX), y: (cropCircles[i].center.y - cropImgY))
            returnArray.append(NSValue.init(cgPoint: point))
        }
        return returnArray
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchSize: CGFloat = 30.0
        let viewFrame = cropImageView.frame.inset(by: UIEdgeInsets.init(top: -touchSize, left: -touchSize, bottom: -touchSize, right: -touchSize))
        if viewFrame.contains(point) {
            return cropImageView
        }
        return super.hitTest(point, with: event)
    }
}
