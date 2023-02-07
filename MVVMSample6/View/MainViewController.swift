//
//  MainViewController.swift
//  MVVMSample6
//
//  Created by 鈴木楓香 on 2023/02/07.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var registerdLabel: UILabel!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    private var viewModel: ViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        viewModel = ViewModel()
        let input = ViewModelInput(titleTextField: titleTextField.rx.text.asObservable())
        viewModel.setup(input: input)
        
        registrationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self!.viewModel.registerdTitleRelay.accept(self!.titleTextField.text!)
                self!.viewModel.isResetEnabledRelay.accept(true)
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext:  {[weak self] in
                self!.viewModel.resetTitleRelay.accept("登録してね！")
                self!.viewModel.isResetEnabledRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        viewModel.output?.validationText
            .drive(validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output?.registeredTitle
            .drive(registerdLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output?.resetTitle
            .drive(registerdLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output?.isRegisterRnabled
            .subscribe(onNext: { [weak self] bool in
                self!.registrationButton.isEnabled = bool
            })
            .disposed(by: disposeBag)
        
        viewModel.output?.isResetRnabled
            .subscribe(onNext: { [weak self] bool in
                self!.resetButton.isEnabled = bool
            })
            .disposed(by: disposeBag)
    }


}
