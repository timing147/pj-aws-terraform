<?php
// AWS SDK for PHP 로드
require_once 'vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Marshaler;
use Aws\Ssm\SsmClient;
use Aws\Credentials\CredentialProvider;

$provider = CredentialProvider::defaultProvider();
// DynamoDB 클라이언트 생성
$dynamodb = new DynamoDbClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest',
    'credentials' => $provider
]);

// Marshaler 객체 생성
$marshaler = new Marshaler();

// Parameter Store 클라이언트 생성
$ssm = new SsmClient([
    'region' => 'ap-southeast-1',
    'version' => 'latest',
    'credentials' => $provider
]);

try {
    // Parameter Store에서 DynamoDB 테이블 이름 가져오기
    $result = $ssm->getParameter([
        'Name' => 'DYNAMODB_TABLE_NAME_PARAMETER_STORE_KEY',
        'WithDecryption' => false
    ]);
    $tableName = $result['Parameter']['Value'];

    // 사용자 입력 받기
    $user_id = $_POST['user_id'];
    $user_password = $_POST['user_password'];

    // DynamoDB에서 사용자 정보 조회
    $result = $dynamodb->getItem([
        'TableName' => $tableName,
        'Key' => $marshaler->marshalItem([
            'user_id' => $user_id
        ])
    ]);

    // 사용자 정보 확인
    if (isset($result['Item'])) {
        $storedPassword = $marshaler->unmarshalItem($result['Item'])['user_password'];
        $userName = $marshaler->unmarshalItem($result['Item'])['user_name'];
        if ($user_password === $storedPassword) {
            // 로그인 성공
            echo "로그인 성공!\n";
            echo "사용자 이름: " . $userName;
        } else {
            // 비밀번호 불일치
            echo "비밀번호가 일치하지 않습니다.";
        }
    } else {
        // 사용자 정보 없음
        echo "사용자 정보가 존재하지 않습니다.";
    }
} catch (Exception $e) {
    // 오류 처리
    echo "오류가 발생했습니다: " . $e->getMessage();
}