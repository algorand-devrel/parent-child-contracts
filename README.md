# How to deploy a Smart Contract using a Smart Contract

Since AVM 1.1 (TEAL 6) the ability to interact with smart contracts from other
smart contracts was made possible. This allows us to deploy new smart contracts
as well as calling existing ones directly from other smart contracts. This
repository includes a smart contract which allows you to deploy new "child"
smart contracts passed as arguments, followed by updating and then destroying.

## Examples

### Deploy parent smart contract

This will be the parent smart contract which contains all the logic for
deploying and maintaining child contracts. This contract is hardcoded to only
allow the original deployer (`global CreatorAddress`) to have the ability to
update this contract, however anyone can use the contract to create and manage
child smart contracts.

```sh
goal app create \
	--creator JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--approval-prog app.teal --clear-prog clear.teal \
	--global-byteslices 0 --global-ints 0 \
	--local-byteslices 0 --local-ints 0
```

Output:

```sh
Created app with app index 62
```

### Identify parent address

Now that the parent smart contract is deployed, we need to find the address for
future transactions (e.g. funding minimum balance).

```sh
$ goal app info --app-id 62
```

Output:

```sh
Application ID:        62
Application account:   NDBRJYD5KXUA6K5Q456OM6JLC5SRKQJ7ME6MK2NCE5VX3WGGEAB5LOYFVQ
Creator:               JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4
Approval hash:         YI3G24DCARVYO6375Y2Z2IH4QXL37RRWJ25UCMGZXI3X4ZE2D27DVJ5HXI
Clear hash:            ZG2RRCHBZ4K2QKP3NGMYVF2MVG7YW2TSNJPVFVLEGX7KGQ46QVPJGOFTK4
Max global byteslices: 0
Max global integers:   0
Max local byteslices:  0
Max local integers:    0
```

### Fund parent with initial minimum balance (100,000 microAlgo)

All accounts must maintain a minimum balance requirement, this is true for smart
contracts too. So we will start off by adding the minimum required (0.1 Algo).

```sh
goal clerk send -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	-t NDBRJYD5KXUA6K5Q456OM6JLC5SRKQJ7ME6MK2NCE5VX3WGGEAB5LOYFVQ \
	-a 100000
```

### Prepare Algo Payment for deploy method

Since an account wishing to deploy a smart contract will increase their minimum
balance requirement, we will make a payment to the smart contract that includes
the increase and save it to a file for later use in a group containing the
deployment of the child smart contract.

```sh
goal clerk send -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	-t NDBRJYD5KXUA6K5Q456OM6JLC5SRKQJ7ME6MK2NCE5VX3WGGEAB5LOYFVQ \
	-a 100000 \
	-o pay.txn
```

### Call deploy(pay,byte[],byte[])uint64 Method

The pay.txn file provides the parent account with the increased minimum balance
required for creating the child smart contract.
The bytes we're putting in both the approval and clear program of the child
smart contract are the same bytes of the clear.teal program included in this
repository.
A fee of 2000 to the fee pool is to cover the inner transaction cost to deploy
the child smart contract.

```sh
goal app method -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--app-id 62 \
	--method "deploy(pay,byte[],byte[])uint64" \
	--arg pay.txn --arg "[6,129,1]" --arg "[6,129,1]" \
	--fee 2000
```

Output:
```sh
method deploy(pay,byte[],byte[])uint64 succeeded with output: 66
```

### Call update(application,byte[],byte[])bool Method

Since the child smart contract allows updating we're also able to perform an
child smart contract upgrade. We don't need the payment to increase the minimum
balance requirement, but we do still need to send a fee of 2000 to cover the
inner transactino cost.

```sh
goal app method -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--app-id 62 \
	--method "update(application,byte[],byte[])bool" \
	--arg 66 --arg "[6,129,1]" --arg "[6,129,1]" \
	--fee 2000
```

Output:
```sh
method update(application,byte[],byte[])bool succeeded with output: true
```

### Call destroy(application)bool Method

Since the child smart contract allows destroying we're also able to perform a
child smart contract destory. Unlike the deploy where we included an extra
payment to cover the minimum balance, this time the sender is sent the 0.1 Algo
at the extra cost of another inner transaction. This is why the fee is 3000
microAlgo this time.

```sh
goal app method -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--app-id 62 \
	--method "destroy(application)bool" \
	--arg 66 \
	--fee 3000
```

Output:
```sh
method destroy(application)bool succeeded with output: true
```

