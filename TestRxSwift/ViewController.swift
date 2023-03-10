//
//  ViewController.swift
//  TestRxSwift
//
//  Created by SHKIM4 on 2022/12/27.
//
//https://blog.naver.com/yb2316/222284011277

import UIKit
import RxSwift
import RxCocoa
import RxRelay

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
        
        /*
         Variable (Deprecated)
         - BehaviorSubject를 래핑하고 값을 직선형으로 저장함
         - value 속성을 사용하여 값에 접근할 수 있음
         - 이제는 사용하지 않기 때문에 BehaviorRelay로 대체하길 권장됨
         */
        // String 타입의 이벤트를 받는 Variable
        /*
         let variable = Variable("Initial Value")
         variable.value = "Hello World"
         variable.asObservable() // Observable로 변환
         .subscribe {
         print($0) // next(Hello World)
         }
         
         // [String] 타입의 이벤트를 받는 Variable
         let variable1 = Variable([String]())
         
         variable1.value.append("item 1")
         variable1.asObservable()
         .subscribe {
         print($0) // next(["item 1"])
         }
         // 배열 값에 변화가 있으면 구독이 만료되고 새로고침 됨으로써 동작함
         variable1.value.append("item 2") // next(["item 1", "Item 2"])
         */
        
        /*
         < BehaviorRelay >
         - Variable을 대체할 수 있는 방법
         - RxSwift가 아닌 RxRelay(RxCocoa 내에 포함됨) 프레임워크에 포함되어 있음
         - relay 클래스는 종료 이벤트(completed 또는 error)가 발생하지 않기 때문에 구독이 취소될 일이 없다
         → UI 이벤트에 사용하기 적절하다!
         */
        
        
        // String 타입의 이벤트를 받는 BehaviorRelay
        let relay = BehaviorRelay(value: "Initial Value")
        relay.asObservable() // Observable로 변환
            .subscribe {
                print($0) // next(Initial Value)
            }
        //relay.value = "Hello World" // 오류 발생, value는 immutable 하기 때문
        relay.accept("Hello World") // next(Hello World)
        
        // [String] 타입의 이벤트를 받는 BehaviorRelay
        let relayT = BehaviorRelay(value: [String]())
        //relay.value.append("Item 1") // 오류 발생, value는 immutable
        // BehaviorRelay 에 값을 새로 추가하는 방법 (기존 값은 사라짐)
        relayT.accept(["Item 1"])
        relayT.asObservable()
            .subscribe {
                print($0) // next(["Item 1"])
            }
        
        // 기존 값을 유지하면서 값을 새로 추가하는 방법 1 - 수식으로 추가
        relayT.accept(relayT.value + ["Item 2"])
        relayT.asObservable()
            .subscribe {
                print($0.element) // next(["Item 1", "Item 2"])
            }
        
        // 기존 값을 유지하면서 값을 새로 추가하는 방법 2 - 변수를 만들어서 추가
        var value = relayT.value
        value.append("Item 3")
        value.append("Item 4")
        relayT.accept(value)
        relayT.asObservable()
            .subscribe {
                print($0) // next(["Item 1", "Item 2", "Item 3", "Item 4"])
            }
        
        
        /*
         Operators 란 Observable을 다루기 위한 여러 메서드들을 말해요.
         Observable을 생성하거나 Observable 시퀀스의 값을 변형하거나 Observable에서 발생한 에러를 처리하는 등의 연산을 수행할 수 있습니다.
         
         대부분의 Operator는 Observable에 대해 연산을 수행하고 Observable을 반환하기 때문에 여러 Operator들을 연결해서 사용할 수 있어요!
         이를 Chaining Operators​ 라고 해요.
         
         여러 연산자들을 연결해서 사용하게 되면 바로 이전 연산의 결과에 따라 현재 연산의 결과가 달라질 수 있겠죠?
         그래서 Operator를 사용할 때는 각 연산자를 사용하는 순서가 중요합니다!
         (연산의 순서에 따라 결과가 어떻게 달라지는지 시각적으로 보여주는 게임 사이트가 있어서 가져와봤어요 ><)
         https://david-peter.de/cube-composer/
         
         < Creating Observables Operator 란? >
         Creating Observables Operator는 여러 Operator 중에서도 Observable을 생성하기 위한 Operator를 말해요
         
         앞서 Observable에 대해 살펴봤을 때 봤던 Just / of / from 메서드와 create 메서드 역시 Creating Observables Operator에 속하는 메서드에요.
         이외에도 어떤 Opetator들이 있는지 ReactiveX 문서에서 선별한 것들 위주로 살펴볼게요!
         */
        Observable<String>.create { observer in
            observer.onNext("Create A")
            observer.onCompleted()
            return Disposables.create()
            // create 메서드를 통해 생성한 Observable은 Disposable을 생성해 반환해야 함
        }
        .subscribe( // 받은 이벤트에 따라 처리할 수 있는 클로저
            onNext: { print($0) },
            onError: { print($0) },
            onCompleted: { print("Completed") },
            onDisposed: { print("Disposed") }
        )
        .disposed(by: disposeBag)
        
        /*
         2. Deferred (docs)
         - lazy 하게 Observable을 생성하는 메서드
         - subscribe 할 때까지 Observable 생성을 미루다가(deferred) subscribe 할 때 Observable을 생성하고 이벤트를 방출
         - 각 Subscriber는 동일한 Observable이 아닌 개별 Observable을 구독하고 있게 됨
         */
        
        var count: Int = 0
        let deferredSequence = Observable<String>.deferred {
            print("count: \(count)")
            count += 1
            return Observable.create { observer in
                observer.onNext("A")
                observer.onNext("B")
                return Disposables.create()
            }
        }
        deferredSequence.subscribe {
            print($0)
        }.disposed(by: disposeBag)
        // count: 0
        // next(A)
        // next(B)
        deferredSequence.subscribe {
            print($0)
        }.disposed(by: disposeBag)
        // count: 1
        // next(A)
        // next(B)
        
        /*
         3. Empty, Never, Throw (docs)
         - Empty, Never, Throw 세 개의 메서드는 ​값을 방출하지 않는 Observable을 생성
         - Empty: completed 이벤트를 보내고 종료 되는 Observable 생성
         - Never: 종료되지 않는 Observable 생성
         - Throw: error 이벤트를 보내고 종료 되는 Observable 생성
         */
        /// Empty 메서드로 생성
        
        Observable<String>.empty()
            .subscribe {
                print($0)
            }.disposed(by: disposeBag)
        // completed
        
        /// Never 메서드로 생성
        Observable<String>.never()
            .subscribe {
                print($0)
            }.disposed(by: disposeBag)
        // 출력값 없음
        
        // 커스텀 에러
        enum TestError: Error {
            case unknown
        }
        
        /// Throw 메서드로 생성
        Observable<String>.error(TestError.unknown)
            .subscribe {
                print($0)
            }.disposed(by: disposeBag)
        // error(unknown)
        
        /*
         4. Interval (docs)
         - 주어진 시간을 간격으로(interval) 정수를 증가시켜 방출하는 Observable을 생성
         - Int 타입의 Observable에만 사용할 수 있음
         */
        // interval은 Int 타입의 Observable에만 사용 가능
        let observable = Observable<Int>.interval(
            .seconds(1), // --> 3초마다 값을 방출
            scheduler: MainScheduler.instance
        ).subscribe {
            print($0)
        }
        //.disposed(by: disposeBag)

        
        // 직접 해제시켜야함
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            observable.dispose()
        }
        // next(0) --> 0에서부터 1씩 증가시킨 값을 차례대로 방출
        // next(1)
        // next(2)
        
        /*
         5. Range (docs)
             - 특정 범위(range)의 정수를 방출하는 Observable을 생성
             - Int 타입의 Observable에만 사용할 수 있음
         */
        // range는 Int 타입의 Observable에만 사용 가능
        Observable<Int>.range(start: 10, count: 3)
            .subscribe {
                print($0)
            }.disposed(by: disposeBag)
        // next(10)
        // next(11)
        // next(12)
        // completed
        
        /*
         6. Repeat (docs)
             - 특정 항목을 여러번 방출하는 Observable을 생성
             - 따로 제어하지 않으면 생성을 무한 반복
             - 일정 횟수만큼 반복해서 방출하려면 take 메서드 등을 사용해서 제어 가능
         */
        
        Observable<String>.repeatElement("A")
            .take(5) // --> 5번만 방출하도록 제어
            .subscribe {
                print($0)
            }.disposed(by: disposeBag)
        
        /*
         7. Timer (docs)
             - 주어진 시간만큼 지연시킨 후 정수를 증가시켜 방출하는 Observable을 생성
             - 하나의 값을 내보낸 후 completed 이벤트를 보냄으로써 종료됨
         */
        /// 단일 값을 방출하는 timer 메서드

        let timerObservable1 = Observable<Int>.timer(
            .seconds(1), // 최초 시간 지연
            scheduler: MainScheduler.instance
        )
        //.timeout(.seconds(10), scheduler: MainScheduler.instance)
        .take(10)
        .subscribe (onNext: {
            print("timer1",$0)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 100) {
            timerObservable1.dispose()
        }
        
        //.disposed(by: disposeBag)
        // timer1 0
        /// 여러 개의 값을 방출하는 timer 메서드

        let timerObservable2 = Observable<Int>.timer(
            RxTimeInterval.seconds(3), // 최초 시간 지연
            period: RxTimeInterval.seconds(1), // 이후 시간 지연, 무한 반복
            scheduler: MainScheduler.instance
        )
        .take(5)
        .subscribe {
            print("timer2",$0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            timerObservable2.dispose()
        }
//        timer2 next(0)
//        timer2 next(1)
//        timer2 next(2)
//        timer2 next(3)
//        timer2 next(4)
//        timer2 completed
        
        /*
         < Transforming Observables Operator 란? >
         Transforming Observables Operator는 Observable에서 방출한 항목을 변환시키는 메서드를 말해요.
         Observables에서 방출하는 값들에 일정한 변화를 적용할 수도 있고
         조건을 기준으로 요소들을 병합하는 등의 연산을 수행할 수 있습니다.
         Operator는 Observable을 전달받아 Observable을 반환하는 경우가 대부분이라고 앞서 언급한 적이 있는데요.
         그래서 Transforming Observables Operator는 다음 연산을 위해 값을 변환하는데 사용한다고 볼 수 있어요!
         */
        
        /*
         1. Map (docs)
             - Observable에서 방출한 각각의 값들에 특정 함수 연산을 수행시킨 시퀀스를 결과로 반환하는​ 메서드
             - Swift의 map 메서드와 동작이 유사함
         */
        
        Observable.of(1, 2, 3)
            .map { $0 * 10 }  // 각 항목에 10을 곱하는 연산
            .subscribe { print("map",$0) }
            .disposed(by: disposeBag)
        // 10
        // 20
        // 30
        // completed
        
        /*
         2. FlatMap (docs)
             - Observable에서 방출한 값들에 특정한 연산을 수행시킨 후 하나의 새로운 시퀀스로 병합한 결과를 반환하는 메서드
             - Swift의 flatMap과 동작이 유사함
             - 순서를 보장하지 않음
         */
        let sequence1  = Observable<Int>.of(1, 2)
        let sequence2  = Observable<Int>.of(3, 4, 5)
        Observable.of(sequence1, sequence2)
            .flatMap{ $0 }  // 각 항목을 그대로 반환하는 연산
            .subscribe { print("flatMap",$0) }
            .disposed(by: disposeBag)
        
        /*
         3. GroupBy (docs)
             - Observable에서 방출한 값들을 Key 값에 따라 평가하고 Key 값을 기준으로 나눠서 각각의 시퀀스를 결과로 반환하는 메서드
             - 분류한 이벤트들의 Key 값과 Observable에서 방출한 본래의 값을 함께 가지는 Observable을 반환함
         */
        
        Observable.of(1, 2, 3, 4, 5)
            .groupBy { $0 % 2 == 0 }  // --> 짝수/홀수를 구분하는 연산
            .flatMap { $0.toArray() }  // --> 결과 그룹을 array 로 표현하기 위한 Operator
            .subscribe { print("GroupBy",$0) }
            .disposed(by: disposeBag)
        // next([1, 3, 5])
        // next([2, 4])
        // completed
        
        /*
         4. Buffer (docs)
             - Observable에서 방출한 값들을 주기적으로 일정 개수만큼 모아서 묶음(배열)으로 만든 시퀀스를 결과로 반환하는 메서드
             - 특정 주기 내에 일정 개수만큼의 값이 모인다면 주기를 기다리지 않고 바로 값을 방출함
             - 버퍼 내에 값을 모으던 중 에러가 발생하면 해당 버퍼의 값은 버리고 에러 이벤트를 방출함
         */
        Observable<Int>.interval(
            RxTimeInterval.seconds(1),  // --> 1초마다 0에서부터 1씩 증가하는 정수 생성
            scheduler: MainScheduler.instance
        )
        .map { $0 }
        .buffer(
            timeSpan: RxTimeInterval.seconds(5),  // --> 5초를 주기로 기다리면서 값을 모음
            count: 3,  // --> 최대 3개의 값을 묶음
            scheduler: MainScheduler.instance
        )

        .subscribe {
            print("Buffer", $0)
        }
        .disposed(by: disposeBag)
        /*
        Buffer next([0, 1, 2])
        Buffer next([3, 4, 5])
        Buffer next([6, 7, 8])
        Buffer next([9, 10, 11])
         */
        
        /*
         < Filtering Observables Operators 란? >
         Filtering Observables Operators는 Observable에서 방출되는 요소들을 선택적으로 내보낼 수 있는 연산자를 말해요.
         일정 시간 동안 여러 개의 이벤트가 들어왔을 때 하나만 선택해서 내보내거나
         앞에서부터 몇 개를 고르거나
         서로 다른 이벤트만 고르는 등
         조건에 따라 Observable의 시퀀스를 다룰 수 있어요!
         */
        /*
         1-1. Debounce (docs)
             - 마지막 이벤트를 기준으로 일정 시간(dueTime)이 지나면 마지막 이벤트를 방출하는 메서드
             - 일정 시간 동안 들어온 이벤트는 무시됨
             - 주로 텍스트 필드 입력 중에 사용
         */
        let numbers = Array(stride(from: 1, through: 10, by: 1))
        // 1초마다 1~10의 숫자를 방출하는 Observable
        let intervalObservable = Observable<Int>.create { observer in
            numbers.forEach { number in
                DispatchQueue.global().asyncAfter(
                    deadline: DispatchTime.now() + Double(number)
                ) {
                    print("emit \(number)")
                    observer.onNext(number)
                    if numbers.last == number {
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }

        intervalObservable
        .debounce(
            // 2.5초를 간격으로 디바운싱
            RxTimeInterval.milliseconds(2500),
            scheduler: MainScheduler.instance
        )
        .subscribe {
            print("intervalObservable",$0)
        }
        .disposed(by: disposeBag)
        // emit 1
        // emit 2
        // ...
        // emit 10
        // next(10) --> 2.5초가 지나기 전에 새 이벤트가 들어오므로 마지막 이벤트만 방출됨
        // completed
        /*
         1-2. Throttle (docs)
             - 최초 방출된 이벤트로부터 일정 시간(dueTime) 동안 이벤트를 무시하는 메서드
             - latest 설정에 따라 dueTime 중 발생한 이벤트를 방출하거나(true) 하지 않을 수 있음(false)
             - 주로 버튼 이벤트 중복 호출 방지에 사용
         */
        let throttleNumbers = Array(stride(from: 1, through: 10, by: 1))
        // 1초마다 1~10의 숫자를 방출하는 Observable
        let intervalTObservable = Observable<Int>.create { observer in
            throttleNumbers.forEach { number in
                DispatchQueue.global().asyncAfter(
                    deadline: DispatchTime.now() + Double(number)
                ) {
                    print("ThrottleEmit \(number)")
                    observer.onNext(number)
                    if numbers.last == number {
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }

        intervalTObservable
        .throttle(
            RxTimeInterval.milliseconds(2500),
            latest: true,
            scheduler: MainScheduler.instance
        )
        .subscribe {
            print("Throttle",$0)
        }
//        ThrottleEmit 1
//        Throttle next(1)
//        ThrottleEmit 2
//        ThrottleEmit 3
//        Throttle next(3)
//        ThrottleEmit 4
//        ThrottleEmit 5
//        ThrottleEmit 6
//        Throttle next(6)
//        ThrottleEmit 7
//        ThrottleEmit 8
//        Throttle next(8)
//        ThrottleEmit 9
//        ThrottleEmit 10
//        Throttle next(10)
//        Throttle completed
        .disposed(by: disposeBag)
        
        intervalObservable
        .throttle(
            RxTimeInterval.milliseconds(2500),
            latest: false,  // --> latest가 false일 경우 dueTime 내의 이벤트 방출하지 않음
            scheduler: MainScheduler.instance
        )
        .subscribe {
            print("falseThrottle",$0)
        }
        //.disposed(by: disposeBag)
//        falseThrottle next(1)
//        falseThrottle next(4)
//        falseThrottle next(7)
//        falseThrottle next(10)
//        falseThrottle completed
        
        /*
         2. Distinct (docs)
             - 중복 방출되는 이벤트에 대해 하나의 이벤트만 방출시켜주는 메서드
             - 일부 구현 중에는 연속으로 중복되는 이벤트만 걸러주기도 함 (RxSwift의 경우)
         */
        Observable<Int>.of(1, 2, 3, 3, 2, 3)
            .distinctUntilChanged()
            .subscribe {
                print("Distinct",$0)
            }
        //    .disposed(by: disposeBag)
        // next(1)
        // next(2)
        // next(3) --> 연속되는 중복 항목 제거
        // next(2)
        // next(3) --> 연속되지 않는 중복 항목이므로 이벤트 방출
        // completed
        
        /*
         3. ElementAt (docs)
             - Observable 내의 이벤트 중 n번째 이벤트만 방출하는 메서드
             - 0에서부터 이벤트 개수를 셈
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .element(at: 3)
            .subscribe {
                print("ElementAt",$0)
            }
            .disposed(by: disposeBag)
//        ElementAt next(4)
//        ElementAt completed
        
        /*
         4. Filter (docs)
             - 조건에 맞는 이벤트만 방출하는 메서드
             - 조건은 반드시 Bool 결과를 반환해야 함
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .filter {
                $0 < 3
            }
            .subscribe {
                print("filter",$0)
            }
            .disposed(by: disposeBag)
        // next(1)
        // next(2)
        // completed
        
        /*
         5. First (docs)
             - Observable이 방출한 첫 번째 항목 또는 조건에 맞는 첫 번째 항목을 방출하는 메서드
             - 일부 구현 중에는 Observable을 반환하도록 구현되어 있지 않기 때문에 Take 연산자를 쓰거나 ElementAt 연산자를 쓰면 원하는 결과를 얻을 수 있음 (RxSwift의 경우)
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .first()
            .subscribe {
                print("First",$0)
            }
            .disposed(by: disposeBag)
        // success(Optional(1)) --> 결과 값이 다르다, Single 타입을 반환하기 때문
        
        /*
         6. IgnoreElements (docs)
             - Observable에서 항목을 방출하지 않고 바로 종료 이벤트를 보내는 메서드
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .ignoreElements()
            .subscribe {
                print("IgnoreElements",$0)
            }
            .disposed(by: disposeBag)
        // completed
        
        /*
         7. Sample (docs)
             - 매개변수로 받은 Observable(source)이 트리거될 때 마다 자신(data)의 최신 이벤트를 방출하는 메서드
             - data observable이 완료되면 source observable이 트리거 될 때 완료 이벤트를 전달함
         */
        let source = PublishSubject<Void?>()
        let data = PublishSubject<Int>()
        data.sample(source)
            .subscribe {
                print("Sample",$0)
            }
            .disposed(by: disposeBag)
        data.onNext(1)
        data.onNext(2)
        source.onNext(())  // next(2)
        source.onNext(())  // 무시
        data.onNext(3)
        source.onNext(nil)  // next(3) --> source의 값은 무엇이든 상관 없음
        source.onNext(nil)  // 무시
        data.onCompleted()
        source.onNext(())  // completed
        
        /*
         8. Skip (docs)
             - Observable에서 방출되는 n개의 이벤트를 무시하는(스킵하는) 메서드
             - 스킵한 이벤트 이후의 이벤트는 정상적으로 방출됨
             - take 메서드와 반대되는 동작
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .skip(3)
            .subscribe {
                print("Skip",$0)
            }
            .disposed(by: disposeBag)
        // next(4)
        // next(5)
        // completed
        
        /*
         8-1. SkipWhile (docs)
             - Observable에서 방출되는 항목이 조건에 해당하는 동안 이벤트를 방출하지 않는 메서드
             - 조건이 false를 반환하면 이후 이벤트는 모두 방출
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .skip(while: {
                $0 < 3
            })
            .subscribe {
                print("SkipWhile",$0)
            }
            .disposed(by: disposeBag)
        // next(3)
        // next(4)
        // next(5)
        // completed
        
        /*
         - 매개변수로 받은 Observable(trigger)이 이벤트를 방출한 이후로 자신(data)의 이벤트를 모두 방출하는 메서드
         - trigger observable이 한 번 이벤트를 방출한 후에는 다른 이벤트를 방출해도 data의 이벤트 방출에는 영향이 없음
         */
        
        let trigger = PublishSubject<String>()
        let triggerData = PublishSubject<Int>()
        triggerData.skip(until: trigger)
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        triggerData.onNext(1)  // 무시
        triggerData.onNext(2)  // 무시
        trigger.onNext("A")  // --> trigger의 값이 방출된 이후로 모든 이벤트를 방출
        triggerData.onNext(3)  // next(3)
        trigger.onNext("B")  // --> 이후 이벤트는 상관 X
        triggerData.onNext(4)  // next(4)
        triggerData.onCompleted()  // completed
        
        /*
         9. Take (docs)
             - Observable에서 방출되는 n개의 이벤트만 방출하는 메서드
             - n개째의 이벤트를 방출하면서 종료 이벤트를 함께 보냄
             - skip 메서드와 반대되는 동작
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .take(3)
            .subscribe {
                print("Take",$0)
            }
            .disposed(by: disposeBag)
        // next(1)
        // next(2)
        // next(3)
        // completed
        
        /*
         9-1. TakeWhile (docs)
             - Observable에서 방출되는 항목이 조건에 해당하지 않을 때까지 이벤트를 방출하는 메서드
             - 조건이 만족하지 않을 때 종료 이벤트를 보냄
         */
        Observable<Int>.of(1, 2, 3, 4, 5)
            .take(while: {
                $0 < 3
            })
            .subscribe {
                print("TakeWhile",$0)
            }
            .disposed(by: disposeBag)

        // next(1)
        // next(2)
        // completed
        
        /*
         9-2. TakeUntil (docs)
             - 매개변수로 받은 Observable(trigger)이 이벤트를 방출할 때까지 자신(data)의 이벤트를 모두 방출하는 메서드
             - trigger observable이 이벤트를 방출한 후 종료 이벤트를 함께 보냄
         */
        let triggerPublish = PublishSubject<String>()
        let dataPublish = PublishSubject<Int>()
        dataPublish.take(until: trigger)
            .subscribe {
                print("TakeUntil",$0)
            }
            .disposed(by: disposeBag)
        dataPublish.onNext(1)  // next(1)
        dataPublish.onNext(2)  // next(2)
        triggerPublish.onNext("A")  // completed
        dataPublish.onNext(3)  // 무시
        triggerPublish.onNext("B")  // --> 이후 이벤트는 상관 X
        dataPublish.onNext(4)  // 무시
        dataPublish.onCompleted()  // 무시
    }
}
