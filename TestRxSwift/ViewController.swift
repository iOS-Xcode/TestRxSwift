//
//  ViewController.swift
//  TestRxSwift
//
//  Created by SHKIM4 on 2022/12/27.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let observable = Observable.just(1)
    // just 메서드를 사용하면 단 하나의 요소로 옵저버블을 생성할 수 있음
    // 정수 1을 방출하는 옵저버블을 생성함

    let observable2 = Observable.of(1, 2, 3)
    // of 메서드를 사용하면 여러개의 요소로 옵저버블을 생성할 수 있음
    // Observable<Int> 타입 --> 해당 옵저버블을 구독하면 Int 타입의 정수 1, 2, 3을 얻을 수 있다.

    let observable3 = Observable.of([1, 2, 3])
    // Observable<[Int]> 타입 --> 타입 추정에 의해 옵저버블의 타입을 결정함

    let observable4 = Observable.from([1, 2, 3, 4, 5])
    // from 메서드를 사용하면 전달 인자의 개별 요소로 옵저버블을 생성할 수 있음
    
    //let subject = PublishSubject<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         Observable
         Subscribe
         */
        
        //just
//        just next(1)
//        just completed
        observable.subscribe { event in
            print("just",event)
        }
        //of
//        of next(1)
//        of next(2)
//        of next(3)
//        of completed
        observable2.subscribe{ event in
            print("of",event)
        }
        
        /// from 메서드로 생성한 옵저버블
        observable4.subscribe { event in
            print("from",event)

        }
//        from next(1)
//        from next(2)
//        from next(3)
//        from next(4)
//        from next(5)
//        from completed
        observable4.subscribe { event in
            if let element = event.element {
                print("fromWithElement",element)
            }
        }
//        fromWithElement 1
//        fromWithElement 2
//        fromWithElement 3
//        fromWithElement 4
//        fromWithElement 5
        /// of 메서드로 생성한 옵저버블

        observable3.subscribe { event in
            print("of",event)

        }
//        of next([1, 2, 3])
//        of completed
        observable3.subscribe { event in
            if let element = event.element {

                print("ofWithElement",element)
            }
        }
        //ofWithElement [1, 2, 3]
        observable4.subscribe(onNext: { element in

            print("onNext",element)

        })
//        onNext 1
//        onNext 2
//        onNext 3
//        onNext 4
//        onNext 5
        
        let subscription4 = observable4.subscribe(onNext: { element in
            print("dispose",element)
        })
        subscription4.dispose() // 구독을 종료했으므로 메모리에서 해제됨
        
        //DisposeBag 사용.
        let disposeBag = DisposeBag()

        Observable.of("A", "B", "C")
            .subscribe{
                print("disposeBag",$0)
        }.disposed(by: disposeBag) // DisposeBag에 Disposable을 담아둠
        
        /// create 메서드 사용
        Observable<String>.create { observer in
            observer.onNext("A")
            observer.onCompleted()
            observer.onNext("?")
            // create 메서드를 통해 생성한 Observable은 Disposable을 생성해 반환해야 함
            return Disposables.create()
        }
        .subscribe( // 받은 이벤트에 따라 처리할 수 있는 클로저
            onNext: { print($0) },
            onError: { print($0) },
            onCompleted: { print("Completed") },
            onDisposed: { print("Disposed") }
        )
        .disposed(by: disposeBag)
//        A
//        Completed
//        Disposed
        
        /*
         Subject(Observable이자 Observer == Subscriber)
         Subscribe
         구독 이후 발생한 이벤트만 트리거
         Subject는 이벤트를 방출할 수도 있고, 구독할 수도 있습니다.
         즉, Subject는 스스로 데이터를 가질 수 있는 Observable 이라고 볼 수 있어요. (2022.12.02. 추가)
         */
        
        //PublishSubject
        // String 타입의 이벤트만 내보낼 수 있는 PublishSubject
        let subject = PublishSubject<String>()
//        subject.subscribe(onNext: { string in
//            print("string",string)
//        })
    //    // 이벤트 추가 --> 아무 일도 발생하지 않음 (Subscriber가 없기 때문)
        subject.onNext("No onNext Issue 1")
    //
    //    // 구독 추가 --> 하지만 구독이 호출되지 않음, 구독 이전에 발생한 이벤트는 트리거하지 않기 때문
        subject.subscribe { event in
            print(event)
        }

        // 이벤트 추가 --> 이벤트가 구독자들에게 방출됨
        subject.onNext("Issue 2") // next(Issue 2)
        subject.onNext("Issue 3") // next(Issue 3)
        
        subject.onCompleted()
        subject.onNext("Issue 5") // completed 이므로 출력하지 않음
        
        /*
         BehaviorSubject
             - PublishSubject와 비슷하지만 한 가지 차이점이 있음
                 → 구독을 시작하는 시점에 subject가 가진 값 중 사용 가능한 마지막 값(최신 값)을 방출함
             - 초기화 시 기본값이 필요함
                 → 구독할 때 초기 값 또는 Subject가 가지고 있던 마지막 값을 제공하기 때문
             - 기본값을 넣어주지 않으려면 옵셔널 타입의 값을 넣어주면 됨
             - 오류가 발생하면 이미 구독하고 있는 Subscriber 뿐만 아니라 새로 구독하는 Subscriber 에게도 오류 방출 (2022.12.02.)
         */
        // 초기값이 있는 BehaviorSubject
        let subjectB = BehaviorSubject(value: "Initial Value")
        subjectB.onNext("Last Issue") // subject가 가지고 있던 마지막 이벤트를 트리거, 이 구문이 없으면 "Initial Value" 출력
        // 구독 추가 --> 구독 호출 됨, 구독 이전에 발생한 이벤트를 트리거하기 때문
        subjectB.subscribe { event in
            print(event) // next(Last Issue)
        }
        // .onNext("Last Issue") 구문이 없었으면 "Initial Value" 출력
        // 이벤트 추가
        subjectB.onNext("Issue 1") // next(Issue 1)
        
        
        /*
         ReplaySubject
             - ReplaySubject의 이벤트는 설정한 ​버퍼 사이즈를 기반으로 동작
                 → 구독할 때 Subject가 가진 최신 이벤트를 버퍼 사이즈 만큼 방출
             - 초기화 시 기본값은 필요하지 않지만 버퍼 값을 지정해야 함
                 → 기본값을 지정하지 않으려면 타입을 옵셔널로 선언하는 방법이 있다.
             - 버퍼에 제한을 두지 않으려면 unbounded 로 생성하는 방법이 있다.
                 → ReplaySubject<String>.createUnbounded()
         */
        
        // String 타입의 이벤트 2개를 방출하는 ReplaySubject (기준: 마지막 값에서 부터 2개)
        let subjectC = ReplaySubject<String>.create(bufferSize: 2)
        subjectC.onNext("Issue 1C")
        subjectC.onNext("Issue 2C")
        subjectC.onNext("Issue 3C")
        // 구독 추가 --> 구독 이전에 발생한 2개의 최신 이벤트를 트리거
        subjectC.subscribe {
            print($0) // next(Issue 2)
                              // next(Issue 3)
        }
        subjectC.onNext("Issue 4C") // next(Issue 4)
        subjectC.onNext("Issue 5C") // next(Issue 5)
        subjectC.onNext("Issue 6C") // next(Issue 6)

        // 새로운 구독 추가 --> 마찬가지로 가장 최신 이벤트 2개를 트리거
        subjectC.subscribe {
            print($0) // next(Issue 5)
                              // next(Issue 6)
        }
    }
}

