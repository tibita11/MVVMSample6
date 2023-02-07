//
//  ViewModel.swift
//  MVVMSample6
//
//  Created by 鈴木楓香 on 2023/02/07.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

struct ViewModelInput {
    let titleTextField: Observable<String?>
}

protocol ViewModelOutput {
    var validationText: Driver<String> { get }
    var registeredTitle: Driver<String?> { get }
    var resetTitle: Driver<String> { get }
    var isRegisterRnabled: Observable<Bool> { get }
    var isResetRnabled: Observable<Bool> { get }
}

protocol ViewModelType {
    var output: ViewModelOutput? { get }
    func setup(input: ViewModelInput)
}

class ViewModel: ViewModelType {
    var output: ViewModelOutput?
    
    private let maxTextCharacters = 10
    private let minTextCharacters = 5
    
    /// バリデーション文字列
    private var validationRelay = BehaviorRelay<String>(value: "")
    /// 登録ボタンが利用可能か
    private var isRegisterEnabledRelay = BehaviorRelay<Bool>(value: false)
    /// リセットボタンが利用可能か
    var isResetEnabledRelay = BehaviorRelay<Bool>(value: false)
    /// 登録ボタンが押された場合に発火
    var registerdTitleRelay = PublishRelay<String>()
    /// リセットボタンが押された場合に発火
    var resetTitleRelay = PublishRelay<String>()

    
    private let disposeBag = DisposeBag()
    
    init() {
        self.output = self
    }
    
    func setup(input: ViewModelInput) {
        input.titleTextField
            .filterNil()
            .subscribe(onNext: { [weak self] text in
                let count = text.count
                if count <= self!.maxTextCharacters,
                   count >= self!.minTextCharacters {
                    self!.validationRelay.accept("登録できます！")
                    self!.isRegisterEnabledRelay.accept(true)
                } else if count <= self!.maxTextCharacters
                            , count < self!.minTextCharacters {
                    self!.validationRelay.accept("5文字以上で記入してください")
                    self!.isRegisterEnabledRelay.accept(false)
                } else {
                    self!.validationRelay.accept("10文字以下で記入してください")
                    self!.isRegisterEnabledRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
            
    }

}

extension ViewModel: ViewModelOutput {
    var isRegisterRnabled: Observable<Bool> {
        return isRegisterEnabledRelay
            .asObservable()
    }
    
    var isResetRnabled: Observable<Bool> {
        return isResetEnabledRelay
            .asObservable()
    }
    
    var registeredTitle: Driver<String?> {
        return registerdTitleRelay
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: nil)
    }
    
    var resetTitle: Driver<String> {
        return resetTitleRelay
            .asDriver(onErrorJustReturn: "")
    }
    
    var validationText: Driver<String> {
        return validationRelay
            .asDriver()
    }
}
