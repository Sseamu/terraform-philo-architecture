# terraform-philo-architecture
## philoberry_ecs-architecture
![philoberry-ecs-architecture](https://github.com/Sseamu/terraform-philo-architecture/assets/50833458/2a426537-f6b3-4cf2-94b8-e76f429af077)

# 2023.09.06 ~ 09.24 
- terraform을 이용한 기본 아키텍쳐 alb 동작 및 bastion host로 동작되는 아키텍쳐 구현

# 2023.09.25
- ECS 기본 아키텍쳐 구축
- hashicorp-valut 및 terraform.tfvars를 이용해 중요데이터 암호화

# 2023.09.26
- ECS service 구축
# 2023.09.27
- ECS service 및 ecs-cluster, alb-rule 내용추가
# 2023.09.28
-ECS Cluster 생성 및 iam 생성 앞으로 할작업들에 대해서 공부 및 정리
# 2023.09 ~ 10.01
- ECS instance type 에서 Fargate로 전환 및 ECS 기본설정 
- taskdefinition 및 Autoscaling 구현

# 2023.10.02
- 로컬에서 작성한 도커 이미지 ECR에 업로드 ECR access iam 권한 부여 

# 2023. 10.10 ~ 11
- ECS Fargate로 전환 완료 및 cloud watch logs 결합 
- autoscaling 과 taskdefintion 수정

# 2023. 10.12
- 한개의 ECR에서 프론트, 백엔드, nginx이미지를 세개의 repository로 분할, s3에 cors 정책 부여 

# 2023.10.15
- Nginx.config 업데이트 awscloudmap 사용 

# 2023.10.16 ~ 17
- 다끝난줄 알았는데 도커이미지 빌드중 오류 발생 => 확인해보니 서버사이드렌더링 문제여서 먼저 백엔드가
실행이 되어야 해당 도커이미지가 빌드가됨 => env 파일로 관련 api 요청 build와 production 환경 분리 

# 2023.10.18 ~ 19일 
- ECS 프론트 컨테이너에 EFS 장착 why? EFS를 장착을 안하면 EBS 가아닌 임시스토리지인 블록스토리지가 사용이 되어 컨테이너가 없어지거나 스케일링 되는경우 데이터가 공유가 안됨 => EFS 사용(iam 역할 부여 )
- ECS service를 돌려보니 targetgroup redirection 과 healthcheck가 제대로 설정 x 

# 2023.10.20
- 프론트. 백엔드 에 각 서비스에 해당하는 cloudmap 적용 

# 2023.10.23
- Nginx 구성업데이트(이때 까지 nginx 설정및 작동방식을 이해하지못했음)
- ecs task에서 express 부분에 healthcheck가 제대로 되지 않음 => cors 구성 업데이트 및 기타 구성 업데이트

# 2023.10.24
- security group 업데이트 및 헬스체크 완료(이당시에는 미완 프론트 컨테이너만 헬스체크 되는거였음) 
- 서비스 동작 확인 및 구글 url 연관성 작업

# 2023.10.23
- ci/cd 툴 githubaaction으로 결정 사용법 공부 및 적용

# 2023.10.26 ~ 27
- github action으로 ci/cd 구축하기

# 2023.10.30 
- ci /cd 마무리 및 secrets 설정 중 치명적오류 확인
- 백엔드 서버를 따로 두지 않아서 서버사이드렌더링에서 ci/cd 중 오류 발생 => 백엔드 생성 task 따로구분

# 2023.10.31
- 기존에 task한개에서 프론트, 백엔드 구성하던걸 각각의 기능에 맞게 분할 

# 2023.11.01 ~ 11.03
- 로컬에서 작동중인 docker-compose 파일 업데이트 
- express 컨테이너 에러발생 
- 빌드중 오류나는 문제라서 프론트/백엔드 개발자와 협력하여 문제 해결
- targetgroup 과 관련한 헬스체크 문제는 express 내부컨테이너에 cors 정책 넣어주고 타겟그룹에 대한 보안그룹 설정 및 제대로 연결하여 문제해결

# 2023.11.04  ~11.14
- dev 환경에서 사용중인 public access RDS를 private로 전환하기 위해 갖은 노력
- 로컬환경에서 mysqlworkbench or Dbeaver같은 툴을 사용하기 위해서 원래는 SSM 을통한 접근에서 => bastion  host로 변경함.
- DB 스키마에 대한 작업을 1차적으로 외부 vpc와 연결된 DB를 스냅샷 => 내 vpc에 연결해서 사용하는 방식을 하려고했는데 안됨 => 그래서 내 vpc 의 rds를 퍼블릭 공개 => private로 전환 스냅샷 => 위와같은 작업으로 스키마 작성

# 2023.11.15 
- 스냅샷 부분과 오류나는 부분 수정 
- ecs fargate 경우 특정 가용영역에 호스팅 불가 (자율적으로 배분되는거 ㅇㅇ )
- ecs service의 구성부분을 수정 원래는 staging의 front task에서 alb 연결 => 각각 alb를 연결하고 사용하려면 task 및 해당하는 서비스를 생성해야 각각에 해당하는 cloudmap이나 alb연결이 가능함

# 2023.11.16 ~ 17
- ECS frontend, backend task 분할

# 2023.11.18 
- 타겟그룹및 securitygroup 업데이트 사이트 연결완료

# 2023.11.20
- 여기서 ecs 컨테이너에 rds 에 접근할수 있는권한을 부여해야함 => 이작업때문에 좀 걸림 

# 2023.11.21
- aws secretmanager 도입하려다가 포기 => 우리 서비스에 필요한 기능 x 
- rds에 는 입력이 되는데 s3에 이미지 업로드가 안되서 문제 파악 => aws cognito + amplify 자료 수집 => 근데 이것과 관련한 문제 x 

# 2023.11.22
- s3 vpc end point 생성 및 ecr endpoint 붙이기 => 비용절감에 용이 => s3가 그래도 이미지가 업로드가 안되서 기존 private s3에 연결해서 작업 

# 2023.11.23
- s3 endpoint 및 안되는 이유 파악 => lambda 추가 
- nginx 타겟그룹 및 구성을 정상적으로 수정 nginx는 리버스프록시 및 /api 경로로 가던것을 단순 정적페이지만 관리하도록 변경 
- 위작업 대부분을 타겟그룹이하도록 변경 

# 2023.11.24
- s3 업로드 기능 완성

# 2023.11.27
- 변화한것에 맞게 ci/cd 업데이트 
- cloudwatch logstream 필터링 및 줄이기 
- 정적사이트 공부 및 s3 bucket정책 업데이트(내 terraform 코드에서 작업가능)

# 2023.12.01 
- CI/CD 업데이트 및 1차 아키텍쳐 마무리 