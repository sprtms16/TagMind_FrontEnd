# TagMind Frontend

> **당신의 생각과 경험을 자동으로 분석하여, 삶을 형성하는 숨겨진 패턴을 발견해주는 지능형 저널**

이 리포지토리는 TagMind 모바일 애플리케이션의 프론트엔드 소스 코드를 관리합니다. Flutter를 사용하여 iOS와 Android를 모두 지원합니다.

---

## 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [프로젝트 설정 및 실행](#프로젝트-설정-및-실행)
- [개발 로드맵](#개발-로드맵)
- [트러블슈팅](#트러블슈팅)

## 주요 기능

- **마찰 없는 일기 작성:** 앱을 열자마자 바로 생각을 기록할 수 있는 단순하고 직관적인 UI
- **지능형 자동 태깅:** 일기 내용을 분석하여 관련 태그(인물, 활동, 감정, 장소 등)를 자동으로 추천
- **데이터 시각화:** 'Year in Pixels' 스타일의 기분 달력, 태그-감정 상관관계 분석 등 다양한 차트를 통해 자신의 삶을 시각적으로 탐색
- **감성적 게임화:** '마음의 정원' 컨셉을 통해 기록 활동에 대한 감성적 보상과 장기적인 동기 부여

## 기술 스택

- **Framework:** Flutter
- **State Management:** Provider / Riverpod (예정)
- **HTTP Client:** Dio
- **Storage:** flutter_secure_storage (인증 토큰), shared_preferences (사용자 설정)
- **Linting:** lint

## 프로젝트 설정 및 실행

1.  **Flutter 설치:** [공식 문서](https://flutter.dev/docs/get-started/install)를 참고하여 Flutter SDK를 설치합니다.
2.  **리포지토리 클론:**
    ```bash
    git clone https://github.com/sprtms16/TagMind_FrontEnd.git
    cd TagMind_FrontEnd
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

상세한 개발 Task는 [WBS(Work Breakdown Structure)](./frontend_development_plan.md) 문서를 참고하세요. (추후 이 README에 통합 예정)

## 트러블슈팅

이 섹션에는 프로젝트 진행 중 발생한 주요 에러와 해결 과정을 기록합니다.

| 날짜       | 문제 상황 | 해결 과정 | 참고 링크 |
| ---------- | --------- | --------- | --------- |
| 2025-07-16 | 예: iOS 빌드 시 Cocoapods 버전 충돌 | `pod repo update` 후 `pod install` 재실행 | -         |

