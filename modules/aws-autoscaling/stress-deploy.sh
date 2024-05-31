#!/bin/bash
yum update -y
amazon-linux-extras enable php7.4
yum install -y httpd php php-cli php-common php-pdo php-fpm php-json php-mysqlnd
amazon-linux-extras install -y epel
yum install -y stress

systemctl start httpd
systemctl enable httpd

export HOME=/root
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
composer require aws/aws-sdk-php:^3.0
composer require cboden/ratchet
composer require react/event-loop
mv composer.* /var/www/html/
mv vendor /var/www/html/

# IMDSv2 토큰 요청
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# IMDSv2를 사용하여 메타데이터 조회
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/placement/availability-zone)
SUBNET_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/network/interfaces/macs/$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/mac)/subnet-id)

# 조회된 메타데이터를 사용하여 index.html 생성
# ${alb_address} 를 직접 찾아서 ALB URL 주소로 변경하세요. 
cat <<EOF > /var/www/html/index.html
<html>
<head>
<title>EC2 Instance Meta-Data</title>
</head>
<body>
<h1>Instance Information</h1>
<p>Instance ID: ${INSTANCE_ID}</p>
<p>Availability Zone: ${AVAILABILITY_ZONE}</p>
<p>Subnet ID: ${SUBNET_ID}</p>
<p>CPU Load: <span id="cpuLoad">Waiting...</span></p>
<button id="startTest">Start Stress Test</button>
<script>
    var ws = new WebSocket('ws://${alb_address}:8080');
    ws.onopen = function(event) {
        console.log("Connected to the WebSocket server.");
    };

    ws.onmessage = function(event) {
        var data = JSON.parse(event.data);
        if (data.type === "load") {
            document.getElementById('cpuLoad').textContent = data.load + "%";
        } else if (data.type === "status") {
            console.log(data.msg);
        }
    };

    document.getElementById('startTest').addEventListener('click', function() {
        ws.send('startStressTest');
    });
</script>
<div>
    <button onclick="location.href='/db.php'">DB 조회</button>
</div>
</body>
</html>
EOF

cat <<EOF > /var/www/html/server.php
<?php
require dirname(__FILE__) . '/vendor/autoload.php';

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;
use React\EventLoop\Factory;
use React\EventLoop\LoopInterface;

class StressWebSocketServer implements MessageComponentInterface {
    protected \$clients;
    protected \$loop;

    public function __construct(LoopInterface \$loop) {
        \$this->clients = new \SplObjectStorage;
        \$this->loop = \$loop;
    }

    public function onOpen(ConnectionInterface \$conn) {
        \$this->clients->attach(\$conn);
    }

    public function onMessage(ConnectionInterface \$from, \$msg) {
        if (\$msg === "startStressTest") {
            // Start stress test
            // NOTE: Replace this with actual stress command or logic
            exec("stress --cpu 1 --timeout 60 > /dev/null 2>&1 &");
            \$load = sys_getloadavg();
            \$msgToSend = json_encode(["type" => "load", "load" => \$load[0]]);
            \$from->send(\$msgToSend);
        } else {
            // Send CPU load
            \$load = sys_getloadavg();
            \$msgToSend = json_encode(["type" => "load", "load" => \$load[0]]);
            foreach (\$this->clients as \$client) {
                \$client->send(\$msgToSend);
            }
        }
    }

    public function onClose(ConnectionInterface \$conn) {
        \$this->clients->detach(\$conn);
    }

    public function onError(ConnectionInterface \$conn, \Exception \$e) {
        \$conn->close();
    }

    public function startSendingCpuLoad() {
        \$load = getCpuUsage();
        \$data = json_encode(["type" => "load", "load" => \$load]);

        foreach (\$this->clients as \$client) {
                \$client->send(\$data);
        }
    }
}

function getCpuUsage() {
    \$stat1 = file('/proc/stat');
    sleep(1);
    \$stat2 = file('/proc/stat');
    \$info1 = explode(" ", preg_replace("!cpu +!", "", \$stat1[0]));
    \$info2 = explode(" ", preg_replace("!cpu +!", "", \$stat2[0]));
    \$dif = [];
    \$dif['user'] = \$info2[0] - \$info1[0];
    \$dif['nice'] = \$info2[1] - \$info1[1];
    \$dif['sys'] = \$info2[2] - \$info1[2];
    \$dif['idle'] = \$info2[3] - \$info1[3];
    \$total = array_sum(\$dif);
    \$cpuUsage = 100 * (\$total - \$dif['idle']) / \$total;
    return \$cpuUsage;
}

\$loop = Factory::create();
\$server = new StressWebSocketServer(\$loop);

