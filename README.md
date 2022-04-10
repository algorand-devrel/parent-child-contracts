# How to deploy a Smart Contract using a Smart Contract

### Deploy parent smart contract
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
```sh
goal clerk send -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	-t NDBRJYD5KXUA6K5Q456OM6JLC5SRKQJ7ME6MK2NCE5VX3WGGEAB5LOYFVQ \
	-a 100000
```

### Prepare Algo Payment for deploy method
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
method deploy(pay,byte[],byte[])uint64 succeeded with output: 65
```

### Call update(application,byte[],byte[])bool Method
```sh
goal app method -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--app-id 62 \
	--method "update(application,byte[],byte[])bool" \
	--arg 65 --arg "[6,129,1]" --arg "[6,129,1]" \
	--fee 2000
```

Output:
```sh
method update(application,byte[],byte[])bool succeeded with output: true
```

### Call destroy(application)bool Method
```sh
goal app method -f JAQA7FTVZP2ZK32Z7HEVIL5XJZEMTEFV7FRI6BJAT7VUQB6GA7NEBN4KS4 \
	--app-id 62 \
	--method "destroy(application)bool" \
	--arg 65 \
	--fee 3000
```

Output:
```sh
method destroy(application)bool succeeded with output: true
```

