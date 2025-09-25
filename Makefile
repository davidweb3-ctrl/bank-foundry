# Bank Smart Contract Makefile

# Default target
.DEFAULT_GOAL := help

# Variables
NETWORK ?= anvil
PRIVATE_KEY ?= 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Help
help: ## Show this help message
	@echo "Bank Smart Contract Commands"
	@echo "============================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Build
build: ## Compile the smart contracts
	forge build

clean: ## Clean the build artifacts
	forge clean

# Testing
test: ## Run all tests
	forge test

test-unit: ## Run unit tests only
	forge test --match-contract BankTest

test-fuzz: ## Run fuzz tests only
	forge test --match-contract BankFuzzTest

test-coverage: ## Run tests with coverage report
	forge coverage

test-gas: ## Run tests with gas reporting
	forge test --gas-report

# Local Development
anvil: ## Start local Anvil node
	anvil

deploy-local: ## Deploy to local Anvil network
	forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast --private-key $(PRIVATE_KEY)

# Testnet Deployment
deploy-sepolia: ## Deploy to Sepolia testnet
	@echo "Deploying to Sepolia..."
	forge script script/Deploy.s.sol --rpc-url $(SEPOLIA_RPC_URL) --broadcast --verify

# Interactions
deposit: ## Make a deposit (requires BANK_CONTRACT_ADDRESS and DEPOSIT_AMOUNT env vars)
	forge script script/interactions/Deposit.s.sol --rpc-url $(RPC_URL) --broadcast

withdraw: ## Make a withdrawal (requires BANK_CONTRACT_ADDRESS and WITHDRAW_AMOUNT env vars)
	forge script script/interactions/Withdraw.s.sol --rpc-url $(RPC_URL) --broadcast

# Verification
verify: ## Verify contract on Etherscan
	@echo "Please run: forge verify-contract <CONTRACT_ADDRESS> src/Bank.sol:Bank --etherscan-api-key \$$ETHERSCAN_API_KEY --chain $(NETWORK)"

# Formatting and Linting
fmt: ## Format Solidity code
	forge fmt

# Documentation
doc: ## Generate documentation
	forge doc

# Utilities
size: ## Check contract sizes
	forge build --sizes

flatten: ## Flatten the contract
	forge flatten src/Bank.sol > Bank_flattened.sol

# Setup
setup: ## Initial project setup
	@echo "Setting up Bank project..."
	@forge install
	@cp env.example .env
	@echo "✅ Setup complete! Please edit .env file with your configuration."

# Quick commands for development workflow
dev: build test ## Build and test (development workflow)

full-test: clean build test-coverage test-gas ## Complete test suite

# Demo commands
demo-local: ## Run complete local demo
	@echo "Starting local demo..."
	@make anvil &
	@sleep 3
	@make deploy-local
	@echo "✅ Local demo setup complete!"

.PHONY: help build clean test test-unit test-fuzz test-coverage test-gas anvil deploy-local deploy-sepolia deposit withdraw verify fmt doc size flatten setup dev full-test demo-local
