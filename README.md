# TravelApplication

## 개요
여행 계획을 작성하고, 추억이 담긴 사진을 업로드하는 애플리케이션 프로젝트입니다.


<br></br>
## 프로젝트 기간
2022.1 ~ 2023.2


<br></br>
## 사용 기술
|구현 내용|도구|
|---|---|
|아키텍처|MVVM + Clean Architecture|
|UI|UIKit|
|동시성 프로그래밍|Swift Concurrency|
|원격 데이터 저장소|Firebase Firestore 및 Storage|
|지도 서비스|MapKit & Core Location|



<br></br>
## 패키지 종속성 관리
Swift Package Manager를 사용하여 모듈 및 라이브러리 종속성을 관리했습니다.
|패키지|내용|
|---|---|
|FirebasePlatform|데이터 모듈|
|Domain|도메인 모듈|
|SnapKit|레이아웃 코드 작성|
|JGProgressHUD|Progress indicator 생성|




<br></br>
## MVVM Architecture
<p align="center">
 <img src="/Document/MVVM.png">
</p>

- Combine 프레임워크를 사용해서 **View**와 **View Model**간에 바인딩을 수행
- 콘텐츠를 작성하는 사용자 액션(UIControl event 발생)과 **ViewModel**의 데이터를 바인딩하고 저장할 때 **Model**을 업데이트

<br></br>
## Clean Architecture

- MVVM 아키텍처 패턴을 기반으로 Presentation layer, Domain layer, Data layer로 나눔.
- Clean Architecture의 핵심은 계층을 나누고 의존성 정책을 정의하여 그것을 지키는 것이며 올바른 의존성 정책에서 테스트 용이성, 낮은 유지보수 비용이라는 이점을 누릴 수 있다고 생각하였음.


<br></br>
### 의존성 정책
<p align="center">
 <img src="/Document/Dependency policy.png" height=300>
</p>

- 의존성은 **Presentation layer -> Domain layer -> Data layer**와 같이 안쪽으로 향하되, 계층의 경계마다 인터페이스를 두고 코드의 의존성을 역전시킴.
- **독립적으로 확장 및 유지보수가 가능.** 예를 들어, 원격 데이터 저장소로 Firebase 서비스를 이용하고 있는데, 후에 이를 교체할 필요가 있다면 이미 정의된 Repository 인터페이스를 청사진으로 삼아 확장하고 연결해주기만 하면 되도록 구성


<br></br>
### Use case

- Use case는 애플리케이션의 핵심 비즈니스 로직을 포함
- 각 Use case는 데이터 포맷을 정의하여 Repository와 데이터를 주고받는 로직을 최소한의 단위로 캡슐화함.


<br></br>
## 뷰 및 동작
### Plans
|메인|계획 수정|계획 수정 2|계획 추가|
|---|---|---|---|
|<image src="Document/plansList.png" width="180">|<image src="Document/editPlan.png" width="180">|<image src="Document/editPlan2.png" width="180">|<image src="Document/newPlan.png" width="180">|

- 각 여행 계획(Plan)에는 상세 일정(Schedule)들이 포함됨.
- 따라서 여행 계획은 상세 일정의 내용을 취합하여 보여줌.


<br></br>
|상세 일정 추가|상세 일정 수정|변경 사항 추적|동적인 레이아웃|
|---|---|---|---|
|<image src="Document/newSchedule.png" width="180">|<image src="Document/editSchedule.png" width="180">|<image src="Document/cancel.png" width="180">|<image src="Document/dynamicLayout.gif" width="180">|

- 추가, 수정 중 취소를 눌렀을 때, 변경 사항을 추적해서 알려줌.
- 동적인 레이아웃을 제공하여 불필요한 뷰를 줄임.


<br></br>
### MapKit과 애니메이션
|HybridMap|Dark mode|카메라 애니메이션|상세 일정 순서 수정|
|---|---|---|---|
|<image src="Document/MKHybridMapConfiguration.png" width="180">|<image src="Document/darkmode.png" width="180">|<image src="Document/nextAnimation.gif" width="180">|<image src="Document/editOrder.gif" width="180">|


<br></br>
### Memories
<p align="center">
 <img src="Document/memoriesTab.gif" width="250">
</p>

- 추억이 담긴 사진 업로드 및 다운로드
- Firebase Storage의 데이터를 다운로드하여 사용가능한 이미지로 변환(Data <-> UIImage)
- **Memory**탭 초기 진입 시 이미지 다운로드 병렬 처리 및 재진입 시 캐시 전략 적용
