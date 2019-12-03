//
//  ViewController.swift
//  CoreML_Handson
//
//  Created by 藤山裕輝 on 2019/11/30.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    
    // 撮影した画像を表示するImageView
    @IBOutlet weak var photographTaken: UIImageView!
    // 中央に，alpha_0.5で表示するImageView
    @IBOutlet weak var photographTakenCenter: UIImageView!
    @IBOutlet weak var actorPhotographCenter: UIImageView!
    // 芸能人の画像を表示するImageView
    @IBOutlet weak var actorPhotograph: UIImageView!
    
    // 結果を表示するlabel
    @IBOutlet weak var resultLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        // カメラ起動ボタンのデザイン
        self.startButton.backgroundColor = UIColor.systemBlue
        self.startButton.setTitleColor(UIColor.white, for: .normal)
        self.startButton.layer.cornerRadius = 20
        self.startButton.layer.shadowColor = UIColor.gray.cgColor
        self.startButton.layer.shadowRadius = 5
        self.startButton.layer.shadowOpacity = 0.4
        self.startButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.startButton.layer.borderColor = UIColor.white.cgColor
        self.startButton.layer.borderWidth = 1.0
    }
    
    // ボタンがタップされた時にカメラを起動する
    @IBAction func captureStart(_ sender: Any) {
        let sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        
        // カメラが利用可能かチェックする
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    // 撮影が完了した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        // dismiss
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            photographTaken.contentMode = .scaleAspectFill
            photographTaken.image = pickedImage
            photographTakenCenter.contentMode = .scaleAspectFill
            photographTakenCenter.image = pickedImage
            
            
            startJudge(pickedImage)
        }
    }
    
    
    /*----------------- 判定を開始するメソッド（引数には撮影した写真を渡す） ---------------*/
    func startJudge(_ targetPhoto: UIImage) {
        // 先程作成したmlmodelをCoreMLで使用出来るようにVNCoreMLModelに変換する
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {
            print("VNCoreMLModelの変換に失敗しました")
            return
        }
        // 判定するためのリクエスト組み立て
        let request = VNCoreMLRequest(model: model) {
            request, error in
            // resultsに配列で判定結果が返ってくる
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            // resultsの1番最初の値を変数nameに格納する
            let name = results[0].identifier
            self.resultLabel.text = "あなたは，もはや\(name)です"
            
            // 判定結果に合った芸能人の画像を表示
            self.actorPhotograph.image = UIImage(named: "\(name).png")
            self.actorPhotograph.contentMode = .scaleAspectFill
            self.actorPhotographCenter.image = UIImage(named: "\(name).png")
            self.actorPhotographCenter.contentMode = .scaleAspectFill
            
        }
        
        // 画像のリサイズ
        request.imageCropAndScaleOption = .centerCrop
        
        // CIImageに変換
        guard let ciImage = CIImage(image: targetPhoto) else {
            return
        }
        
        // 画像の向きを調節
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(targetPhoto.imageOrientation.rawValue))!
        
        // ハンドラを実行
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            try handler.perform([request])
        } catch {
            print("error handler")
        }
    }
    /*------------------------ ここまでがCoreMLを用いた処理 -----------------------------*/
    
}

