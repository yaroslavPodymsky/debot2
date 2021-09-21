import { TonClient } from '@tonclient/core'
import { createClient } from './utils/client'
import TonContract from './utils/ton-contract'
import pkgSafeMultisigWallet from '../ton-packages/SafeMultisigWallet.package'
import deployDebot from './parts/deploy-eventDebotA'
import deployDebot2 from './parts/deploy-eventDebotB'

describe('debot test', () => {
	let client: TonClient
	let smcSafeMultisigWallet: TonContract
	let b: TonContract

	before(async () => {
		client = createClient()
		smcSafeMultisigWallet = new TonContract({
			client,
			name: 'SafeMultisigWallet',
			tonPackage: pkgSafeMultisigWallet,
			address: process.env.MULTISIG_ADDRESS,
			keys: {
				public: process.env.MULTISIG_PUBKEY,
				secret: process.env.MULTISIG_SECRET,
			},
		})
	})

	it('deploy DeBot2', async () => {
		b = await deployDebot2(client, smcSafeMultisigWallet)
	})
	it('deploy DeBot1', async () => {
		await deployDebot(client, smcSafeMultisigWallet, b.address)
	})
})
