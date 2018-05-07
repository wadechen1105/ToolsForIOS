//
//  QRCodeViewController.swift
//  Tools
//
//  Created by ilab on 2018/1/31.
//  Copyright © 2018年 wade.wade. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    override func viewDidLoad() {
        //get AVCaptureDevice device
        let captureDevice = AVCaptureDevice.default(for: .video)!
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // init captureSession
            captureSession = AVCaptureSession()
            // capture session set input
            captureSession?.addInput(input)
        } catch {
            print(error)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [.qr]
        
        // 初始化影像預覽層，並將其加為 viewPreview 視圖層的子層
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // 開始影像擷取
        captureSession?.startRunning()
        // 將訊息標籤移到最上層視圖
//        view.bringSubviewToFront(messageLabel)
        
        // 初始化 QR Code Frame 來突顯 QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        
        let redLineView = UIView()
        redLineView.bounds.size.width = self.view.frame.width
        redLineView.bounds.size.height = 1
        redLineView.frame.origin = CGPoint(x: 0.0, y: self.view.center.y)
        redLineView.backgroundColor = UIColor.red
        
        view?.addSubview(redLineView)
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 檢查 metadataObjects 陣列是否為非空值，它至少需包含一個物件
        if metadataObjects.isEmpty {
            qrCodeFrameView?.frame = .zero
//            messageLabel.text = "No QR code is detected"
            return
        }
        
        // 取得元資料（metadata）物件
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == .qr {
            
            //倘若發現的原資料與 QR code 原資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            if metadataObj.stringValue != nil {
//                messageLabel.text = metadataObj.stringValue
                Log.i(" value : \(metadataObj.stringValue), is running? \(captureSession?.isRunning)")
                
                
            }
        }
    }
    
}
