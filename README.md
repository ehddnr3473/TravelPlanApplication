# TravelApplication

## 개요
여행 계획을 작성하고, 추억이 담긴 사진을 업로드하는 애플리케이션 프로젝트입니다.


<br></br>
## 사용 기술
|구현 내용|도구|
|---|---|
|아키텍처|MVVM|
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
## 아키텍처
<p align="center">
 <img src="/Document/MVVM.png">
</p>

- 원격 데이터 저장소로부터 데이터를 받아와서, 또는 콘텐츠를 작성하는 사용자 액션을 통해 **Model**을 업데이트.
- Combine 프레임워크를 사용해서 **View**와 **View Model**간에 바인딩을 수행



<br></br>
## 뷰 및 동작
<p align="center">
 <img src="/Document/Simulator Recording.gif" width="25%">
 <img src="/Document/cancel.png" width="25%">
 <img src="/Document/new memory.png" width="25%">
</p>

- 내비게이션 및 모달 기능을 적절히 사용하여 View Hierachy 이동
- 콘텐츠를 수정 및 추가할 때, 변경사항을 추적하여 공지함.
- 사진 불러오기: Firebase Storage의 데이터를 다운로드하여 사용가능한 이미지로 변환(Data <-> UIImage). 
- **Memory**탭 초기 진입시 이미지 다운로드 병렬 처리 및 재진입 시 캐시 전략 적용
