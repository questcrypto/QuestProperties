require("dotenv").config()
const HDWalletProvider = require("@truffle/hdwallet-provider")
const upgrades = require("@openzeppelin/truffle-upgrades")
const privateKeys = process.env.PRIVATE_KEY || ""

module.exports = {
	networks: {
		development: {
			host: "127.0.0.1",
			port: 8545,
			network_id: "*",
			from: "0x1a8f0B73f7224D1301791928edE42Ed2996192B0",
		},
		polygon: {
			provider: () =>
				new HDWalletProvider(
					privateKeys.split(","),
					`https://polygon-rpc.com/`
				),
			network_id: 137, // Ropsten's id
			usdcToken: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
			from: "tr", //need to fill
			gas: 5500000, // Ropsten has a lower block limit than mainnet
			confirmations: 5, // # of confs to wait between deployments. (default: 0)
			timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
			skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
		},
		mumbai: {
			provider: () =>
				new HDWalletProvider(
					privateKeys.split(","),
					`https://matic-mumbai.chainstacklabs.com`
				),
			network_id: 80001,
			from: "", //need to fill
			skipDryRun: true,
		},
	},
	compilers: {
		solc: {
			version: "0.8.10",
			settings: {
				optimizer: {
					enabled: true,
					runs: 200,
				},
			},
		},
	},
	plugins: ["truffle-plugin-upgrades"]["truffle-plugin-verify"],
	api_keys: {
		polygon: "",
	},
	db: {
		enabled: false,
	},
}
