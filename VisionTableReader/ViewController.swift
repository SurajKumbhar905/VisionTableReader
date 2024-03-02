//
//  ViewController.swift
//  VisionTableReader
//
//  Created by Suraj Kumbhar on 02/03/24.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var resultTextLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizeTextFromTableVertical(in: UIImage(named: "Test2") ?? UIImage())
        //        recognizeTextFromTableHorizhontal(in: UIImage(named: "Test2") ?? UIImage())
    }
    
    func recognizeTextFromTableVertical(in image: UIImage) {
        
        guard let cgImage = image.cgImage else { return }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let bounds = CGRect(origin: .zero, size: size)
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        let request = VNRecognizeTextRequest { [self] request, error in
            guard
                let results = request.results as? [VNRecognizedTextObservation],
                error == nil
            else { return }
            
            let rects = results.map {
                convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
            }
            
            
            var targetBoundingBoxes: [String: CGRect] = [:]
            let keyWordArray :[String] = ["Salesperson"]
            
            for targetWord in keyWordArray {
                for result in results {
                    if let candidate = result.topCandidates(1).first, candidate.string.lowercased() == targetWord.lowercased() {
                        var boundingBox = convert(boundingBox: result.boundingBox, to: CGRect(origin: .zero, size: size))
                        //                        boundingBox.origin.y += bounds.minY // Extend left and right by half of xExtension
                        boundingBox.size.height += bounds.width // Extend the width by xExtension
                        targetBoundingBoxes[targetWord] = boundingBox
                        
                    }
                }
            }
            
            
            for (_, boundingBox) in targetBoundingBoxes {
                var textInsideTargetBox = ""
                for result in results {
                    let boundingBox1 = convert(boundingBox: result.boundingBox, to: CGRect(origin: .zero, size: size))
                    if boundingBox.intersects(boundingBox1), let text = result.topCandidates(1).first?.string {
                        textInsideTargetBox += "\(text)\n"
                    }
                    
                }
                
                DispatchQueue.main.async { [self] in
                    resultTextLabel.text = textInsideTargetBox
                }
                
                
                
                
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let finalImage = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                    image.draw(in: bounds)
                    UIColor.green.setStroke()
                    //                    for rect in rects {
                    let path = UIBezierPath(rect: boundingBox)
                    path.lineWidth = 9
                    path.stroke()
                    UIColor.red.setStroke()
                    for rect in rects {
                        let path = UIBezierPath(rect: rect)
                        path.lineWidth = 1
                        path.stroke()
                    }
                    //                    }
                }
                DispatchQueue.main.async { [self] in
                    ImageView.image = finalImage
                }
            }
            
            
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    func recognizeTextFromTableHorizhontal(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let bounds = CGRect(origin: .zero, size: size)
        let request = VNRecognizeTextRequest { [self] request, error in
            guard
                let results = request.results as? [VNRecognizedTextObservation],
                error == nil
            else { return }
            
            let rects = results.map {
                convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
            }
            
            
            var targetBoundingBoxes: [String: CGRect] = [:]
            let keyWordArray :[String] = ["Bromley"]
            for targetWord in keyWordArray {
                for result in results {
                    if let candidate = result.topCandidates(1).first, candidate.string.lowercased() == targetWord.lowercased() {
                        var boundingBox = convert(boundingBox: result.boundingBox, to: CGRect(origin: .zero, size: size))
                        boundingBox.origin.x -= bounds.minX  // Extend left and right by half of xExtension
                        boundingBox.size.width += bounds.width  // Extend the width by xExtension
                        targetBoundingBoxes[targetWord] = boundingBox
                        
                    }
                }
            }
            
            
            for (word, boundingBox) in targetBoundingBoxes {
                print("Bounding box of '\(word)': \(boundingBox)")
                
                var textInsideTargetBox = ""
                for result in results {
                    let boundingBox1 = convert(boundingBox: result.boundingBox, to: CGRect(origin: .zero, size: size))
                    if boundingBox.intersects(boundingBox1), let text = result.topCandidates(1).first?.string {
                        textInsideTargetBox += "\(text)\n "
                    }
                    
                }
                print(textInsideTargetBox,"suraj string")
                DispatchQueue.main.async { [self] in
                    resultTextLabel.text = textInsideTargetBox
                }
                
                
                
                
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                let final = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                    image.draw(in: bounds)
                    UIColor.green.setStroke()
                    //                    for rect in rects {
                    let path = UIBezierPath(rect: boundingBox)
                    path.lineWidth = 9
                    path.stroke()
                    UIColor.red.setStroke()
                    for rect in rects {
                        let path = UIBezierPath(rect: rect)
                        path.lineWidth = 1
                        path.stroke()
                    }
                    //                    }
                }
                DispatchQueue.main.async { [self] in
                    ImageView.image = final
                }
            }
            
            
            
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    
    func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = boundingBox
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.minX
        rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    
}

