# Branch Merge Workflow Instructions

## 概要
この PR は、特定ブランチへの PR マージ時に実行される GitHub Actions ワークフローの追加を目的としています。

## ワークフロー内容
以下の内容で `.github/workflows/branch-merge.yml` を作成してください：

```yaml
name: Branch Merge Workflow
on:
  pull_request:
    branches:
      - "main"
    types: [closed]

jobs:
  check-should-run:
    runs-on: ubuntu-latest
    outputs:
      should_run: ${{ steps.check.outputs.should_run }}
    steps:
      - name: Check should run
        id: check
        run: |
          if [[ "${{ github.event.pull_request.merged }}" == "true" && \
                "${{ startsWith(github.head_ref, 'feature-') }}" == "true" && \
                "${{ github.base_ref }}" == "main" ]]; then
            echo "should_run=true" >> $GITHUB_OUTPUT
          else
            echo "should_run=false" >> $GITHUB_OUTPUT
          fi

  execute-on-merge:
    needs: check-should-run
    if: needs.check-should-run.outputs.should_run == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          ref: ${{ github.base_ref }}
      
      - name: Show current branch
        run: |
          echo "Current branch: $(git branch --show-current)"
          echo "Target branch (base_ref): ${{ github.base_ref }}"
          echo "Source branch (head_ref): ${{ github.head_ref }}"
          echo "PR was merged into: ${{ github.base_ref }}"
```

## 動作条件
- feature-* ブランチから main ブランチへの PR がマージされた時のみ実行
- 現在のブランチ情報を出力

## 実装手順
1. GitHub の Web UI で上記ワークフローファイルを作成
2. または、適切な権限を持つトークンでプッシュ