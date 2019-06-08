#Serialize Mint Test.

#Util lib.
import ../../../../src/lib/Util

#Hash lib.
import ../../../../src/lib/Hash

#MinerWallet lib,
import ../../../../src/Wallet/MinerWallet

#Mint lib.
import ../../../../src/Database/Transactions/Mint

#Serialize libs.
import ../../../../src/Network/Serialize/Transactions/SerializeMint
import ../../../../src/Network/Serialize/Transactions/ParseMint

#Compare Transactions lib.
import ../../../DatabaseTests/TransactionsTests/CompareTransactions

#Random standard lib.
import random

#Seed Random via the time.
randomize(getTime())

var
    #Mint.
    mint: Mint
    #Reloaded Mint.
    reloaded: Mint

#Test 255 serializations.
for s in 0 .. 255:
    #Create the Mint.
    mint = newMint(
        rand(high(int32)),
        newMinerWallet().publicKey,
        uint64(rand(high(int32)))
    )

    #Serialize it and parse it back.
    reloaded = mint.serialize().parseMint()

    #Test the serialized versions.
    assert(mint.serialize() == reloaded.serialize())

    #Compare the Mint.
    compare(mint, reloaded)

echo "Finished the Network/Serialize/Transactions/Mint Test."
