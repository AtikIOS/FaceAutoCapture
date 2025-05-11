//
//  ViewController.swift
//  FaceAutoCapture
//
//  Created by Atik Hasan on 5/10/25.
//

// MARK: --------  AI CODE JUST AKBER IMAGE CAPTURE KORBE ----------

//import UIKit
//import Vision
//import AVFoundation
//
//class ViewController: UIViewController {
//    
//    @IBOutlet weak var cameraView: UIView!
//    
//    var faceDetectedStartTime: Date?
//    var faceStillVisible = false
//    var photoCaptured = false
//    var drawings: [CAShapeLayer] = []
//    var videoOutput: AVCaptureVideoDataOutput?
//    let captureSession = AVCaptureSession()
//    var backFacingCamera: AVCaptureDevice?
//    var frontFacingCamera: AVCaptureDevice?
//    var currentDevice: AVCaptureDevice?
//    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        cameraPreviewLayer?.frame = cameraView.bounds
//    }
//
//    func setupCamera() {
//        configure()
//        
//        guard let currentDevice = currentDevice,
//              let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice),
//              captureSession.canAddInput(captureDeviceInput) else {
//            print("Failed to configure camera input.")
//            return
//        }
//
//        captureSession.sessionPreset = .high
//        captureSession.addInput(captureDeviceInput)
//        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        cameraPreviewLayer?.videoGravity = .resizeAspectFill
//        cameraPreviewLayer?.frame = cameraView.layer.bounds
//        if let previewLayer = cameraPreviewLayer {
//            cameraView.layer.insertSublayer(previewLayer, at: 0)
//        }
//
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            self?.captureSession.startRunning()
//        }
//        
//        
//        // Add video output for frame analysis
//        videoOutput = AVCaptureVideoDataOutput()
//        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        videoOutput?.alwaysDiscardsLateVideoFrames = true
//
//        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//        }
//
//    }
//    
//    private func configure() {
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
//            deviceTypes: [.builtInWideAngleCamera],
//            mediaType: .video,
//            position: .unspecified
//        )
//        
//        for device in deviceDiscoverySession.devices {
//            if device.position == .back {
//                backFacingCamera = device
//            } else if device.position == .front {
//                frontFacingCamera = device
//            }
//        }
//        
//        currentDevice = backFacingCamera
//    }
//    
//    private func detectFace(image: CVPixelBuffer) {
//        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                if let results = request.results as? [VNFaceObservation], !results.isEmpty {
//                    // Face(s) detected
//                    self.handleFaceDetectionResults(observedFaces: results, pixelBuffer: image)
//                } else {
//                    // Face lost
//                    self.clearDrawings()
//                    self.faceStillVisible = false
//                    self.faceDetectedStartTime = nil
//                    self.photoCaptured = false
//                    print("Face lost")
//                }
//            }
//        }
//
//        let orientation: CGImagePropertyOrientation = (self.currentDevice?.position == .front) ? .leftMirrored : .right
//
//        let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: orientation, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([faceDetectionRequest])
//            } catch {
//                print("Face detection error: \(error)")
//            }
//        }
//    }
//
//
//
//
//
//    
//    private func handleFaceDetectionResults(observedFaces: [VNFaceObservation], pixelBuffer: CVPixelBuffer) {
//        clearDrawings()
//        guard let cameraPreviewLayer = cameraPreviewLayer else { return }
//
//        // Face dekhte thakle flag set kora
//        faceStillVisible = true
//
//        // Jodi face detect hoy na, tahole photoCaptured flag abar false kora
//        if observedFaces.isEmpty {
//            photoCaptured = false
//        }
//
//        // New face detect hole timer start kora
//        if faceDetectedStartTime == nil {
//            faceDetectedStartTime = Date()
//            photoCaptured = false
//
//            // 3 seconds por abar check kore capture kora
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
//                guard let self = self else { return }
//
//                if let startTime = self.faceDetectedStartTime,
//                   Date().timeIntervalSince(startTime) >= 3.0,
//                   self.faceStillVisible,
//                   !self.photoCaptured {
//                    self.photoCaptured = true
//                    self.capturePhoto() // Photo capture
//                    print("Photo captured!")
//                }
//            }
//        }
//
//        // Face bounding box draw kora
//        for faceObservation in observedFaces {
//            let boundingBox = faceObservation.boundingBox
//            let size = cameraView.bounds.size
//            let x = boundingBox.origin.x * size.width
//            let y = (1 - boundingBox.origin.y - boundingBox.size.height) * size.height
//            let width = boundingBox.size.width * size.width
//            let height = boundingBox.size.height * size.height
//
//            let faceBoundingBoxOnScreen = CGRect(x: x, y: y, width: width, height: height)
//            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
//            let faceBoundingBoxShape = CAShapeLayer()
//
//            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
//            faceBoundingBoxShape.path = faceBoundingBoxPath
//            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
//            cameraView.layer.addSublayer(faceBoundingBoxShape)
//            drawings.append(faceBoundingBoxShape)
//        }
//    }
//
//
//
//
//    func capturePhoto() {
//        let photoSettings = AVCapturePhotoSettings()
//        let photoOutput = AVCapturePhotoOutput()
//
//        if captureSession.canAddOutput(photoOutput) {
//            captureSession.addOutput(photoOutput)
//            photoOutput.capturePhoto(with: photoSettings, delegate: self)
//        }
//    }
//
//    private func clearDrawings() {
//        drawings.forEach { $0.removeFromSuperlayer() }
//        drawings.removeAll()
//    }
//
//}
//
//
//extension ViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard error == nil else {
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation() else {
//            return
//        }
//
//        let image = UIImage(data: imageData)
//        print(image as Any)
//    }
//}
//
//
//
//extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput,
//                       didOutput sampleBuffer: CMSampleBuffer,
//                       from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        detectFace(image: pixelBuffer)
//    }
//
//}





// MARK: --------  AI CODE BAR BAR IMAGE CAPTURE KORBE ----------


import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    var faceDetectedStartTime: Date?
    var faceStillVisible = false
    var photoCaptured = false
    var drawings: [CAShapeLayer] = []
    var videoOutput: AVCaptureVideoDataOutput?
    let captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraPreviewLayer?.frame = cameraView.bounds
    }

    func setupCamera() {
        configure()
        guard let currentDevice = currentDevice,
              let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice),
              captureSession.canAddInput(captureDeviceInput) else {
            print("Failed to configure camera input.")
            return
        }

        captureSession.sessionPreset = .high
        captureSession.addInput(captureDeviceInput)
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.frame = cameraView.layer.bounds
        if let previewLayer = cameraPreviewLayer {
            cameraView.layer.insertSublayer(previewLayer, at: 0)
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        
        // Add video output for frame analysis
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput?.alwaysDiscardsLateVideoFrames = true

        if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Add photo output for capturing photos (only once)
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }

    private func configure() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
    }

    private func detectFace(image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], !results.isEmpty {
                    // Face(s) detected
                    self.handleFaceDetectionResults(observedFaces: results, pixelBuffer: image)
                } else {
                    // Face lost
                    self.clearDrawings()
                    self.faceStillVisible = false
                    self.faceDetectedStartTime = nil
                    self.photoCaptured = false
                    print("Face lost")
                }
            }
        }

        let orientation: CGImagePropertyOrientation = (self.currentDevice?.position == .front) ? .leftMirrored : .right

        let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: orientation, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([faceDetectionRequest])
            } catch {
                print("Face detection error: \(error)")
            }
        }
    }

    private func handleFaceDetectionResults(observedFaces: [VNFaceObservation], pixelBuffer: CVPixelBuffer) {
        clearDrawings()
        guard let cameraPreviewLayer = cameraPreviewLayer else { return }

        // Face dekhte thakle flag set kora
        faceStillVisible = true

        // Jodi face detect hoy na, tahole photoCaptured flag abar false kora
        if observedFaces.isEmpty {
            photoCaptured = false
        }

        // New face detect hole timer start kora
        if faceDetectedStartTime == nil {
            faceDetectedStartTime = Date()
            photoCaptured = false

            // 3 seconds por abar check kore capture kora
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }

                if let startTime = self.faceDetectedStartTime,
                   Date().timeIntervalSince(startTime) >= 3.0,
                   self.faceStillVisible,
                   !self.photoCaptured {
                    self.photoCaptured = true
                    self.capturePhoto() // Photo capture
                    print("Photo captured!")
                }
            }
        }

        // Face bounding box draw kora
        for faceObservation in observedFaces {
            let boundingBox = faceObservation.boundingBox
            let size = cameraView.bounds.size
            let x = boundingBox.origin.x * size.width
            let y = (1 - boundingBox.origin.y - boundingBox.size.height) * size.height
            let width = boundingBox.size.width * size.width
            let height = boundingBox.size.height * size.height

            let faceBoundingBoxOnScreen = CGRect(x: x, y: y, width: width, height: height)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            
            faceBoundingBoxShape.strokeColor = UIColor.green.cgColor
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            cameraView.layer.addSublayer(faceBoundingBoxShape)
            drawings.append(faceBoundingBoxShape)
        }
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()

        // Photo output is already added, so no need to add it again
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    private func clearDrawings() {
        drawings.forEach { $0.removeFromSuperlayer() }
        drawings.removeAll()
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }

        let image = UIImage(data: imageData)
        print(image as Any)
    }
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(image: pixelBuffer)
    }
}
