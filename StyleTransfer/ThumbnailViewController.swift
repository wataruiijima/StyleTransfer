//
//  ThumbnailViewController.swift
//  StyleTransfer
//
//  Created by w-iijima on 2019/06/13.
//  Copyright © 2019 w-iijima. All rights reserved.
//

import UIKit
import CoreML

class ThumbnailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var cgImage:CGImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let ciImage = CIImage(cgImage: cgImage!)

        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setDefaults()
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.2, forKey: kCIInputScaleKey)
        
        let filterOutput = filter?.outputImage?.oriented(.right)
        
        let numStyles  = 9
        let styleIndex = 0
        
        let styleArray = try? MLMultiArray(shape: [numStyles] as [NSNumber], dataType: MLMultiArrayDataType.double)
        
        for i in 0...((styleArray?.count)!-1) {
            styleArray?[i] = 0.0
        }
        styleArray?[styleIndex] = 1.0
        
        
        let model = MyStyleTransfer()
        
        // set input size of the model
        let modelInputSize = CGSize(width: 600, height: 600)

        // create a cvpixel buffer
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(modelInputSize.width),
                            Int(modelInputSize.height),
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        
        // put bytes into pixelBuffer
        let context = CIContext()
        context.render(filterOutput!, to: pixelBuffer!)
        
        // predict image
        let output = try? model.prediction(image: pixelBuffer!, index: styleArray!)
        let predImage = CIImage(cvPixelBuffer: (output?.stylizedImage)!)
        
        imageView.image = UIImage(ciImage: predImage)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
