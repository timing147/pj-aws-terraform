<?php
// AWS SDK for PHP 로드
require_once 'vendor/autoload.php';

use Aws\DynamoDb\DynamoDbClient;
use Aws\DynamoDb\Marshaler;

// DynamoDB 클라이언트 생성
$dynamodb = new DynamoDbClient([
    'region' => 'DYNAMODB_REGION',
    'version' => 'latest'
]);

// Marshaler 객체 생성
$marshaler = new Marshaler();

// 사용자 입력 받기
$userid = $_POST['user_id'];
$username = $_POST['user_name'];
$password = $_POST['user_password'];

// DynamoDB 테이블 이름
$tableName = 'DYNAMODB_TABLE_NAME';

try {
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
    echo "회원 가입이 완료되었습니다.";
} catch (Exception $e) {
    // 오류 처리
    echo "오류가 발생했습니다: " . $e->getMessage();
}
?>
