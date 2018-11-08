//
//  ViewController.swift
//  testRXswift1015
//
//  Created by 高垣 豊 on 2018/10/16.
//  Copyright © 2018年 yutaka takagaki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    // 観測対象のObjectの一括会報用
    let disposeBag = DisposeBag()
    
    // SegmentedControlに対応する値の定義
    enum State: Int {
        case useButtons
        case useTextField
    }
    
    
    // UIパーツの配置
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    // 初期化時の初期値の設定
    let lastSelectedGreeting: Variable<String> = Variable("こんにちは")
    
    @IBOutlet var greetingButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // nameフィールドで、テキスト入力を観測対象に
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        
        // freeフィールドで、テキスト入力を観測対象に
        let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
        
        let freewordWithNameObservable: Observable<String?> = Observable.combineLatest(
            nameObservable,
            freeObservable
        ) { (string1: String?, string2: String?) in
            return string1! + string2!
        }
        
        freewordWithNameObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
        let segmentedControlObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
        
        let stateObservervable: Observable<State> = segmentedControlObservable.map {
            (selectedIndex: Int) -> State in
            return State(rawValue: selectedIndex)!
        }
        
        let greetingTextFieldEnabaledObservable: Observable<Bool> = stateObservervable.map {
            (state: State) -> Bool in
            return state == .useTextField
        }
        
        greetingTextFieldEnabaledObservable.bind(to: freeTextField.rx.isEnabled).disposed(by: disposeBag)
        
        let buttonsEnabledObservable: Observable<Bool> = greetingTextFieldEnabaledObservable.map {
            (greetingEnabled: Bool) -> Bool in
            return !greetingEnabled
        }
        
        greetingButtons.forEach{ button in
            
            buttonsEnabledObservable.bind(to: button.rx.isEnabled).disposed(by: disposeBag)
            
            button.rx.tap.subscribe(onNext: {(nothing: Void) in self.lastSelectedGreeting.value = button.currentTitle!}).disposed(by: disposeBag)
        }
        
        let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()
        
        let finalGreetingObservable: Observable<String> = Observable.combineLatest(stateObservervable, freeObservable, predefinedGreetingObservable, nameObservable) { (state: State, freeword: String?, predefinedGreeting: String, name:String?) -> String in
        
        switch state {
        case .useTextField: return freeword! + name!
        case .useButtons: return predefinedGreeting + name!
        }
        }

        finalGreetingObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
}


}
