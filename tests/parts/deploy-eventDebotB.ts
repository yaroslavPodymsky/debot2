import { TonClient } from '@tonclient/core'
import TonContract from '../utils/ton-contract'
import pkgDebot from '../../ton-packages/tdb.package'
import { NETWORK_MAP } from '../utils/client'
const fs = require('fs')

export default async (
	client: TonClient,
	smcSafeMultisigWallet: TonContract
) => {
	let smcDePassDebot

	const keys = await client.crypto.generate_random_sign_keys()
	smcDePassDebot = new TonContract({
		client,
		name: 'DePassDebot',
		tonPackage: pkgDebot,
		keys,
	})

	await smcDePassDebot.calcAddress()

	await smcSafeMultisigWallet.call({
		functionName: 'sendTransaction',
		input: {
			dest: smcDePassDebot.address,
			value: 1_000_000_000,
			bounce: false,
			flags: 2,
			payload: '',
		},
	})

	await smcDePassDebot.deploy({})

	await new Promise<void>((resolve) => {
		fs.readFile('./build/tdb.abi.json', 'utf8', async function (err, data) {
			if (err) {
				return console.log({ err })
			}

			const buf = Buffer.from(data, 'ascii')
			const hexvalue = buf.toString('hex')

			await smcDePassDebot.call({
				functionName: 'setABI',
				input: {
					dabi: hexvalue,
				},
			})

			resolve()
		})
	})

	console.log(
		`./bin/tonos-cli --url ${NETWORK_MAP[process.env.NETWORK]} debot fetch ${
			smcDePassDebot.address
		}`
	)

	return smcDePassDebot
}
