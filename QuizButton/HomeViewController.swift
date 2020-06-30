//
//  ViewController.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2019/04/16.
//  Copyright © 2019 Shutaro Aoyama. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation

final class HomeViewController: UIViewController {
    
    internal var presenter: HomePresenterProtocol!
    
    func inject(presenter: HomePresenterProtocol) {
        self.presenter = presenter
    }
    
    @IBOutlet weak var countLabel: UILabel!
        
    let screenSize = UIScreen.main.bounds
    
    var count = 0
    
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //Sound setup
        var fileURL = Bundle.main.path(forResource: "quizsound", ofType: "m4a")!
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
        } catch  {
            print("error on audio")
        }
    }
    
    @IBAction func ConnectButtonTapped(_ sender: Any) {
        presenter.connectButtonPressed()
    }
    
    // Sending Data
    @IBAction func answerButtonTapped(_ sender: Any) {
        presenter.answerButtonPressed()
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        presenter.resetButtonPressed()
    }
    
    
    // Score Counter
    @IBAction func addCounter(_ sender: UIButton) {
        count += sender.tag
        countLabel.text = String(count)
    }
    
    @IBAction func subtractCounter(_ sender: UIButton) {
        count -= sender.tag
        countLabel.text = String(count)
    }
    
}

extension HomeViewController: HomePresenterOutput {
    
    func showConnectionAlert() {
        let actionSheet = UIAlertController(title: "Quiz Button", message: "Host or Join a session", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            self.presenter.hostSessionSelected()
        }))

        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            self.presenter.joinSessionSelected()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height/2, width: 0, height: 0)
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showConnectionBrowser(view: UIViewController) {
        present(view, animated: true, completion: nil)
    }
    
    func changeBackgroundColor(to color: BackgroundColor) {
        switch color {
        case .red:
            view.backgroundColor = .red
        case .blue:
            view.backgroundColor = .blue
        case .black:
            view.backgroundColor = UIColor(red:0.12, green:0.13, blue:0.14, alpha:1.0)
        }
    }
    
    func playBeepSound() {
        audioPlayer?.currentTime = 0         // 再生箇所を頭に移す
        audioPlayer?.play()
    }
    
}
