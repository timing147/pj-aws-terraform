<?php
// EC2 메타데이터 서비스 URL
$metadataUrl = "http://169.254.169.254/latest/meta-data/placement/region";

// 메타데이터 서비스에서 리전 정보 가져오기
$region = file_get_contents($metadataUrl);

// 출력할 리전 정보가 없을 경우 대비
if ($region === FALSE) {
    $region = "Unknown region";
}

echo "&copy; 2023 Region 1 - Running in region: " . htmlspecialchars($region);
?>
