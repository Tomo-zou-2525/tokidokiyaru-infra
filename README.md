# tokidokiyaru-infra

## 概要

[tokidokiyaru-backend](https://github.com/Tomo-zou-2525/tokidokiyaru-backend)や[tokidokiyaru-frontend](https://github.com/Tomo-zou-2525/tokidokiyaru-frontend)を稼働させるためのインフラストラクチャを作成するコード。

## 開発

### VSCode Dev Container

[VSCode Dev Container](https://code.visualstudio.com/docs/remote/containers)を利用している。
Dev Container を使うことを強制はしないが、使わない場合は、必要なライブラリを自分でインストールすること。

### pre-commit フック

[pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform#terraform_docs)を利用して、commit 前に特定の処理を実施している。

pre-commit-terraform で実施する処理は大きく二種類ある。

- 自動で修正/作成する処理
  - この場合は修正/作成されたファイルがステージングされていない状態になるので、確認して問題なければ、`git add`して`git commit`する。
- 静的解析（lint）
  - commit がエラーになるが、Git のログからは lint エラーの原因は確認できない。そのため、ターミナルから以下のコマンドを実行して、原因を確認し、対応する。

```sh
pre-commit run -a
```

## デプロイ

GitHub Actions の`Terraform CD`を実行する。実行時にデプロイする環境を選択すること。


# 事前準備

## AWS の準備

環境ごとに以下を実施する。

### Terraform Backend 用リソース作成

CloudFormation で作成する。

1. CloudFormation のコンソール画面でスタックの作成を開く
1. テンプレートに`terraform-backend.yaml`を指定する
1. スタックの名前を指定する（e.g. `stg-terraform-state`）
1. Environment パラメータに環境名（e.g. `stg`, `prod`）を入力する
1. タグを入力する（e.g. `{env: stg, service: tokidokiyaru}`）

### ドメインを取得して Route53 に登録

1. ドメインを取得する
1. ドメインを Route53 に登録
1. Amazon Route53 でホストゾーンを作成
1. ドメイン取得元のサイトでネームサーバを設定

なお、Route53 でドメインを取得した場合はドメインを Route53 に登録する作業は自動で実施されると思われる。

### OIDC で AWS 認証するための準備

GitHub Actions で OIDC を使用して AWS 認証するために、ID プロバイダや IAM ロールを作成する。
なお、シングルアカウントの場合は、環境ごとでなく一つ作成すれば良い。

CloudFormation で作成する。

1. CloudFormation のコンソール画面でスタックの作成を開く
1. テンプレートに`oidc-github.yaml`を指定する
1. スタックの名前を指定する（e.g. `stg-oidc-for-github-actions`）
1. タグを入力する（e.g. `{env: stg, service: tokidokiyaru}`）

## GitHub リポジトリの設定

Environments に stg と prod を作成する。

それぞれの Environment variables に`ROLE_TO_ASSUME`を作成し、[OIDC で AWS 認証するための準備]で作成した IAM Role の ARN を設定する。
