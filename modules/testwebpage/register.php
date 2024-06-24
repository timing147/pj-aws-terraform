<?php
// AWS SDK for PHP 로드
require_once './vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Marshaler;
use Aws\Ssm\SsmClient;
use Aws\Credentials\CredentialProvider;


$provider = CredentialProvider::instanceProfile();
$memoizedProvider = CredentialProvider::memoize($provider);

// DynamoDB 클라이언트 생성
$dynamodb = new DynamoDbClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest'
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

// 사용자 입력 받기
$userid = $_POST['register_user_id'];
$username = $_POST['register_user_name'];
$password = $_POST['register_user_password'];

// DynamoDB 테이블 이름
$tableName = 'DYNAMODB_TABLE_NAME';

$ssm = new SsmClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest',
    'credentials' => $memoizedProvider
]);
try {
    $result = $ssm->getParameter([
        'Name' => 'DYNAMODB_TABLE_NAME', // 올바른 파라미터 이름으로 변경
        'WithDecryption' => false
    ]);
    $tableName = $result['Parameter']['Value'];
    // DynamoDB에 사용자 정보 저장
    $result = $dynamodb->putItem([
        'TableName' => $tableName,
        'Item' => $marshaler->marshalItem([
            'user_id' => $userid,
            'user_name' => $username,
            'user_password' => $password
        ])
    ]);

    // 회원 가입 성공
    echo "회원 가입이 완료되었습니다. ID : $userid, 이름: $username";
} catch (Exception $e) {
    // 오류 처리
    echo "오류가 발생했습니다: " . $e->getMessage();
}
?>
