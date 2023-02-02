# TravelApplication

## 개요
여행 계획을 작성하고, 추억이 담긴 사진을 업로드하는 애플리케이션 프로젝트입니다.


<br></br>
## 사용 기술
|구현 내용|도구|
|---|---|
|아키텍처|MVVM + Clean Architecture|
|UI|UIKit|
|동시성 프로그래밍|Swift Concurrency|
|원격 데이터 저장소|Firebase Firestore 및 Storage|



<br></br>
## 패키지 종속성 관리
Swift Package Manager를 사용하여 종속성을 관리했습니다.
|패키지|내용|
|---|---|
|Firebase|데이터 저장|
|SnapKit|레이아웃 코드 작성|
|JGProgressHUD|Progress indicator 생성|



<br></br>
## MVVM Architecture
<p align="center">
 <img src="/Document/MVVM.png">
</p>

- Combine 프레임워크를 사용해서 **View**와 **View Model**간에 바인딩을 수행
- 원격 데이터 저장소로부터 데이터를 받아와서, 또는 콘텐츠를 작성하는 사용자 액션을 통해 **Model**을 업데이트


<br></br>
## Clean Architecture
<p align="center">
 <img src="/Document/CleanArchitecture.jpg" height=300>
</p>

<p align="center">
 출처: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
</p>

- MVVM 아키텍처 패턴을 기반으로 Presentation layer, Domain layer, Data layer로 나눔.
- Clean Architecture의 핵심은 계층을 나누고 의존성 정책을 정의하여 그것을 지키는 것이라고 생각함. 올바른 의존성 정책에서 테스트 용이성, 낮은 유지보수 비용이라는 이점을 누릴 수 있음.


<br></br>
### UseCase
<p align="center">
 <img src="/Document/UseCase.png" height=300>
</p>

- UseCase는 애플리케이션의 핵심 비즈니스 로직을 포함.
- 각 UseCase는 데이터 포맷을 정의하여 Repository와 데이터를 주고 받거나, 모델을 조작하는 로직을 최소한의 단위로 캡슐화함.


<br></br>
### 의존성 정책
<p align="center">
 <img src="/Document/Dependency policy.png" height=300>
</p>

- 코드의 의존성은 **Presentation layer -> Domain layer -> Data layer**와 같이 안쪽으로 향하되, 계층의 경계마다 Plug Point 인터페이스(프로토콜)를 두고 의존성을 역전시킴.
- **독립적으로 확장 및 유지보수가 가능.** 예를 들어, 원격 데이터 저장소로 Firebase 서비스를 이용하고 있는데, 후에 이를 교체할 필요가 있다면 이미 정의되어 있는 Repository 인터페이스를 청사진으로 삼아 확장하고 연결해주기만 하면 되도록 구성.

<br></br>
## 뷰 및 동작
<p align="center">
 <img src="/Document/Simulator Recording.gif" width="25%">
 <img src="/Document/cancel.png" width="25%">
 <img src="/Document/new memory.png" width="25%">
</p>

- 내비게이션 및 모달 기능을 적절히 사용하여 View Hierarchy 이동
- 콘텐츠를 수정 및 추가할 때, 변경사항을 추적하여 공지함.
- 사진 불러오기: Firebase Storage의 데이터를 다운로드하여 사용가능한 이미지로 변환(Data <-> UIImage). 
- **Memory**탭 초기 진입시 이미지 다운로드 병렬 처리 및 재진입 시 캐시 전략 적용