\$webSock = new React\Socket\Server('0.0.0.0:8080', \$loop);
\$webServer = new IoServer(new HttpServer(new WsServer(\$server)), \$webSock);

\$loop->addPeriodicTimer(1, function () use (\$server) {
        \$server->startSendingCpuLoad();
});
\$loop->run();
?>
EOF

# 파라메터 스토어에 다음의 파라메터를 추가해야 합니다.
# /rds/endpoint, /rds/name, /rds/username, /rds/password
cat <<EOF > /var/www/html/db.php
<?php
require 'vendor/autoload.php';

use Aws\Ssm\SsmClient;
use Aws\DynamoDb\DynamoDbClient;

// SSM 클라이언트 초기화
\$client = new SsmClient([
    'version' => 'latest',
    'region' => 'ap-northeast-2',
]);

\$dbHost = \$dbName = \$dbUser = \$dbPassword = "";

if (isset(\$_GET['loadParams'])) {
    // Parameter Store에서 데이터베이스 접속 정보 가져오기
    \$dbHost = \$client->getParameter(['Name' => '/rds/endpoint', 'WithDecryption' => false])['Parameter']['Value'];
    \$dbName = \$client->getParameter(['Name' => '/rds/name', 'WithDecryption' => false])['Parameter']['Value'];
    \$dbUser = \$client->getParameter(['Name' => '/rds/username', 'WithDecryption' => false])['Parameter']['Value'];
    \$dbPassword = \$client->getParameter(['Name' => '/rds/password', 'WithDecryption' => true])['Parameter']['Value'];
} else {
    \$dbHost = \$_GET['dbHost'];
    \$dbName = \$_GET['dbName'];
    \$dbUser = \$_GET['dbUser'];
    \$dbPassword = \$_GET['dbPassword'];
}

\$dbType = \$_GET['database'];

switch (\$dbType) {
    case 'mysql':
    case 'aurora':
        try {
            // 데이터베이스 접속 및 쿼리 실행
            \$pdo = new PDO("mysql:host=\$dbHost;dbname=\$dbName", \$dbUser, \$dbPassword);
            // 에러 모드를 예외로 설정
            \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // SQL 쿼리 실행
            \$sql = "SELECT user, host FROM user";
            \$stmt = \$pdo->prepare(\$sql);
            \$stmt->execute();

            // 쿼리 결과 출력
            \$results = \$stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach (\$results as \$row) {
                echo \$row['user'] . ' - ' . \$row['host'] . "<br />";
            }
        } catch (PDOException \$e) {
            die("Could not connect to the database \$dbname :" . \$e->getMessage());
        }
        break;
    case 'dynamodb':
        // DynamoDB로 접속
        \$dynamoDbClient = new DynamoDbClient([
            'version' => 'latest',
            'region' => 'ap-southeast-1',
        ]);

        try {
            \$result = \$dynamoDbClient->scan([
                'TableName' => \$dbName, // 스캔할 DynamoDB 테이블 이름
            ]);

            // 스캔 결과 출력
            foreach (\$result['Items'] as \$item) {
                // id, name, host 값을 가져오고 출력합니다.
                \$id = isset(\$item['id']['S']) ? \$item['id']['S'] : 'N/A';
                \$name = isset(\$item['name']['S']) ? \$item['name']['S'] : 'N/A';
                \$host = isset(\$item['host']['S']) ? \$item['host']['S'] : 'N/A';

                echo "ID: {\$id}, Name: {\$name}, Host: {\$host}<br />";
            }
        } catch (Aws\DynamoDb\Exception\DynamoDbException \$e) {
            echo 'Unable to scan DynamoDB table: ', \$e->getMessage();
        }
        break;
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Database Select</title>
</head>
<body>
    <h2>Database Select</h2>
    <form action="" method="get">
        <select name="database" id="database">
            <option value="mysql">MySQL</option>
            <option value="aurora">Aurora</option>
            <option value="dynamodb">DynamoDB</option>
        </select><br><br>
        
        <label for="dbHost">Database Host:</label>
        <input type="text" id="dbHost" name="dbHost"><br><br>
        
        <label for="dbName">Database Name:</label>
        <input type="text" id="dbName" name="dbName"><br><br>
        
        <label for="dbUser">Database User:</label>
        <input type="text" id="dbUser" name="dbUser"><br><br>
        
        <label for="dbPassword">Database Password:</label>
        <input type="password" id="dbPassword" name="dbPassword"><br><br>
        
        <input type="submit" value="Test Connection">
        <button type="submit" name="loadParams" value="true">Get Parameter</button>
    </form>
</body>
</html>
EOF


nohup php /var/www/html/server.php &