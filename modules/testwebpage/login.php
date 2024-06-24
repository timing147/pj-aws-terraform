<?php
// AWS SDK for PHP 로드
require_once './vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Marshaler;
use Aws\Ssm\SsmClient;
use Aws\Credentials\CredentialProvider;


$provider = CredentialProvider::instanceProfile();
$memoizedProvider = CredentialProvider::memoize($provider);

try {
    // 자격 증명을 가져옵니다
    $credentials = $memoizedProvider()->wait();
} catch (Exception $e) {
    // 오류 처리
    echo "자격 증명을 가져오는 중 오류가 발생했습니다: " . $e->getMessage();
    exit;
}
// DynamoDB 클라이언트 생성
$dynamodb = new DynamoDbClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest',
    'credentials' => $memoizedProvider
]);

// Marshaler 객체 생성
$marshaler = new Marshaler();

// Parameter Store 클라이언트 생성
$ssm = new SsmClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest',
    'credentials' => $memoizedProvider
]);

try {
    // Parameter Store에서 DynamoDB 테이블 이름 가져오기
    $result = $ssm->getParameter([
        'Name' => 'DYNAMODB_TABLE_NAME', // 올바른 파라미터 이름으로 변경
        'WithDecryption' => false
    ]);
    $tableName = $result['Parameter']['Value'];

    // 사용자 입력 받기
    $user_id = $_POST['login_user_id'];
    $user_password = $_POST['login_user_password'];

    // DynamoDB에서 사용자 정보 조회
    $result = $dynamodb->getItem([
        'TableName' => $tableName,
        'Key' => [
            'user_id' => ['S' => $user_id]
        ]
    ]);

    // 사용자 정보 확인
    if (isset($result['Item'])) {
        $storedPassword = $result['Item']['user_password']['S'];
        $userName = $result['Item']['user_name']['S'];
        if ($user_password === $storedPassword) {
            // 로그인 성공
            echo "사용자 정보 일치! v1.0\n";
            echo "사용자 이름: " . $userName;
        } else {
            // 비밀번호 불일치
            echo "비밀번호가 일치하지 않습니다.";
        }
    } else {
        // 사용자 정보 없음
        echo "사용자 정보가 존재하지 않습니다.";
    }
} catch (AwsException $e) {
    // AWS SDK 오류 처리
    echo "AWS SDK error: " . $e->getAwsErrorMessage();
} catch (Exception $e) {
    // 일반 오류 처리
    echo "오류가 발생했습니다: " . $e->getMessage();
}
?>
