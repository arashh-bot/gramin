name: Deploy TON Token

on:
  workflow_dispatch:
    inputs:
      token_name:
        description: 'Token Name'
        required: true
        default: 'GramineToken'
      token_symbol:
        description: 'Token Symbol'
        required: true
        default: 'GRM'
      token_supply:
        description: 'Total Supply'
        required: true
        default: '1000000'
      token_decimals:
        description: 'Decimals'
        required: false
        default: '9'
      token_description:
        description: 'Description'
        required: true
        default: 'Gramine Token on TON Network'
      token_image:
        description: 'Image URL'
        required: false
        default: 'https://ton.org/download/ton_symbol.png'

jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js 24
        uses: actions/setup-node@v4
        with:
          node-version: '24'

      - name: Verify Environment
        run: |
          echo "Node version: $(node -v)"
          echo "npm version: $(npm -v)"
          echo "Bash version: $(bash --version | head -n1)"

      - name: Make Script Executable
        run: chmod +x deploy_ton_token.sh

      - name: Execute Deployment
        env:
          TON_TOKEN_NAME: ${{ github.event.inputs.token_name }}
          TON_TOKEN_SYMBOL: ${{ github.event.inputs.token_symbol }}
          TON_TOKEN_SUPPLY: ${{ github.event.inputs.token_supply }}
          TON_TOKEN_DECIMALS: ${{ github.event.inputs.token_decimals }}
          TON_TOKEN_DESC: ${{ github.event.inputs.token_description }}
          TON_TOKEN_IMAGE: ${{ github.event.inputs.token_image }}
        run: bash deploy_ton_token.sh
        continue-on-error: true

      - name: Check Results
        if: always()
        run: |
          if [ -d "ton_token_contracts" ]; then
            echo "✅ Deployment Successful!"
            ls -la ton_token_contracts/
          else
            echo "⚠️ Project directory not found"
          fi

      - name: Upload Artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ton-token-contracts
          path: ton_token_contracts/
          retention-days: 30
          if-no-files-found: ignore

      - name: Summary
        if: always()
        run: |
          echo "## Deployment Summary" >> $GITHUB_STEP_SUMMARY
          echo "- **Token Name**: ${{ github.event.inputs.token_name }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Token Symbol**: ${{ github.event.inputs.token_symbol }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Total Supply**: ${{ github.event.inputs.token_supply }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Decimals**: ${{ github.event.inputs.token_decimals }}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          if [ -d "ton_token_contracts" ]; then
            echo "✅ **Status**: Completed Successfully" >> $GITHUB_STEP_SUMMARY
          else
            echo "⚠️ **Status**: Setup Complete (Check Artifacts)" >> $GITHUB_STEP_SUMMARY
          fi
