# Onchain (Hardhat) for FinanceChain

This folder contains a Hardhat setup and two contracts:

- `PersonalFinance`: stores personal finance transactions on-chain (used by the main dApp UI).
- `PersonalFinanceHash`: stores a proof hash on-chain (used by the chat demo page).

## Free demo paths

### Option A — Local Hardhat (100% free, offline)

1. Install deps

```bash
npm install
```

2. Start local node

```bash
npx hardhat node
```

3. Deploy

```bash
npm run deploy:local
```

4. Copy the deployed contract address and set it in the frontend env:

- Set `VITE_PERSONAL_FINANCE_CONTRACT=0x...` in `Frontend/.env`
- For local chain also set `VITE_CHAIN_ID=0x7a69` (31337) and `VITE_CHAIN_RPC=http://127.0.0.1:8545`

### Option B — Cronos Testnet (free RPC + free faucet)

1. Create `.env` in this folder with:

```
CRONOS_TESTNET_RPC=https://evm-t3.cronos.org
CRONOS_TESTNET_PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

2. Deploy to Cronos testnet:

```bash
npx hardhat run --network cronosTestnet scripts/deploy_pf.js
```

3. Put the deployed address into `Frontend/.env` (`VITE_PERSONAL_FINANCE_CONTRACT`).

## Sepolia (optional)

Sepolia is also supported, but usually needs an RPC endpoint (many providers have free tiers). Create `.env`:

```
RPC_URL=https://...your-sepolia-rpc...
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
```

Then deploy:

```bash
npm run deploy:sepolia
```

## Security notes

- Never commit `.env` or private keys.
- For demo, keep most data off-chain; store hashes/proofs on-chain when needed.
