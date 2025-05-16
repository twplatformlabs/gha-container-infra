#!/usr/bin/env bats

@test "terraform version" {
  run bash -c "docker exec gha-container-infra-image terraform version"
  [[ "${output}" =~ "1.8" ]]
}

@test "tflint version" {
  run bash -c "docker exec gha-container-infra-image tflint --version"
  [[ "${output}" =~ "0.51" ]]
}

@test "python3 version" {
  run bash -c "docker exec gha-container-infra-image python -V"
  [[ "${output}" =~ "3.11" ]]
}

@test "awscli version" {
  run bash -c "docker exec gha-container-infra-image aws --version"
  [[ "${output}" =~ "1.32" ]]
}

@test "bats version" {
  run bash -c "docker exec gha-container-infra-image bats -v"
  [[ "${output}" =~ "1.11" ]]
}

@test "ruby version" {
  run bash -c "docker exec gha-container-infra-image ruby -v"
  [[ "${output}" =~ "3.2" ]]
}

@test "awspec version" {
  run bash -c "docker exec gha-container-infra-image awspec -v"
  [[ "${output}" =~ "1.30" ]]
}

@test "inspec version" {
  run bash -c "docker exec gha-container-infra-image inspec -v"
  [[ "${output}" =~ "5.22" ]]
}

@test "trivy version" {
  run bash -c "docker exec gha-container-infra-image trivy --version"
  [[ "${output}" =~ "0.51" ]]
}

@test "checkov version" {
  run bash -c "docker exec gha-container-infra-image checkov -v"
  [[ "${output}" =~ "3.2" ]]
}

@test "snyk version" {
  run bash -c "docker exec gha-container-infra-image snyk version"
  [[ "${output}" =~ "1.1291" ]]
}

@test "terrascan version" {
  run bash -c "docker exec gha-container-infra-image terrascan version"
  [[ "${output}" =~ "1.19" ]]
}

@test "shasum version" {
  run bash -c "docker exec gha-container-infra-image shasum --version"
  [[ "${output}" =~ "6." ]]
}

@test "cosign version" {
  run bash -c "docker exec gha-container-infra-image cosign version"
  [[ "${output}" =~ "2.2" ]]
}
