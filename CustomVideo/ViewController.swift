//
//  ViewController.swift
//  CustomVideo
//
//  Created by Aditya Narayan on 4/11/17.
//
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{

    var captureSession = AVCaptureSession()
    
    var previewLayer:CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareCamera()
    }
    
    func prepareCamera(){
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            
            self.captureDevice = availableDevices.first
            self.beginSession()
        }
        
    }

    func beginSession() {
        
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.captureDevice)
            
            self.captureSession.addInput(captureDeviceInput)
            
        } catch{
            print(error.localizedDescription)
        }
        
        if let prevLayer = AVCaptureVideoPreviewLayer(session: self.captureSession){
            self.previewLayer = prevLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer?.frame = self.view.layer.frame
            self.captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if self.captureSession.canAddOutput(dataOutput){
                self.captureSession.addOutput(dataOutput)
            }
            
            self.captureSession.commitConfiguration()
            
            
            let queue = DispatchQueue(label: "alexsavitt.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
            
        }
        
        
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        self.takePhoto = true
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if (self.takePhoto == true){
            self.takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                
                    let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                    
                    photoVC.takenPhoto = image
                
                    DispatchQueue.main.async {
                        self.present(photoVC, animated: true, completion: { 
                            self.stopCaptureSession()
                        })
                    }
            }
        }
        
    }

    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
     
        return nil
    }
    
    func stopCaptureSession(){
        self.captureSession.stopRunning()
        
        if let inputs = self.captureSession.inputs as? [AVCaptureDeviceInput]{
            for input in inputs{
                self.captureSession.removeInput(input)
            }
        }
    }
    
}




























