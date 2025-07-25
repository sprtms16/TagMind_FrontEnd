# TagMind Frontend

> **당신의 생각과 경험을 기록하고 관리하는 모바일 저널**

이 리포지토리는 TagMind 모바일 애플리케이션의 프론트엔드 소스 코드를 관리합니다. Flutter를 사용하여 iOS와 Android를 모두 지원합니다.

---

## 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [주요 변경 사항](#주요-변경-사항)
- [프로젝트 설정 및 실행](#프로젝트-설정-및-실행)
- [개발 로드맵](#개발-로드맵)
- [트러블슈팅](#트러블슈팅)

## 주요 기능

TagMind는 단순한 일기장을 넘어, 사용자의 삶을 더 깊이 이해하도록 돕는 동반자입니다.

- **마찰 없는 일기 작성 (Frictionless Entry):** 앱을 열자마자 바로 생각을 기록할 수 있는 단순하고 직관적인 UI를 제공하여, 꾸준한 기록 습관을 지원합니다.
- **태그 기반 일기 관리 (Tag-based Journaling):** 사용자가 일기를 작성하고 태그를 선택하여 내용을 분류합니다.
- **핵심 데이터 시각화 (Core Visualization):**
  - **타임라인/캘린더 뷰:** 작성된 일기를 시간 순서나 달력 형태로 쉽게 탐색할 수 있습니다.
  - **인사이트 대시보드:** 'Year in Pixels' 스타일의 기분 달력, 태그-감정 상관관계 분석 등 다양한 차트를 통해 자신의 삶의 패턴을 시각적으로 탐색합니다.
- **감성적 게임화 (Emotional Gamification):** '마음의 정원' 컨셉을 통해, 일기를 기록할수록 자신만의 정원이 성장하는 감성적 보상을 제공하여 장기적인 동기를 부여합니다.
- **기본 검색 (Basic Search):** 텍스트 내용이나 태그를 기반으로 과거의 일기를 빠르게 검색할 수 있습니다.

## 기술 스택

- **Framework:** Flutter
- **State Management:** Provider
- **HTTP Client:** http
- **Storage:** flutter_secure_storage (인증 토큰), shared_preferences (사용자 설정)
- **Linting:** lint
- **Testing:** flutter_test, mockito

## 주요 변경 사항

최근 업데이트를 통해 다음과 같은 개선 사항이 적용되었습니다:

- **테스트 코드 개선**:
    - `testWidgets` 중첩 오류를 수정하여 테스트 스위트가 올바르게 실행되도록 했습니다.
    - `mockito` 사용법을 개선하고 불필요한 빈 줄을 제거하여 테스트 코드의 가독성과 간결성을 높였습니다.
- **UI/UX 개선**:
    - `Diary` 모델 생성자의 매개변수 순서를 Dart 컨벤션에 맞게 재정렬하여 가독성을 높였습니다.
    - `TagStoreScreen.routeName` 정적 상수를 사용하여 하드코딩된 라우트 이름을 대체하고 유지보수성을 향상시켰습니다.
    - `AppBar` 내 `TextField`의 텍스트 및 힌트 스타일 색상을 `AppBar` 배경과 대비가 좋도록 변경하여 가독성을 개선했습니다.
    - `ThemeData` 정의 내에 하드코딩된 색상 값을 상수로 정의하고 재사용하여 테마 관리의 용이성을 높였습니다.
- **상태 관리 및 성능 최적화**:
    - `DiaryProvider`의 `diaries` getter에 대한 setter를 추가하여 `_diaries` 리스트의 일관성 없는 직접 할당 문제를 해결하고 적절한 상태 관리를 보장했습니다.
    - `initState`에서 불필요한 네트워크 호출을 제거하고, `_allDiaries`에서 로컬 필터링을 통해 데이터를 가져오도록 최적화하여 앱 시작 시 네트워크 부하를 줄이고 성능을 향상시켰습니다.
    - `diary_edit_screen.dart` 및 `tag_store_screen.dart`에서 `if (!mounted) return;` 검사를 추가하여 비동기 작업 후 위젯이 dispose될 경우 발생할 수 있는 런타임 오류를 방지했습니다.
- **코드 품질 향상**:
    - `_groupTagsByCategory` 메서드를 `static`으로 변경하여 코드 구성 및 테스트 용이성을 개선했습니다.
    - 불필요한 `.cast<Widget>()` 호출을 제거하여 코드를 간결하게 만들었습니다.
    - `Diary` 모델의 `content` 속성이 non-nullable이므로 `home_screen.dart`에서 `?? 'No content'`와 같은 불필요한 null-coalescing 연산자를 제거했습니다.
    - `image_picker` 의존성을 제거했습니다.
    - `print()` 문을 `debugPrint()`로 대체했습니다.
- **유효성 검사 추가**: `diary_edit_screen.dart`에서 일기 저장 전 최소 하나의 태그가 선택되었는지 확인하는 유효성 검사를 추가했습니다.

## 프로젝트 설정 및 실행

1.  **Flutter 설치:** [공식 문서](https://flutter.dev/docs/get-started/install)를 참고하여 Flutter SDK를 설치합니다.
2.  **리포지토리 클론:**
    ```bash
    git clone https://github.com/your-username/TagMind.git
    cd TagMind/frontend
    ```
3.  **의존성 설치:**
    ```bash
    flutter pub get
    ```
4.  **애플리케이션 실행:**
    ```bash
    flutter run
    ```

## 개발 로드맵

프로젝트는 4단계의 린(Lean)하고 반복적인 접근법을 따릅니다.

### 1단계: 발견, 기획 및 디자인 (1-4주차)
- **WBS 1.1:** 시장 및 사용자 리서치
- **WBS 1.2:** 제품 전략 및 로드맵 확정
- **WBS 1.3:** UX/UI 디자인 (와이어프레임, 목업, 프로토타입)
- **WBS 1.4:** 기술 아키텍처 설계

### 2단계: 최소 기능 제품(MVP) 개발 (5-12주차)
- **WBS 2.1:** 백엔드 개발 (사용자 인증, 기본 API, DB)
- **WBS 2.2:** 프론트엔드 개발 (핵심 UI/UX)
- **WBS 2.3:** 핵심 기능 구현 (일기 CRUD, 수동 태깅, 캘린더/타임라인 뷰, 기본 검색)
- **WBS 2.4:** QA 및 테스트
- **WBS 2.5:** 소프트 론칭 (비공개 베타 테스트)

### 3단계: 기능 확장 및 개선 (13-20주차)
- **WBS 3.1:** 고급 검색 및 필터링 기능 구현
- **WBS 3.2:** 사용자 맞춤형 통계 및 리포트 기능 개발
- **WBS 3.3:** 알림 기능 구현
- **WBS 3.4:** 데이터 백업 및 복원 기능 구현
- **WBS 3.5:** 사용자 피드백 시스템 구축

### 4단계: 공식 출시, 마케팅 및 반복 (21주차 이후)
- **WBS 4.1:** 앱 스토어 출시
- **WBS 4.2:** 마케팅 캠페인 실행
- **WBS 4.3:** 수익화 기능 구현
- **WBS 4.4:** 지속적인 데이터 분석 및 기능 반복 개선

## 트러블슈팅

이 섹션에는 프로젝트 진행 중 발생한 주요 에러와 해결 과정을 기록합니다.

| 날짜       | 문제 상황 | 해결 과정 | 참고 링크 |
| ---------- | --------- | --------- | --------- |
| 2025-07-17 | Frontend/Backend CORS 오류 | FastAPI 백엔드에서 `CORSMiddleware` 설정을 수정하여 모든 출처(`allow_origins=["*"]`)를 허용하도록 변경. 중복 선언된 미들웨어를 정리하고 Docker 이미지를 재빌드하여 해결. | - |
| 2025-07-17 | `passlib`와 `bcrypt` 버전 충돌 | `requirements.txt`에 `bcrypt==3.2.0` 버전을 명시적으로 추가하여 라이브러리 호환성 문제를 해결하고 Docker 이미지를 재빌드함. | - |
| 2025-07-16 | 예: iOS 빌드 시 Cocoapods 버전 충돌 | `pod repo update` 후 `pod install` 재실행 | -         |
| 2025-07-24 | `DiaryProvider`의 `diaries` getter에 직접 할당 시 런타임 오류 | `DiaryProvider`에 `setDiaries` setter를 추가하고, `HomeScreen`에서 해당 setter를 사용하여 `_diaries` 리스트를 업데이트하도록 수정. | - |